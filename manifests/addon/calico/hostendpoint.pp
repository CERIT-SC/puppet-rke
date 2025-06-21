define rke::addon::calico::hostendpoint (
  Boolean $enable       = true,
  Array   $interfaces,
) {
   if $enable {
     $interfaces.each |$_interface| {
       file{"/var/lib/rancher/rke2/server/manifests/calico/calico-hostendpoint-${name}-${_interface}.yaml":
         ensure => file,
         content  => epp('rke/calico-hostendpoint.yaml', 'interface' => $_interface, 'hostname' => $name),
       }
     }
   }
}
