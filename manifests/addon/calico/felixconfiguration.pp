define rke::addon::calico::felixconfiguration (
  Optional[String] $ipv4 = undef,
  Optional[String] $ipv6 = undef,
) {
  $_manifest = regsubst("calico-felixconfiguration-${name}", '\.', '-', 'G')

  file { "/var/lib/rancher/rke2/server/manifests/calico/${_manifest}.yaml":
    ensure  => file,
    mode    => '0600',
    content => epp('rke/calico-felixconfiguration.yaml.epp', { 'hostname' => $name, 'ipv4' => $ipv4, 'ipv6' => $ipv6 }),
  }
}
