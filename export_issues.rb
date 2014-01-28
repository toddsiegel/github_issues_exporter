require 'csv'
require 'dotenv'
require 'octokit'

env = Dotenv.load

raise "You need a .env file with your GitHub credentials in the current path. Look at .env.sample for reference." if env.empty?

def parse_label_names(issue)
  issue['labels'].map { |l| l['name']}
end

def exclude_issue?(labels)
  labels.include?('internal') || labels.include?('refactor')
end

client = Octokit::Client.new(:login => env['username'], :password => env['password'])

user = client.user
user.login

client.auto_paginate = true
issues = client.list_issues(env['repo_name'], :per_page => 100)
puts "Fetched #{issues.length} open issues"

CSV.open("issues.csv", "w") do |file|
  file<< ["Issue Number", "Title", "Description", "Tags", "Milestone"]

  issues.each do |issue|
    
    labels = parse_label_names(issue)

    unless exclude_issue?(issue)

      file<< [issue['number'],
              issue['title'],
              issue['body'],
              labels.join(', '),
              issue['milestone'].nil? ? "None" : issue['milestone']['title']]
    end
  end
end