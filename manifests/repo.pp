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
  # Check to see if the title is an enabled repo
  if ! ($title in $facts['rhsm']['enabled_repo_ids']) {
    exec { "RHSM-enable_${title}":
      command => "subscription-manager repos --enable ${title}",
      path    => '/bin:/usr/bin:/usr/sbin',
    }
  }
}
