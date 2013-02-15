class openshift_origin::broker {
  if $::openshift_origin::named_tsig_priv_key == '' {
    warning "Generate the Key file with '/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named ${cloud_domain}'"
    warning "Use the last field in the generated key file /var/named/K${cloud_domain}*.key"
    fail 'named_tsig_priv_key is required.'
  }

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
  # TODO: is this correct?
  ensure_resource( 'package', 'freeipa-client', {
    ensure  => present,
    # require => Yumrepo[freeipa-client]
    })

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
    # TODO: configure IPA/Kerberos Auth
    # TODO: separately, install ipa-client?
    'ipa': {
      package { ['freeipa-client']:
        ensure  => present, # or installed?
        require => Yumrepo[freeipa-client]
      }
      package { ['rubygem-openshift-origin-auth-remote-user']:
        ensure  => present,
        require => Yumrepo[openshift-origin]
      }
      if ! $::openshift_origin::ipa_client_install { 
      # TODO: must turn off NetworkManager (is this already done?)
      # and config dhcp correctly for nameserver to resolve to IPA Server
      # use full paths to commands, eg /usr/bin/
        exec { 'install ipa-client'
          command =>
          'service NetworkManager stop && service NetworkManager disable &&
          ipa-client-install --setup-dns --domain=${IPA_DOMAIN} --server=${IPA_SERVER} -U \
          && kinit admin -p ${IPA_PASSWORD}'
        }
        exec { 'enroll ipa-client host'
          command =>
            'ipa service-add HTTP/${FQDN}@${REALM} &&\
            ipa-getkeytab -s ${IPA_SERVER} -p HTTP/${FQDN} \
            -k /var/www/openshift/broker/httpd/conf.d/httpd.keytab',
          creates => '/var/www/openshift/broker/httpd/conf.d/httpd.keytab'

        }
      }else{
        file { 'ipa service keytab':
          ensure  => present,
          path    => '/var/www/openshift/httpd/conf.d/httpd.keytab'
          content => source($::openshift_origin::ipa_service_keytab),
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          require => Package['freeipa-client']

        }
      }
      # TODO: is this needed with the above?
      file {'kerberos keytab':
        path    => '/var/www/openshift/broker/httpd/conf.d/httpd.keytab', # TODO: make sure correct location
        content => source($::openshift_origin::ipa_service_keytab), # TODO: probably have to exec ipa service-add
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['freeipa-client']
    }
      file {'openshift kerberos':
        path    => 
          '/var/www/openshift/broker/httpd/conf.d/openshift-origin-auth-remote-user-kerberos.conf',
        content => 
          template('openshift_origin/broker/plugin/auth/kerberos/kerberos.conf.plugin.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
          Package['rubygem-openshift-origin-auth-remote-user'], # do I need this?
          File['kerberos keytab']
        ]
    }
      file {'Auth plugin config':
        path    => '/etc/openshift/plugins.d/openshift-origin-auth-remote-user.conf',
        content => 
          template('openshift_origin/broker/plugin/auth/basic/remote-user.conf.plugin.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
          Package['rubygem-openshift-origin-auth-remote-user'],
          File['openshift kerberos']
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

  exec { 'Broker gem dependencies' :
    cwd         => '/var/www/openshift/broker/',
    command     => '/usr/bin/rm -f Gemfile.lock && \
    /usr/bin/bundle install && \
    /usr/bin/chown apache:apache Gemfile.lock && \
    /usr/bin/rm -rf tmp/cache/*',
    subscribe   => [
      Package['openshift-origin-broker'],
      Package['rubygem-openshift-origin-controller'],
      File['openshift broker.conf'],
      File['mcollective broker plugin config'],
      File['Auth plugin config'],
    ],
    refreshonly => true
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
