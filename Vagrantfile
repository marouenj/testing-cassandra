$script = <<SCRIPT
sudo apt-get update
sudo swapoff --all
SCRIPT

Vagrant.configure("2") do |cluster|

    cluster.vm.define "cassandra" do |machine|
        machine.vm.box = "ubuntu/trusty64"
        machine.vm.hostname = "cassandra"

        machine.vm.provision "shell", inline: $script
        machine.vm.provision "docker", images: ["cassandra:latest"]

        machine.vm.provider "virtualbox" do |vbox|
            vbox.name = "cassandra"
            vbox.memory = 2048
        end
    end

end
