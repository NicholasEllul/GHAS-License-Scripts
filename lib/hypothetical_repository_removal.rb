class HypotheticalRepositoryRemoval
  class InvalidRepositoryArgument < StandardError
    def message
      "repos_to_disable must be an array of strings of the form '<org>/<repo>'."
    end
  end

  class InvalidActiveCommitterData < StandardError
    def message
      "active_committer_data must be an array where each element is in the form of [<username>, <org>/<repo committed to>]."
    end
  end

  def initialize(repos_to_disable:, active_committer_data:)
    validate_repositories!(repos_to_disable)
    validate_active_comitter_data!(active_committer_data)

    @repos_to_disable = repos_to_disable
    @active_committer_data = active_committer_data
  end

  def licenses_saved
    licenses_used_now - licenses_used_if_repos_disabled
  end

  def licenses_used_now
    @licenses_used_now ||= @active_committer_data[1..-1].map { |row| row[0] }.uniq.compact.count
  end
  
  def licenses_used_if_repos_disabled
    @licenses_used_if_repos_disabled ||= begin

      updated_committers_to_repos = @active_committer_data[1..-1].map do |username, repo| 
        next if @repos_to_disable.include?(repo.downcase) 
        username
      end
      
      updated_committers_to_repos.uniq.compact.count
    end
  end

  private 

  def validate_repositories!(repos_to_disable)
    raise InvalidRepositoryArgument unless repos_to_disable.is_a?(Array) 
    raise InvalidRepositoryArgument unless repos_to_disable.all? { |repo| repo.is_a?(String) && repo.include?("/") }
  end

  def validate_active_comitter_data!(active_committer_data)
    raise InvalidActiveCommitterData unless active_committer_data.is_a?(Array)
    raise InvalidActiveCommitterData unless active_committer_data.all? { |row| row.is_a?(Array) && row.count == 2 }
  end
end