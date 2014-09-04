# == Class: rhsm
#
# Subscribe the node to the RHSM
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { rhsm:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class rhsm (
 $servername = 'subscription.rhn.redhat.com',
 $proxy_hostname = undef,
 $proxy_port = undef,
 $proxy_user = undef,
 $proxy_password = undef,
 $baseurl= 'https://cdn.redhat.com',
 $manage_repos = 1,
 $activationkey,
 $organisation
) {

  if $proxy_hostname {
    $proxycli = "--proxy=http://${proxy_hostname}:${proxy_port} --proxyuser=${proxy_user} --proxypass=${proxy_password}"
  }

  $command = "/usr/sbin/subscription-manager register --force --name=\"${::fqdn}\" --activationkey=\"${activationkey}\" --org=\"${organisation}\" ${proxycli} && /usr/sbin/subscription-manager repo-override --repo rhel-7-server-optional-rpms --add=enabled:1 && /usr/sbin/subscription-manager repo-override --repo rhel-7-server-extras-rpms --add=enabled:1"

  file { '/etc/rhsm/rhsm.conf':
    ensure => file,
  }

  notify { "RHNSM command: ${command}": }
}
