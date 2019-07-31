# @author Craig Dunn crayfishx/puppet-rhsm
Puppet::Type.newtype(:rh_subscription) do
  @doc = 'Manage Red Hat subscriptions'

  ensurable

  newparam(:name, isnamevar: true) do
  end

  newparam(:serial) do
  end
end
