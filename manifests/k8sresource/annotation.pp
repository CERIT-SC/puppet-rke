define rke::k8sresource::annotation (
  String $ensure                            = present,
  Optional[String] $resource_type           = undef,
  Optional[Array]  $annotations             = [],
  Optional[String] $resource_name           = undef,
  String $namespace                         = "",
  Boolean $overwrite                        = false,
  ) {

  if $ensure == present {
    $annotations.each |String $annotation| {
      $splitted = split($annotation, "=") 
      $exe    = "annotate ${resource_type} ${resource_name}"
      if $overwrite {
        $command = "/var/lib/rancher/rke2/bin/kubectl ${exe} --overwrite --namespace=${namespace} ${annotation}"
        exec {"${annotation} ${exe}":
          environment => ['KUBECONFIG=/etc/rancher/rke2/rke2.yaml'],
          command     =>  $command,
        }
      } else {
        $command = "kubectl ${exe} --namespace=${namespace} ${splitted[0]}- > /dev/null ; kubectl ${exe} --namespace=${namespace} ${annotation}"
        exec {"${annotation} ${exe}":
          command     => $command,
          environment => ['KUBECONFIG=/etc/rancher/rke2/rke2.yaml'],
          unless      => "/var/lib/rancher/rke2/bin/kubectl get ${resource_type} ${resource_name} --namespace=${namespace} -o json | jq '.metadata.annotations' | grep -q '\"${splitted[0]}\": \"${splitted[1]}\"'",
        }
      }
    }
  }

  if $ensure == absent {
    $annotations.each |String $annotation| {
      $exe     = "annotate ${resource_type} ${resource_name}"
      $command = "/var/lib/rancher/rke2/bin/kubectl ${exe} --namespace=${namespace}  ${annotation}-"
      exec {"remove ${annotation} ${exe}":
        command     => $command,
        environment => ['KUBECONFIG=/etc/rancher/rke2/rke2.yaml'],
        onlyif      => "/var/lib/rancher/rke2/bin/kubectl get ${resource_type} ${resource_name} --namespace=${namespace} -o json | jq '.metadata.annotations' | grep -q '\"${annotation}\": '"
      }
    }
  }
}
