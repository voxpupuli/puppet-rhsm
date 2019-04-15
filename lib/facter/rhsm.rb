Facter.add(:rhsm, type: :aggregate) do
  confine :os do |os|
    os['family'] == 'RedHat'
  end

  # List the currently enabled repositories
  if File.exist? '/etc/yum.repos.d/redhat.repo'
    chunk(:enabled_repo_ids) do
      repos = Array.[]
      repo_list = IniFile.load('/etc/yum.repos.d/redhat.repo')
      repo_list.each_section do |section|
        repos.push(section) if repo_list[section]['enabled'] == 1 || repo_list[section]['enabled'].nil?
      end
      { enabled_repo_ids: repos }
    end
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
    os['family'] == 'RedHat'
  end

  setcode do
    Facter.value(:rhsm)[:enabled_repo_ids]
  end
end

Facter.add('rhsm_subscription_type') do
  confine :os do |os|
    os['family'] == 'RedHat'
  end

  setcode do
    Facter.value(:rhsm)[:subscription_type]
  end
end
