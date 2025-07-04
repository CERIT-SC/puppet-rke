define rke::k8sresource::namespace (
  String $ensure              = present,
  Optional[String] $namespace = undef,
){
  if $ensure == present {
    $exe          = "create namespace ${namespace}"
    $command      = "/var/lib/rancher/rke2/bin/kubectl ${exe}" 
    $unless       = "/var/lib/rancher/rke2/bin/kubectl get namespace | grep -q ${namespace}"
  }

  # absent

  exec { $exe:
    environment => ['KUBECONFIG=/etc/rancher/rke2/rke2.yaml'],
    command     => $command,
    unless      => $unless,
  }
}
