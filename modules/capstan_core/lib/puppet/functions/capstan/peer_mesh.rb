# frozen_string_literal: true

# Puppet 4/8 modern function: capstan::peer_mesh
# Generates fully-connected or hub-and-spoke WireGuard peer list excluding local node identity.
Puppet::Functions.create_function(:'capstan::peer_mesh') do
  dispatch :filter_mesh do
    param 'String', :self_node_id
    param 'Array[Hash[String, Any]]', :all_nodes
    return_type 'Array[Hash[String, Any]]'
  end

  def filter_mesh(self_node_id, all_nodes)
    all_nodes.reject { |node| node['id'] == self_node_id }
  end
end
