---
date: "2016-09-28T09:00:00+00:00"
categories: [ "Ansible" ]
aggregators: [ "Fedora", "KDE" ]
title: "Ansible Tower High Availability maintenance"
---

In the last few months I've setted up multiple times Ansible Tower, but I've noticed that there is not much documentation on how to perform basic maintenance on Ansible Tower High Availability setup, so I decided to write an article about it.

Ansible Tower High Availability setup (also known as Ansible Tower Cluster) is composed by one Primary Tower (Active), one or more Secondary Tower (Passive), and a PostgreSQL 9.4+ database.
At the moment, Ansible Tower High Availability supports only a single Primary instance at any given time (active/passive clustering).
If a Secondary instance gets promoted to Primary, while another live instance is set as Primary, the active Primary will be demoted to Secondary before the promotion will occur.

The PostgreSQL is used as a service by Ansible Tower and therefore will not be covered it in this article.
Clearly, if the PostgreSQL is not redundant, the database becomes the single point of failure of the infrastructure, making it less reliable.

## Add a new Secondary Ansible Tower to the cluster
Although the easiest way to add Secondary Towers is during the installation, it may be useful to add additional Ansible Towers to the cluster in a different moment.
To do so, firstly re-run the installer adding the new machine as secondary, after ensuring that the machine running the installer can actually access the newly created machine via SSH using SSH keys.
After the install is completed, copy the Ansible Tower configurations from a machine that is currently part of the cluster to newly installed machine or from a backup (the Ansible Tower configurations are located in */etc/tower*).

Restart the Ansible Tower services on the newly created machine to ensure that the proper configuration gets picked up, utilizing:

    ansible-tower-service restart

At this point, the machine should be part of the cluster and working properly.

## Remove a Secondary Ansible Tower from the cluster
There are cases where a Secondary Tower needs to be removed from the cluster.
To do so, execute the following command on a machine that is part of the Ansible Tower Cluster:

    tower-manage remove_instance --hostname HOSTHERE

Even if a machine died, is very important to remove it from the cluster so that the Ansible Tower Cluster configuration is kept clean and functional.

## Promote a Secondary Ansible Tower instance to become Primary
To promote a Secondary instance to Primary, execute the following command on a machine that is part of the Ansible Tower Cluster:

    tower-manage update_instance --primary --hostname HOSTHERE

The Primary machine will automatically be demoted to Secondary when a new machine becomes Primary.
