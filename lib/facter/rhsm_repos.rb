Facter.add('rhsm_repos') do
  setcode do
    repos = Array.[]
    repo_list = Facter::Core::Execution.exec('yum repolist | grep "Red Hat" | cut -d " " -f 1')
    repo_list.each_line do |line|
      repos.push(line.strip)
    end
    repos
  end
end
