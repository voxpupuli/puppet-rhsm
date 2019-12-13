# rhsm
#
# Subscribe the node to RHSM
#
# Copyright 2014 Ger Apeldoorn, unless otherwise noted.
#
# @summary Subscribe the node to RHSM
#
# @param rh_user User for the Customer Portal.
#   You need to specify either (rh_user and rh_password) or (org and activationkey)
# @param rh_password Password for the rh_user account
# @param org Organization to use
# @param activationkey Activationkey to use
# @param servername Servername, default provided
#   Used directly in rhsm.conf template
# @param serverprefix server.prefix to use
#   Used directly in rhsm.conf template
#   /rhsm for Satellite 6
#   /subscription for RHSM
# @param serverport server.port to use
#   Used directly in rhsm.conf template
# @param ca_cert_dir Server CA certificate location
# @param repo_ca_cert_filename File containting the CA cert to use when generating yum repo configs
#   katello-server-ca.pem for Satellite 6
#   redhat-uep.pem for RHSM
# @param repo_ca_cert_source URI, if set the content is used for CA file resource ${ca_cert_dir}/${repo_ca_cert_filename}
#   Possible values are puppet:, file: and http:
# @param manage_repos 1 if subscription manager should manage yum repos file or
#   0 if the subscription is only used for tracking purposes
# @param full_refresh_on_yum rhsm.full_refresh_on_yum
#   Used directly in rhsm.conf template
#   1 for Satellite 6
#   0 for RHSM
# @param proxy_hostname Proxy hostname
# @param proxy_port Proxy port
# @param proxy_user Proxy user
# @param proxy_password Proxy password
# @param baseurl Base URL for rhsm, default provided
# @param package_ensure Whether to install subscription-manager, directly passed to the `ensure` param of the package.
# @param enabled_repo_ids A listing of the Repo IDs to provide to the subscription-manager repo --enable command.
# @param server_timeout HTTP timeout in seconds
# @param inotify Inotify is used for monitoring changes in directories with certificates. When this directory is mounted using a network
#   file system without inotify notification support (e.g. NFS), then disabling inotify is strongly recommended.
#
# @example
#   include rhsm
#
# @example
#   # Hierafile:
#   ---
#   rhsm::rh_user: myuser
#   rhsm::rh_password: mypassword
#
# @author Ger Apeldoorn <info@gerapeldoorn.nl>
#
class rhsm (
  Optional[String[1]]    $rh_user               = undef,
  Optional[String[1]]    $rh_password           = undef,
  Optional[String[1]]    $org                   = undef,
  Optional[String[1]]    $activationkey         = undef,
  Optional[Stdlib::Fqdn] $proxy_hostname        = undef,
  Optional[Stdlib::Port] $proxy_port            = undef,
  Optional[String[1]]    $proxy_user            = undef,
  Optional[String[1]]    $proxy_password        = undef,
  Stdlib::Httpurl        $baseurl               = 'https://cdn.redhat.com',
  Stdlib::Fqdn           $servername            = 'subscription.rhsm.redhat.com',
  Stdlib::Absolutepath   $serverprefix          = '/subscription',
  Stdlib::Port           $serverport            = 443,
  Stdlib::Absolutepath   $ca_cert_dir           = '/etc/rhsm/ca/',
  String[1]              $repo_ca_cert_filename = 'redhat-uep.pem',
  Optional[String[1]]    $repo_ca_cert_source   = undef,
  Integer[0,1]           $manage_repos          = 1,
  Integer[0,1]           $full_refresh_on_yum   = 0,
  String[1]              $package_ensure        = 'installed',
  Array[String[1]]       $enabled_repo_ids      = [],
  Integer[0,1]           $inotify               = 1,
  Integer[0]             $server_timeout        = 180,
){

  if ($rh_user == undef and $rh_password == undef) and ($org == undef and $activationkey == undef) {
    fail("${module_name}: Must provide rh_user and rh_password or org and activationkey")
  }

  if $rh_user {
    $_user = " --username='${rh_user}'"
  } else {
    $_user = ''
  }

  if $rh_password {
    $_password = " --password='${rh_password}'"
  } else {
    $_password = ''
  }

  if $org {
    $_org = " --org='${org}'"
  } else {
    $_org = ''
  }

  if $activationkey {
    $_activationkey = " --activationkey='${activationkey}'"
  } else {
    $_activationkey = ''
  }

  if $proxy_hostname {
    if $proxy_user and $proxy_password {
      $proxycli = " --proxy=http://${proxy_hostname}:${proxy_port} --proxyuser=${proxy_user} --proxypass=${proxy_password}"
    } else {
      $proxycli = " --proxy=http://${proxy_hostname}:${proxy_port}"
    }
  } else {
    $proxycli = ''
  }

  package { 'subscription-manager':
    ensure => $package_ensure,
  }

  file { '/etc/rhsm/rhsm.conf':
    content => template("${module_name}/rhsm.conf.erb"),
    require => Package['subscription-manager'],
    notify  => Service['rhsmcertd'],
  }

  if $repo_ca_cert_source {
    file { "${ca_cert_dir}/${repo_ca_cert_filename}":
      source  => $repo_ca_cert_source,
      mode    => '0644',
      require => Package['subscription-manager'],
      before  => File['/etc/rhsm/rhsm.conf'],
    }
  }

  rh_repo { $enabled_repo_ids:
    ensure => present,
  }

  exec { 'RHSM-register':
    command => "subscription-manager register --name='${facts['networking']['fqdn']}'${_user}${_password}${_org}${_activationkey}${proxycli}",
    creates => '/etc/pki/consumer/cert.pem',
    path    => '/bin:/usr/bin:/usr/sbin',
    require => File['/etc/rhsm/rhsm.conf'],
  }
  -> Rh_subscription <||>
  -> Rh_repo <||>

  service { 'rhsmcertd':
    ensure => running,
    enable => true,
  }
}
