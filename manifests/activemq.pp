class openshift_origin::activemq{
  ensure_resource( 'package', 'activemq', {
      ensure  => latest,
      require => Yumrepo[openshift-origin-deps],
    }
  )

  ensure_resource( 'package', 'activemq-client',
    {
      ensure  => present,
      require => Yumrepo[openshift-origin-deps],
    }
  )

  case $::operatingsystem {
    'Fedora' : {
      file { '/etc/tmpfiles.d/activemq.conf':
        path    => '/etc/tmpfiles.d/activemq.conf',
        content => template('openshift_origin/activemq/tmp-activemq.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        require => Package['activemq'],
      }
    }
    default : {
    }
  }
  
  file { '/var/run/activemq/':
    ensure => 'directory',
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0750',
    require => Package['activemq'],
  }

  file { 'activemq.xml config':
    path    => '/etc/activemq/activemq.xml',
    content => template('openshift_origin/activemq/activemq.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Package['activemq'],
  }

  file { 'jetty.xml config':
    path    => '/etc/activemq/jetty.xml',
    content => template('openshift_origin/activemq/jetty.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Package['activemq'],
  }

  file { 'jetty-realm.properties config':
    path    => '/etc/activemq/jetty-realm.properties',
    content => template('openshift_origin/activemq/jetty-realm.properties.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Package['activemq'],
  }

  if $::openshift_origin::enable_network_services == true {
    ensure_resource( 'service', 'activemq', {
      require    => [
        File['activemq.xml config'],
        File['jetty.xml config'],
        File['jetty-realm.properties config'],
      ],
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
    })
  }
  
  if $::openshift_origin::configure_firewall == true {
    exec { 'Open port for ActiveMQ':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-port=61616/tcp",
        default => "/usr/sbin/lokkit --port=61616:tcp",
      },
      require => Package['firewall-package']
    }
  }
}
