require 'travis'
# https://github.com/travis-ci/travis.rb/pull/644/files
Travis::Client::Session.prepend(Module.new do
  private

  def fetch_one(entity, id = nil)
    path = "/#{entity.base_path}/#{id}"

    if entity == Travis::Client::Artifact
      load({'log' => {'id' => id, 'body' => get_raw(path)}})[entity.one]
    else
      get(path)[entity.one]
    end
  end
end)
