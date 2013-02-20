class openshift_origin::console {
  ensure_resource( 'package', 'rubygem-openshift-origin-console', {
    ensure  => present,
    require => Yumrepo[openshift-origin]
  })

  ensure_resource( 'package', 'openshift-origin-console', {
    ensure  => present,
    require => Yumrepo[openshift-origin]
  })

  file { 'openshift console.conf':
    path    => '/etc/openshift/console.conf',
    content => template('openshift_origin/console/console.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-console']
  }
  
  $console_asset_rake_cmd = $::operatingsystem ? {
    'Fedora' => '/usr/bin/rake assets:precompile',
    default  => '/usr/bin/scl enable ruby193 "rake assets:precompile"',
  }
  
  $console_bundle_show = $::operatingsystem  ? {
    "Fedora"  => '/usr/bin/bundle install',
    default   => '/usr/bin/scl enable ruby193 "bundle show"',
  }
  
  exec { 'Console gem dependencies' :
    cwd         => '/var/www/openshift/console/',
    command     => "${::openshift_origin::rm} -f Gemfile.lock && \
    ${console_bundle_show} && \
    ${::openshift_origin::chown} apache:apache Gemfile.lock && \
    ${::openshift_origin::rm} -rf tmp/cache/* && \
    ${console_asset_rake_cmd} && \
    ${::openshift_origin::chown} -R apache:apache /var/www/openshift/console",
    subscribe   => [
      Package['openshift-origin-console'],
      Package['rubygem-openshift-origin-console'],
      File['openshift console.conf'],
    ],
    refreshonly => true
  }

  ensure_resource( 'selboolean', 'httpd_can_network_connect', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_can_network_relay', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_read_user_content', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_enable_homedirs', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_execmem', {
    persistent => true,
    value => 'on'
  })

  if $::openshift_origin::enable_network_services == true {
    service { 'openshift-console':
      require => [
        Package['openshift-origin-console']
      ],
      enable  => true,
    }
  }else{
    warning 'Please ensure that openshift-console service is enable on console machines'
  }
}
