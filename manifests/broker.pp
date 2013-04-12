# == Class: openshift_origin::broker
#
# Manage the OpenShift Origin broker.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::broker
#
# === Copyright
#
# Copyright 2013 Mojo Lingo LLC.
# Copyright 2013 Red Hat, Inc.
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class openshift_origin::broker {
  ensure_resource('package', 'mysql-devel', {
      ensure => 'latest',
    }
  )

  ensure_resource('package', 'mongodb-devel', {
      ensure => 'latest',
    }
  )

  ensure_resource('package', 'openshift-origin-broker', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'rubygem-openshift-origin-msg-broker-mcollective', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'rubygem-openshift-origin-dns-nsupdate', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  if($::operatingsystem == 'Fedora') {
    ensure_resource('package', 'rubygem-openshift-origin-dns-avahi', {
        ensure  => present,
        require => Yumrepo[openshift-origin],
      }
    )
  }

  ensure_resource('package', 'rubygem-openshift-origin-dns-bind', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'rubygem-openshift-origin-controller', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-broker-util', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'rubygem-passenger', {
      ensure  => present,
      require => Yumrepo[openshift-origin-deps],
    }
  )

  ensure_resource('package', 'openssh', {
      ensure => present,
    }
  )

  ensure_resource('package', 'mod_passenger', {
      ensure  => present,
      require => Yumrepo[openshift-origin-deps],
    }
  )

  if $::operatingsystem == 'Fedora' {
  
    ensure_resource('package', 'mysql', {
        provider => 'gem',
        require  => [Package['ruby-devel'], Package['mysql-devel']]
      }
    )
    
    ensure_resource('package', 'mongoid', {
        ensure   => '3.0.21',
        provider => 'gem',
      }
    )

    ensure_resource('package', 'moped', {
        ensure   => '1.3.2',
        provider => 'gem',
      }
    )
    
    ensure_resource('package', 'origin', {
        ensure   => '1.0.11',
        provider => 'gem',
      }
    )

    ensure_resource('package', 'minitest', {
        ensure   => '3.2.0',
        provider => 'gem',
        alias    => 'minitest'
      }
    )
  
    ensure_resource('package', 'rubygem-actionmailer', {
        ensure   => 'latest',
        alias    => 'actionmailer',
      }
    )
    
    ensure_resource('package', 'rubygem-actionpack', {
        ensure   => 'latest',
        alias    => 'actionpack',
      }
    )

    ensure_resource('package', 'rubygem-activemodel', {
        ensure   => 'latest',
        alias    => 'activemodel'
      }
    )
    
    ensure_resource('package', 'rubygem-activerecord', {
        ensure   => 'latest',
        alias    => 'activerecord'
      }
    )

    ensure_resource('package', 'rubygem-activeresource', {
        ensure   => 'latest',
        alias    => 'activeresource'
      }
    )

    ensure_resource('package', 'rubygem-activesupport', {
        ensure   => 'latest',
        alias    => 'activesupport'
      }
    )
    
    ensure_resource('package', 'rubygem-arel', {
        ensure   => 'latest',
        alias    => 'arel'
      }
    )

    ensure_resource('package', 'rubygem-bigdecimal', {
        ensure   => 'latest',
        alias    => 'bigdecimal'
      }
    )

    ensure_resource('package', 'rubygem-bson', {
        ensure   => 'latest',
        alias    => 'bson',
        require  => [
          Package['ruby-devel'],
          Package['mongodb-devel'],
        ],
      }
    )
    
    ensure_resource('package', 'rubygem-bson_ext', {
        ensure   => 'latest',
        alias    => 'bson_ext'
      }
    )

    ensure_resource('package', 'rubygem-builder', {
        ensure   => 'latest',
        alias    => 'builder'
      }
    )
    
    ensure_resource('package', 'rubygem-bundler', {
        ensure   => 'latest',
        alias    => 'bundler'
      }
    )

    ensure_resource('package', 'rubygem-cucumber', {
        ensure   => 'latest',
        alias    => 'cucumber'
      }
    )
    
    ensure_resource('package', 'rubygem-diff-lcs', {
        ensure   => 'latest',
        alias    => 'diff-lcs'
      }
    )

    ensure_resource('package', 'rubygem-dnsruby', {
        ensure   => 'latest',
        alias    => 'dnsruby'
      }
    )
    
    ensure_resource('package', 'rubygem-erubis', {
        ensure   => 'latest',
        alias    => 'erubis'
      }
    )

    ensure_resource('package', 'rubygem-gherkin', {
        ensure   => 'latest',
        alias    => 'gherkin'
      }
    )

    ensure_resource('package', 'rubygem-hike', {
        ensure   => 'latest',
        alias    => 'hike'
      }
    )
    
    ensure_resource('package', 'rubygem-i18n', {
        ensure   => 'latest',
        alias    => 'i18n'
      }
    )

    ensure_resource('package', 'rubygem-journey', {
        ensure   => 'latest',
        alias    => 'journey'
      }
    )
    
    ensure_resource('package', 'rubygem-json', {
        ensure   => 'latest',
        alias    => 'json'
      }
    )

    ensure_resource('package', 'rubygem-mail', {
        ensure   => 'latest',
        alias    => 'mail'
      }
    )
    
    ensure_resource('package', 'rubygem-metaclass', {
        ensure   => 'latest',
        alias    => 'metaclass'
      }
    )

    ensure_resource('package', 'rubygem-mime-types', {
        ensure   => 'latest',
        alias    => 'mime-types'
      }
    )

    ensure_resource('package', 'rubygem-mocha', {
        ensure   => 'latest',
        alias    => 'mocha'
      }
    )

    ensure_resource('package', 'rubygem-mongo', {
        ensure   => 'latest',
        alias    => 'mongo'
      }
    )
    
    ensure_resource('package', 'rubygem-cucumber', {
        ensure   => 'latest',
        alias    => 'cucumber'
      }
    )

    ensure_resource('package', 'rubygem-multi_json', {
        ensure   => 'latest',
        alias    => 'multi_json'
      }
    )

    ensure_resource('package', 'rubygem-netrc', {
        ensure   => 'latest',
        alias    => 'netrc'
      }
    )

    ensure_resource('package', 'rubygem-open4', {
        ensure   => 'latest',
        alias    => 'open4'
      }
    )

    ensure_resource('package', 'rubygem-parseconfig', {
        ensure   => 'latest',
        alias    => 'parseconfig'
      }
    )
    
    ensure_resource('package', 'rubygem-polyglot', {
        ensure   => 'latest',
        alias    => 'polyglot'
      }
    )

    ensure_resource('package', 'rubygem-rack', {
        ensure   => 'latest',
        alias    => 'rack'
      }
    )

    ensure_resource('package', 'rubygem-rack-cache', {
        ensure   => 'latest',
        alias    => 'rack-cache'
      }
    )
    
    ensure_resource('package', 'rubygem-rack-ssl', {
        ensure   => 'latest',
        alias    => 'rack-ssl'
      }
    )

    ensure_resource('package', 'rubygem-rack-test', {
        ensure   => 'latest',
        alias    => 'rack-test'
      }
    )
    
    ensure_resource('package', 'rubygem-rails', {
        ensure   => 'latest',
        alias    => 'rails'
      }
    )

    ensure_resource('package', 'rubygem-railties', {
        ensure   => 'latest',
        alias    => 'railties'
      }
    )

    ensure_resource('package', 'rubygem-rake', {
        ensure   => 'latest',
        alias    => 'rake'
      }
    )

    ensure_resource('package', 'rubygem-rdoc', {
        ensure   => 'latest',
        alias    => 'rdoc'
      }
    )

    ensure_resource('package', 'rubygem-regin', {
        ensure   => 'latest',
        alias    => 'regin'
      }
    )
    
    ensure_resource('package', 'rubygem-rest-client', {
        ensure   => 'latest',
        alias    => 'rest-client'
      }
    )
    
    ensure_resource('package', 'rubygem-simplecov', {
        ensure   => 'latest',
        alias    => 'simplecov'
      }
    )
    
    ensure_resource('package', 'rubygem-simplecov-html', {
        ensure   => 'latest',
        alias    => 'simplecov-html'
      }
    )
    
    ensure_resource('package', 'rubygem-sprockets', {
        ensure   => 'latest',
        alias    => 'sprockets'
      }
    )

    ensure_resource('package', 'rubygem-state_machine', {
        ensure   => 'latest',
        alias    => 'state_machine'
      }
    )

    ensure_resource('package', 'rubygem-stomp', {
        ensure   => 'latest',
        alias    => 'stomp'
      }
    )
    
    ensure_resource('package', 'rubygem-systemu', {
        ensure   => 'latest',
        alias    => 'systemu'
      }
    )

    ensure_resource('package', 'rubygem-term-ansicolor', {
        ensure   => 'latest',
        alias    => 'term-ansicolor'
      }
    )
    
    ensure_resource('package', 'rubygem-thor', {
        ensure   => 'latest',
        alias    => 'thor'
      }
    )

    ensure_resource('package', 'rubygem-tilt', {
        ensure   => 'latest',
        alias    => 'tilt'
      }
    )
    
    ensure_resource('package', 'rubygem-treetop', {
        ensure   => 'latest',
        alias    => 'treetop'
      }
    )

    ensure_resource('package', 'rubygem-tzinfo', {
        ensure   => 'latest',
        alias    => 'tzinfo'
      }
    )
    
    ensure_resource('package', 'rubygem-xml-simple', {
        ensure   => 'latest',
        alias    => 'xml-simple'
      }
    )

    ensure_resource('package', 'rubygem-webmock', {
        ensure   => 'latest',
        alias    => 'webmock'
      }
    )
    
    ensure_resource('package', 'rubygem-fakefs', {
        ensure   => 'latest',
        alias    => 'fakefs'
      }
    )
  }

  if ($::operatingsystem == "RedHat" or $::operatingsystem == "CentOS") {
    ensure_resource('package', 'ruby193-rubygem-actionmailer', {
        ensure => 'latest',
        alias  => 'actionmailer',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-actionpack', {
        ensure => 'latest',
        alias  => 'actionpack',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-activemodel', {
        ensure => 'latest',
        alias  => 'activemodel',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-activerecord', {
        ensure => 'latest',
        alias  => 'activerecord',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-activeresource', {
        ensure => 'latest',
        alias  => 'activeresource',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-activesupport', {
        ensure => 'latest',
        alias  => 'activesupport',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-arel', {
        ensure => 'latest',
        alias  => 'arel',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-bigdecimal', {
      ensure => 'latest',
      alias  => 'bigdecimal',
    }
    )

    ensure_resource('package', 'ruby193-rubygem-bson', {
        ensure  => 'latest',
        alias   => 'bson',
        require => [
          Package['ruby-devel'],
          Package['mongodb-devel'],
        ],
      }
    )

    ensure_resource('package', 'ruby193-rubygem-bson_ext', {
        ensure  => 'latest',
        alias   => 'bson_ext',
        require => [
          Package['ruby-devel'],
          Package['mongodb-devel'],
        ],
      }
    )

    ensure_resource('package', 'ruby193-rubygem-builder', {
        ensure => 'latest',
        alias  => 'builder',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-bundler', {
        ensure => 'latest',
        alias  => 'bundler',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-cucumber', {
        ensure => 'latest',
        alias  => 'cucumber',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-diff-lcs', {
        ensure => 'latest',
        alias  => 'diff-lcs',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-dnsruby', {
        ensure => 'latest',
        alias  => 'dnsruby',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-erubis', {
        ensure => 'latest',
        alias  => 'erubis',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-gherkin', {
        ensure  => 'latest',
        alias   => 'gherkin',
        require => Package['ruby-devel'],
      }
    )

    ensure_resource('package', 'ruby193-rubygem-hike', {
        ensure => 'latest',
        alias  => 'hike',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-i18n', {
        ensure => 'latest',
        alias  => 'i18n',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-journey', {
        ensure => 'latest',
        alias  => 'journey',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-json', {
        ensure => 'latest',
        alias  => 'json',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-mail', {
        ensure => 'latest',
        alias  => 'mail',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-metaclass', {
        ensure => 'latest',
        alias  => 'metaclass',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-mime-types', {
        ensure => 'latest',
        alias  => 'mime-types',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-minitest', {
        ensure => 'latest',
        alias  => 'minitest',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-mocha', {
        ensure => 'latest',
        alias  => 'mocha',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-mongo', {
        ensure => 'latest',
        alias  => 'mongo',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-mongoid', {
        ensure => 'latest',
        alias  => 'mongoid',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-moped', {
        ensure => 'latest',
        alias  => 'moped',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-multi_json', {
        ensure => 'latest',
        alias  => 'multi_json',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-open4', {
        ensure => 'latest',
        alias  => 'open4',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-origin', {
        ensure => 'latest',
        alias  => 'origin',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-parseconfig', {
        ensure => 'latest',
        alias  => 'parseconfig',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-polyglot', {
        ensure => 'latest',
        alias  => 'polyglot',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rack', {
        ensure => 'latest',
        alias  => 'rack',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rack-cache', {
        ensure => 'latest',
        alias  => 'rack-cache',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rack-ssl', {
        ensure => 'latest',
        alias  => 'rack-ssl',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rack-test', {
        ensure => 'latest',
        alias  => 'rack-test',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rails', {
        ensure => 'latest',
        alias  => 'rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-railties', {
        ensure => 'latest',
        alias  => 'railties',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rake', {
        ensure => 'latest',
        alias  => 'rake',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rdoc', {
        ensure => 'latest',
        alias  => 'rdoc',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-regin', {
        ensure => 'latest',
        alias  => 'regin',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rest-client', {
        ensure => 'latest',
        alias  => 'rest-client',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-simplecov', {
        ensure => 'latest',
        alias  => 'simplecov',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-simplecov-html', {
        ensure => 'latest',
        alias  => 'simplecov-html',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-sprockets', {
        ensure => 'latest',
        alias  => 'sprockets',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-state_machine', {
        ensure => 'latest',
        alias  => 'state_machine',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-stomp', {
        ensure => 'latest',
        alias  => 'stomp',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-systemu', {
        ensure => 'latest',
        alias  => 'systemu',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-term-ansicolor', {
        ensure => 'latest',
        alias  => 'term-ansicolor',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-thor', {
        ensure => 'latest',
        alias  => 'thor',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-tilt', {
        ensure => 'latest',
        alias  => 'tilt',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-treetop', {
        ensure => 'latest',
        alias  => 'treetop',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-tzinfo', {
        ensure => 'latest',
        alias  => 'tzinfo',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-xml-simple', {
        ensure => 'latest',
        alias  => 'xml-simple',
      }
    )
  }

  if $::openshift_origin::development_mode {
    file { '/etc/openshift/development':
      content => '',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['openshift-origin-broker'],
    }
  }

  file { 'openshift broker.conf':
    path    => '/etc/openshift/broker.conf',
    content => template('openshift_origin/broker/broker.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-broker'],
  }

  file { 'openshift broker-dev.conf':
    path    => '/etc/openshift/broker-dev.conf',
    content => template('openshift_origin/broker/broker.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-broker'],
  }

  file { 'openshift production log':
    path    => '/var/www/openshift/broker/log/production.log',
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    require => Package['openshift-origin-broker'],
  }

  if !defined(File['mcollective client config']) {
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

  if !defined(File['mcollective server config']) {
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

  if($::operatingsystem == 'Redhat' or $::operatingsystem == 'CentOS') {
    if !defined(File['mcollective env']) {
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
    exec { 'Generate self signed keys for broker auth':
      command => '/bin/mkdir -p /etc/openshift && \
      /usr/bin/openssl genrsa -out /etc/openshift/server_priv.pem 2048 && \
      /usr/bin/openssl rsa -in /etc/openshift/server_priv.pem -pubout > \
            /etc/openshift/server_pub.pem',
      creates => '/etc/openshift/server_pub.pem',
    }
  } else {
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
      require => [Package['rubygem-openshift-origin-controller'], Package['openshift-origin-broker'], Package['openssh']]
    }
  } else {
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
    path    => '/etc/httpd/conf.d/000000_openshift_origin_broker_servername.conf',
    content => template('openshift_origin/broker/broker_servername.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['openshift-origin-broker'],
  }

  file { 'mcollective broker plugin config':
    ensure  => present,
    path    => '/etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf',
    content => template('openshift_origin/broker/msg-broker-mcollective.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-msg-broker-mcollective'],
  }

  case $::openshift_origin::broker_auth_plugin {
    'mongo'      : {
      package { ['rubygem-openshift-origin-auth-mongo']:
        ensure  => present,
        require => Yumrepo[openshift-origin],
      }

      file { 'Auth plugin config':
        ensure  => present,
        path    => '/etc/openshift/plugins.d/openshift-origin-auth-mongo.conf',
        content => template('openshift_origin/broker/plugins/auth/mongo/mongo.conf.plugin.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['rubygem-openshift-origin-msg-broker-mcollective'],
      }
    }
    'basic-auth' : {
      package { ['rubygem-openshift-origin-auth-remote-user']:
        ensure  => present,
        require => Yumrepo[openshift-origin],
      }

      file { 'openshift htpasswd':
        path    => '/etc/openshift/htpasswd',
        content => template('openshift_origin/broker/plugins/auth/basic/htpasswd.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['rubygem-openshift-origin-auth-remote-user']
      }

      file { 'Broker htpasswd config':
        path    => '/var/www/openshift/broker/httpd/conf.d/openshift-origin-auth-remote-user-basic.conf',
        content => template('openshift_origin/broker/plugins/auth/basic/openshift-origin-auth-remote-user-basic.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
          Package['rubygem-openshift-origin-auth-remote-user'],
          File['openshift htpasswd'],
        ],
        notify  => Service["openshift-broker"],
      }

      file { 'Auth plugin config':
        path    => '/etc/openshift/plugins.d/openshift-origin-auth-remote-user.conf',
        content => template('openshift_origin/broker/plugins/auth/basic/remote-user.conf.plugin.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
          Package['rubygem-openshift-origin-auth-remote-user'],
          File['openshift htpasswd'],
        ],
        notify  => Service["openshift-broker"],
      }
    }
    'kerberos' : {
      package { ['rubygem-openshift-origin-auth-remote-user']:
        ensure => present,
        require => Yumrepo[openshift-origin],
      }

      package { ['mod_auth_kerb']:
        ensure => installed,
      }
      
      file {'kerberos keytab':
        ensure => present,
        path => $::openshift_origin::kerberos_keytab,
        owner => 'apache',
        group => 'apache',
        mode => '0644',
        require => Package['rubygem-openshift-origin-auth-remote-user']
      }

      file {'broker kerbros.conf':
        path => '/var/www/openshift/broker/httpd/conf.d/openshift-origin-auth-remote-user-kerberos.conf',
        content => 
          template('openshift_origin/broker/plugins/auth/kerberos/openshift-origin-auth-remote-user-kerberos.conf.erb'),
        owner => 'apache',
        group => 'apache',
        mode => '0644',
        require => [
          Package['rubygem-openshift-origin-auth-remote-user'],
          Package['mod_auth_kerb'],
          File['kerberos keytab']
        ]
      }

      file {'console kerberos.conf':
        path => '/var/www/openshift/console/httpd/conf.d/openshift-origin-auth-remote-user-kerberos.conf',
        content =>
          template('openshift_origin/console/openshift-origin-auth-remote-user-kerberos.conf.erb'),
        owner => 'apache',
        group => 'apache',
        mode => '0644',
        require => [
          Package['rubygem-openshift-origin-auth-remote-user'],
          Package['mod_auth_kerb'],
          File['kerberos keytab']
        ]
      }

      file { 'Auth plugin config':
        path    => '/etc/openshift/plugins.d/openshift-origin-auth-remote-user.conf',
        content => template('openshift_origin/broker/plugins/auth/basic/remote-user.conf.plugin.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['rubygem-openshift-origin-auth-remote-user']
      }
    }
    default      : {
      fail "Unknown Auth plugin ${::openshift_origin::broker_auth_plugin}"
    }
  }

  case $::openshift_origin::broker_dns_plugin {  
    'nsupdate'   : {
      if $openshift_origin::named_tsig_priv_key == '' {
        warning "Generate the Key file with '/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named ${openshift_origin::cloud_domain}'"
        warning "Use the last field in the generated key file /var/named/K${openshift_origin::cloud_domain}*.key"
        fail 'named_tsig_priv_key is required.'
      }
      
      file { 'plugin openshift-origin-dns-nsupdate.conf':
        path    => '/etc/openshift/plugins.d/openshift-origin-dns-nsupdate.conf',
        content => template('openshift_origin/broker/plugins/dns/nsupdate/nsupdate.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['rubygem-openshift-origin-dns-nsupdate'],
      }
    }
    'avahi'      : {
      file { 'plugin openshift-origin-dns-avahi.conf':
        path    => '/etc/openshift/plugins.d/openshift-origin-dns-avahi.conf',
        content => template('openshift_origin/broker/plugins/dns/avahi/avahi.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['rubygem-openshift-origin-dns-avahi'],
      }
    }
    default      : {
      fail "Unknown DNS plugin ${::openshift_origin::broker_dns_plugin}"
    }
  }
  
  $broker_bundle_show = $::operatingsystem ? {
    'Fedora' => '/usr/bin/bundle show',
    'CentOS' => '/usr/bin/scl enable ruby193 "bundle show"',
    default  => '/usr/bin/scl enable ruby193 "bundle show"',
  }

  exec { 'Broker gem dependencies':
    cwd     => '/var/www/openshift/broker/',
    command => "${::openshift_origin::rm} -f Gemfile.lock && \
    ${broker_bundle_show} && \
    ${::openshift_origin::chown} apache:apache Gemfile.lock && \
    ${::openshift_origin::rm} -rf tmp/cache/*",
    unless  => $broker_bundle_show,
    require => [
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
    ],
  }

  exec { 'fixfiles rubygem-passenger':
    command     => '/sbin/fixfiles -R rubygem-passenger restore && \
      /sbin/fixfiles -R mod_passenger restore',
    subscribe   => Package['rubygem-passenger'],
    refreshonly => true,
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'openshift-broker':
      require => [Package['openshift-origin-broker']],
      enable  => true,
    }
  } else {
    warning 'Please ensure that openshift-broker service is enable on broker machines'
  }

  file { '/var/log/passenger-analytics':
    ensure  => directory,
    owner   => 'apache',
    group   => 'apache',
    mode    => '0750',
    require => [Package['rubygem-passenger'],Package['httpd']]
  }
}
