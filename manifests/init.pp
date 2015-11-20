# == Class: rhsm
#
# Subscribe the node to the RHSM
#
# === Parameters
#
# Document parameters here.
#
# [*rh_user*]
#   User for the Customer Portal
# [*rh_password*]
#   Password for the rh_user account
# [*servername*]
#   Servername, default is provided.
# [*proxy_hostname*]
#   Proxy hostname
# [*proxy_port*]
#   Proxy port
# [*proxy_user*]
#   Proxy user
# [*proxy_password*]
#   Proxy password
# [*baseurl*]
#   Base URL for rhsm, default provided.
# [*manage_repos*]
#   Manage the repositories
#
# === Examples
#
# include rhsm
#
# Hierafile:
# ---
# rhsm::rh_user: myuser
# rhsm::rh_password: mypassword
#
# === Authors
#
# Ger Apeldoorn <info@gerapeldoorn.nl>
#
# === Copyright
#
# Copyright 2014 Ger Apeldoorn, unless otherwise noted.
#
class rhsm (
 $rh_user,
 $rh_password,
 $servername = 'subscription.rhn.redhat.com',
 $proxy_hostname = undef,
 $proxy_port = undef,
 $proxy_user = undef,
 $proxy_password = undef,
 $baseurl= 'https://cdn.redhat.com',
 $manage_repos = 1,
) {

  if $proxy_hostname {
    $proxycli = "--proxy=http://${proxy_hostname}:${proxy_port} --proxyuser=${proxy_user} --proxypass=${proxy_password}"
  }

  $command = "/usr/sbin/subscription-manager register --force --name=\"${::fqdn}\"  --username=\"${rh_user}\" --password=\"${rh_password}\" --auto-attach ${proxycli}"
  
  package { 'subscription-manager':
    ensure => latest,
  }
  exec {'sm yum clean all':
    command     => '/usr/bin/yum clean all',
    refreshonly => true,
    subscribe   => Package['subscription-manager'],
  }

  file { '/etc/rhsm/rhsm.conf':
    ensure => file,
  }

  exec { 'RHNSM-register':
    command => $command,
    unless  => '/usr/sbin/subscription-manager status | grep Current',
  }
}
