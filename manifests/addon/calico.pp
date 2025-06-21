class rke::addon::calico (
   String            $bgp                   = $rke::params::calico_bgp,
   Optional[String]  $bgp_filter            = $rke::params::calico_bgpfilter,
   Optional[Array]   $bgp_filter_imports    = $rke::params::calico_bgpfilterimports,
   Optional[Integer] $bgp_local_asn         = $rke::params::calico_bgplocalasn,
   Optional[Boolean] $bgp_nexthop           = $rke::params::calico_bgpnexthop,
   Optional[Array]   $bgp_peers             = $rke::params::calico_bgppeers,
   Boolean           $enable_failsafe       = $rke::params::calico_enablefailsafe,
   Boolean           $enable_firewall       = $rke::params::calico_enablefirewall,
   Boolean           $enable_wireguard      = $rke::params::calico_enablewireguard,
   String            $encapsulation         = $rke::params::calico_encapsulation,
   Boolean           $hostendpoints         = $rke::params::calico_hostendpoints,
   Optional[Hash]    $ip_pools              = $rke::params::calico_ippools,
   Optional[Array]   $lb_src_cidrs          = $rke::params::calico_lbsrccidrs,
   Optional[Array]   $local_cidrs           = $rke::params::calico_localcidrs,
   Optional[Integer] $mtu                   = $rke::params::calico_mtu,
) inherits rke::params {

   if $hostendpoints {
     class{'rke::addon::calico::hostendpoints':
        interfaces => unique(delete_undef_values([$rke::node_iface, $rke::node_iface6]))
     }
   }

   if $rke::controlnode {
     $_cidrs = split($rke::cluster_cidr, ',')
     if $_cidrs =~ Array {
       $_ipv6pool = $_cidrs.filter |$_cidr| {
                          $_cidr =~ /:/
                    }[0]
     } else {
       $_ipv6pool = undef
     }

     file{'/var/lib/rancher/rke2/server/manifests/rke2-calico-config.yml':
        ensure  => file,
        mode    => '0600',
        content => epp('rke/rke2-calico-config.yml.epp', { 'mtu'             => $mtu,
                                                           'bgp'             => $bgp,
                                                           'interface4'      => $rke::node_iface,
                                                           'interface6'      => $rke::node_iface6,
                                                           'encapsulation'   => $encapsulation,
                                                           'ipv6pool'        => $_ipv6pool,
                                                           'enablewireguard' => $enable_wireguard,
                                                           'enablefailsafe'  => $enable_failsafe,
                                                         }),
     }

     file{'/var/lib/rancher/rke2/server/manifests/calico':
       ensure => directory,
     }

     if $enable_firewall {
       contain rke::addon::calico::firewall
     }

     if $hostendpoints {
       Rke::Addon::Calico::Hostendpoint<<| tag == $rke::server_addr |>>{}
     }

     if $bgp_peers {
       $_peertmpl = $bgp_peers.map |$_peer| {
         $_asn     = $_peer['asn']
         $_address = $_peer['address']
         if $_address =~ /:/ {
            $_suffix = 'v6'
            $_id = split($_address, ':')[-1]
         } else {
            $_suffix = 'v4'
            $_id = split($_address, '\.')[3]
         }
         $_name     = "global-${_suffix}-${_id}"
         epp('rke/calico-peer.yaml.epp', { 'name' => $_name, 'asn' => $_asn, 'address' => $_address, 'keepnexthop' => $bgp_nexthop })

       }

       file { "/var/lib/rancher/rke2/server/manifests/calico/bgp-peers.yaml":
           ensure  => file,
           mode    => '0600',
           content => join($_peertmpl, "\n---\n"),
       }
     }

     if $bgp_local_asn {
        if $rke::addon::calico::ip_pools  =~ Hash {
           $_ippools = $rke::addon::calico::ip_pools.values.flatten().map |$_pool| { $_pool['cidr'] }
        } else {
           fail("bgp local asn defined and ip_pools is empty")
        }

        $_reject = split("${rke::cluster_cidr},${rke::service_cidr}", ',')
        $_accept = $_ippools

        $_exports = $_accept.map |$cidr| {
                { 'cidr' => $cidr, 'type' => 'accept' }
            } + $_reject.map |$cidr| {
                { 'cidr' => $cidr, 'type' => 'reject' }
            }

        file { '/var/lib/rancher/rke2/server/manifests/calico/bgp-filter.yaml':
           ensure  => file,
           mode    => '0600',
           content => epp('rke/calico-bgp-filter.yaml.epp', { 'name' => $bgp_filter, 'exports' => $_exports, 'imports' => $bgp_filter_imports }),
        }

        file { '/var/lib/rancher/rke2/server/manifests/calico/bgp.yaml':
           ensure  => file,
           mode    => '0600',
           content => epp('rke/calico-bgp.yaml.epp', { 'localasn' => $bgp_local_asn, 'ippools' => $_ippools, 'filter' => $bgp_filter }),
        }
     }
 
   }
}
