class rke::config::registries (
  Boolean $enabled = $rke::params::rke2_registries_enabled, 
  String  $file    = $rke::params::rke2_registries,
) inherits rke::params {

  if $enabled and $rke::registries and $rke::reg_dockermirror {
    if $rke::reg_custommirror {
       $_custommirror = regsubst(to_yaml($rke::reg_custommirror, {indentation => 4}), '^---\n', '', 'M')
    } else {
       $_custommirror = undef
    }
    file{$file:
        ensure    => file,
        show_diff => false,
        mode      => '0600',
        content   => epp('rke/registries.yaml', { 'registries' => $rke::registries, 'dockermirror' => $rke::reg_dockermirror, 'custommirror' => $_custommirror }),
        require   => Package_versionlock['rke2'],
    }
  }
}
