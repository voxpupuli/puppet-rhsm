Facter.add('rhsm_repos') do
  confine :osfamily => :RedHat
  setcode do
    repos = Array.[]
    repo_list = Facter::Core::Execution.exec("yum repolist | awk '/Red Hat/ {print $1}'")
    repo_list.each_line do |line|
      repos.push(line.strip)
    end
    repos
  end
end
