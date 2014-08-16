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
  if $::openshift_origin::manage_firewall {
    include openshift_origin::firewall::apache
  }
  include openshift_origin::selbooleans
  include openshift_origin::selbooleans::broker_console
  include openshift_origin::broker_console_dirs

  package { 'openshift-origin-console':
    ensure  => present,
    require => [
      Class['openshift_origin::install_method'],
      Package['httpd'],
    ]
  }

  # These dirs should be created by the package.
  file {
    [
      '/var/log/openshift/console',
      '/var/log/openshift/console/httpd',
      '/var/www/openshift/console',
      '/var/www/openshift/console/httpd',
      '/var/www/openshift/console/httpd/run',
    ]:
    ensure  => directory,
  }

  selinux_fcontext {
    [
      '/var/log/openshift/console(/.*)?',
      '/var/log/openshift/console/httpd(/.*)?',
    ]:
    ensure   => 'present',
    seltype  => 'httpd_log_t',
  }

  selinux_fcontext { '/var/www/openshift/console/httpd/run(/.*)?':
    ensure   => 'present',
    seltype  => 'httpd_var_run_t',
  }

  # Add semanage types to dirs before anything else goes into them.
  File['/var/log/openshift/console'] {
    seltype => 'httpd_log_t',
    require => [
      Class['openshift_origin::broker_console_dirs'],
      Selinux_fcontext['/var/log/openshift/console(/.*)?'],
    ],
  }

  File['/var/www/openshift/console/httpd/run'] {
    seltype => 'httpd_var_run_t',
    require => [
      Package['httpd'],
      Class['openshift_origin::broker_console_dirs'],
      Selinux_fcontext['/var/www/openshift/console/httpd/run(/.*)?'],
    ],
  }

  file { 'openshift console.conf':
    path    => '/etc/openshift/console.conf',
    content => template('openshift_origin/console/console.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => [
      Package['openshift-origin-console'],
      Class['openshift_origin::broker_console_dirs'],
    ],
    notify  => Service['openshift-console'],
  }

  if $::openshift_origin::development_mode == true {
    file { 'openshift console-dev.conf':
      path    => '/etc/openshift/console-dev.conf',
      content => template('openshift_origin/console/console.conf.erb'),
      owner   => 'apache',
      group   => 'apache',
      mode    => '0644',
      require => [
        Package['openshift-origin-console'],
        Class['openshift_origin::broker_console_dirs'],
      ],
      notify  => Service['openshift-console'],
    }
  }

  # This File resource is to guarantee that the Gemfile.lock created
  # by the following Exec has the appropriate permissions (otherwise
  # it is created as owned by root:root)
  file { '/var/www/openshift/console/Gemfile.lock':
    ensure    => 'present',
    owner     => 'apache',
    group     => 'apache',
    mode      => '0644',
    require   => Package['openshift-origin-console'],
  }

  # SCL and Puppet don't play well together; the 'default' here
  # circumvents the use of the `scl enable ruby193` mechanism
  # while still invoking ruby commands in the correct context
  $console_asset_rake_cmd = $::operatingsystem ? {
    'Fedora' => '/usr/bin/rake assets:precompile',
    default  => 'LD_LIBRARY_PATH=/opt/rh/ruby193/root/usr/lib64:/opt/rh/v8314/root/usr/lib64 GEM_PATH=/opt/rh/ruby193/root/usr/local/share/gems:/opt/rh/ruby193/root/usr/share/gems /opt/rh/ruby193/root/usr/bin/rake assets:precompile',
  }

  $console_bundle_show    = $::operatingsystem ? {
    'Fedora' => '/usr/bin/bundle show',
    default  => 'LD_LIBRARY_PATH=/opt/rh/ruby193/root/usr/lib64 GEM_PATH=/opt/rh/ruby193/root/usr/local/share/gems:/opt/rh/ruby193/root/usr/share/gems /opt/rh/ruby193/root/usr/bin/bundle show',
  }

  exec { 'Console gem dependencies':
    cwd         => '/var/www/openshift/console/',
    command     => "${::openshift_origin::params::rm} -f Gemfile.lock && \
    ${console_bundle_show} && \
    ${::openshift_origin::params::chown} apache:apache Gemfile.lock && \
    ${::openshift_origin::params::rm} -rf tmp/cache/* && \
    ${console_asset_rake_cmd} && \
    ${::openshift_origin::params::chown} -R apache:apache /var/www/openshift/console",
    require     => Package['openshift-origin-console'],
    subscribe   => [
      Package['openshift-origin-console'],
      File['/var/www/openshift/console/Gemfile.lock'],
    ],
    notify      => Service['openshift-console'],
    refreshonly => true,
  }

  exec { 'restorecon console dir':
    command  => 'restorecon -R /var/www/openshift/console',
    provider => 'shell',
    require  => Package['openshift-origin-console'],
    notify   => Service['openshift-console'],
  }

  service { 'openshift-console':
    ensure     => true,
    require    => Package['openshift-origin-console'],
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
