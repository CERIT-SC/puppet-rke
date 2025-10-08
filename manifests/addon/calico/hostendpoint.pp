define rke::addon::calico::hostendpoint (
  Boolean $enable       = true,
  Array   $interfaces,
) {
   if $enable {
     $interfaces.each |$_interface| {
       $_manifest = regsubst("calico-hep-${name}-${_interface}", '\.', '-', 'G')
       file{"/var/lib/rancher/rke2/server/manifests/calico/${_manifest}.yaml":
         ensure => file,
         content  => epp('rke/calico-hostendpoint.yaml', 'interface' => $_interface, 'hostname' => $name),
       }
       file{"/var/lib/rancher/rke2/server/manifests/calico/calico-hostendpoint-${name}-${_interface}.yaml":
         ensure => absent,
       }
     }
   }
}
