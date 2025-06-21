class rke::addon::calico::hostendpoints (
  Array   $interfaces,
) {
  contain rke

  @@rke::addon::calico::hostendpoint{ $facts['networking']['fqdn']:
    interfaces => $interfaces,
    tag        => $rke::server_addr,
  }
}
