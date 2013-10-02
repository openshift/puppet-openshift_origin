class openshift_origin::update_resolv_conf {
  augeas { 'network-scripts':
    context => "/files/etc/sysconfig/network-scripts/ifcfg-${::openshift_origin::conf_node_external_eth_dev}",
    changes => [
      'set PEERDNS no',
      "set DNS1 ${::openshift_origin::named_ip_addr}",
    ],
  }
  
  file { '/etc/resolv.conf':
    content => "search ${::openshift_origin::domain}\nnameserver ${::openshift_origin::named_ip_addr}"
  }
}