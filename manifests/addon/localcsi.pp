class rke::addon::localcsi (
  String  $version              = $rke::params::localcsi_version,
  String  $namespace            = $rke::params::localcsi_namespace,
  String  $localdir             = $rke::params::localcsi_localdir,
  String  $classname            = $rke::params::localcsi_classname,
  Boolean $classdefault         = $rke::params::localcsi_classdefault,
) inherits rke::params {
   
    contain helm

    $_path = ['/sbin','/bin','/usr/sbin','/usr/bin']
   
    helm::repo { 'sig-storage-local-static-provisioner':
        ensure            => present,
        path              => $_path,
        repo_name         => 'sig-storage-local-static-provisioner',
        env               => $helm::env,
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        url               => 'https://kubernetes-sigs.github.io/sig-storage-local-static-provisioner',
    }

    file{'/var/lib/rancher/rke2/server/values/localcsi-values.yaml':
        ensure  => file,
        content => epp('rke/localcsivalues.yaml', {'name'     => $classname,
                                                     'localdir' => $localdir,
                                                     'default'  => $classdefault}),
        mode    => '0600',
    }

    helm::chart {'local-static-provisioner':
        ensure            => present,
        chart             => 'sig-storage-local-static-provisioner/local-static-provisioner',
        namespace         => $namespace,
        path              => $_path,
        release_name      => 'local-static-provisioner',
        env               => $helm::env,
        version           => $version,
        values            => ["/var/lib/rancher/rke2/server/values/localcsi-values.yaml"],
        wait              => true,              ### wait until all pods are ready
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        require           =>  [Helm::Repo['sig-storage-local-static-provisioner'], File['/var/lib/rancher/rke2/server/values/localcsi-values.yaml']], 
    }
}
