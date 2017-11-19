Vagrant.configure("2") do |config|
  [
    ["vault", "192.168.0.50", "vault/provision.sh"]
  ].each do |name, ip, script|
    config.vm.define name do |server|
      server.vm.box = "ubuntu/trusty64"
      server.vm.hostname = "#{name}.ubuntu.box"
      server.vm.network "private_network", ip: ip
      server.vm.provider :virtualbox do |vb|
        vb.memory = 256
      end
      server.vm.provision "shell" do |s|
        s.path = script
      end
    end
  end
end