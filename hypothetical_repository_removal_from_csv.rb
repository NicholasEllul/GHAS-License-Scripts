#!/usr/bin/env ruby

# Given your org's active committers CSV, and a file containing repos to hypothetically
# disable GitHub Advanced Security on, this script would calculate the number of licenses 
# that would be saved if those repos disabled

require 'csv'
require_relative 'lib/hypothetical_repository_removal'

# See readme for usage
PATH_TO_REPOS_TO_DISABLE_FILE = "demo_data/repositories_to_disable.txt"

# Download your org's CSV file from https://github.com/organizations/<org_name>/settings/billing
PATH_TO_GHAS_ACTIVE_COMMITTER_CSV = "demo_data/ghas_active_committers_your_org_2022-01-01T1234.csv"

repositories_to_disable = File.readlines(PATH_TO_REPOS_TO_DISABLE_FILE).map(&:strip)
active_committer_data = CSV.read(PATH_TO_GHAS_ACTIVE_COMMITTER_CSV).map { |row| row[0..1] }

hypothetical = HypotheticalRepositoryRemoval.new(
  repos_to_disable: repositories_to_disable, 
  active_committer_data: active_committer_data
)

puts "We currently pay for #{hypothetical.licenses_used_now} GHAS licenses.\n\n"
puts "We would free up #{hypothetical.licenses_saved} GHAS licenses if we disabled GHAS on the following repos:\n"
puts "#{repositories_to_disable.map {|repo| "* #{repo}" }.join("\n")}"
puts "\nOur total GHAS licenses used would become #{hypothetical.licenses_used_if_repos_disabled}."
