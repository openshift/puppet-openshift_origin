class openshift_origin::broker {
  if $::openshift_origin::named_tsig_priv_key == '' {
    warning "Generate the Key file with '/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named ${cloud_domain}'"
    warning "Use the last field in the generated key file /var/named/K${cloud_domain}*.key"
    fail 'named_tsig_priv_key is required.'
  }

  ensure_resource( 'package', 'ruby-devel', {
    ensure   => 'latest',
  })

  ensure_resource( 'package', 'mysql-devel', {
    ensure   => 'latest',
  })

  ensure_resource( 'package', 'mongodb-devel', {
    ensure   => 'latest',
  })

  ensure_resource( 'package', 'openshift-origin-broker', {
    ensure  => present,
    require => Yumrepo[openshift-origin]
  })

  ensure_resource( 'package', 'rubygem-openshift-origin-msg-broker-mcollective', {
    ensure  => present,
    require => Yumrepo[openshift-origin]
  })

  ensure_resource( 'package', 'rubygem-openshift-origin-dns-nsupdate', {
    ensure  => present,
    require => Yumrepo[openshift-origin]
  })

  ensure_resource( 'package', 'rubygem-openshift-origin-dns-bind', {
    ensure  => present,
    require => Yumrepo[openshift-origin]
  })

  ensure_resource( 'package', 'rubygem-openshift-origin-controller', {
    ensure  => present,
    require => Yumrepo[openshift-origin]
  })

  ensure_resource( 'package', 'openshift-origin-broker-util', {
    ensure  => present,
    require => Yumrepo[openshift-origin]
  })

  ensure_resource( 'package', 'rubygem-passenger', {
    ensure  => present,
    require => Yumrepo[openshift-origin-deps] }
  )

  ensure_resource( 'package', 'openssh', {
    ensure  => present,
  })

  ensure_resource( 'package', 'mod_passenger', {
    ensure  => present,
    require => Yumrepo[openshift-origin-deps]
  })

  if $::operatingsystem == "Fedora" {
    ensure_resource( 'package', 'actionmailer', {
      ensure   => '3.2.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'actionpack', {
      ensure   => '3.2.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'activemodel', {
      ensure   => '3.2.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'activerecord', {
      ensure   => '3.2.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'activeresource', {
      ensure   => '3.2.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'activesupport', {
      ensure   => '3.2.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'arel', {
      ensure   => '3.0.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'bigdecimal', {
      ensure   => '1.1.0',
      provider => 'gem',
    })
    ensure_resource( 'package', 'bson', {
      ensure   => '1.8.2',
      provider => 'gem',
      require  => [Package['ruby-devel'],Package['mongodb-devel']]
    })
  
    ensure_resource( 'package', 'bson_ext', {
      ensure   => '1.8.2',
      provider => 'gem',
      require  => [Package['ruby-devel'],Package['mongodb-devel']]
    })
  
    ensure_resource( 'package', 'builder', {
      ensure   => '3.0.4',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'bundler', {
      ensure   => '1.1.4',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'cucumber', {
      ensure   => '1.1.9',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'diff-lcs', {
      ensure   => '1.1.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'dnsruby', {
      ensure   => '1.53',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'erubis', {
      ensure   => '2.7.0',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'gherkin', {
      ensure   => '2.9.3',
      provider => 'gem',
      require  => [Package['ruby-devel']]
    })
  
    ensure_resource( 'package', 'hike', {
      ensure   => '1.2.1',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'i18n', {
      ensure   => '0.6.1',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'journey', {
      ensure   => '1.0.4',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'json', {
      ensure   => '1.7.6',
      provider => 'gem',
      require  => [Package['ruby-devel']]
    })
  
    ensure_resource( 'package', 'mail', {
      ensure   => '2.4.4',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'metaclass', {
      ensure   => '0.0.1',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'mime-types', {
      ensure   => '1.20.1',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'minitest', {
      ensure   => '3.2.0',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'mocha', {
      ensure   => '0.12.1',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'mongo', {
      ensure   => '1.8.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'mongoid', {
      ensure   => '3.0.21',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'moped', {
      ensure   => '1.3.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'multi_json', {
      ensure   => '1.5.0',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'netrc', {
      ensure   => '0.7.1',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'open4', {
      ensure   => '1.3.0',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'origin', {
      ensure   => '1.0.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'parseconfig', {
      ensure   => '0.5.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'polyglot', {
      ensure   => '0.3.3',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'rack', {
      ensure   => '1.4.4',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'rack-cache', {
      ensure   => '1.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'rack-ssl', {
      ensure   => '1.3.3',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'rack-test', {
      ensure   => '0.6.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'rails', {
      ensure   => '3.2.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'railties', {
      ensure   => '3.2.11',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'rake', {
      ensure   => '0.9.2.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'rdoc', {
      ensure   => '3.12',
      provider => 'gem',
    })
    
    ensure_resource( 'package', 'mysql', {
      provider => 'gem',
      require  => [Package['ruby-devel'],Package['mysql-devel']]
    })
  
    ensure_resource( 'package', 'regin', {
      ensure   => '0.3.8',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'rest-client', {
      ensure   => '1.6.7',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'simplecov', {
      ensure   => '0.7.1',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'simplecov-html', {
      ensure   => '0.7.1',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'sprockets', {
      ensure   => '2.2.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'state_machine', {
      ensure   => '1.1.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'stomp', {
      ensure   => '1.2.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'systemu', {
      ensure   => '2.5.2',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'term-ansicolor', {
      ensure   => '1.0.7',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'thor', {
      ensure   => '0.17.0',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'tilt', {
      ensure   => '1.3.3',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'treetop', {
      ensure   => '1.4.12',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'tzinfo', {
      ensure   => '0.3.35',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'xml-simple', {
      ensure   => '1.1.2',
      provider => 'gem',
    })
    
    ensure_resource( 'package', 'webmock', {
      ensure   => '1.9.0',
      provider => 'gem',
    })
  
    ensure_resource( 'package', 'fakefs', {
      ensure   => '0.4.2',
      provider => 'gem',
    })
  }
  
  if $::operatingsystem == "RedHat" {
    ensure_resource( 'package', 'ruby193-rubygem-actionmailer', {
      ensure   => 'latest',
      alias    => 'actionmailer',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-actionpack', {
      ensure   => 'latest',
      alias    => 'actionpack',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-activemodel', {
      ensure   => 'latest',
      alias    => 'activemodel',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-activerecord', {
      ensure   => 'latest',
      alias    => 'activerecord',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-activeresource', {
      ensure   => 'latest',
      alias    => 'activeresource',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-activesupport', {
      ensure   => 'latest',
      alias    => 'activesupport',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-arel', {
      ensure   => 'latest',
      alias    => 'arel',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-bigdecimal', {
      ensure   => 'latest',
      alias    => 'bigdecimal',
    })
    
    ensure_resource( 'package', 'ruby193-rubygem-bson', {
      ensure   => 'latest',
      alias    => 'bson',
      require  => [Package['ruby-devel'],Package['mongodb-devel']]
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-bson_ext', {
      ensure   => 'latest',
      alias    => 'bson_ext',
      require  => [Package['ruby-devel'],Package['mongodb-devel']]
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-builder', {
      ensure   => 'latest',
      alias    => 'builder',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-bundler', {
      ensure   => 'latest',
      alias    => 'bundler',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-cucumber', {
      ensure   => 'latest',
      alias    => 'cucumber',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-diff-lcs', {
      ensure   => 'latest',
      alias    => 'diff-lcs',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-dnsruby', {
      ensure   => 'latest',
      alias    => 'dnsruby',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-erubis', {
      ensure   => 'latest',
      alias    => 'erubis',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-gherkin', {
      ensure   => 'latest',
      alias    => 'gherkin',
      require  => [Package['ruby-devel']]
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-hike', {
      ensure   => 'latest',
      alias    => 'hike',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-i18n', {
      ensure   => 'latest',
      alias    => 'i18n',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-journey', {
      ensure   => 'latest',
      alias    => 'journey',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-json', {
      ensure   => 'latest',
      alias    => 'json',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-mail', {
      ensure   => 'latest',
      alias    => 'mail',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-metaclass', {
      ensure   => 'latest',
      alias    => 'metaclass',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-mime-types', {
      ensure   => 'latest',
      alias    => 'mime-types',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-minitest', {
      ensure   => 'latest',
      alias    => 'minitest',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-mocha', {
      ensure   => 'latest',
      alias    => 'mocha',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-mongo', {
      ensure   => 'latest',
      alias    => 'mongo',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-mongoid', {
      ensure   => 'latest',
      alias    => 'mongoid',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-moped', {
      ensure   => 'latest',
      alias    => 'moped',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-multi_json', {
      ensure   => 'latest',
      alias    => 'multi_json',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-open4', {
      ensure   => 'latest',
      alias    => 'open4',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-origin', {
      ensure   => 'latest',
      alias    => 'origin',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-parseconfig', {
      ensure   => 'latest',
      alias    => 'parseconfig',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-polyglot', {
      ensure   => 'latest',
      alias    => 'polyglot',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-rack', {
      ensure   => 'latest',
      alias    => 'rack',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-rack-cache', {
      ensure   => 'latest',
      alias    => 'rack-cache',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-rack-ssl', {
      ensure   => 'latest',
      alias    => 'rack-ssl',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-rack-test', {
      ensure   => 'latest',
      alias    => 'rack-test',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-rails', {
      ensure   => 'latest',
      alias    => 'rails',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-railties', {
      ensure   => 'latest',
      alias    => 'railties',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-rake', {
      ensure   => 'latest',
      alias    => 'rake',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-rdoc', {
      ensure   => 'latest',
      alias    => 'rdoc',
    })
    
    ensure_resource( 'package', 'ruby193-rubygem-regin', {
      ensure   => 'latest',
      alias    => 'regin',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-rest-client', {
      ensure   => 'latest',
      alias    => 'rest-client',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-simplecov', {
      ensure   => 'latest',
      alias    => 'simplecov',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-simplecov-html', {
      ensure   => 'latest',
      alias    => 'simplecov-html',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-sprockets', {
      ensure   => 'latest',
      alias    => 'sprockets',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-state_machine', {
      ensure   => 'latest',
      alias    => 'state_machine',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-stomp', {
      ensure   => 'latest',
      alias    => 'stomp',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-systemu', {
      ensure   => 'latest',
      alias    => 'systemu',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-term-ansicolor', {
      ensure   => 'latest',
      alias    => 'term-ansicolor',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-thor', {
      ensure   => 'latest',
      alias    => 'thor',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-tilt', {
      ensure   => 'latest',
      alias    => 'tilt',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-treetop', {
      ensure   => 'latest',
      alias    => 'treetop',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-tzinfo', {
      ensure   => 'latest',
      alias    => 'tzinfo',
    })
  
    ensure_resource( 'package', 'ruby193-rubygem-xml-simple', {
      ensure   => 'latest',
      alias    => 'xml-simple',
    })
  }

  if $::openshift_origin::development_mode {
    file { '/etc/openshift/development':
      content => '',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['openshift-origin-broker']
    }
  }

  file { 'openshift broker.conf':
    path    => '/etc/openshift/broker.conf',
    content => template('openshift_origin/broker/broker.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-broker']
  }

  file { 'openshift broker-dev.conf':
    path    => '/etc/openshift/broker-dev.conf',
    content => template('openshift_origin/broker/broker.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-broker']
  }

  file { 'openshift production log':
    path    => '/var/www/openshift/broker/log/production.log',
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    require => Package['openshift-origin-broker']
  }

  if ! defined(File['mcollective client config']) {
    file { 'mcollective client config':
      ensure  => present,
      path    => '/etc/mcollective/client.cfg',
      content => template('openshift_origin/mcollective-client.cfg.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['mcollective'],
    }
  }

  if ! defined(File['mcollective server config']) {
    file { 'mcollective server config':
      ensure  => present,
      path    => '/etc/mcollective/server.cfg',
      content => template('openshift_origin/mcollective-server.cfg.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['mcollective'],
    }
  }
  
  if $::operatingsystem == "Redhat" {
    if ! defined(File['mcollective env']) {
      file { 'mcollective env':
        ensure  => present,
        path    => '/etc/sysconfig/mcollective',
        content => template('openshift_origin/rhel-scl-ruby193-env.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['mcollective'],
      }
    }
  }
  
  if $::openshift_origin::broker_auth_pub_key == '' {
    exec { 'Generate self signed keys for broker auth' :
      command =>
      '/bin/mkdir -p /etc/openshift && \
      /usr/bin/openssl genrsa -out /etc/openshift/server_priv.pem 2048 && \
      /usr/bin/openssl rsa -in /etc/openshift/server_priv.pem -pubout > \
            /etc/openshift/server_pub.pem',
      creates => '/etc/openshift/server_pub.pem'
    }
  }else{
    file { 'broker auth public key':
      ensure  => present,
      path    => '/etc/openshift/server_pub.pem',
      content => source($::openshift_origin::broker_auth_pub_key),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['rubygem-openshift-origin-controller'],
    }

    file { 'broker auth private key':
      ensure  => present,
      path    => '/etc/openshift/server_priv.pem',
      content => source($::openshift_origin::broker_auth_priv_key),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['rubygem-openshift-origin-controller'],
    }
  }

  if $::openshift_origin::broker_rsync_key == '' {
    exec { 'rsync ssh key':
      command => '/usr/bin/ssh-keygen -P "" -t rsa -b 2048 -f /etc/openshift/rsync_id_rsa',
      unless  => '/usr/bin/[ -f /etc/openshift/rsync_id_rsa ]',
      require => [Package['rubygem-openshift-origin-controller'],Package['openshift-origin-broker'],Package['openssh']]
    }
  }else{
    file { 'broker auth private key':
      ensure  => present,
      path    => '/etc/openshift/rsync_id_rsa',
      content => source($::openshift_origin::broker_rsync_key),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['rubygem-openshift-origin-controller'],
    }
  }

  file { 'broker servername config':
    ensure  => present,
    path    =>
      '/etc/httpd/conf.d/000000_openshift_origin_broker_servername.conf',
    content =>
      template('openshift_origin/broker/broker_servername.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['openshift-origin-broker'],
  }

  file { 'mcollective broker plugin config':
    ensure  => present,
    path    =>
      '/etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf',
    content =>
      template('openshift_origin/broker/msg-broker-mcollective.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-msg-broker-mcollective'],
  }

  case $::openshift_origin::broker_auth_plugin {
    'mongo': {
      package { ['rubygem-openshift-origin-auth-mongo']:
        ensure  => present,
        require => Yumrepo[openshift-origin],
      }

      file { 'Auth plugin config':
        ensure  => present,
        path    => '/etc/openshift/plugins.d/openshift-origin-auth-mongo.conf',
        content =>
          template('openshift_origin/broker/plugins/auth/mongo/mongo.conf.plugin.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['rubygem-openshift-origin-msg-broker-mcollective'],
      }
    }
    'basic-auth': {
      package { ['rubygem-openshift-origin-remote-user']:
        ensure  => present,
        require => Yumrepo[openshift-origin],
      }

      file { 'openshift htpasswd':
        path    => '/etc/openshift/htpasswd',
        content =>
          template('openshift_origin/broker/plugins/auth/basic/openshift-htpasswd.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['rubygem-openshift-origin-auth-remote-user']
      }

      file { 'Auth plugin config':
        path    =>
          '/etc/openshift/plugins.d/openshift-origin-auth-remote-user.conf',
        content =>
          template('openshift_origin/broker/plugins/auth/basic/remote-user.conf.plugin.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
          Package['rubygem-openshift-origin-auth-remote-user'],
          File['openshift htpasswd']
        ]
      }
    }
    default: {
      fail "Unknown Auth plugin ${::openshift_origin::broker_auth_plugin}"
    }
  }

  file { 'plugin openshift-origin-dns-nsupdate.conf':
    path    => '/etc/openshift/plugins.d/openshift-origin-dns-nsupdate.conf',
    content => template('openshift_origin/broker/plugins/dns/nsupdate/nsupdate.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-dns-nsupdate']
  }

  $broker_bundle_show = $::operatingsystem  ? {
    "Fedora"  => '/usr/bin/bundle show',
    default   => '/usr/bin/scl enable ruby193 "bundle show"',
  }

  exec { 'Broker gem dependencies' :
    cwd         => '/var/www/openshift/broker/',
    command     => "${::openshift_origin::rm} -f Gemfile.lock && \
    ${broker_bundle_show} && \
    ${::openshift_origin::chown} apache:apache Gemfile.lock && \
    ${::openshift_origin::rm} -rf tmp/cache/*",
    unless      => "/usr/bin/bundle show",
    require     => [
      Package['openshift-origin-broker'],
      Package['rubygem-openshift-origin-controller'],
      File['openshift broker.conf'],
      File['mcollective broker plugin config'],
      File['Auth plugin config'],
      Package['actionmailer'],
      Package['actionpack'],
      Package['activemodel'],
      Package['activerecord'],
      Package['activeresource'],
      Package['activesupport'],
      Package['arel'],
      Package['bigdecimal'],
      Package['bson'],
      Package['bson_ext'],
      Package['builder'],
      Package['bundler'],
      Package['cucumber'],
      Package['diff-lcs'],
      Package['dnsruby'],
      Package['erubis'],
      Package['gherkin'],
      Package['hike'],
      Package['i18n'],
      Package['journey'],
      Package['json'],
      Package['mail'],
      Package['metaclass'],
      Package['mime-types'],
      Package['minitest'],
      Package['mocha'],
      Package['mongo'],
      Package['mongoid'],
      Package['moped'],
      Package['multi_json'],
      Package['open4'],
      Package['origin'],
      Package['parseconfig'],
      Package['polyglot'],
      Package['rack'],
      Package['rack-cache'],
      Package['rack-ssl'],
      Package['rack-test'],
      Package['rails'],
      Package['railties'],
      Package['rake'],
      Package['rdoc'],
      Package['regin'],
      Package['rest-client'],
      Package['simplecov'],
      Package['simplecov-html'],
      Package['sprockets'],
      Package['state_machine'],
      Package['stomp'],
      Package['systemu'],
      Package['term-ansicolor'],
      Package['thor'],
      Package['tilt'],
      Package['treetop'],
      Package['tzinfo'],
      Package['xml-simple'],
    ]
  }

  exec { 'fixfiles rubygem-passenger':
    command     => '/sbin/fixfiles -R rubygem-passenger restore && \
      /sbin/fixfiles -R mod_passenger restore',
    subscribe   => Package['rubygem-passenger'],
    refreshonly => true
  }

  ensure_resource( 'selboolean', 'httpd_run_stickshift', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_verify_dns', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'allow_ypbind', {
    persistent => true,
    value => 'on'
  })

  if $::openshift_origin::enable_network_services == true {
    service { 'openshift-broker':
      require => [
        Package['openshift-origin-broker']
      ],
      enable  => true,
    }
  }else{
    warning 'Please ensure that openshift-broker service is enable on broker machines'
  }
}
