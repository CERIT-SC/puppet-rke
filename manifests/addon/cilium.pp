class rke::addon::cilium (
  Boolean $enabled                         = $rke::params::cilium_enabled,
  Optional[Boolean] $autodirectnoderouters = $rke::params::cilium_autodirectnoderouters,
  Optional[String]  $routingmode           = $rke::params::cilium_routingmode,
  Optional[Boolean] $l2announcements       = $rke::params::cilium_l2announcements,
  Optional[Boolean] $bgpcontrolplane       = $rke::params::cilium_bgpcontrolplane,
  Optional[Boolean] $externalips           = $rke::params::cilium_externalips,
  Optional[String]  $ipv4cidr              = $rke::params::cilium_ipv4cidr,
  Optional[String]  $ipv6cidr              = $rke::params::cilium_ipv6cidr,
  Optional[Boolean] $cniexclusive          = $rke::params::cilium_cniexclusive,
  Optional[Boolean] $proxyreplacement      = $rke::params::cilium_proxyreplacement,
  Optional[String]  $lb_pool_name          = $rke::params::cilium_lbpoolname,
  Optional[Array]   $lb_cidrs              = $rke::params::cilium_lbcidrs,
  Optional[String]  $bgp_advtype           = $rke::params::cilium_bgpadvtype,
  Optional[Array]   $bgp_addresses         = $rke::params::cilium_bgpaddresses,
  Optional[Integer] $bgp_localasn          = $rke::params::cilium_localasn,
  Optional[Array]   $bgp_peers             = $rke::params::cilium_bgppeers,
  Optional[Array]   $bgp_families          = $rke::params::cilium_bgpfamilies,
  Optional[Boolean] $hostfirewall          = $rke::params::cilium_hostfirewall,
) inherits rke::params {
  contain rke

  if $enabled {
    # Note: if bgpcontrolplane is updated, cilium operator pods need to be restarted
    file{'/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml':
      ensure  => file,
      content => epp('rke/rke2-cilium-config.yaml', { 'autodirectnoderouters' => $autodirectnoderouters,
                                                      'routingmode'           => $routingmode,
                                                      'l2announcements'       => $l2announcements, 
                                                      'bgpcontrolplane'       => $bgpcontrolplane,
                                                      'externalips'           => $externalips,
                                                      'ipv4cidr'              => $ipv4cidr,
                                                      'ipv6cidr'              => $ipv6cidr,
                                                      'cniexclusive'          => $cniexclusive,
                                                      'proxyreplacement'      => $proxyreplacement,
                                                      'hostfirewall'          => $hostfirewall,
                                                    }),
      require => Package_versionlock['rke2'],
      mode    => '0600',
    }
    if $lb_pool_name != undef and $lb_cidrs != undef {
      file{'/var/lib/rancher/rke2/server/manifests/rke2-cilium-lb-cidrs.yaml':
        ensure  => file,
        content => epp('rke/cilium-lb-ipool.yaml.epp', { 'name'  => $lb_pool_name,
                                                        'cidrs' => $lb_cidrs, 
                                                       }),
        require => Package_versionlock['rke2'],
        mode    => '0600',
      }
    }
    if $bgp_peers != undef { 
      file{'/var/lib/rancher/rke2/server/manifests/rke2-cilium-bgppeers.yaml':
        ensure  => file,
        content => epp('rke/cilium-bgp.yaml', { 'advtype'     => $bgp_advtype,
                                                'addresses'   => $bgp_addresses,
                                                'localasn'    => $bgp_localasn,
                                                'peers'       => $bgp_peers,
                                                'bgpfamilies' => $bgp_families,
                                              }),
        require => Package_versionlock['rke2'],
        mode    => '0600',
      }
    }
  } else {
    file{'/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml':
      ensure => absent,
    }
    file{'/var/lib/rancher/rke2/server/manifests/rke2-cilium-lb-cidrs.yaml':
      ensure => absent,
    }
    file{'/var/lib/rancher/rke2/server/manifests/rke2-cilium-bgppeers.yaml':
      ensure => absent,
    }
  } 
}
