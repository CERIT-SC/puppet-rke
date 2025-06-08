class rke::addon::helmupdate (
) {
    contain helm

    if $helm::proxy {
      $_env = ["HTTPS_PROXY=${helm::proxy}"]
    } else {
      $_env = undef
    }

    helm::repo_update {"all":
        update            => true,
        path              => ['/usr/local/bin', '/usr/bin', '/bin'],
        env               => $_env,
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
    }
}
