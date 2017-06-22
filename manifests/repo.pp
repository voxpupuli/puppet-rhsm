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
  yumrepo { $title:
    enabled  => true,
    require => Package['subscription-manager'],
    target  => '/etc/yum.repos.d/redhat.repo',
  }
}
