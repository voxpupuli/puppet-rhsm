# rhsm::repo
#
# Target file is /etc/yum.repos.d/redhat.repo
#
# Copyright 2014 Ger Apeldoorn, unless otherwise noted.
#
# @summary Manage additional RedHat repositories
#
# @author Ger Apeldoorn <info@gerapeldoorn.nl>
#
# @example
#   ::rhsm::repo { "rhel-${::operatingsystemmajrelease}-server-extras-rpms": }
define rhsm::repo (
) {
  yumrepo { $title:
    enabled => '1',
    require => Package['subscription-manager'],
    target  => '/etc/yum.repos.d/redhat.repo',
  }
}
