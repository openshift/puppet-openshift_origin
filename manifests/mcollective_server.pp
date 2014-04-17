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
class openshift_origin::mcollective_server {
  include openshift_origin::params
  
  ensure_resource( 'package' , "${::openshift_origin::params::ruby_scl_prefix}mcollective", {
      alias => 'mcollective',
      require => Class['openshift_origin::install_method'],
    } 
  )

  $cluster_members = $::openshift_origin::mcollective_cluster_members

  if $cluster_members {
    $pool_size = size($cluster_members)
  } else {
    $pool_size = '1'
  }

  # Ensure classes are run in order
  Class['Openshift_origin::Role']               -> Class['Openshift_origin::Mcollective_server']
  Class['Openshift_origin::Update_conf_files'] -> Class['Openshift_origin::Mcollective_server']

  file { 'mcollective server config':
    ensure  => present,
    path    => "${::openshift_origin::params::ruby_scl_path_prefix}/etc/mcollective/server.cfg",
    content => template('openshift_origin/mcollective/mcollective-server.cfg.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mcollective'],
    notify  => Service["${::openshift_origin::params::ruby_scl_prefix}mcollective"],
  }
  
  if( $::operatingsystem == 'Fedora' ) {
    $require_real = [
      File['mcollective server config', '/usr/lib/systemd/system/mcollective.service'],
      Exec['systemd-daemon-reload']
    ]

    file { '/usr/lib/systemd/system/mcollective.service':
      content => template('openshift_origin/mcollective/mcollective.service'),
      require => Package['mcollective'],
      notify  => Exec['systemd-daemon-reload']
    }
    
    exec { 'systemd-daemon-reload':
      command     => '/bin/systemctl --system daemon-reload',
      refreshonly => true,
      notify      => Service["${::openshift_origin::params::ruby_scl_prefix}mcollective"],
    }
  } else {
    $require_real = File['mcollective server config']
  }

  service { "${::openshift_origin::params::ruby_scl_prefix}mcollective":
    enable     => true,
    ensure     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => $require_real,
    provider   => $::openshift_origin::params::os_init_provider,
  }
  
  exec { 'openshift-facts':
    command     => "/usr/bin/oo-exec-ruby ${::openshift_origin::params::ruby_scl_path_prefix}/usr/libexec/mcollective/update_yaml.rb ${::openshift_origin::params::ruby_scl_path_prefix}/etc/mcollective/facts.yaml",
    environment => ['LANG=en_US.UTF-8', 'LC_ALL=en_US.UTF-8'],
    require     => [
      Package['openshift-origin-msg-node-mcollective'],
      Package['mcollective'],
      File['openshift node config'],
    ],
    refreshonly => true,
  }
}
