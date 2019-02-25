# Travis input plugin for Embulk

Fetch Travis build results

## Overview

- **Plugin type**: input
- **Resume supported**: ?
- **Cleanup supported**: ?
- **Guess supported**: ?

## Configuration

- **repo**: Target repository name like `rails/rails` (string, required)
- **build_num_from**: Build number from (integer, required)
- **build_num_to**: Build number to (integer, optional)
- **step**: Amount of builds (string, default: `10`)
- **token**: Travis API token which can be found on https://travis-ci.org/account/preferences (string, default: `null`)

## Example

```yaml
in:
  type: travis
  repo: rails/rails
  build_num_from: 59100
  step: 15
  token: xxxxxxxxxxxxxxxxxxxxxx
```

## Build

```
$ rake
```
