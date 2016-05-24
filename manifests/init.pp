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
 $servername     = 'subscription.rhn.redhat.com',
 $pool           = undef,
 $proxy_hostname = undef,
 $proxy_port     = undef,
 $proxy_user     = undef,
 $proxy_password = undef,
 $baseurl        = 'https://cdn.redhat.com',
 $manage_repos   = 1,
) {

  if $proxy_hostname {
    if $proxy_user and $proxy_password {
      $proxycli = "--proxy=http://${proxy_hostname}:${proxy_port} --proxyuser=${proxy_user} --proxypass=${proxy_password}"
    } else {
      $proxycli = "--proxy=http://${proxy_hostname}:${proxy_port}"
    }
  }

  if $pool == undef {
    $command = "/usr/sbin/subscription-manager register --name=\"${::fqdn}\"  --username=\"${rh_user}\" --password=\"${rh_password}\" --auto-attach ${proxycli} && /usr/sbin/subscription-manager repo-override --repo rhel-${::operatingsystemmajrelease}-server-optional-rpms --add=enabled:1 && /usr/sbin/subscription-manager repo-override --repo rhel-${::operatingsystemmajrelease}-server-extras-rpms --add=enabled:1"
  } else {
    $command = "/usr/sbin/subscription-manager register --name=\"${::fqdn}\"  --username=\"${rh_user}\" --password=\"${rh_password}\" ${proxycli} && /usr/sbin/subscription-manager attach --pool=${pool}"
  }

  file { '/etc/rhsm/rhsm.conf':
    content => template('rhsm/rhsm.conf.erb'),
    ensure  => file
  }

  exec { 'RHNSM-register':
    command => $command,
    onlyif  => '/usr/sbin/subscription-manager list | grep "Not Subscribed"',
  }
}
