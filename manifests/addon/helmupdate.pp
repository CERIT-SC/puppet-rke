class rke::addon::helmupdate (
) {
    contain helm

    helm::repo_update {"all":
        update            => true,
        path              => ['/usr/local/bin', '/usr/bin', '/bin'],
        repository_config => '/root/.config/helm/repositories.yaml',
        repository_cache  => '/root/.cache/helm/repository',
    }
}
