class rke::addon::democratic_csi (
  String           $namespace                = $rke::params::csi_namespace,
  Boolean          $create_csi_namespace     = $rke::params::csi_create_namespace,
  Optional[Array]  $democratic_manual_values = $rke::params::democratic_manual_values,
) inherits rke::params {
   
    contain rke
    contain helm

    if $create_csi_namespace and !defined(Rke::K8sresource::Namespace[$namespace]) {
       rke::k8sresource::namespace {$namespace:
          namespace => $namespace,
       }
    }

    $_path = ['/sbin','/bin','/usr/sbin','/usr/bin']

    if $helm::proxy {
      $_env = ["HTTPS_PROXY=${helm::proxy}"]
    } else {
      $_env = undef
    }

    helm::repo { "democratic":
        ensure            => present,
        path              => ['/sbin','/bin','/usr/sbin','/usr/bin','/opt/puppetlabs/bin'],
        env               => $_env,
        repo_name         => 'democratic-csi',
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        url               => 'https://democratic-csi.github.io/charts/',
        require           => Rke::K8sresource::Namespace[$namespace],
    }

    if $democratic_manual_values {
      helm::chart {"democratic-manual":
        ensure            => present,
        chart             => 'democratic-csi/democratic-csi',
        namespace         => $namespace,
        env               => $_env,
        path              => $_path,
        release_name      => 'democratic-manual',
        set               => $democratic_manual_values,
        wait              => true,              ### wait until all pods are ready
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
        require           =>  Helm::Repo["democratic"],
      }
    }
   
}
