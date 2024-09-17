# Capstan Site Manifest
# Primary entrypoint for declarative catalog compilation and node classification.

# Set deterministic resource defaults across all managed nodes
File {
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  backup => false,
}

Exec {
  path => [
    '/usr/local/sbin',
    '/usr/local/bin',
    '/usr/sbin',
    '/usr/bin',
    '/sbin',
    '/bin',
    '/opt/capstan/bin',
  ],
  logoutput => on_failure,
}

# Node classification entrypoint
node default {
  # Inspect node facts to determine assigned role profile
  $node_role = lookup('capstan::role', String, 'first', 'edge_gateway')

  notice("Capstan compiling catalog for node ${trusted['certname']} with role: ${node_role}")

  # Apply base baseline profile to all edge hosts
  include profile::base

  # Dynamically evaluate role class
  case $node_role {
    'edge_gateway': {
      include role::edge_gateway
    }
    'colo_hypervisor': {
      include role::colo_hypervisor
    }
    'enclave_validator': {
      include role::enclave_validator
    }
    'storage_node': {
      include role::storage_node
    }
    'compute_worker': {
      include role::compute_worker
    }
    default: {
      warning("Unrecognized role ${node_role}; falling back to base edge node profile")
    }
  }
}
