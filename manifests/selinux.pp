# == Class: openshift_origin::mongo
#
# Manage SELinux booleans for OpenShift Origin.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::selinux
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
class openshift_origin::selinux {
  include openshift_origin::params
  
  if $::openshift_origin::configure_broker == true {
    $broker_booleans = [
      'httpd_run_stickshift',
      'httpd_verify_dns',
      'allow_ypbind'
    ]
  } else {
    $broker_booleans = []
  }
  
  if $::openshift_origin::configure_console == true {
    $console_booleans = [
      'httpd_can_network_connect',
      'httpd_can_network_relay',
      'httpd_read_user_content',
      'httpd_enable_homedirs',
      'httpd_execmem'
    ]
  } else {
    $console_booleans = []
  }
  
  if $::openshift_origin::configure_named == true {
    $named_booleans = [
      'named_write_master_zones'
    ]
  } else {
    $named_booleans = []
  }
  
  if $::openshift_origin::configure_node == true {
    $node_booleans = [
      'httpd_run_stickshift',
      'allow_polyinstantiation',
      'httpd_can_network_connect',
      'httpd_can_network_relay',
      'httpd_read_user_content',
      'httpd_enable_homedirs',
      'httpd_execmem'
    ]
  } else {
    $node_booleans = []
  }

  if $::openshift_origin::set_sebooleans == true {
    $booleans = unique(flatten([ 
      $broker_booleans,
      $console_booleans,
      $named_booleans,
      $node_booleans,
    ]))
    selboolean { $booleans:
      persistent => true,
      value => 'on'
    }
  }
  
  if $openshift_origin::set_sebooleans == 'delayed' {
    file { 'selinux setup script':
      ensure  => present,
      path    => '/usr/sbin/oo-selinux-setup',
      content => template('openshift_origin/oo-selinux-setup.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }
  
    $openshift_init_provider = $::operatingsystem ? {
      'Fedora' => 'systemd',
      'CentOS' => 'redhat',
      default  => 'redhat',
    }
    
    if $openshift_init_provider == 'systemd' {
      file { 'selinux setup service':
        ensure  => present,
        path    => '/usr/lib/systemd/system/openshift-selinux-setup.service',
        content => template('openshift_origin/openshift-selinux-setup.service'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
          File['selinux setup script']
        ],
      }      
    } else {
      fail "Delayed selinux setup for RHEL not available"
    }

    service { ['openshift-selinux-setup']:
      require  => [
        File['selinux setup script'],
        File['selinux setup service'],
      ],
      provider => $openshift_init_provider,
      enable   => true,
    }
  }
}
