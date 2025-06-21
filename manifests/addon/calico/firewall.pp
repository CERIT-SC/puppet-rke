class rke::addon::calico::firewall(
) inherits rke::params {
  contain rke

  if $rke::addon::calico::ip_pools  =~ Hash {
     $_ippools = $rke::addon::calico::ip_pools.values.flatten().map |$_pool| { $_pool['cidr'] }
  } else {
     $_ippools = undef
  }
 
  $_bgppeers = $rke::addon::calico::bgp_peers.map |Hash $_peer| {
     $_peer['address']
  }

  file{'/var/lib/rancher/rke2/server/manifests/calico/calico-policy.yaml':
    ensure   => file,
    content  => epp('rke/calico-policy.yaml', 
                      'clustercidr'  => $rke::cluster_cidr,
                      'bgppeers'     => $_bgppeers,
                      'localcidrs'   => $rke::addon::calico::local_cidrs,
                      'lbpools'      => $_ippools,
                      'lbsrcnets'    => $rke::addon::calico::lb_src_cidrs,
                      'zabbixserver' => hiera(cerit::zabbix::agent::server, undef),
                  ),
  }
}
