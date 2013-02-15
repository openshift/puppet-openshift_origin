# Class: ipa::client
#
# IPA client.
#
# Parameters:
#  $ensure:
#    Whether XYZ should be 'present' or 'absent'. Defaults to 'present'.
#  $other:
#    Optional other. Default: none
#
# Sample Usage :
#  class { 'ipa::client':
#      install_options = '--enable-dns-updates',
#  }
#  ipa-client-install --enable-dns-updates --configure-ssh --mkhomedir
#

# can I even do this - inherit then define?
# make sure we use IPA server as ntp server so Kerberos can sync
class openshift_origin::ipa inherits openshift_origin::ntpd {
	ensure_resource( 'package', 'ntpdate', { ensure => 'latest' } )

	class { 'ntp':
	ensure     => running,
	servers    => [ '${ipa_server}', # may have multiple IPA servers/replicas
					'time.apple.com iburst',
	                'pool.ntp.org iburst',
	                'clock.redhat.com iburst'],
	autoupdate => true
	}
}

class openshift_origin::ipa{
	# if Fedora then freeipa, if RHEL then ipa
	case $::operatingsystem {
		'Fedora': { $ipa = 'freeipa'}
		default : { $ipa = 'ipa' }
	}

	package { "${ipa}-client":     ensure => present }
	package { "${ipa}-admintools":	ensure => present }

	# for DNS  setup/updates
	package { "bind": ensure => present }
	package { "bind-dyndb-ldap": ensure => present }


	# IPA client params
	if $domain      { $opt_domain      = " --domain=${domain}"           }
	if $ipa_server  { $opt_server      = " --server=${ipa_server}"       }
	if $password    { $opt_password    = " -p admin -w ${password}"      }
	if $dns_updates { $opt_dns_updates = " --enable-dns-updates"         }
	if $automount   { $opt_automount   = " --mkhomedir"                  }

	# define Kerberos Realm e.g. $realm = EXAMPLE.COM

	# setup firewalls

	# initial setup for Puppet Agent to be a client of IPA Server
	# kinit PM on PA
	exec { 'kinit-puppetmaster':
		command => "kinit -kt /etc/krb5.keytab host/${puppetmaster_hostname}",
		unless => "kinit -kt /etc/krb5.keytab host/${puppetmaster_hostname} | grep 'ERROR'",
			# need to somehow fail gracefully
	}


	# install ipa-client if /etc/ipa/default.conf does not exist
	# wtf am I supposed to do w/ passwords? 

	exec { 'ipa-client-install-check':
		command => "/usr/sbin/ipa-client-install --installed | grep 'True'",
		# somehow catch
		creates => '/etc/ipa/default.conf',
		require => Package["${ipa}-client" ],
	}

	# add service if it's not already enrolled in IPA server
	exec { 'ipa-service-add':
		command => "/bin/ipa service-add puppet/$(/bin/hostname)",
		onlyif  => "/bin/ipa service-show puppet/$(/bin/hostname) | \
		grep 'service not found'",
		require => [
			Package["${ipa}-client"],
			Package["${ipa}-admintools"],
		]
	}

	# get IPA cert if .pem files don't exist
	exec {'ipa-getcert':
		command => "/bin/ipa-getcert request -K puppet/$(/bin/hostname) \
		-D ${domain} -k /etc/puppet/private_keys/$(/bin/hostname).pem -f\
		/etc/puppet/public_keys/$(/bin/hostname).pem",
		creates => ['/etc/puppet/private_keys/$(/bin/hostname).pem',
		'/etc/puppet/public_keys/$(/bin/hostname).pem'],
		require => [
			Package['${ipa}-client'],
			Package['${ipa}-admintools'],
			Exec['ipa-service-add'],
		],
	}

	# if broker machine
	# should this be case broker/node?
	if $::openshift_origin::broker {

		# kinit Broker
		exec { 'kinit':
			command => "/bin/kinit -k -t /etc/httpd/conf/puppet.keytab",
			onlyif  => "/usr/bin/klist | grep 'No credentials cache found'",
			returns => '',
			require =>[
				Package['${ipa}-client'],
				Package['${ipa}-admintools'],
			],
		}

		# add the Broker as a service to IPA
		exec { 'ipa-service-add-broker':
			command => "/bin/ipa service-add HTTP/${broker_domain}",
			onlyif  => "/bin/ipa service-show HTTP/${broker_domain} |\
			grep 'service not found",
			require => [
				Package["${ipa}-client"],
				Package["${ipa}-admintools"],
				Exec["kinit"],
			],
		}

		# if Broker doesn't have keytab, get one
		exec { 'ipa-getkeytab':
			command => "/sbin/ipa-getkeytab -s ${ipa_server} -p puppet/$(/bin/hostname)\
			-k /etc/httpd/conf/puppet.keytab",
			creates => "/etc/httpd/conf/puppet.keytab",
			require => [
				Package['${ipa}-client'],
				Package['${ipa}-admintools'],
				Exec['kinit'],
				Exec['ipa-service-add-broker'],
			],
		}

		# make sure keytab is owned by apache
		file { 'keytab':
			owner   =>  'apache',
			group   =>  'apache', # is this the right group?
			mode    =>  '0640',  # is this right mode?
			subscribe => Exec['ipa-getkeytab'],
			require =>  Package['freeipa-client'],
		}

		# configure Apache w/ kerberos 
		file { 'Auth plugin config':
	        path    =>
	          '/etc/openshift/plugins.d/openshift-origin-auth-kerberos.conf',
	        content =>
	          template('openshift_origin/broker/plugins/auth/kerberos/kerberos.conf.plugin.erb'),
	        owner   => 'root', # are these the correct permissions?
	        group   => 'root',
	        mode    => '0644',
	        subscribe => File['keytab'],
	        require => Package['rubygem-openshift-origin-auth-remote-user'],
      }
	}

	# if node machine
	if $::openshift_origin::node {
		# do they need a keytab?
	}
}

# need to configure BIND correctly
class openshift_origin::ipa inherits openshift_origin::named {

}

# Class: ipa::params
#
# Parameters for and from the ipa module.
#
# Parameters :
#  none
#
# Sample Usage :
#  include nginx::params
#
class ipa::params {

    # The main "ipa" name, used for packages, services, etc.
    case $::operatingsystem {
        'Fedora': { $ipa = 'freeipa' }
         default: { $ipa = 'ipa' }
    }

}

# Class: ipa::server
#
# IPA server. Note that all of the parameters are only used when initially
# installing and configuring the IPA server instance. If any parameters are
# changed later on, it will not be taken into account.
#
# Sample Usage :
#  class { 'ipa::server':
#      realm_name      => 'EXAMPLE.COM',
#      domain_name     => 'example.com',
#      dm_password     => 'godBechyuemtir',
#      admin_password  => 'KierwirgOrokCyb',
#      install_options => '--ssh-trust-dns --subject="O=Example" --setup-dns --forwarder=8.8.8.8 --forwarder=8.8.4.4 --reverse-zone=1.168.192.in-addr.arpa.',
#  }
#
class ipa::server (
    $realm_name,
    $domain_name,
    $dm_password,
    $admin_password,
    $install_options = '',
    $dns_packages = true
) inherits ipa::params {

    package { "${ipa}-server": ensure => installed }
    if $dns_packages {
        package { [ 'bind', 'bind-dyndb-ldap' ]:
            ensure => installed,
            before => Exec['ipa-server-install'],
        }
    }

    # Initial unattended installation
    exec { 'ipa-server-install':
        command => "/usr/sbin/ipa-server-install -r ${realm_name} -n ${domain_name} -p ${dm_password} -a ${admin_password} --unattended ${install_options} &>/root/ipa-install.log",
        creates => '/var/lib/ipa/sysrestore/sysrestore.state',
        require => Package["${ipa}-server"],
    }

}