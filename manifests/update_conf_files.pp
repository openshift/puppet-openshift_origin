class openshift_origin::update_conf_files {
  file { 'network-scripts':
    ensure  => present,
    path    => "/etc/sysconfig/network-scripts/ifcfg-${::openshift_origin::conf_node_external_eth_dev}",
    content => template('openshift_origin/sysconfig_conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { 'dhcpclient':
    ensure  => present,
    path    => "/etc/dhcp/dhclient-${::openshift_origin::conf_node_external_eth_dev}.conf",
    content => template('openshift_origin/dhclient_conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/resolv.conf':
    ensure  => present,
    path    => '/etc/resolv.conf',
    content => template('openshift_origin/resolv_conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
