# rhsm

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with rhsm](#setup)
    * [What rhsm affects](#what-rhsm-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with rhsm](#beginning-with-rhsm)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module registers your systems with Redhat Subscription Management

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

Or, with Hiera: (recommended)
```puppet
  include rhsm
```
  Hierafile:
```yaml
  rhsm::rh_user: myuser
  rhsm::rh_password: mypassword
```  


## Limitations

Well, only RedHat is supported :)
