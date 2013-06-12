#!/bin/bash -x

#Disable updates-testing repository
if [ -a /etc/yum.repos.d/fedora-updates-testing.repo ] ; then
  mv /etc/yum.repos.d/fedora-updates-testing.repo /etc/yum.repos.d/fedora-updates-testing.disabled;
fi

yum install --skip-broken -y ruby ruby-irb ruby-libs ruby-devel rubygem-thor puppet git rubygem-cucumber
yum install -y mod_passenger rubygem-passenger rubygem-passenger-devel rubygem-passenger-native rubygem-passenger-native-libs

yum update -y --exclude=kernel* --skip-broken

#Workaround https://bugzilla.redhat.com/show_bug.cgi?id=952955
sed -i '/include-dependencies/d' /usr/share/ruby/vendor_ruby/puppet/provider/package/gem.rb

#Patch facter IP address fact
rm -f /usr/share/ruby/vendor_ruby/facter/ipaddress.rb
curl --output /usr/share/ruby/vendor_ruby/facter/ipaddress.rb https://raw.github.com/puppetlabs/facter/master/lib/facter/ipaddress.rb

PASSENGER_DIR=`ls -d /usr/lib64/gems/ruby/passenger-3.*`
PASSENGER_VERSION=`basename ${PASSENGER_DIR}`
echo "Passenger version ${PASSENGER_VERSION}\n\n"

mkdir -p /usr/share/gems/gems/${PASSENGER_VERSION}/ext/ruby/native
cp -f /usr/lib64/gems/ruby/${PASSENGER_VERSION}/lib/native/* /usr/share/gems/gems/${PASSENGER_VERSION}/ext/ruby/native/

DEVICE=`ip link | grep BROADCAST | awk ' BEGIN {FS=": "} {print $2}'`
sed -i "s/eth_device.*/eth_device => '${DEVICE}'/" /home/vagrant/manifests/configure.pp
