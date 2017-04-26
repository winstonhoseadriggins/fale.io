---
date: 2017-04-26
title: libVirt on Hetzner
aggregators:
  - Fedora
  - KDE
categories:
  - Linux
tags:
  - KVM
  - libvirt
  - networking
  - Hetzner
---

After many years of using Hetzner as a server provider, and having rented from them multiple servers for many reasons, I decided to rent a server with 128Gb of RAM to do some tests with many (virtualized) machines on top of CentOS.

As it often happens, hosting providers put in place a lot of security measurements that sometimes make doing simple stuff more complex.
The first approach I tried was using the (only) Ethernet interface as a bridged interface, but that did not brought me very far.
Speaking with the support they pointed out that it was impossible in my setup, so I moved to the second option: the *broute*.

In the broute approach, a bridge is added to the interface, but all the traffic gets routed.
With the broute the configuration is very easy, in fact, to install and properly configure libVirt in such environment, the following steps are enough.

Let's start installing the needed software.

    yum install bridge-utils libvirt libvirt-daemon-kvm qemu-kvm virt-install libguestfs-tools

In my case, I'll use `qemu-kvm` as virtualisation engine, and that's why I'm installing it.
Also, I install `virt-install` and `libguestfs-tools` since I want to do some changes to the images before running them.

The second step is to start and enable the `libvirtd` daemon:

    systemctl enable libvirtd
    systemctl start libvirtd

We can now move to configure the networking.
In my case, I had the following situation IP wide:

* 1 primary IPv4 (`88.99.208.11/32`)
* 1 primary IPv6 network (`2a01:4f8:10a:390a::1/64`)
* 1 additional IPv4 network (`88.99.247.224/28`)

My goal was to create 3 different networks:

* an `internal` network that is not routable but where all VMs can talk to each other (and to the underlying system)
* a `public` network where all machines get a public IP
* a `private` network that is routable through NAT and therefore the machines can connect to internet but not be reached from outside

## Prepare the OS
The first step is ensure that the kernel rp_filter will not block the packages during the routing process.
To do so, you need to put in the file `/etc/sysctl.d/98-rp-filter.conf`:

```
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
```

In case you also want to be able to use nested-virtualisation acceleration, you need to put in `/etc/modprobe.d/kvm_intel.conf`:

```
options kvm-intel nested=1
options kvm-intel enable_shadow_vmcs=1
options kvm-intel enable_apicv=1
options kvm-intel ept=1
```

Even if it's not mandatory, I always suggest to upgrade all your packages.
To do so, you can run:

    yum update -y

At this point you should reboot your box to ensure that all kernel options are properly loaded and that you are running the latest kernel version.

To make IPv6 work, it's necessary to change the IPv6 class in `/etc/sysconfig/network-scripts/ifcfg-enp0s2` (or the file that identifies your primary network interface) from `/64` to `/128`.
This will allow the bridge to obtain all the other IPv6 available in that class and be able to assign them to your virtual machines.
To configure the three networks, we are going to use `virsh`, using xml files that describe the network.

## Network creation
The file that describes the internal network is going to be called `/tmp/internal.xml` and contains:

```xml
<network>
  <name>internal</name>
  <bridge name="br-internal" stp="on" delay="0"/>
  <ip address="10.0.0.1" netmask="255.255.255.0">
  </ip>
</network>
```

As you can see we are just declaring an IP range (10.0.0.1/24), the bridge name (br-internal) and the network name (internal).
We can now create the network:

    virsh net-define /tmp/internal.xml
    virsh net-start internal
    virsh net-autostart internal

The second network is in the file `/tmp/public.xml` and contains the following:

```xml
<network>
  <name>public</name>
  <bridge name="br-public" />
  <forward mode="route"/>
  <ip address="88.99.247.224" netmask="255.255.255.240">
  </ip>
  <ip family="ipv6" address="2a01:4f8:10a:390a::1" prefix="64">
  </ip>
</network>
```

This is very similar to the previous one, with a couple of differences:

* we are declaring a forward mode (route) that will allow this network to speak with the other networks available to the physical box, that will behave as a router
* we are declaring an IPv4 class (which is the additional IPv4/28 class)
* we are declaring an IPv6 class (which is the primary IPv6/64 class)

We can now create the network:

    virsh net-define /tmp/public.xml
    virsh net-start public
    virsh net-autostart public

The third file, called `/tmp/private.xml` contains:

```xml
<network>
  <name>private</name>
  <bridge name="br-private" stp="on" delay="0"/>
  <forward mode="nat">
    <nat>
      <port start="1024" end="65535"/>
    </nat>
  </forward>
  <ip address="10.0.1.1" netmask="255.255.255.0">
  </ip>
</network>
```

This is very similar to the internal one, with the addition of the forward section, where we declare the ability of forwarding packages toward the internet via NAT.

We can now create the network:

    virsh net-define /tmp/private.xml
    virsh net-start private
    virsh net-autostart private

If you now run `virsh net-list` you can now see the networks:

```
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 defaul               active     yes           yes
 internal             active     yes           yes
 public               active     yes           yes
 private              active     yes           yes
```

In case you want to remove the default one (mainly for cleaness reasons):

    virsh net-destroy default
    virsh net-undefine default

## Create the virtual machine
We can now move to starting our first virtual machine.
I already had in `/var/lib/libvirt/images/rhel-guest-image-7.3-35.x86_64.qcow2` a qcow2 RHEL7 image.
The first step is copy it to a new file that will become the disk of the VM:

    cp /var/lib/libvirt/images/rhel-guest-image-7.3-35.x86_64.qcow2 /var/lib/libvirt/images/vm00.qcow2

At this point we can customize the image with `virt-customize` to make the machine able to run properly:

    virt-customize -a /var/lib/libvirt/images/vm00.qcow2 \
        --root-password password:PASSWORD_HERE \
        --ssh-inject root:file:/root/.ssh/fale.pub \
        --run-command 'systemctl disable cloud-init; systemctl mask cloud-init' \
        --run-command "echo -e 'DEVICE=eth0\nONBOOT=yes\nBOOTPROTO=none\nIPADDR=88.99.247.225\nNETMASK=255.255.255.255\nSCOPE=\"peer 88.99.208.11\"\nGATEWAY=88.99.208.11\nIPV6INIT=yes\nIPV6ADDR=2a01:4f8:10a:390a::10/64\nIPV6_DEFAULTGW=2a01:4f8:10a:390a::2' > /etc/sysconfig/network-scripts/ifcfg-eth0" \
        --run-command "echo -e 'DEVICE=eth1\nONBOOT=yes\nBOOTPROTO=none\nIPADDR=10.0.1.10\nNETMASK=255.255.255.0' > /etc/sysconfig/network-scripts/ifcfg-eth1" \
        --selinux-relabel

With this command we are going to perform a lot of changes.
In order:

* set a *root password* since by default RHEL qcow image has no password and therefore is not possible to login
* inject an *SSH key for root*
* disable cloud-init since it will not be able to connect to anything and will fail
* configure eth0 that is going to be attached to public
* configure eth1 that is going to be attached to private
* make SELinux re-label the wholte filesystem to ensure that all files are properly labled

At this point we can create the machine with:

    virt-install
        --ram 8192
        --vcpus=4
        --os-variant rhel7
        --disk path=/var/lib/libvirt/images/vm00.qcow2,device=disk,bus=virtio,format=qcow2
        --import
        --noautoconsole
        --network network:public
        --network network:private
        --name vm00

You can now connect via SSH to the machine.
