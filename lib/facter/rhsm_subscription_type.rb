Facter.add('rhsm_subscription_type') do
  confine osfamily: :RedHat
  setcode do
    if File.exist? '/etc/sysconfig/rhn/systemid'
      'rhn_classic'
    elsif File.exist? '/etc/pki/consumer/cert.pem'
      'rhsm'
    else
      'unknown'
    end
  end
end
