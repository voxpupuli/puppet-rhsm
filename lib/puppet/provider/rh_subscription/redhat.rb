# @author Craig Dunn crayfishx/puppet-rhsm
Puppet::Type.type(:rh_subscription).provide(:redhat) do
  commands rhsm: '/usr/sbin/subscription-manager'
  mk_resource_methods

  def self.subscriptions
    subs = {}
    rhsm('list', '--consumed').split("\n\n").each do |blk|
      sub_data = {}
      blk.split("\n").each do |line|
        element = line.match(%r{^([^:]+):[^\w]+(\w.*)})
        next unless element.is_a?(MatchData)
        sub_data[element[1]] = element[2]
      end
      subs[sub_data['Pool ID']] = {
        name: sub_data['Subscription Name'],
        active: sub_data['Active'],
        serial: sub_data['Serial']
      }
    end
    subs
  end

  def self.active?(str)
    case str
    when 'True'
      :true
    when 'False'
      :false
    end
  end

  def self.instances
    subscriptions.map do |pool, data|
      new(
        ensure: :present,
        name:   pool,
        active: active?(data[:active]),
        serial: data[:serial]
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    rhsm('attach', "--pool=#{@resource[:name]}")
  end

  def destroy
    rhsm('remove', "--serial=#{@property_hash[:serial]}")
  end
end
