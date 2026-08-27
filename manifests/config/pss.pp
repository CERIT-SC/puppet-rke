class rke::config::pss (
  Boolean          $enabled      = $rke::params::pss_enabled,
  Optional[Array]  $namespaces   = $rke::psa_privileged_ns,
) inherits rke::params {
  
  if $enabled {
    file{$rke::config::pss_file:
        ensure  => file,
        content => epp('rke/rke2-pss-cerit.yaml', {'psaprivilegedns' => $namespaces}),
        require => Package_versionlock['rke2'],
        mode    => '0600',
    }
  }
}
