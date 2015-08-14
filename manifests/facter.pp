class rhsm::facter {
#Custom facter to see if server has subscription to rhsm
  file { "/etc/puppetlabs/facter/facts.d/rhsm_subscribed.sh":
    source             => "puppet:///modules/rhsm/facter",
    mode               => "0700",
    owner              => "root",
    group              => "root",
    }

}
