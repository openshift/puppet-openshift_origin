class openshift_origin::qpidd {
  ensure_resource( 'package', 'qpid-cpp-server', { ensure  => present } )
  ensure_resource( 'package', 'mcollective-qpid-plugin', { ensure  => present } )

  file { '/etc/qpidd.conf':
    content => template('openshift/qpid/qpidd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['qpid-cpp-server'],
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'qpidd':
      require   => File['/etc/qpidd.conf'],
      enable    => true,
    }
  }

  if $::openshift_origin::configure_firewall == true {
    exec { 'Open port for Qpid':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-port=5672/tcp",
        default => "/usr/sbin/lokkit --port=5672:tcp",
      },
      require => Package['firewall-package']
    }
  }
}
