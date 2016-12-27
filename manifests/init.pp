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
# [*pool*]
#   Attach system to a specific pool instead of auto attach to compatible subscriptions.
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
  $servername     = 'subscription.rhn.redhat.com',
  $pool           = undef,
  $proxy_hostname = undef,
  $proxy_port     = undef,
  $proxy_user     = undef,
  $proxy_password = undef,
  $baseurl        = 'https://cdn.redhat.com',
  $package_ensure = 'latest',
  $repo_extras    = false,
  $repo_optional  = false
) {

  if $proxy_hostname {
    if $proxy_user and $proxy_password {
      $proxycli = "--proxy=http://${proxy_hostname}:${proxy_port} --proxyuser=${proxy_user} --proxypass=${proxy_password}"
    } else {
      $proxycli = "--proxy=http://${proxy_hostname}:${proxy_port}"
    }
  } else {
    $proxycli = ''
  }

  if $pool == undef {
    $command = "subscription-manager attach --auto ${proxycli}"
  } else {
    $command = "subscription-manager attach --pool=${pool} ${proxycli}"
  }

  package { 'subscription-manager':
    ensure => $package_ensure,
  }

  exec {'sm yum clean all':
    command     => '/usr/bin/yum clean all',
    refreshonly => true,
    subscribe   => Package['subscription-manager'],
  }

  file { '/etc/rhsm/rhsm.conf':
    ensure  => file,
    content => template('rhsm/rhsm.conf.erb'),
  }

  exec { 'RHNSM-register':
    command => "subscription-manager register --name='${::fqdn}' --username='${rh_user}' --password='${rh_password}' ${proxycli}",
    onlyif  => 'subscription-manager identity | grep "not yet registered"',
    path    => '/bin:/usr/bin:/usr/sbin',
    require => Package['subscription-manager'],
  }

  exec { 'RHNSM-subscribe':
    command => $command,
    onlyif  => 'subscription-manager list | grep "Not Subscribed\|Unknown"',
    path    => '/bin:/usr/bin:/usr/sbin',
    require => Exec['RHNSM-register'],
  }

  if $repo_extras {
    ::rhsm::repo { "rhel-${::operatingsystemmajrelease}-server-extras-rpms":
      require => Exec['RHNSM-register'],
    }
  }

  if $repo_optional {
    ::rhsm::repo { "rhel-${::operatingsystemmajrelease}-server-optional-rpms":
      require => Exec['RHNSM-register'],
    }
  }

}
