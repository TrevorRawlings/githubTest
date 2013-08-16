#!/usr/bin/env ruby
require "rubygems"
require "json"
require 'open-uri'

#
# github_language.rb
# ----------------
#
# Outputs the most popular language for the given user:
#
# ./github_language.rb TrevorRawlings
#   Fetching GitHub repositories for TrevorRawlings...
#   14 repositories found
#
#   Language        |  Repositories
#   --------------------------------------------------
#   JavaScript      | 7 - backbone-edit, Backbone-relational, Backbone.Subset, colorbox, fullcalendar, select2, SlickGrid
#   Ruby            | 7 - active_model_serializers, backbone-on-rails, formtastic_datepicker_inputs, guard-jasmine, rgviz, ruby-plsql, zendesk_remote_auth
#
#   Most popular languages for TrevorRawlings are JavaScript, Ruby
#
#
# ./github_language.rb  ivaynberg
#   Fetching GitHub repositories for ivaynberg...
#   6 repositories found
#
#   Language        |  Repositories
#   --------------------------------------------------
#   Java            | 3 - weld-core, weld-extensions, wicket
#   JavaScript      | 2 - select2, WicketTesterSandbox
#   CSS             | 1 - wicket-select2
#
#   Most popular language for ivaynberg is Java
#
#


#
# Fetch the list of repos:
#
# curl -i https://api.github.com/users/TrevorRawlings/repos
#
# ---------------------
# [
#  {
#    "id": 4784111,
#    "name": "active_model_serializers",
#    "full_name": "TrevorRawlings/active_model_serializers",
#    "owner": { <....> },
#    "private": false,
#    "html_url": "https://github.com/TrevorRawlings/active_model_serializers",
#    "description": "ActiveModel::Serializer implementation and Rails hooks",
#    "fork": true,
#    <....>
#    "language": "Ruby",
#    "has_issues": false,
#    <....>
#  },
#  { ... }
# ]


if ARGV.length != 1
  puts 'expected a GitHub user name'
  exit
end

user = ARGV[0]

puts "Fetching GitHub repositories for #{user}..."

response = URI.parse("https://api.github.com/users/#{user}/repos").read
json_repos = JSON.parse(response)

if json_repos.length == 0
  puts "No GitHub repositories found for user #{user}"
  exit
else
  puts "#{json_repos.length} repositories found \n\n"
end

# Build a hash table containing an entry for each language
#
# languages['C'] = ['my first repo', 'another repo']
# languages['Ruby'] = ['rails']
#
languages = {}
json_repos.each do |repo|
  puts 'ERROR: Key missing from the returned JSON' if !repo.has_key?('language') or !repo.has_key?('name')
  language_name = repo['language'] || '?'
  repo_name = repo['name'] || '?'

  if languages.has_key?(language_name)
    languages[language_name].push(repo_name)
  else
    languages[language_name] = [repo_name]
  end
end

# Sort by number of repos
#
#  languages_array = [{ :language_name => 'C', :repos => ['my first repo', 'another repo'] }, { ... } ]
#
languages_array = []
languages.each_pair { |language_name, repos| languages_array.push({ :language_name => language_name, :repos => repos  }) }
languages_array = languages_array.sort_by{ |item| item[:repos].length }.reverse!



puts " #{'Language'.ljust(15)} |  Repositories "
puts '-------------------------------------------------- '
languages_array.each do |item|
  puts " #{item[:language_name].ljust(15)} | #{item[:repos].length} - #{item[:repos].join(', ')}"
end
puts "\n\n"


# Find the most popular (several may share the top spot)
most_popular_count = languages_array[0][:repos].length
most_popular = languages_array.select{ |item| item[:repos].length == most_popular_count }

if most_popular.length == 1
  puts "Most popular language for #{user} is #{most_popular[0][:language_name]}"
else
  puts "Most popular languages for #{user} are #{most_popular.map{ |i| i[:language_name] }.join(', ')}"
end



