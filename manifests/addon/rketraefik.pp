class rke::addon::rketraefik (
  Boolean           $enabled                = $rke::params::rketraefik_enabled,
  Optional[String]  $ipv4                   = $rke::params::rketraefik_ipv4,
  Optional[String]  $ipv6                   = $rke::params::rketraefik_ipv6,
  Optional[String]  $ipannotation           = $rke::params::rketraefik_ipannotation,
  Optional[String]  $issuerkind             = $rke::params::rketraefik_issuerkind,
  Optional[String]  $externaltraffic        = $rke::params::rketraefik_externaltraffic,
  Optional[String]  $cpu                    = $rke::params::rketraefik_cpu,
  Optional[String]  $cpulimit               = $rke::params::rketraefik_cpulimit,
  Optional[String]  $memory                 = $rke::params::rketraefik_memory,
  Optional[String]  $externalname           = $rke::params::rketraefik_externalname,
  Optional[Integer] $replicas               = $rke::params::rketraefik_replicas,
  Optional[Boolean] $oldstyleconfig         = $rke::params::rketraefik_oldstyleconfig,
  Optional[Boolean] $metrics                = $rke::params::rketraefik_metrics,
  Optional[Boolean] $ingresswithoutclasss   = $rke::params::rketraefik_ingresswithoutclass,
  Optional[String]  $ingressclass           = $rke::params::rketraefik_ingressclass,
  Optional[String]  $ingresscontrollerclass = $rke::params::rketraefik_ingresscontrollerclass,
  Optional[Boolean] $publicgateway          = $rke::params::rketraefik_publicgateway,
  Optional[Integer] $proxyreadtimeout       = $rke::params::rketraefik_proxyreadtimeout,
  Variant[String,Boolean] $customimage      = 'v3.6.7',
  Optional[Boolean] $deploylbcert           = $rke::params::rketraefik_deploylbcert,
  Optional[Boolean] $sslgateway             = $rke::params::rketraefik_sslgateway,
  Optional[String]  $certissuer             = $rke::params::rketraefik_certissuer,
  Optional[Array[String]] $additional_hostnames = $rke::params::rketraefik_additional_hostnames,
  Optional[Array[String]] $additionalsans       = $rke::params::rketraefik_additionalsans,
  Optional[Boolean]       $allowedlisteners     = $rke::params::rketraefik_allowedlisteners,
) inherits rke::params {
    contain rke

    if $enabled {
      if $ipv4 {
        $_families4 = "IPv4"
      } else {
        $_families4 = undef
      }
      if $ipv6 {
        $_families6 = "IPv6"
      } else {
        $_families6 = undef
      }

      $_families = delete_undef_values(flatten($_families4, $_families6))

      $_ip = delete_undef_values(flatten($ipv4, $ipv6)).join(',')

      file{'/var/lib/rancher/rke2/server/manifests/rke2-traefik-config.yaml':
        ensure  => file,
        content => epp('rke/rke2-traefik-config.yaml', {       'lbip'                   => $_ip,
                                                               'ipannotation'           => $ipannotation,
                                                               'ipfamilies'             => $_families,
                                                               'externaltraffic'        => $externaltraffic,
                                                               'cpu'                    => $cpu,
                                                               'cpulimit'               => $cpulimit,
                                                               'memory'                 => $memory,
                                                               'externalname'           => $externalname,
                                                               'replicas'               => $replicas,
                                                               'oldstyle'               => $oldstyleconfig,
                                                               'metrics'                => $metrics,
                                                               'customimage'            => $customimage,
                                                               'ingresswithoutclasss'   => $ingresswithoutclasss,
                                                               'ingressclass'           => $ingressclass,
                                                               'ingresscontrollerclass' => $ingresscontrollerclass,
                                                               'publicgateway'          => $publicgateway,
                                                               'proxyreadtimeout'       => $proxyreadtimeout,
                                                               'sslgateway'             => $sslgateway,
                                                               'allowedlisteners'       => $allowedlisteners,
                                                             }),
        mode    => '0600',
        #require => Package_versionlock['rke2'],
      }

      if $deploylbcert {
        file{'/var/lib/rancher/rke2/server/manifests/rke2-gatewaycert.yaml':
          ensure  => file,
          content => epp('rke/rke2-gatewaycert.yaml', { 'hostname'             => $externalname,
                                                        'certissuer'           => $certissuer,
                                                        'issuerkind'           => $issuerkind,
                                                        'additional_hostnames' => $additional_hostnames,
                                                        'additionalsans'       => $additionalsans }),
          mode    => '0600',
          #require => Package_versionlock['rke2'],
        }
      }
    } else {
      file{'/var/lib/rancher/rke2/server/manifests/rke2-traefik-config.yaml':
        ensure => absent,
      }
    }
}
