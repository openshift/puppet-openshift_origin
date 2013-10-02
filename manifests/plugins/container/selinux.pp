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
class openshift_origin::plugins::container::selinux {
  ensure_resource('package', 'pam_openshift', {
      ensure  => present,
      require => Class['openshift_origin::install_method'],
    }
  )

  package { 'rubygem-openshift-origin-container-selinux':
    notify => Exec['openshift-facts']
  }
  
  augeas { 'update login.defs with min gear uid/gid':
    context   => "/files/etc/login.defs",
    changes   => [
      "set /files/etc/login.defs/UID_MIN 1000",
      "set /files/etc/login.defs/GID_MIN 1000",
    ],
    subscribe => File['openshift node config']
  }

  augeas { 'openshift node pam sshd':
    context => "/files/etc/pam.d/sshd",
    changes => [
      "set /files/etc/pam.d/sshd/#comment[.='pam_selinux.so close should be the first session rule'] 'pam_openshift.so close should be the first session rule'",
      "ins 01 before *[argument='close']",
      "set 01/type session",
      "set 01/control required",
      "set 01/module pam_openshift.so",
      "set 01/argument close",
      "set 01/#comment 'Managed by puppet:openshift_origin'",
      
      "set /files/etc/pam.d/sshd/#comment[.='pam_selinux.so open should only be followed by sessions to be executed in the user context'] 'pam_openshift.so open should only be followed by sessions to be executed in the user context'",
      "ins 02 before *[argument='open']",
      "set 02/type session",
      "set 02/control required",
      "set 02/module pam_openshift.so",
      "set 02/argument[1] open",
      "set 02/argument[2] env_params",
      "set 02/#comment 'Managed by puppet:openshift_origin'",
      
      "rm *[module='pam_selinux.so']",
      
      # We add two rules.  The first checks whether the user's shell is
      # /usr/bin/oo-trap-user, which indicates that this is a gear user,
      # and skips the second rule if it is not.
      "set 03/type session",
      "set 03/control '[default=1 success=ignore]'",
      "set 03/module pam_succeed_if.so",
      "set 03/argument[1] quiet",
      "set 03/argument[2] shell",
      "set 03/argument[3] '='",
      "set 03/argument[4] '/usr/bin/oo-trap-user'",
      "set 03/#comment 'Managed by puppet:openshift_origin'",
      
      # The second rule enables polyinstantiation so that the user gets
      # private /tmp and /dev/shm directories.
      "set 04/type session",
      "set 04/control required",
      "set 04/module pam_namespace.so",
      "set 04/argument[1] no_unmount_on_close",
      "set 04/#comment 'Managed by puppet:openshift_origin'",
      
      "set 05/type session",
      "set 05/control optional",
      "set 05/module pam_cgroup.so",
      "set 05/#comment 'Managed by puppet:openshift_origin'",
    ],
    onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
  }
  
  augeas { 'openshift node pam runuser':
    context => "/files/etc/pam.d/runuser",
    changes => [
      "set 01/type session",
      "set 01/control '[default=1 success=ignore]'",
      "set 01/module pam_succeed_if.so",
      "set 01/argument[1] quiet",
      "set 01/argument[2] shell",
      "set 01/argument[3] '='",
      "set 01/argument[4] '/usr/bin/oo-trap-user'",
      "set 01/#comment 'Managed by puppet:openshift_origin'",
    
      "set 02/type session",
      "set 02/control required",
      "set 02/module pam_namespace.so",
      "set 02/argument[1] no_unmount_on_close",
      "set 02/#comment 'Managed by puppet:openshift_origin'",
    ],
    onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
  }

  augeas { 'openshift node pam runuser-l':
    context => "/files/etc/pam.d/runuser-l",
    changes => [
    "set 01/type session",
    "set 01/control '[default=1 success=ignore]'",
    "set 01/module pam_succeed_if.so",
    "set 01/argument[1] quiet",
    "set 01/argument[2] shell",
    "set 01/argument[3] '='",
    "set 01/argument[4] '/usr/bin/oo-trap-user'",
    "set 01/#comment 'Managed by puppet:openshift_origin'",
  
    "set 02/type session",
    "set 02/control required",
    "set 02/module pam_namespace.so",
    "set 02/argument[1] no_unmount_on_close",
    "set 02/#comment 'Managed by puppet:openshift_origin'",
    ],
    onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
  }
  
  augeas { 'openshift node pam su':
    context => "/files/etc/pam.d/su",
    changes => [
    "set 01/type session",
    "set 01/control '[default=1 success=ignore]'",
    "set 01/module pam_succeed_if.so",
    "set 01/argument[1] quiet",
    "set 01/argument[2] shell",
    "set 01/argument[3] '='",
    "set 01/argument[4] '/usr/bin/oo-trap-user'",
    "set 01/#comment 'Managed by puppet:openshift_origin'",
  
    "set 02/type session",
    "set 02/control required",
    "set 02/module pam_namespace.so",
    "set 02/argument[1] no_unmount_on_close",
    "set 02/#comment 'Managed by puppet:openshift_origin'",
    ],
    onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
  }
  
  augeas { 'openshift node pam system-auth-ac':
    context => "/files/etc/pam.d/system-auth-ac",
    changes => [
    "set 01/type session",
    "set 01/control '[default=1 success=ignore]'",
    "set 01/module pam_succeed_if.so",
    "set 01/argument[1] quiet",
    "set 01/argument[2] shell",
    "set 01/argument[3] '='",
    "set 01/argument[4] '/usr/bin/oo-trap-user'",
    "set 01/#comment 'Managed by puppet:openshift_origin'",
  
    "set 02/type session",
    "set 02/control required",
    "set 02/module pam_namespace.so",
    "set 02/argument[1] no_unmount_on_close",
    "set 02/#comment 'Managed by puppet:openshift_origin'",
    ],
    onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
  }  
  
  # Configure the pam_namespace module to polyinstantiate the /tmp and
  # /dev/shm directories.  Above, we only enable pam_namespace for
  # OpenShift users, but to be safe, blacklist the root and adm users
  # to be sure we don't polyinstantiate their directories.
  $os_all_unmanaged_users = [['root', 'adm', 'apache'], $::openshift_origin::node_unmanaged_users]
  
  file { 'openshift node pam-namespace tmp.conf':
    ensure  => present,
    path    => '/etc/security/namespace.d/tmp.conf',
    content => template('openshift_origin/plugins/container/namespace-d-tmp.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['pam_openshift'],
  }
  
  file { 'openshift node pam-namespace vartmp.conf':
    ensure  => present,
    path    => '/etc/security/namespace.d/vartmp.conf',
    content => template('openshift_origin/plugins/container/namespace-d-vartmp.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['pam_openshift'],
  }
  
  file { 'openshift node pam-namespace shm.conf':
    ensure  => present,
    path    => '/etc/security/namespace.d/shm.conf',
    content => template('openshift_origin/plugins/container/namespace-d-shm.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['pam_openshift'],
  }
  
  if $::operatingsystem != 'Fedora' {
    file { '/etc/cgconfig.conf':
      content => template('openshift_origin/plugins/container/cgconfig.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Exec['prepare cgroups']
    }
    
    exec { 'prepare cgroups':
      command     => '/sbin/restorecon -rv /etc/cgconfig.conf; mkdir -p /cgroup; restorecon -rv /cgroup',
      refreshonly => true
    }
    
    service { ['cgconfig', 'cgred']:
      enable => true
    }
  }
}
