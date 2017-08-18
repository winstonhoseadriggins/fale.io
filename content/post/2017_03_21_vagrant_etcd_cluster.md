---
date: 2017-03-21
title: Vagrant etcd cluster
aggregators:
  - Fedora
  - KDE
categories:
  - Ansible
  - Linux
tags:
  - Vagrant
  - etcd
---

Sometimes I need to do some tests which are destructive and I need to perform them over and over until I figure out a process that reliably brings me to a desired state.
I usually create some kind of easy to provision environments and work on it.

In the last few weeks I found myself working on an etcd cluster, so I created an environment with Vagrant, and since I had to write the majority of this by myself, since I have not found anything on Google that suited my needs, I'm going to share this with you.

I have created 3 files to setup the environment, install etcd and cluster the machines.

The first file is the `Vagrantfile`, and looks like this:

~~~ruby
N = 3
Vagrant::configure("2") do |config|
    (0..N-1).each do |machine_id|
        config.vm.box = "centos/7"
        config.vm.define "etcd#{machine_id}" do |machine|
            machine.vm.hostname = "etcd#{machine_id}"
            machine.vm.network "private_network", ip: "192.168.60.#{10+machine_id}"
            if machine_id == N-1
                machine.vm.provision :ansible do |ansible|
                    ansible.limit = "all"
                    ansible.playbook = "setup.yaml"
                end
            end
        end
    end
end
~~~

As you can notice, in the first line `N` is declared.
`N` is the number of nodes of the cluster.
If you change it from 3 to 5, for instance, everything will work as well.

Since I have used the `centos/7` image, CentOS 7 will be installed, and to to the high compatibility of the CentOS image and the absence of specific syntax for any specific virtualisation backend, this code should perform properly on the majority of virtualisation backends.

The second file `setup.yaml` is an Ansible Playbook to actually install the etcd daemon.

~~~yaml
---
- name: Configure properly etcd
  hosts: all
  tasks:
    - name: Ensure that etcd is present
      yum:
        name: etcd
        state: present
      become: True
    - name: Ensure that etcd is properly configured
      template:
        src: etcd.conf
        dest: /etc/etcd/etcd.conf
      become: True
    - name: Ensure etcd is running
      service:
        name: etcd
        state: started
        enabled: True
      become: True
~~~

As you can notice, I install etcd from yum.
This allowed me to simplify the process and be able to keep it updated using simply yum.

The third file (`etcd.conf`), is a template for the `/etc/etcd/etcd.conf` file.

~~~django
ETCD_NAME={{ ansible_hostname }}
ETCD_INITIAL_ADVERTISE_PEER_URLS=http://{{ ansible_eth1.ipv4.address }}:2380
ETCD_LISTEN_PEER_URLS=http://{{ ansible_eth1.ipv4.address }}:2380
ETCD_LISTEN_CLIENT_URLS=http://{{ ansible_eth1.ipv4.address }}:2379
ETCD_ADVERTISE_CLIENT_URLS=http://{{ ansible_eth1.ipv4.address }}:2379
ETCD_INITIAL_CLUSTER_TOKEN=etcd-vagrant-test
ETCD_INITIAL_CLUSTER="{% for host in groups['all'] %}{{ hostvars[host]['ansible_hostname'] }}=http://{{ hostvars[host]['ansible_eth1']['ipv4']['address'] }}:2380,{% endfor %}"
~~~

This template will generate a proper configuration file with all needed variables setted up properly, so that when etcd will be run (last step of the Ansible Playbook) the nodes will recognise each other and start the election to determine the leader.

I hope this will be useful for other people as well.

A copy of the sources can also be found on [GitHub](https://github.com/Fale/vagrant/tree/master/etcd/).
