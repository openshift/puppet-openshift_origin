# == Class: openshift_origin::node
#
# Manage an OpenShift Origin node.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::node
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
class openshift_origin::node {
  include openshift_origin::params
  ensure_resource('package', 'rubygem-openshift-origin-node', {
      ensure  => latest,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-node-util', {
      ensure  => latest,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'pam_openshift', {
      ensure  => latest,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-node-proxy', {
      ensure  => latest,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-port-proxy', {
      ensure  => latest,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-msg-node-mcollective', {
      ensure  => latest,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'git', {
      ensure => present
    }
  )
  ensure_resource('package', 'make', {
      ensure => present
    }
  )
  ensure_resource('package', 'cronie', {
      ensure => present
    }
  )
  ensure_resource('package', 'oddjob', {
      ensure => present
    }
  )

  if $::openshift_origin::configure_firewall == true {
    $webproxy_http_port = $::use_firewalld ? {
      'true'  => '8000/tcp',
      default => '8000:tcp',
    }

    exec { 'Open HTTP port for Node-webproxy':
      command => "${openshift_origin::params::firewall_port_cmd}${webproxy_http_port}",
      require => Package['firewall-package'],
    }

    $webproxy_https_port = $::use_firewalld ? {
      'true'  => '8443/tcp',
      default => '8443:tcp',
    }

    exec { 'Open HTTPS port for Node-webproxy':
      command => "${openshift_origin::params::firewall_port_cmd}${webproxy_https_port}",
      require => Package['firewall-package'],
    }
  } else {
    warning 'Please ensure that ports 80, 443, 8000, 8443 are open for web requests'
  }

  file { 'node servername config':
    ensure  => present,
    path    => '/etc/httpd/conf.d/000001_openshift_origin_node_servername.conf',
    content => template('openshift_origin/node/openshift-origin-node_servername.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-node'],
  }

  file { 'openshift node config':
    ensure  => present,
    path    => '/etc/openshift/node.conf',
    content => template('openshift_origin/node/node.conf.erb'),
    require => Package['rubygem-openshift-origin-node'],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  augeas { 'update login.defs with min gear uid/gid':
    context   => "/files/etc/login.defs",
    changes   => [
      "set /files/etc/login.defs/UID_MIN ${::openshift_origin::min_gear_uid}",
      "set /files/etc/login.defs/GID_MIN ${::openshift_origin::min_gear_uid}",
    ],
    subscribe => File['openshift node config']
  }

  file { 'node sshd config':
    ensure  => present,
    path    => '/etc/ssh/sshd_config',
    content => template('openshift_origin/node/sshd_config.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  if !defined(File['mcollective client config']) {
    file { 'mcollective client config':
      ensure  => present,
      path    => $::openshift_origin::mcollective_client_cfg,
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
      path    => $::openshift_origin::mcollective_server_cfg,
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
        require => [
          Package['mcollective'],
          Yumrepo[openshift-origin-deps],
        ],
      }
    }
  }

  if $::openshift_origin::configure_fs_quotas == true {
    exec { 'Initialize quota DB':
      command => '/usr/sbin/oo-init-quota',
      creates => "${::gear_root_mount}/aquota.user",
      require => Package['openshift-origin-node-util'],
    }
  } else {
    warning 'Please ensure that quotas are enabled for /var/lib/openshift'
  }

  if $::openshift_origin::configure_fs_quotas == true {
    if $::operatingsystem == "Fedora" {
      if $::operatingsystemrelease == "18" {
        file { 'quota enable service':
          ensure  => present,
          path    => '/usr/lib/systemd/system/openshift-quotaon.service',
          content => template('openshift_origin/openshift-quotaon.service'),
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          require => [],
        }
        service { ['openshift-quotaon']:
          require => [
            File['quota enable service'],
          ],
          provider => 'systemd',
          enable => true,
        }
      }
    }
  }

  if $::openshift_origin::configure_cgroups == true {
    if $::openshift_origin::enable_network_services == true {
      service { [
        'cgconfig',
        'cgred',
        'openshift-port-proxy',
        'openshift-tc',
      ]:
        require => [
          Package['rubygem-openshift-origin-node'],
          Package['openshift-origin-node-util'],
          Package['openshift-origin-node-proxy'],
          Package['openshift-origin-port-proxy'],
        ],
        enable  => true,
      }
    } else {
      warning 'Please ensure that cgconfig, cgred, openshift-port-proxy are running on all nodes'
    }
  } else {
    warning 'CGroups disabled'
  }

  if $::openshift_origin::node_container == 'selinux' {
    ensure_resource('package', "rubygem-openshift-origin-container-selinux", {
        ensure  => latest,
        require => Yumrepo['openshift-origin'],
      }
    )

    if $::openshift_origin::configure_pam == true {
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
    
            "set 03/type session",
            "set 03/control required",
            "set 03/module pam_namespace.so",
            "set 03/argument[1] no_unmount_on_close",
            "set 03/#comment 'Managed by puppet:openshift_origin'",
    
            "set 04/type session",
            "set 04/control optional",
            "set 04/module pam_cgroup.so",
            "set 04/#comment 'Managed by puppet:openshift_origin'",
          ],
          onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
      }
    
      augeas { 'openshift node pam runuser':
        context => "/files/etc/pam.d/runuser",
        changes => [
            "set 01/type session",
            "set 01/control required",
            "set 01/module pam_namespace.so",
            "set 01/argument[1] no_unmount_on_close",
            "set 01/#comment 'Managed by puppet:openshift_origin'",
          ],
          onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
      }
    
      augeas { 'openshift node pam runuser-l':
        context => "/files/etc/pam.d/runuser-l",
        changes => [
            "set 01/type session",
            "set 01/control required",
            "set 01/module pam_namespace.so",
            "set 01/argument[1] no_unmount_on_close",
            "set 01/#comment 'Managed by puppet:openshift_origin'",
          ],
          onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
      }
    
      augeas { 'openshift node pam su':
        context => "/files/etc/pam.d/su",
        changes => [
            "set 01/type session",
            "set 01/control required",
            "set 01/module pam_namespace.so",
            "set 01/argument[1] no_unmount_on_close",
            "set 01/#comment 'Managed by puppet:openshift_origin'",
          ],
          onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
      }
    
      augeas { 'openshift node pam system-auth-ac':
        context => "/files/etc/pam.d/system-auth-ac",
        changes => [
            "set 01/type session",
            "set 01/control required",
            "set 01/module pam_namespace.so",
            "set 01/argument[1] no_unmount_on_close",
            "set 01/#comment 'Managed by puppet:openshift_origin'",
          ],
          onlyif => "match *[#comment='Managed by puppet:openshift_origin'] size == 0"
      }  
    
      $os_all_unmanaged_users = [['root', 'adm', 'apache'], $::openshift_origin::os_unmanaged_users]
    
      file { 'openshift node pam-namespace sandbox.conf':
        ensure  => present,
        path    => '/etc/security/namespace.d/sandbox.conf',
        content => template('openshift_origin/node/namespace-d-sandbox.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['pam_openshift'],
      }
    
      file { 'openshift node pam-namespace tmp.conf':
        ensure  => present,
        path    => '/etc/security/namespace.d/tmp.conf',
        content => template('openshift_origin/node/namespace-d-tmp.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['pam_openshift'],
      }
    
      file { 'openshift node pam-namespace vartmp.conf':
        ensure  => present,
        path    => '/etc/security/namespace.d/vartmp.conf',
        content => template('openshift_origin/node/namespace-d-vartmp.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['pam_openshift'],
      }
    } else {
      warning 'Please configure pam on all nodes.'
    }
  }

  if $::openshift_origin::node_container == 'libvirt-lxc' {
    ensure_resource('package', 'libvirt-daemon', {
        ensure  => latest,
        require => Yumrepo['openshift-origin'],
      }
    )

    ensure_resource('package', 'libvirt-sandbox', {
        ensure  => latest,
      }
    )

    service { 'libvirtd':
      enable  => true,
      require => [Package['libvirt-daemon'], Package['libvirt-sandbox']]
    }
  }
  

  file { 'sysctl config tweaks':
    ensure  => present,
    path    => '/etc/sysctl.conf',
    content => template('openshift_origin/node/sysctl.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'crond':
      enable  => true,
      require => Package['cronie']
    }

    service { 'messagebus':
      enable  => true,
      require => Package['oddjob']
    }

    service { 'oddjobd':
      enable  => true,
      require => Package['oddjob']
    }

    $openshift_init_provider = $::operatingsystem ? {
      'Fedora' => 'systemd',
      'CentOS' => 'redhat',
      default  => 'redhat',
    }

    service { ['openshift-gears', 'openshift-node-web-proxy']:
      require  => [
        Package['rubygem-openshift-origin-node'],
        Package['openshift-origin-node-util'],
        Package['openshift-origin-node-proxy'],
      ],
      provider => $openshift_init_provider,
      enable   => true,
    }

    case $::operatingsystem {
      'Fedora' : {
        service { 'mcollective':
          require => [Package['mcollective']],
          enable  => true,
        }
      }
      default  : {
        service { 'ruby193-mcollective':
          require => [Package['mcollective']],
          enable  => true,
        }
      }
    }
  } else {
    warning 'Please ensure that mcollective, cron, openshift-gears, openshift-node-web-proxy, and oddjobd are running on all nodes'
  }

  exec { 'Restoring SELinux contexts':
    command => '/sbin/restorecon -rv /var/lib/openshift \
          /var/lib/openshift/.httpd.d/',
    require => [Package['rubygem-openshift-origin-node']],
  }

  exec { 'jenkins repo key':
    command => "${::openshift_origin::rpm} --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key",
    creates => '/etc/yum.repos.d/jenkins.repo',
  }

  yumrepo { 'jenkins':
    name     => 'jenkins',
    baseurl  => 'http://pkg.jenkins-ci.org/redhat',
    enabled  => 1,
    gpgcheck => 1,
  }

  Exec['jenkins repo key'] -> Yumrepo['jenkins']
  
  ensure_resource('package', 'rubygem-openshift-origin-frontend-apache-mod-rewrite', {
      ensure  => latest,
      require => Yumrepo[openshift-origin],
    }
  )
  
  ensure_resource('package', 'rubygem-openshift-origin-frontend-nodejs-websocket', {
      ensure  => latest,
      require => Yumrepo[openshift-origin],
    }
  )

  if ($::openshift_origin::configure_broker == true and $::openshift_origin::configure_node == true) {
    file { 'broker and console route for node':
      ensure  => present,
      path    => '/tmp/nodes.broker_routes.txt',
      content => template('openshift_origin/node/node_routes.txt.erb'),
      owner   => 'root',
      group   => 'apache',
      mode    => '0640',
      require => [
        Package['rubygem-openshift-origin-node'],
        Package['rubygem-openshift-origin-frontend-apache-mod-rewrite'],
        Package['rubygem-openshift-origin-frontend-nodejs-websocket'],
      ],
    }

    exec { 'regen node routes':
      command => "${::openshift_origin::cat} /etc/httpd/conf.d/openshift/nodes.txt /tmp/nodes.broker_routes.txt > /etc/httpd/conf.d/openshift/nodes.txt.new && \
                      ${::openshift_origin::mv} /etc/httpd/conf.d/openshift/nodes.txt.new /etc/httpd/conf.d/openshift/nodes.txt && \
                      ${::openshift_origin::httxt2dbm} -f DB -i /etc/httpd/conf.d/openshift/nodes.txt -o /etc/httpd/conf.d/openshift/nodes.db.new && \
                      ${::openshift_origin::chown} root:apache /etc/httpd/conf.d/openshift/nodes.txt /etc/httpd/conf.d/openshift/nodes.db.new && \
                      ${::openshift_origin::chmod} 750 /etc/httpd/conf.d/openshift/nodes.txt /etc/httpd/conf.d/openshift/nodes.db.new && \
                      ${::openshift_origin::mv} -f /etc/httpd/conf.d/openshift/nodes.db.new /etc/httpd/conf.d/openshift/nodes.db",
      unless  => "${::openshift_origin::grep} '__default__/broker' /etc/httpd/conf.d/openshift/nodes.txt 2>/dev/null",
      require => File['broker and console route for node'],
    }
  }

  if ($::openshift_origin::configure_node == true) {
    if $::operatingsystem == "Fedora" {
      file { 'allow cartridge files through apache':
        ensure  => present,
        path    => '/etc/httpd/conf.d/cartridge_files.conf',
        content => template('openshift_origin/node/cartridge_files.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0660',
        require =>  Package['httpd'],
      }
    }
  }

  file { 'create node setting markers dir':
    ensure  => 'directory',
    path    => '/var/lib/openshift/.settings',
    owner   => 'root',
    group   => 'root',
    mode    => '0755'
  }

  file { 'create v2 cartridge marker':
    ensure  => present,
    path    => '/var/lib/openshift/.settings/v2_cartridge_format',
    content => '',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['create node setting markers dir']
  }

  package { 'jenkins':
    ensure  => "1.510-1.1",
    require => [
      Yumrepo['jenkins'],
    ]
  }

  package { 'yum-plugin-versionlock':
    ensure  => latest,
  }

  exec { '/usr/bin/yum versionlock jenkins':
    require => [
      Package['jenkins'],
      Package['yum-plugin-versionlock'],
    ]
  }

  package { [
    'openshift-origin-cartridge-10gen-mms-agent',
    'openshift-origin-cartridge-cron',
    'openshift-origin-cartridge-diy',
    'openshift-origin-cartridge-haproxy',
    'openshift-origin-cartridge-jenkins',
    'openshift-origin-cartridge-jenkins-client',
    'openshift-origin-cartridge-mongodb',
    'openshift-origin-cartridge-nodejs',
    'openshift-origin-cartridge-perl',
    'openshift-origin-cartridge-php',
    'openshift-origin-cartridge-phpmyadmin',
    'openshift-origin-cartridge-postgresql',
    'openshift-origin-cartridge-python',
    'openshift-origin-cartridge-ruby',
  ]:
    ensure  => latest,
    require => [
      Yumrepo[openshift-origin],
      Yumrepo[openshift-origin-deps],
      Package['jenkins'],
    ],
    notify => Exec['oo-admin-cartridge'],
  }

  case $::operatingsystem {
    'Fedora' : {
        package { [
          'openshift-origin-cartridge-mariadb',
          'openshift-origin-cartridge-jbossas',
        ]:
        ensure  => latest,
        require => [
          Yumrepo[openshift-origin],
          Yumrepo[openshift-origin-deps],
        ],
      }
    }
    default  : {
      package { [
          'openshift-origin-cartridge-mysql',
        ]:
        ensure  => latest,
        require => [
          Yumrepo[openshift-origin],
          Yumrepo[openshift-origin-deps],
        ],
      }
    }
  }

  if( $::openshift_origin::development_mode == true ) {
    package { [
      'openshift-origin-cartridge-mock',
      'openshift-origin-cartridge-mock-plugin',
    ]:
      ensure  => latest,
      require => [
        Yumrepo[openshift-origin],
        Yumrepo[openshift-origin-deps],
      ],
      notify => Exec['oo-admin-cartridge'],
    }
  }
  
  # Note, this does not handle cartridge uninstalls
  exec { 'oo-admin-cartridge':
    command => '/usr/sbin/oo-admin-cartridge --recursive -a install -s /usr/libexec/openshift/cartridges/',
    refreshonly => true,
    notify => Exec['openshift-facts'],
  }

  if( $::operatingsystem == 'Fedora' ) {
    file { '/usr/lib/systemd/system/mcollective.service':
      content => template('openshift_origin/node/mcollective.service.erb'),
      notify  => Exec['systemd-daemon-reload']
    }
    
    exec { 'openshift-facts':
      command     => "/usr/bin/oo-exec-ruby /usr/libexec/mcollective/update_yaml.rb ${::openshift_origin::mcollective_facts_yaml}",
      environment => ['LANG=en_US.UTF-8', 'LC_ALL=en_US.UTF-8'],
      require     => [
        Package['openshift-origin-msg-node-mcollective'],
        Package['mcollective'],
      ],
      refreshonly => true,
    }
  } else {
    exec { 'openshift-facts':
      command     => '/usr/bin/oo-exec-ruby /opt/rh/ruby193/root/usr/libexec/mcollective/update_yaml.rb /opt/rh/ruby193/root/etc/mcollective/facts.yaml',
      environment => ['LANG=en_US.UTF-8', 'LC_ALL=en_US.UTF-8'],
      require     => [
        Package['openshift-origin-msg-node-mcollective'],
        Package['mcollective'],
      ],
      refreshonly => true,
    }
  }

  exec { 'systemd-daemon-reload':
    command     => '/bin/systemctl --system daemon-reload',
    refreshonly => true,
  }
}
