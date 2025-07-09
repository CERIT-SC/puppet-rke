class rke (
  Boolean                 $auto_start              = $rke::params::autostart,
  Boolean                 $auditlog_enable         = $rke::params::audit_enabled,
  Optional[String]        $cis_profile             = $rke::params::cisprofile,
  String                  $cni                     = $rke::params::cni,
  String                  $cluster_cidr            = $rke::params::clustercidr,
  Optional[String]        $controller_gates        = $rke::params::controllergates,
  Variant[Boolean,String] $controlplane_requests   = $rke::params::controlplanerequests,
  Boolean                 $disable_kubeproxy       = $rke::params::disablekubeproxy,
  Optional[String]        $etcd_s3_accesskey       = $rke::params::etcds3accesskey,
  Optional[String]        $etcd_s3_secretkey       = $rke::params::etcds3secretkey,
  Optional[String]        $etcd_s3_endpoint        = $rke::params::etcds3endpoint,
  Optional[String]        $etcd_s3_path            = $rke::params::etcds3path,
  Optional[Integer]       $etcd_quota_backend      = $rke::params::etcdquotabackend,
  Boolean                 $internal_ingress        = $rke::params::internalingress,
  Optional[String]        $kubelet_gates           = $rke::params::kubeletgates,
  Optional[Integer]       $kubeapi_burst           = $rke::params::kubeapiburst,
  Optional[Integer]       $kubeapi_qps             = $rke::params::kubeapiqps,
  Optional[String]        $kubeapi_gates           = $rke::params::kubeapigates,
  Optional[Array]         $kubelet_args            = $rke::params::kubeletargs,
  Optional[Hash]          $node_labels             = $rke::params::nodelabels,          
  String                  $node_type               = $rke::params::nodetype,
  Optional[Integer]       $nodev6_cidr             = $rke::params::nodev6cidr,
  Optional[String]        $http_proxy              = $rke::params::http_proxy,
  Optional[String]        $no_proxy                = $rke::params::no_proxy,
  Optional[Boolean]       $node_ip_auto            = $rke::params::nodeipauto,
  Optional[String]        $node_ip_skip_mask       = $rke::params::nodeipskipmask,
  Optional[String]        $node_iface              = $rke::params::nodeiface,
  Optional[String]        $node_iface6             = $rke::params::nodeiface6,
  Optional[Integer]       $node_max_pods           = $rke::params::nodemaxpods,
  Optional[String]        $node_taint              = $rke::params::nodetaint,
  Optional[Array]         $psa_privileged_ns       = $rke::params::psa_privileged_ns,
  Optional[String]        $reg_dockermirror        = $rke::params::reg_dockermirror,
  Optional[Hash]          $reg_custommirror        = $rke::params::reg_custommirror,
  Hash                    $registries              = $rke::params::registries,
  Optional[String]        $scheduler_gates         = $rke::params::schedulergates,
  Optional[Array]         $scheduler_extenders     = $rke::params::schedulerextenders,
  Optional[String]        $scheduler_policy        = $rke::params::schedulerpolicy,
  Optional[Array]         $scheduler_profiles      = $rke::params::schedulerprofiles,
  String                  $service_cidr            = $rke::params::servicecidr,
  String                  $server_addr             = $rke::params::serveraddr,
  Optional[String]        $static_cpu_policy       = $rke::params::staticcpupolicy,
  Optional[String]        $static_reserved_cpus    = $rke::params::staticreservedcpus,
  Boolean                 $tls_security            = $rke::params::tlssecurity,
  Boolean                 $controlnode             = $rke::params::controlnode,
) inherits rke::params {
  
  contain rke::install
  contain rke::config
  contain rke::priority
  contain rke::cishardening  

  if $facts['rke2token']  {
     @@rke::token{$facts['networking']['fqdn']:
          clustertoken => $facts['rke2token'],
          tag          => $server_addr,
     }
  }

}
