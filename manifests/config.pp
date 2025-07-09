class rke::config (
   Optional[String]  $pss_file              = $rke::params::pss_file,
   Optional[String]  $audit_file            = $rke::params::audit_file,
   Optional[String]  $audit_log_file        = $rke::params::auditlogfile,
   Optional[Integer] $grace_period          = $rke::params::graceperiod,
   Optional[Integer] $grace_period_critical = $rke::params::graceperiodcritical,
   Optional[Boolean] $k8s_preboot           = $rke::params::k8spreboot,
   Optional[String]  $kubelet_config_file   = $rke::params::kubeletconfigfile,
   Optional[String]  $dns_secret            = $rke::params::dnssecret,
) inherits rke::params {

   contain rke::config::registries
   contain rke::config::proxyenv
   if $rke::node_type =~ /controlplane/ {
     contain rke::config::pss
     contain rke::config::audit
   }
   contain rke::config::boot
   contain rke::config::main
}
