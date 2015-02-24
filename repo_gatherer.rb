#!/usr/bin/env ruby

#TODO: Authentication

require 'net/http'
require 'json'

KEYWORD_FILE = 'keywords.txt'
REPO_FILE = 'repos.txt'
URL_PREFIX= 'https://api.github.com/search/issues?'
SEARCH_TERMS = 'in:title,body+language:javascript+state:closed'
SEARCH_PARAMETERS = '&sort=created&order=asc&per_page=100'

class RepoGatherer

  attr_accessor :total_counts, :keywords, :repos

  def initialize
    @keywords = []
    @repos = []
    File.readlines(KEYWORD_FILE).each { |line| @keywords.push(line.chomp) }
    @total_counts = Hash.new
    @keywords.each { |keyword| @total_counts[keyword] = 0 }
  end

  def estimate_page_number
    build_urls.each do |key, value|
      res = Net::HTTP.get_response(URI(value))
      # Json parsing
      @total_counts[key] = JSON.parse(res.body)['total_count']
    end

    @total_counts.each { |key, value| puts key + ': ' + value.to_s }
  end

  def build_urls()
    urls = Hash.new
    @keywords.each do |keyword|
      search_term = "q=#{keyword}+"
      search_url = URL_PREFIX + search_term + SEARCH_TERMS + SEARCH_PARAMETERS
      puts "[INFO] Initial Search URL: #{search_url}"
      urls[keyword] = search_url
    end
    urls
  end

  def gather
    build_urls.each do |key, value|
      res = Net::HTTP.get_response(URI(value))
      # Status
      puts res.code       # => '200'
      puts res.message    # => 'OK'
      puts res.class.name # => 'HTTPOK'

      issue_hash = JSON.parse(res.body)
      issue_hash['items'].each do |repo|
        repo_url = repo['url'].sub(/api/, 'www').sub(/\/repos/, '').sub(/\/issues.*/, '') + "\n"
        @repos.push(repo_url)
      end
    end

    file = File.new(REPO_FILE, 'a')
    repos.uniq.each { |repo_url| file.write(repo_url) }
    file.close
  end
end

repo_gatherer = RepoGatherer.new
repo_gatherer.estimate_page_number
repo_gatherer.gather