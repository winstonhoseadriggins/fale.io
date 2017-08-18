---
date: 2017-07-26
title: Ansible Tower in Vagrant
aggregators:
  - Fedora
  - KDE
categories:
  - Linux
  - Ansible
tags:
  - Ansible Tower
  - Vagrant
---

A lot of times during my job I found myself with the need of Ansible Tower testing environments.

In the last few weeks I created a Vagrant script to actually automate it.

As this is a single host installation (which is usually more than enough for the majority of tests I do, the Vagrant file is very easy:

```ruby
Vagrant.configure(2) do |config|

    # Set machine size
    config.vm.provider :libvirt do |domain|
        domain.memory = 2048
        domain.cpus = 1
    end

    # Tower/PgSQL machine
    config.vm.define "tower" do |tower|
        tower.vm.box = "centos/7"
    end

    # Ansible Tower configuration
    config.vm.provision "ansible" do |ansible|
        ansible.playbook = "playbook.yaml"
    end

end
```

I basically create a 2Gb of RAM machine leveraging libvirt and run an Ansible Playbook on it.
The reason I created a 2Gb of RAM machine and I've not tried to shrink it further is because the Ansible Tower installation checks for 2Gb of RAM, and I wanted to create something easy.
I'm sure I could patch the installer to accept a 1Gb machine, but it's not worth the effort to me. Also, in my usual usage of the computer I rarely go below 11Gb free memory, so I'm not too concerned in giving 2Gb to my VM.

In the Vagrant file we were calling an Ansible Playbook to install Ansible Tower.
Here is the Ansible Playbooks:

```yaml
---
- hosts: all
  name: Install Ansible Tower
  vars:
    version: '3.1.3'
  tasks:
    - name: Ensure EPEL is enabled
      yum:
        name: epel-release
        state: present
      become: True
    - name: Set hostname
      hostname:
        name: '{{ inventory_hostname }}' 
      become: True
    - get_url:
        url: 'http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-{{ version }}.tar.gz'
        dest: '/tmp/ansible-tower-setup-{{ version }}.tar.gz'
    - unarchive:
        src: '/tmp/ansible-tower-setup-{{ version }}.tar.gz'
        dest: /tmp
    - copy:
        remote_src: True
        dest: '/tmp/ansible-tower-setup-{{ version }}/inventory'
        src: /vagrant/inventory
    - shell: ./setup.sh
      args:
        chdir: '/tmp/ansible-tower-setup-{{ version }}'
      become: True
```

As you can see is a very straightforward Ansible Playbook which ensures that EPEL is enabled (since is required by Ansible Tower installer), then proceeds to set the hostname matching Vagrant hostname.
After this Ansible Tower installer gets downloaded, uncompressed, the inventory file gets imported and finally the installer gets run.

To make the process working we do need a valid Ansible Inventory file.
I use the following one:

```ini
[tower]
localhost ansible_connection=local

[database]
localhost ansible_connection=local

[all:vars]
admin_password='admin'

pg_host='localhost'
pg_port='5432'

pg_database='awx'
pg_username='awx'
pg_password='tower'

rabbitmq_port=5672
rabbitmq_vhost=tower
rabbitmq_username=tower
rabbitmq_password='tower'
rabbitmq_cookie=cookiemonster

# Needs to be true for fqdns and ip addresses
rabbitmq_use_long_name=false
```

As you can immagine from the Ansible Inventory file, the user `admin` will end up having the password `admin`.

To run the whole thing you'll just need to `vagrant up` the stack and you'll get your Ansible Tower installation.
Remember that - at least at the moment of writing - Ansible Tower is close source and will require a valid license to actually work.
The first time you'll login it will ask you for a valid license that you can provide (if you already have one) or require one [here](https://www.ansible.com/license).

For complete and updated code, you can have a look [here](https://github.com/Fale/vagrant/tree/master/tower-single).
