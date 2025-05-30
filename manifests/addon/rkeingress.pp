class rke::addon::rkeingress (
  Boolean           $enabled             = $rke::params::rkeingress_enabled,
  Optional[String]  $ipv4                = $rke::params::rkeingress_ipv4,
  Optional[String]  $ipv6                = $rke::params::rkeingress_ipv6,
  Optional[String]  $ipannotation        = $rke::params::rkeingress_ipannotation,
  Optional[String]  $externaltraffic     = $rke::params::rkeingress_externaltraffic,
  Optional[String]  $cpu                 = $rke::params::rkeingress_cpu,
  Optional[String]  $memory              = $rke::params::rkeingress_memory,
  Optional[String]  $externalname        = $rke::params::rkeingress_externalname,
  Optional[Integer] $maxreplicas         = $rke::params::rkeingress_maxreplicas,
  Optional[Integer] $openstacktimeout    = $rke::params::rkeingress_openstacktimeout,
  Optional[Boolean] $defaultclass        = $rke::params::rkeingress_defaultclass,
  Optional[Integer] $proxytimeout        = $rke::params::rkeingress_proxytimeout,
  Optional[Array]   $customerrors        = $rke::params::rkeingress_customerrors,
  Optional[Integer] $workertimeout       = $rke::params::rkeingress_workertimeout,
  Optional[Boolean] $defaultbackend      = $rke::params::rkeingress_defaultbackend,
  Optional[String]  $defaultbackendimage = $rke::params::rkeingress_defaultbackendimage,
  Optional[String]  $defaultbackendtag   = $rke::params::rkeingress_defaultbackendtag,
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


      file{'/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml':
        ensure  => file,
        content => epp('rke/rke2-ingress-nginx-config.yaml', { 'lbip'                => $_ip,
                                                               'ipannotation'        => $ipannotation,
                                                               'ipfamilies'          => $_families,
                                                               'externaltraffic'     => $externaltraffic,
                                                               'cpu'                 => $cpu,
                                                               'memory'              => $memory,
                                                               'externalname'        => $externalname,
                                                               'maxreplicas'         => $maxreplicas,
                                                               'openstacktimeout'    => $openstacktimeout,
                                                               'defaultclass'        => $defaultclass,
                                                               'proxytimeout'        => $proxytimeout,
                                                               'customerrors'        => $customerrors,
                                                               'workertimeout'       => $workertimeout,
                                                               'defaultbackend'      => $defaultbackend,
                                                               'defaultbackendimage' => $defaultbackendimage,
                                                               'defaultbackendtag'   => $defaultbackendtag,
                                                             }),
        mode    => '0600',
        require => Package_versionlock['rke2'],
      }
    } else {
      file{'/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml':
        ensure => absent,
      }
    }
}
