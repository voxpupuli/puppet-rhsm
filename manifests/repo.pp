# === Authors
#
# Ger Apeldoorn <info@gerapeldoorn.nl>
#
# === Copyright
#
# Copyright 2014 Ger Apeldoorn, unless otherwise noted.
#
define rhsm::repo (
) {

  if $rhsm::proxy_hostname {
    $proxycli = "--proxy=http://${rhsm::proxy_hostname}:${rhsm::proxy_port} --proxyuser=${rhsm::proxy_user} --proxypass=${rhsm::proxy_password}"
  }

  $command = "/usr/sbin/subscription-manager repos --enable=${title} ${proxycli}"
  
  package { 'subscription-manager':
    ensure => latest,
  }

  exec { "RHSM::repo register ${title}":
    command => $command,
    unless  => "/usr/sbin/subscription-manager repos --list-enabled | /bin/grep ${title}",
    require => [ Exec['RHNSM-register'], Package['subscription-manager']] ,
  }
}
