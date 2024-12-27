# capstan_security::mtls
# Configures ephemeral mutual TLS (mTLS) certificates for intra-cluster daemon RPCs.
class capstan_security::mtls {
  $tls_dir  = "${capstan_core::config_dir}/tls"
  $ca_crt   = "${tls_dir}/ca.crt"
  $node_crt = "${tls_dir}/node.crt"
  $node_key = "${tls_dir}/node.key"

  file { $tls_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  # Generate ephemeral local self-signed CA for node inspection if absent
  exec { 'capstan_generate_mtls_ca':
    command => "openssl req -x509 -newkey rsa:2048 -nodes -keyout ${tls_dir}/ca.key -out ${ca_crt} -days 365 -subj '/CN=Capstan-Internal-CA'",
    creates => $ca_crt,
    path    => ['/usr/bin', '/bin'],
    require => File[$tls_dir],
  }

  # Generate node certificate
  exec { 'capstan_generate_node_cert':
    command => "openssl req -newkey rsa:2048 -nodes -keyout ${node_key} -out ${tls_dir}/node.csr -subj \"/CN=${trusted['certname']}\" && openssl x509 -req -in ${tls_dir}/node.csr -CA ${ca_crt} -CAkey ${tls_dir}/ca.key -CAcreateserial -out ${node_crt} -days 30",
    creates => $node_crt,
    path    => ['/usr/bin', '/bin'],
    require => Exec['capstan_generate_mtls_ca'],
  }
}
