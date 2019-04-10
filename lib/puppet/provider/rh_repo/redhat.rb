# @author Craig Dunn crayfishx/puppet-rhsm
Puppet::Type.type(:rh_repo).provide(:redhat) do
  commands rhsm: '/usr/sbin/subscription-manager'
  mk_resource_methods

  def self.repos
    repos = {}
    rhsm('repos', '--list').split("\n\n").each do |blk|
      repo_data = {}
      blk.split("\n").each do |line|
        element = line.split(%r{:})
        repo_data[element.shift] = element.join.lstrip
      end
      repos[repo_data['Repo ID']] = {
        enabled: repo_data['Enabled']
      }
    end
    repos
  end

  def self.instances
    repos.map do |rid, data|
      new(
        ensure: data[:enabled] == '0' ? :disabled : :enabled,
        name:   rid
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
    @property_hash[:ensure] == :enabled
  end

  def create
    rhsm('repos', "--enable=#{@resource[:name]}")
  end

  def destroy
    rhsm('repos', "--disable=#{@resource[:name]}")
  end
end
