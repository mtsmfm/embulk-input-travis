require 'travis'
require 'embulk/input/travis/travis_patch'

module Embulk
  module Input

    class Travis < InputPlugin
      Plugin.register_input("travis", self)

      def self.transaction(config, &control)
        # configuration code:
        task = {
          "repo" => config.param("repo", :string),
          "build_num_from" => config.param("build_num_from", :integer),
          "build_num_to" => config.param("build_num_to", :integer, nil),
          "token" => config.param("token", :string, nil),
          "step" => config.param("step", :integer, 10),
        }

        columns = [
          Column.new(0, "id", :long),
          Column.new(1, "data", :string),
          Column.new(2, "log", :string),
          Column.new(3, "build_number", :long),
          Column.new(4, "build_data", :string)
        ]

        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)
        report = task_reports.first

        next_from = report["not_finished_build_nums"].min || report["build_num_to"] + 1

        next_config_diff = {
          "build_num_from" => next_from,
          "build_num_to" => next_from + task["step"]
        }
        return next_config_diff
      end

      # TODO
      # def self.guess(config)
      #   sample_records = [
      #     {"example"=>"a", "column"=>1, "value"=>0.1},
      #     {"example"=>"a", "column"=>2, "value"=>0.2},
      #   ]
      #   columns = Guess::SchemaGuess.from_hash_records(sample_records)
      #   return {"columns" => columns}
      # end

      def init
        if client.access_token
          Embulk.logger.info { "embulk-input-travis: Logged in as @#{client.user.login}" }
        end
      end

      def run
        not_finished_build_nums = []

        Embulk.logger.info { "embulk-input-travis: Start from build_num:[#{build_num_from}] to build_num:[#{build_num_to}]" }

        (build_num_from..build_num_to).each do |build_num|
          Embulk.logger.info { "embulk-input-travis: Start build_num:[#{build_num}]" }

          repo.session.clear_cache!

          build = with_retry { repo.build(build_num) }
          unless build&.finished?
            Embulk.logger.info { "embulk-input-travis: Skip build_num:[#{build_num}]" }

            not_finished_build_nums << build_num
            next
          end

          build.job_ids.each do |job_id|
            with_retry do
              job = client.session.find_one(::Travis::Client::Job, job_id)

              Embulk.logger.info { "embulk-input-travis: Start job_id:[#{job.id}]" }

              page_builder.add([
                job.id,
                job.to_h.to_json,
                job.log.body,
                build.number.to_i,
                build.to_h.to_json
              ])
            end
          end
        end

        page_builder.finish

        task_report = {
          "build_num_from" => build_num_from,
          "build_num_to" => build_num_to,
          "not_finished_build_nums" => not_finished_build_nums
        }
        return task_report
      end

      private

      def repo
        @repo ||= client.repo(task["repo"])
      end

      def build_num_from
        @build_num_from ||= task["build_num_from"]
      end

      def build_num_to
        @build_num_to ||= (task["build_num_to"] || build_num_from + task["step"])
      end

      def client
        @client ||= ::Travis::Client.new(access_token: task["token"])
      end

      MAX_RETRY = 5

      def with_retry(&block)
        retries = 0
        begin
          yield
        rescue => e
          sleep retries

          if retries < MAX_RETRY
            retries += 1
            Embulk.logger.warn { "embulk-input-travis: retry ##{retries}, #{e.message}" }
            retry
          else
            Embulk.logger.error { "embulk-input-travis: retry exhausted ##{retries}, #{e.message}" }
            raise e
          end
        end
      end
    end

  end
end
