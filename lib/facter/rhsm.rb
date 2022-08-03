# frozen_string_literal: true

require 'puppet/util/inifile'
require 'puppet/util/json'

Facter.add(:rhsm, type: :aggregate) do
  confine :os do |os|
    os['family'] == 'RedHat'
  end

  # List the currently enabled repositories
  if File.exist? '/etc/yum.repos.d/redhat.repo'
    chunk(:enabled_repo_ids) do
      repos = Array.[]
      repo_file = Puppet::Util::IniConfig::PhysicalFile.new('/etc/yum.repos.d/redhat.repo')
      repo_file.read
      repo_file.sections.each do |section|
        repos.push(section.name) if section['enabled'].nil? || section['enabled'].to_i == 1
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

  # Find any syspurpose defined
  chunk(:syspurpose) do
    syspurpose = Puppet::Util::Json.load_file_if_valid('/etc/rhsm/syspurpose/syspurpose.json') if File.exist? '/etc/rhsm/syspurpose/syspurpose.json'
    syspurpose unless syspurpose.empty?
  end

  # Add satellite server information
  if File.exist? '/etc/rhsm/rhsm.conf'
    chunk(:server) do
      server_file = Puppet::Util::IniConfig::PhysicalFile.new('/etc/rhsm/rhsm.conf')
      server_file.read

      { server: 'unknown' } unless server_file.get_section('server')

      server_conf = server_file.get_section('server').entries.select { |entry| entry.is_a?(Array) }.to_h
      { server: server_conf }
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
