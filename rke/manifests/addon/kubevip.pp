class rke::addon::kubevip (
   String           $iface         = $rke::params::kubevip_iface,
   String           $vip_ip        = $rke::params::kubevip_ip,
   Integer          $vip_cidr      = $rke::params::kubevip_cidr,
   Optional[String] $nodeselector  = $rke::params::kubevip_nodeselector,
   String           $image_version = $rke::params::kubevip_image_version,
) inherits rke::params {

   file{'/var/lib/rancher/rke2/server/manifests/kube-vip.yaml':
      ensure  => file,
      content => epp('rke/kube-vip.yaml', {'vipInterface' => $iface,
                                           'vipAddress'   => $vip_ip,
                                           'vipCidr'      => $vip_cidr,
                                           'nodeselector' => $nodeselector,
                                           'image'        => $image_version}),
      require => Package_versionlock['rke2'],
      mode    => '0600',
   }

}
