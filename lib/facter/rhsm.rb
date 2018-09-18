Facter.add(:rhsm, type: :aggregate) do
  confine :os do |os|
    os['name'] == 'RedHat'
  end

  # List the currently enabled repositories
  chunk(:enabled_repo_ids) do
    repos = Array.[]
    repo_list = Facter::Core::Execution.exec("subscription-manager repos --list-enabled | awk '/Repo ID:/ {print $3}'")
    repo_list.each_line do |line|
      repos.push(line.strip)
    end
    { enabled_repo_ids: repos }
  end

  # Determine the subscription type
  chunk(:subscription_type) do
    if File.exist? '/etc/sysconfig/rhn/systemid'
      { subscription_type: 'rhn_classic' }
    elsif File.exist? '/etc/pki/consumer/cert.pem'
      { subscription_type: 'rhsm' }
    else
      { subscription_type: 'unknown' }
    end
  end
end

# Backward compatibility
Facter.add('rhsm_repos') do
  confine :os do |os|
    os['name'] == 'RedHat'
  end

  setcode do
    Facter.value(:rhsm)[:enabled_repo_ids]
  end
end

Facter.add('rhsm_subscription_type') do
  confine :os do |os|
    os['name'] == 'RedHat'
  end

  setcode do
    Facter.value(:rhsm)[:subscription_type]
  end
end
