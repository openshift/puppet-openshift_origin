# Copyright 2013 Mojo Lingo LLC.
# Modifications by Red Hat, Inc.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
class openshift_origin::console {
  ensure_resource('package', 'openshift-origin-console', {
      ensure  => present,
      require => Class['openshift_origin::install_method'],
    }
  )

  file { 'openshift console.conf':
    path    => '/etc/openshift/console.conf',
    content => template('openshift_origin/console/console.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-console'],
  }

  if $::openshift_origin::development_mode == true {
    file { 'openshift console-dev.conf':
      path    => '/etc/openshift/console-dev.conf',
      content => template('openshift_origin/console/console.conf.erb'),
      owner   => 'apache',
      group   => 'apache',
      mode    => '0644',
      require => Package['openshift-origin-console'],
    }
  }

  $console_asset_rake_cmd = $::operatingsystem ? {
    'Fedora' => '/usr/bin/rake assets:precompile',
    default  => '/usr/bin/scl enable ruby193 "rake assets:precompile"',
  }

  $console_bundle_show    = $::operatingsystem ? {
    'Fedora' => '/usr/bin/bundle show',
    default  => '/usr/bin/scl enable ruby193 "bundle show"',
  }

  # This File resource is to guarantee that the Gemfile.lock created
  # by the following Exec has the appropriate permissions (otherwise
  # it is created as owned by root:root)  
  file { '/var/www/openshift/console/Gemfile.lock':
    ensure    => 'present',
    owner     => 'apache',
    group     => 'apache',
    mode      => '0644',
    subscribe => Exec ['Console gem dependencies'],
    require   => Exec ['Console gem dependencies'],
  }

  exec { 'Console gem dependencies':
    cwd         => '/var/www/openshift/console/',
    command     => "${::openshift_origin::params::rm} -f Gemfile.lock && \
    ${console_bundle_show} && \
    ${::openshift_origin::params::chown} apache:apache Gemfile.lock && \
    ${::openshift_origin::params::rm} -rf tmp/cache/* && \
    ${console_asset_rake_cmd} && \
    ${::openshift_origin::params::chown} -R apache:apache /var/www/openshift/console",
    subscribe   => [
      Package['openshift-origin-console'],
      File['openshift console.conf'],
    ],
    refreshonly => true,
  }

  service { 'openshift-console':
    require => Package['openshift-origin-console'],
    enable  => true,
  }
  
  ensure_resource( 'firewall', 'http', {
      service => 'http',
    }
  )
  
  ensure_resource( 'firewall', 'https', {
      service => 'https',
    }
  )
}
