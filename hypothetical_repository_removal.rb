#!/usr/bin/env ruby

# Given your org's active committers CSV, and a file containing repos to hypothetically
# disable GitHub Advanced Security on, this script would calculate the number of licenses 
# that would be saved if those repos disabled

require 'csv'

# See readme for usage
PATH_TO_REPOS_TO_DISABLE_FILE = "demo_data/repositories_to_disable.txt"

# Download your org's CSV file from https://github.com/organizations/<org_name>/settings/billing
PATH_TO_GHAS_ACTIVE_COMMITTER_CSV = "demo_data/ghas_active_committers_your_org_2022-01-01T1234.csv"

def total_licenses_we_pay_for_now(data)
  data[1..-1].map { |row| row[0] }.uniq.compact.count
end

def num_ghas_licenses_used_if_repos_disabled(data, repos_to_disable)
  updated_committers_to_repos = data[1..-1].map do |username, repo, _| 
    next if repos_to_disable.include?(repo.downcase) 
    username
  end
  
  return updated_committers_to_repos.uniq.compact.count
end

repositories_to_disable = File.readlines(PATH_TO_REPOS_TO_DISABLE_FILE).map(&:strip)
active_committer_data = CSV.read(PATH_TO_GHAS_ACTIVE_COMMITTER_CSV)

licenses_used_now = total_licenses_we_pay_for_now(active_committer_data)
licenses_used_after = num_ghas_licenses_used_if_repos_disabled(active_committer_data, repositories_to_disable)

licenses_saved = licenses_used_now - licenses_used_after

puts "We currently pay for #{licenses_used_now} GHAS licenses.\n\n"
puts "We would free up #{licenses_saved} GHAS licenses if we disabled GHAS on the following repos:\n"
puts "#{repositories_to_disable.map {|repo| "* #{repo}" }.join("\n")}"
puts "\nOur total GHAS licenses used would become #{licenses_used_after}."
