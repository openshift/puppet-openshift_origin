#!/bin/bash
#
# Script to insatll and configure OpenShift Origin v3.0.
#
# Broker server deployment example using non-default settings:
#
# export PREFIX=corp.com
# export UPSTREAM_DNS=10.10.10.10
# export UPSTREAM_NTP=ntp.corp.com
# export USERNAME=admin
# export PASSWORD=ChangeMe
# export ETH_DEV=eth1
# export REPO_NAME=danehans
# export REPO_BRANCH=latest_changes
#
# Node server deployment example using non-default settings:
# 1. Obtain the DNS_SEC_KEY from the broker node:
#   a. SSH to the Broker server
#   b. Set your DNS name environmental variable: export PREFIX=example.com
#   c. cat /var/named/K${PREFIX}.*.key  | awk '{print $8}'
#   d. Copy the key
#   e. Obtain the IP address of the Broker server: ifconfig -a
# 2. Set the DNS_SEC_KEY on the Node server.
#   a. SSH to the Node server
#   b. Set the DNSSEC key: export DNS_SEC_KEY=<KEY_FROM_STEP_1c>
#   d. Set the additional environmental variables below:
#
# export INSTALL_TYPE=node
# export PREFIX=example.com
# export UPSTREAM_DNS=10.10.10.10
# export UPSTREAM_NTP=ntp.corp.com
# export BROKER_IP=<IP_FROM_STEP_1d>
# export ETH_DEV=eth0
# export REPO_NAME=openshift
# export REPO_BRANCH=master
#
set -x
set -e

# Check for Root user
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

#SET Installation type- broker or node
export INSTALL_TYPE="${INSTALL_TYPE:-}"

# Install base packages
yum install -y puppet facter tar git vim

if [ "${INSTALL_TYPE}" == "broker" ] ; then
  yum install -y bind
fi

# Set the DNS name used for the OSO deployment
export PREFIX="${PREFIX:-example.com}"

# Set the upstream DNS server IP that the broker will use
export UPSTREAM_DNS="${UPSTREAM_DNS:-8.8.8.8}"

# Set NTP server
export UPSTREAM_NTP="${UPSTREAM_NTP:-clock.redhat.com}"

# Create and capture DNSSEC key
if [ "${INSTALL_TYPE}" == "broker" ] ; then
  dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named ${PREFIX}
  export DNS_SEC_KEY=`cat /var/named/K${PREFIX}.*.key  | awk '{print $8}'`
else
  export DNS_SEC_KEY="${DNS_SEC_KEY:-}"
fi

# Obtain the systems FQDN needed for the puppet module
export HOSTNAME=`facter hostname`

# Set the OSO authentication credentials
if [ "${INSTALL_TYPE}" == "broker" ] ; then
  export USERNAME="${USERNAME:-openshift}"
  export PASSWORD="${PASSWORD:-password}"
fi

# Set the interface name the broker will use
export ETH_DEV="${ETH_DEV:-eth0}"

# Set the Repo Name and Branch
export REPO_NAME="${REPO_NAME:-openshift}"
export REPO_BRANCH="${REPO_BRANCH:-master}"

# Set the Broker IP address
if [ "${INSTALL_TYPE}" == "node" ] ; then
  export BROKER_IP="${BROKER_IP:-}"
fi

# Install openshift_origin puppet module
cd ~
mkdir -p /etc/puppet/modules
if ! [ -d openshift_origin ]; then
  git clone -b $REPO_BRANCH https://github.com/$REPO_NAME/puppet-openshift_origin.git /etc/puppet/modules/openshift_origin
fi

# Install module dependencies
puppet module install puppetlabs/stdlib
puppet module install puppetlabs/ntp

# Configure the Puppet manifest
if [ "${INSTALL_TYPE}" == "broker" ] ; then
  cat << EOF > /etc/puppet/configure.pp
  \$my_hostname='${HOSTNAME}.${PREFIX}'

  exec { "set_hostname":
    command => "/bin/hostname \${my_hostname}",
    unless  => "/bin/hostname | /bin/grep \${my_hostname}",
  }

  exec { "set_etc_hostname":
    command => "/bin/echo \${my_hostname} > /etc/hostname",
    unless  => "/bin/grep \${my_hostname} /etc/hostname",
  }

class { 'openshift_origin' :
  # Components to install on this host:
  roles                      => ['broker','named','activemq','datastore'],
  # BIND / named config
  # This is the key for updating the OpenShift BIND server
  bind_key                   => '${DNS_SEC_KEY}',
  # The domain under which applications should be created.
  domain                     => '${PREFIX}',
  # Apps would be named <app>-<namespace>.example.com
  # This also creates hostnames for local components under our domain
  register_host_with_named   => true,
  # Forward requests for other domains (to Google by default)
  conf_named_upstream_dns    => ['${UPSTREAM_DNS}'],
  # NTP Servers for OpenShift hosts to sync time
  ntp_servers                => ["${UPSTREAM_NTP} iburst"],
  # The FQDNs of the OpenShift component hosts
  broker_hostname            => \$my_hostname,
  named_hostname             => \$my_hostname,
  datastore_hostname         => \$my_hostname,
  activemq_hostname          => \$my_hostname,
  # Auth OpenShift users created with htpasswd tool in /etc/openshift/htpasswd
  broker_auth_plugin         => 'htpasswd',
  # Username and password for initial openshift user
  openshift_user1            => '${USERNAME}',
  openshift_password1        => '${PASSWORD}',
  #Enable development mode for more verbose logs
  development_mode           => true,
  # Set if using an external-facing ethernet device other than eth0
  conf_node_external_eth_dev => '${ETH_DEV}',
}
EOF
fi

if [ "${INSTALL_TYPE}" == "node" ] ; then
  cat << EOF > /etc/puppet/configure.pp
  \$my_hostname='${HOSTNAME}.${PREFIX}'

  exec { "set_hostname":
    command => "/bin/hostname \${my_hostname}",
    unless  => "/bin/hostname | /bin/grep \${my_hostname}",
  }

  exec { "set_etc_hostname":
    command => "/bin/echo \${my_hostname} > /etc/hostname",
    unless  => "/bin/grep \${my_hostname} /etc/hostname",
  }

class { 'openshift_origin' :
  # Components to install on this host:
  roles                      => ['node'],
  # BIND / named config
  # This is the key for updating the OpenShift BIND server
  bind_key                   => '${DNS_SEC_KEY}',
  named_ip_addr              => '${BROKER_IP}',
  # The domain under which applications should be created.
  domain                     => '${PREFIX}',
  # Apps would be named <app>-<namespace>.example.com
  # This also creates hostnames for local components under our domain
  register_host_with_named   => true,
  # Forward requests for other domains (to Google by default)
  conf_named_upstream_dns    => ['${UPSTREAM_DNS}'],
  # NTP Servers for OpenShift hosts to sync time
  ntp_servers                => ["${UPSTREAM_NTP} iburst"],
  # The FQDNs of the OpenShift component hosts
  broker_hostname            => '${BROKER_IP}',
  activemq_hostname          => '${BROKER_IP}',
  node_hostname              => \$my_hostname,
  #Enable development mode for more verbose logs
  development_mode           => true,
  # To enable installing the Jenkins cartridge:
  install_method             => 'yum',
  jenkins_repo_base          => 'http://pkg.jenkins-ci.org/redhat',
  # Cartridges to install on Node hosts
  install_cartridges         => ['php', 'mysql'],
  # Set if using an external-facing ethernet device other than eth0
  conf_node_external_eth_dev => '${ETH_DEV}',
}
EOF
fi

# Apply the puppet manifest to the system
puppet apply -v -d /etc/puppet/configure.pp | tee /var/log/configure_openshift.log
