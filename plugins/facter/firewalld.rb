Facter.add( "use_firewalld" ) do
  setcode do
    File.exist?('/usr/bin/firewall-cmd') && system("/usr/bin/firewall-cmd --state")
  end
end