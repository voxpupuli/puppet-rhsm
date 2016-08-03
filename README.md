# rhsm

## Overview

This module registers your systems with Redhat Subscription Management.

## Setup

Just declare the module with parameters, or load the data from Hiera.

## Usage
```puppet
  class { 'rhsm':
   rh_user     => 'myuser',
   rh_password => 'mypassword',
  }
```
To attach the system to a specific pool (can be found on a registered system with 'subscription-manager list --available'):
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
You shouldn't specify the protocol, subscription-manager will use HTTP. For proxies with authentication, specify the 'proxy_user' and 'proxy_password' values.

The proxy settings will be used to register the system and as connection option for all the YUM repositories generated in /etc/yum.repos.d/redhat.repo

## Limitations

Well, only RedHat is supported :)
