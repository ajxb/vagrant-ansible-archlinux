require 'yaml'

CONF = YAML.load_file('config.yaml')

workers = []
(1..CONF['numworkers']).each do |n| 
  ip = "#{CONF['baseip'][0]}.#{CONF['baseip'][1]}.#{CONF['baseip'][2]}.#{CONF['baseip'][3] + n}"
  workers.push( { name: "worker#{n}", ip: ip } )
end

template = <<~HOSTS
  [all:vars]
  ansible_connection=ssh
  ansible_user=vagrant
  ansible_ssh_pass=vagrant

  [managers]
  manager

  [workers]
HOSTS

File.open('ansible_hosts', 'w') { |file|
  file.write(template)
  workers.each do |worker|
    file.write("#{worker[:name]}\n")
  end
}

Vagrant.configure('2') do |config|
  config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")
  config.betterhosts.aliases = CONF['aliases'] if Vagrant.has_plugin?("vagrant-betterhosts")

  config.vm.provider :virtualbox do |vb|
    vb.memory = CONF['memory']
    vb.cpus   = CONF['cpus']
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    vb.customize ["modifyvm", :id, "--vram", "32"]
  end

  # Start worker nodes first
  workers.each do |worker|
    config.vm.define worker[:name] do |machine|
      machine.vm.box = 'archlinux/archlinux'
      machine.vm.hostname = worker[:name]
      machine.vm.network 'private_network', ip: worker[:ip]
      machine.vm.provision 'shell', inline: 'pacman --sync --refresh --sysupgrade --noconfirm', reboot: true
    end
  end

  # Start manager and check connection to workers
  config.vm.define 'manager' do |machine|
    machine.vm.box = 'archlinux/archlinux'
    machine.vm.hostname = 'manager'
    machine.vm.network 'private_network', ip: "#{CONF['baseip'][0]}.#{CONF['baseip'][1]}.#{CONF['baseip'][2]}.#{CONF['baseip'][3]}"
    machine.vm.provision 'shell', inline: 'pacman --sync --refresh --sysupgrade --noconfirm', reboot: true
    machine.vm.provision 'shell', inline: 'pacman --sync --noconfirm ansible sshpass vi'
    if File.file? 'ansible_hosts'
      machine.vm.provision 'file', source: 'ansible_hosts', destination: '/tmp/hosts'
      machine.vm.provision 'shell', inline: 'cp /tmp/hosts /etc/ansible/hosts'
    end
  end
end
