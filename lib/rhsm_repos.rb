Facter.add('rhsm_repos') do
  setcode do
    repos = Array.[]
    repo_list = Facter::Core::Execution.exec('subscription-manager repos --list-enabled | grep "Repo ID" | cut -d " " -f 5')
    repo_list.each_line do |line|
      repos.push(line.strip)
    end
    repos
  end
end
