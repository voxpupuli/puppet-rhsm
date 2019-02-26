# rhsm

[![Build Status](https://travis-ci.org/voxpupuli/puppet-rhsm.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-rhsm) [![Version](https://img.shields.io/puppetforge/v/puppet/rhsm.svg)](https://forge.puppet.com/puppet/rhsm)

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Types](#types)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [Development](#development)

## Description

This module registers your systems with Red Hat Subscription Management.

## Setup

Just declare the module with parameters, or load the data from Hiera.

## Types

### rh_repo

Manage yum repos via the subscription-manager.


### rh_subscription

Enable or disable RH subscriptions based on their pool ID.

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

Use `rh_repo` type to add a repository:

```puppet
rh_repo { 'rhel-7-server-extras-rpms':
 ensure => present,
}
```

Use `rh_subscription` type to add or remove a subscription based on its pool ID:

```puppet
rh_subscription { '8e8e7f7a77554a776277ac6dca654':
  ensure => present,
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

### Enabled Repos

A string array of repo IDs can be provided as an argument to the class definition. This list will be used to enable the target repos if that has not already occurred.

The following example enables the server and optional RPMs:

```puppet
class { 'rhsm':
  rh_user          => 'myuser',
  rh_password      => 'mypassword',
  enabled_repo_ids => [
    'rhel-7-server-rpms',
    'rhel-7-server-optional-rpms'
  ]
}
```

Alternatively, hiera can be utilized to specify these arguments.

```yaml
rhsm::rh_user: myuser
rhsm::rh_password: mypassword
rhsm::enabled_repo_ids:
  - 'rhel-7-server-rpms',
  - 'rhel-7-server-optional-rpms'
```

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

## Development

Some general guidelines on PR structure can be found [here](https://voxpupuli.org/docs/#reviewing-a-module-pr).
