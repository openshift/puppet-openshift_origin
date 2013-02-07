class openshift_origin::node{
  ensure_resource( 'package', 'rubygem-openshift-origin-node',
    {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource( 'package', 'openshift-origin-node-util',
    {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource( 'package', 'pam_openshift',
    {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource( 'package', 'openshift-origin-node-proxy',
    {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource( 'package', 'openshift-origin-port-proxy',
    {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource( 'package', 'openshift-origin-msg-node-mcollective',
    {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource( 'selboolean', 'httpd_run_stickshift', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'allow_polyinstantiation', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_can_network_connect', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_can_network_relay', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_read_user_content', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_enable_homedirs', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'selboolean', 'httpd_execmem', {
    persistent => true,
    value => 'on'
  })

  ensure_resource( 'package', 'git', { ensure  => present } )
  ensure_resource( 'package', 'make', { ensure  => present } )

  if $::openshift_origin::configure_firewall == true {
    exec { 'Open HTTP port for Node-webproxy':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-port=8000/tcp",
        default => "/usr/sbin/lokkit --port=8000:tcp",
      },
      require => Package['firewall-package']
    }
    exec { 'Open HTTPS port for Node-webproxy':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-port=8443/tcp",
        default => "/usr/sbin/lokkit --port=8443:tcp",
      },
      require => Package['firewall-package']
    }
  }else{
    warning 'Please ensure that ports 80, 443, 8000, 8443 are open for web requests'
  }

  file { 'node servername config':
    ensure   => present,
    path     =>
      '/etc/httpd/conf.d/000001_openshift_origin_node_servername.conf',
    content  =>
      template('openshift_origin/node/openshift-origin-node_servername.conf.erb'),
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    require  => Package['rubygem-openshift-origin-node'],
  }

  file { 'openshift node config':
    ensure   => present,
    path     => '/etc/openshift/node.conf',
    content  => template('openshift_origin/node/node.conf.erb'),
    require  => Package['rubygem-openshift-origin-node'],
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
  }

  if ! defined(File['mcollective client config']) {
    file { 'mcollective client config':
      ensure   => present,
      path     => '/etc/mcollective/client.cfg',
      content  => template('openshift_origin/mcollective-client.cfg.erb'),
      owner    => 'root',
      group    => 'root',
      mode     => '0644',
      require  => Package['mcollective'],
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

  if $::openshift_origin::configure_fs_quotas == true {
    exec { 'Initialize quota DB':
      command => "/usr/sbin/oo-init-quota",
      creates => "${gear_root_mount}/aquota.user",
    }
  }else{
    warning 'Please ensure that quotas are enabled for /var/lib/openshift'
  }

  if $::openshift_origin::configure_cgroups == true {
    if $::operatingsystem == "Fedora" {
      file { 'fedora cgroups config':
        ensure  => present,
        path    => '/etc/systemd/system.conf',
        content => template('openshift_origin/node/system.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
      }
      if $::operatingsystemrelease == "18" {
        exec { 'Rebuild initrd to include system.conf':
          command     => "/usr/sbin/dracut --include /etc/systemd/system.conf /etc/systemd/system.conf --force",
          require     => File['fedora cgroups config'],
          refreshonly => true,
          subscribe   => File['fedora cgroups config'],
        }
      }
    }

    file { '/cgroup':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { 'cgroups config':
      ensure  => present,
      path    => '/etc/cgconfig.conf',
      content => template('openshift_origin/node/cgconfig.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    if $::openshift_origin::enable_network_services == true {
      service { [
        'cgconfig',
        'cgred',
        'openshift-cgroups',
        'openshift-port-proxy',
      ]:
        require => [
          Package['rubygem-openshift-origin-node'],
          Package['openshift-origin-node-util'],
          Package['openshift-origin-node-proxy'],
          Package['openshift-origin-port-proxy']
        ],
        enable  => true,
      }
    }else{
      warning 'Please ensure that cgconfig, cgred, openshift-cgroups, openshift-port-proxy are running on all nodes'
    }

    exec { 'Restoring cgroups SELinux contexts':
      command =>
        '/sbin/restorecon -rv /etc/cgconfig.* \
            /cgroup',
      require => [
        File['/cgroup'],
        File['cgroups config'],
        Package['rubygem-openshift-origin-node']
      ],
    }
  }else{
    warning 'Please enable that cgroups are enabled with the following mount points:'
    warning 'cpuset  = /cgroup/cpuset;'
    warning 'cpu     = /cgroup/all;'
    warning 'cpuacct = /cgroup/all;'
    warning 'memory  = /cgroup/all;'
    warning 'devices = /cgroup/devices;'
    warning 'freezer = /cgroup/all;'
    warning 'net_cls = /cgroup/all;'
    warning 'blkio   = /cgroup/blkio;'
  }

  if $::openshift_origin::configure_pam == true {
    $pam_sshd_template = $::operatingsystem ? {
      'Fedora' => template('openshift_origin/node/pam.sshd-fedora.erb'),
      default  => template('openshift_origin/node/pam.sshd-rhel.erb'),
    }

    file { 'openshift node pam sshd':
      ensure  => present,
      path    => '/etc/pam.d/sshd',
      content => $pam_sshd_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $pam_runuser_template = $::operatingsystem ? {
      default => template('openshift_origin/node/pam.runuser-fedora.erb'),
    }

    file { 'openshift node pam runuser':
      ensure  => present,
      path    => '/etc/pam.d/runuser',
      content => $pam_runuser_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $pam_runuser_l_template = $::operatingsystem ? {
      default => template('openshift_origin/node/pam.runuser-l-fedora.erb'),
    }

    file { 'openshift node pam runuser-l':
      ensure  => present,
      path    => '/etc/pam.d/runuser-l',
      content => $pam_runuser_l_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $pam_su_template = $::operatingsystem ? {
      'Fedora' => template('openshift_origin/node/pam.su-fedora.erb'),
      default  => template('openshift_origin/node/pam.su-rhel.erb'),
    }

    file { 'openshift node pam su':
      ensure  => present,
      path    => '/etc/pam.d/su',
      content => $pam_su_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $pam_system_auth_ac_template = $::operatingsystem ? {
      'Fedora' => template('openshift_origin/node/pam.system-auth-ac-fedora.erb'),
      default  => template('openshift_origin/node/pam.system-auth-ac-rhel.erb'),
    }

    file { 'openshift node pam system-auth-ac':
      ensure     => present,
      path       => '/etc/pam.d/system-auth-ac',
      content    => $pam_system_auth_ac_template,
      owner      => 'root',
      group      => 'root',
      mode       => '0644',
      require => Package['pam_openshift'],
    }
    
    $os_all_unmanaged_users = [['root','adm','apache'], $::openshift_origin::os_unmanaged_users]
    file { 'openshift node pam-namespace sandbox.conf':
      ensure     => present,
      path       => '/etc/security/namespace.d/sandbox.conf',
      content    => template('openshift_origin/node/namespace-d-sandbox.conf.erb'),
      owner      => 'root',
      group      => 'root',
      mode       => '0644',
      require => Package['pam_openshift'],
    }
    
    file { 'openshift node pam-namespace tmp.conf':
      ensure     => present,
      path       => '/etc/security/namespace.d/tmp.conf',
      content    => template('openshift_origin/node/namespace-d-tmp.conf.erb'),
      owner      => 'root',
      group      => 'root',
      mode       => '0644',
      require => Package['pam_openshift'],
    }
    
    file { 'openshift node pam-namespace vartmp.conf':
      ensure     => present,
      path       => '/etc/security/namespace.d/vartmp.conf',
      content    => template('openshift_origin/node/namespace-d-vartmp.conf.erb'),
      owner      => 'root',
      group      => 'root',
      mode       => '0644',
      require => Package['pam_openshift'],
    }
  }else{
    warning 'Please configure pam on all nodes.'
  }

  file { 'sysctl config tweaks':
    ensure  => present,
    path    => '/etc/sysctl.conf',
    content => template('openshift_origin/node/sysctl.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  exec { 'Update sshd configs':
    command => '/bin/echo \'AcceptEnv GIT_SSH\' >> \'/etc/ssh/sshd_config\'',
    unless  => '/bin/grep -qFx \'AcceptEnv GIT_SSH\' \'/etc/ssh/sshd_config\''
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'crond': enable  => true }

    $openshift_init_provider = $::operatingsystem ? {
      'Fedora' => 'systemd',
      default  => ''
    }

    service { ['openshift-gears', 'openshift-node-web-proxy']:
      require  => [
        Package['rubygem-openshift-origin-node'],
        Package['openshift-origin-node-util'],
        Package['openshift-origin-node-proxy']
      ],
      provider => $openshift_init_provider,
      enable   => true,
    }

    service { 'mcollective':
      require => [
        Package['mcollective']
      ],
      enable  => true,
    }
  }else{
    warning 'Please ensure that mcollective, cron, openshift-gears, openshift-node-web-proxy are running on all nodes'
  }

  exec { 'Restoring SELinux contexts':
    command =>
      '/sbin/restorecon -rv /var/lib/openshift \
          /var/lib/openshift/.httpd.d/',
    require => [
      Package['rubygem-openshift-origin-node']
    ],
  }

  case $::operatingsystem {
    'Fedora' : {
      exec { 'jenkins repo key':
        command =>
            '/usr/bin/rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key',
        creates => '/etc/yum.repos.d/jenkins.repo'
      }

      yumrepo { 'jenkins':
        name     => 'jenkins',
        baseurl  => 'http://pkg.jenkins-ci.org/redhat',
        enabled  => 1,
        gpgcheck => 1,
      }

      Exec['jenkins repo key'] -> Yumrepo['jenkins']
    }
    default: {
      #no changes required
    }
  }

  package {
    [
      'openshift-origin-cartridge-abstract',

      'openshift-origin-cartridge-10gen-mms-agent-0.1',
      'openshift-origin-cartridge-cron-1.4',
      'openshift-origin-cartridge-diy-0.1',
      'openshift-origin-cartridge-haproxy-1.4',
      'openshift-origin-cartridge-mongodb-2.2',
      'openshift-origin-cartridge-mysql-5.1',
      'openshift-origin-cartridge-nodejs-0.6',

      'openshift-origin-cartridge-jenkins-1.4',
      'openshift-origin-cartridge-jenkins-client-1.4',

      'openshift-origin-cartridge-community-python-2.7',
      'openshift-origin-cartridge-community-python-3.3',
    ]:
    ensure  => present,
    require => [
      Yumrepo[openshift-origin],
      Yumrepo[openshift-origin-deps]
    ],
  }

  case $::operatingsystem {
    'Fedora' : {
      package {
        [
          'openshift-origin-cartridge-postgresql-9.2',
          'openshift-origin-cartridge-ruby-1.9',
	  'openshift-origin-cartridge-php-5.4',
	  'openshift-origin-cartridge-perl-5.16',
	  'openshift-origin-cartridge-phpmyadmin-3.5',
        ]:
        ensure  => present,
        require => [
          Yumrepo[openshift-origin],
          Yumrepo[openshift-origin-deps]
        ],
      }
    }
    default : {
      package {
        [
          'openshift-origin-cartridge-postgresql-8.4',
          'openshift-origin-cartridge-ruby-1.9-scl',
	  'openshift-origin-cartridge-php-5.3',
	  'openshift-origin-cartridge-perl-5.10',
	  'openshift-origin-cartridge-python-2.6',
	  'openshift-origin-cartridge-phpmyadmin-3.4',
        ]:
        ensure  => present,
        require => [
          Yumrepo[openshift-origin],
          Yumrepo[openshift-origin-deps]
        ],
      }
    }
  }
}
