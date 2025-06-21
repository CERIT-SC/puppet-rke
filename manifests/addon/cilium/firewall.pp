class rke::addon::cilium::firewall(
) inherits rke::params {
  contain rke

  file{'/var/lib/rancher/rke2/server/manifests/cilium-policy.yaml':
    ensure   => file,
    content  => epp('rke/cilium-policy.yaml', 
                      'zabbixserver' => hiera(cerit::zabbix::agent::server, undef),
                  ),
  }
}
