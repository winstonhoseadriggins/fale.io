---
date: 2017-08-18
title: Ansible Tower 3.1 High Availability maintenance
aggregators:
  - Fedora
  - KDE
categories:
  - Ansible
tags:
  - Ansible Tower
---

Around one year ago, I did a post around [Ansible Tower High Availability maintenance](/blog/2016/09/28/ansible-tower-high-availability-maintenance/), but in the mean time many things changed and that post is not up to date anymore, so I decided to create a new one that covers the same topic but for Ansible Tower 3.1.

From Ansible Tower 3.1 we lost the distinction of Primary Ansible Tower and Secondary Ansible Tower.
That concept was related to the fact that the Secondary Ansible Towers were in a hot-standby mode.
Since Ansible Tower 3.1, we have active-active clustering and therefore all Ansible Towers in your cluster are always active and there is no distinction between them.

The situation of PostgreSQL replication has not changed since my previous post, but if you want to learn more around how to make it Highly Available, you can read [my post about PostgreSQL streaming replication for Ansible Tower](/blog/2017/05/31/postgresql-streaming-replication-for-ansible-tower/).

Let's see how this new clustering system changes operations.

## Add a new Ansible Tower to the cluster
Although the easiest way to add Ansible Towers is during the installation, it may be useful to add additional Ansible Towers to the cluster in a different moment.
To do so, firstly re-run the installer adding the new machine in the `tower` section of the Ansible Inventory, after ensuring that the machine running the installer can actually access the newly created machine via SSH using SSH keys.

At this point, the machine should be part of the cluster and working properly.

As you can see, the process is much easier then in the past.
This is mainly due to the fact that many configurations that historically were conserved in configuration files got moved to the database, making them immediately available to all cluster nodes.

## Remove an Ansible Tower from the cluster
There are cases where an Ansible Tower needs to be removed from the cluster.
To do so, execute the following command on an Ansible Tower:

~~~bash
tower-manage remove_instance --hostname HOSTHERE
~~~

Even if a machine died "naturally", it is very important to remove it from the cluster so that the cluster configuration is kept clean and functional.

This procedure is the same as it was in the past, with the difference that we can remove any Ansible Tower now, while historically we could only remove Secondary Ansible Towers.

## Other operations
Due to the fact that we lost the distinction of Primary Ansible Tower and Secondary Ansible Tower, we do not have any other kind of procedure to manage our Highly Available cluster.

I hope that you'll enjoy the new clustering method.
I find it way more efficient and easy to manage.
