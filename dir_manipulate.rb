#!/usr/bin/env ruby

require "FileUtils"

REPO_FILE = 'repos.txt'
REPO_DIRECTORY = 'GitHubRepos'

FileUtils.mkdir_p(REPO_DIRECTORY)

File.readlines(REPO_FILE).each do |line|
  user = line.split(/\//)[3]
  repo = line.split(/\//)[4].strip

  FileUtils.cd(REPO_DIRECTORY)

  FileUtils.mkdir_p(user)
  FileUtils.cd(user)
  %x{git clone #{line}}

  FileUtils.cd(repo)
  %x{git log > git_log.txt}

  # Display the hashes of commits whose messages contain "check"
  # git log --all --grep=<regular expression> --pretty=%H

  # Display the parent of a certain commit
  # git log --pretty=%P -n 1 <commit hash>

  FileUtils.cd('../../..')
end