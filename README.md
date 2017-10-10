# rhsm

## Overview

This module registers your systems with RedHat Subscription Management.

## Setup

Just declare the module with parameters, or load the data from Hiera.

## Usage
```puppet
class { 'rhsm':
  rh_user     => 'myuser',
  rh_password => 'mypassword',
}
```
To attach the system to a specific pool (can be found on a registered system with `subscription-manager list --available`):

```puppet
class { 'rhsm':
  rh_user     => 'myuser',
  rh_password => 'mypassword',
  pool        => 'the_pool_id'
}
```

### Hiera (recommended)
```puppet
include rhsm
```
  Hierafile:

```yaml
rhsm::rh_user: myuser
rhsm::rh_password: mypassword
```

### Proxy
If the RedHat node must use a proxy to access the internet, you'll have to provide at least the hostname and TCP port.

```puppet
class { 'rhsm':
  proxy_hostname => 'my.proxy.net',
  proxy_port     => 8080
  rh_user        => 'myuser',
  rh_password    => 'mypassword',
}
```
You shouldn't specify the protocol, subscription-manager will use HTTP. For proxies with authentication, specify the `proxy_user` and `proxy_password` values.

The proxy settings will be used to register the system and as connection option for all the YUM repositories generated in `/etc/yum.repos.d/redhat.repo`

### Satellite 6
Registering with Red Hat Satellite 6 needs some additional settings.

```puppet
class { 'rhsm':
  activationkey         => 'act-lce-rhel-7,act-product',
  org                   => 'satellite_organization',
  servername            => 'satellite.example.com',
  serverprefix          => '/rhsm',
  repo_ca_cert_filename => 'katello-server-ca.pem',
  repo_ca_cert_source   => 'puppet:///modules/profile/katello-server-ca.crt',
  full_refresh_on_yum   => 1,
  baseurl               => 'https://satellite.example.com/pulp/repos',
}
```

* You need to specify either (`rh_user` and `rh_password`) or (`org` and `activationkey`).
* Multiple Activationkeys might be provided, separated by comma.
* Download the corresponding certificate from your Satellite (<https://satellite.example.com/pub/katelllo-server-ca.crt>) and publish it, e.g. with a (profile) module.

## Limitations

Well, only RedHat is supported :)
