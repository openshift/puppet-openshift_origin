# == Class: openshift_origin::console
#
# Manage the OpenShift Origin console.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::console
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
class openshift_origin::console {
  ensure_resource('package', 'rubygem-openshift-origin-console', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-console', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
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

  $console_asset_rake_cmd = $::operatingsystem ? {
    'Fedora' => '/usr/bin/rake assets:precompile',
    default  => '/usr/bin/scl enable ruby193 "rake assets:precompile"',
  }

  $console_bundle_show    = $::operatingsystem ? {
    'Fedora' => '/usr/bin/bundle install',
    default  => '/usr/bin/scl enable ruby193 "bundle show"',
  }

  exec { 'Console gem dependencies':
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
    refreshonly => true,
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'openshift-console':
      require => Package['openshift-origin-console'],
      enable  => true,
    }
  } else {
    warning 'Please ensure that openshift-console service is enable on console machines'
  }
}
