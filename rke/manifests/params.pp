class rke::params {
  $addpackages        = []

  $audit_enabled      = true
  $audit_file         = '/etc/rancher/rke2/audit-policy.yaml'
  $auditlogfile       = '/var/log/kube-audit/audit.log'
  $audit_level        = 'Metadata'
  $autostart          = false

  $certman_version        = undef
  $certman_nameservers    = undef
  $certman_namespace      = 'cert-manager'
  $certman_clusterissuers = undef
 
  $cilium_enabled               = true 
  $cilium_autodirectnoderouters = true
  $cilium_routingmode           = 'native'
  $cilium_l2announcements       = true
  $cilium_bgpcontrolplane       = true
  $cilium_externalips           = true
  $cilium_ipv4cidr              = undef
  $cilium_ipv6cidr              = undef
  $cilium_cniexclusive          = true
  $cilium_proxyreplacement      = true
  $cilium_lbpoolname            = undef
  $cilium_lbcidrs               = undef
  $cilium_bgpadvtype            = 'Service'
  $cilium_bgpaddresses          = ['LoadBalancerIP']
  $cilium_localasn              = undef
  $cilium_bgppeers              = undef
  $cilium_bgpfamilies           = undef
  $cilium_hostfirewall          = undef
 
  $cis_enable         = true
  $cis_kubeconfigs    = ['/var/lib/rancher/rke2/server/cred/admin.kubeconfig',
                         '/var/lib/rancher/rke2/server/cred/scheduler.kubeconfig',
                         '/var/lib/rancher/rke2/server/cred/controller.kubeconfig',
                         '/var/lib/rancher/rke2/agent/kubeproxy.kubeconfig',
                         '/var/lib/rancher/rke2/agent/etc/kubelet.config',
                         '/var/lib/rancher/rke2/agent/kubelet.kubeconfig',
                         '/var/lib/rancher/rke2/server/tls/client-admin.crt',
                         '/var/lib/rancher/rke2/server/tls/client-auth-proxy.crt',
                         '/var/lib/rancher/rke2/server/tls/client-ca.crt',
                         '/var/lib/rancher/rke2/server/tls/client-ca.nochain.crt',
                         '/var/lib/rancher/rke2/server/tls/client-controller.crt',
                         '/var/lib/rancher/rke2/server/tls/client-kube-apiserver.crt',
                         '/var/lib/rancher/rke2/server/tls/client-kube-proxy.crt',
                         '/var/lib/rancher/rke2/server/tls/client-rke2-cloud-controller.crt',
                         '/var/lib/rancher/rke2/server/tls/client-rke2-controller.crt',
                         '/var/lib/rancher/rke2/server/tls/client-scheduler.crt',
                         '/var/lib/rancher/rke2/server/tls/client-supervisor.crt',
                         '/var/lib/rancher/rke2/server/tls/request-header-ca.crt',
                         '/var/lib/rancher/rke2/server/tls/server-ca.crt',
                         '/var/lib/rancher/rke2/server/tls/server-ca.nochain.crt',
                         '/var/lib/rancher/rke2/server/tls/serving-kube-apiserver.crt',
                        ]
  $cisprofile         = 'cis'

  $cni                = 'calico'

  $clustercidr        = '10.42.0.0/16'
  $servicecidr        = '10.43.0.0/16'
  $nodev6cidr         = undef

  $controlplanerequests = false

  $localcsi_version      = '2.0.0'
  $localcsi_namespace    = 'csi-storage'
  $localcsi_localdir     = undef
  $localcsi_classname    = undef
  $localcsi_classdefault = true

  $disablekubeproxy   = false

  $dnssecret          = undef
 
  case $facts['os']['name'] {
    'Ubuntu': {
      $disableubuntu  = true
    }
    default: {
      $disableubuntu  = false
    }
  }

  $etcduser           = true

  $etcds3accesskey    = undef
  $etcds3secretkey    = undef
  $etcds3endpoint     = undef
  $etcds3path         = undef

  $graceperiod         = 30
  $graceperiodcritical = 20

  $http_proxy         = undef
  $no_proxy           = undef

  $internalingress    = true

  $k8spreboot         = true

  $controllergates    = 'InPlacePodVerticalScaling=true'
  $kubeletgates       = 'InPlacePodVerticalScaling=true'
  $kubeapigates       = 'InPlacePodVerticalScaling=true'
  $schedulergates     = 'InPlacePodVerticalScaling=true'

  $kubeapiburst       = 100
  $kubeapiqps         = 100
  $kubeletargs        = undef
  $kubeletconfigfile  = '/var/lib/rancher/rke2/agent/etc/kubelet.config'

  $kubevip_iface         = undef
  $kubevip_ip            = undef
  $kubevip_cidr          = undef
  $kubevip_nodeselector  = undef
  $kubevip_image_version = undef

  $nodelabels         = undef
  $nodemaxpods        = undef
  $nodetype           = undef

  $nodeipauto         = true
  $nodeiface          = undef
  $nodeiface6         = undef
  $nodetaint          = undef
 
  $prebootenabled     = true

  $priority           = '-10'
  $priority_processes = ['kubelet', 'kube-controller-manager', 'kube-apiserver', 'kube-proxy', 'etcd']

  $proxyenv_enabled   = true

  $pss_enabled        = true
  $pss_file           = '/etc/rancher/rke2/rke2-pss-cerit.yaml'
  $psa_privileged_ns  = ['cattle-system', 
                         'cattle-fleet-system', 
                         'cattle-monitoring-system',
                         'cattle-logging-system',
                         'cattle-fleet-local-system',
                         'fleet-default',
                         'fleet-local',
                         'kube-node-lease',
                         'kube-public']

  $registries         = undef
  $reg_custommirror   = undef 
  $reg_dockermirror   = undef

  $rke2_config        = '/etc/rancher/rke2/config.yaml'

  $rke2_registries_enabled = true
  $rke2_registries         = '/etc/rancher/rke2/registries.yaml'

  $rke2_version       = '1.32.3+rke2r1'

  $rkeingress_enabled             = true
  $rkeingress_ipv4                = undef
  $rkeingress_ipv6                = undef
  $rkeingress_ipannotation        = 'metallb.universe.tf/loadBalancerIPs'
  $rkeingress_externaltraffic     = 'Local'
  $rkeingress_cpu                 = '2'
  $rkeingress_memory              = '2200Mi'
  $rkeingress_externalname        = undef
  $rkeingress_maxreplicas         = undef
  $rkeingress_openstacktimeout    = undef
  $rkeingress_defaultclass        = true
  $rkeingress_proxytimeout        = 1200
  $rkeingress_customerrors        = [500, 503]
  $rkeingress_workertimeout       = 7200
  $rkeingress_defaultbackend      = true
  $rkeingress_defaultbackendimage = undef
  $rkeingress_defaultbackendtag   = undef
  
  $schedulerextenders = undef
  $schedulerpolicy    = undef
  $schedulerprofiles  = undef

  $setenv_enabled     = true

  $serveraddr         = undef 
  
  $staticcpupolicy    = undef
  $staticreservedcpus = undef

  $tlssecurity        = true
}
