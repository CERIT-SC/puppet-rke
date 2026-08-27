define rke::addon::calico::hostendpoint (
  Boolean        $enable       = true,
  Array          $interfaces,
  Optional[Hash] $int_labels   = undef,
) {
   if $enable {
     $interfaces.each |$_interface| {
       if $int_labels and $int_labels[$_interface] != undef {
         $_labels = $int_labels[$_interface]
       } else {
         $_labels = undef  
       }
       $_manifest = regsubst("calico-hep-${name}-${_interface}", '\.', '-', 'G')
       file{"/var/lib/rancher/rke2/server/manifests/calico/${_manifest}.yaml":
         ensure => file,
         content  => epp('rke/calico-hostendpoint.yaml', 'interface' => $_interface, 'hostname' => $name, 'labels' => $_labels),
       }
       file{"/var/lib/rancher/rke2/server/manifests/calico/calico-hostendpoint-${name}-${_interface}.yaml":
         ensure => absent,
       }
     }
   }
}
