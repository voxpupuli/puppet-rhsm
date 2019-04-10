# @author Craig Dunn crayfishx/puppet-rhsm
Puppet::Type.newtype(:rh_subscription) do
  @doc = 'Manage Red Hat subscriptions'

  ensurable

  newparam(:name, isnamevar: true) do
  end

  newproperty(:active) do
    newvalues(:true, :false)
  end

  newparam(:serial) do
  end
end
