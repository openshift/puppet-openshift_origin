require 'spec_helper'

describe 'openshift_origin' do
  let :facts do {
    :osfamily => 'RedHat',
  } end

  describe 'ose supported configs' do
    let :facts do {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemmajrelease => '6',
      :operatingsystemrelease => '6.5',
      :architecture => 'x86_64',
    } end
    let :params do {
      :ose_version  => 2.2,
      :roles        => ['broker'],
      # BIND / named config
      # This is the key for updating the OpenShift BIND server
      :bind_key                       => 'something',
      # The domain under which applications should be created.
      :domain                         => 'example.com',
      # Apps would be named <app>-<namespace>.example.com
      # This also creates hostnames for local components under our domain
      :register_host_with_nameserver  => true,
      # Forward requests for other domains (to Google by default)
      :conf_nameserver_upstream_dns   => ['8.8.8.8', '8.8.4.4'],

      # NTP Servers for OpenShift hosts to sync time
      :ntp_servers => ['ntp.example.com iburst'],

      # The FQDNs of the OpenShift component hosts
      :broker_hostname     => 'broker.example.com',
      :msgserver_hostname  => 'broker.example.com',
      :node_hostname       => 'node.example.com',

      # To enable installing the Jenkins cartridge:
      :install_method    => 'yum',
      :jenkins_repo_base => 'http://pkg.jenkins-ci.org/redhat',

      # Cartridges to install on Node hosts
      :install_cartridges         => ['php', 'mysql'],

      #Enable development mode for more verbose logs
      :development_mode           => true,

      # apache-mod-rewrite is deprecated
      :node_frontend_plugins   => ['apache-vhost'],

      # clustered message servers need > 2 nodes
      :msgserver_cluster  => true,
      :msgserver_cluster_members  => ['1.1.1.1','2.2.2.2'],

      # replicasets require 3 nodes
      :mongodb_replicasets  => true,
      :mongodb_replicasets_members  => ['a.example.com','b.example.com','c.example.com'],
    } end
    it { should compile.with_all_deps }
  end
end
