---
date: 2016-12-01
title: Speedup Ansible
aggregators:
  - Fedora
  - KDE
categories:
  - Ansible
tags:
  - Performances
---
The single most frequent complain I hear about Ansible is about it's slowness.
This is very common, but even more common among people that used to use Puppet.
There are many reasons why Ansible is slower than Puppet.
The three main reasons are:

* **Linear execution**: Ansible will execute each operation in order and will not run many steps at the same time as Puppet does.
* **SSH Connection**: all Ansible commands will be issued from the control system to the controlled system via SSH. On the other hand, in Puppet, all commands will be issued locally on the controlled host by the Puppet agent.
* **Host limitation**: since the Ansible Controller is involved with the process of applying changes to the controlled system, a limited number of systems can be changes at once.

Those limits come out from design decisions that preferred a simpler Playbook writing and a safer execution rather than speed.
There are some things that can be done to increase the performances of Ansible:

1. Update to **last version**. Ansible 2.0 is slower than Ansible 1.9 because it included an important change to the execution engine to allow any user to choose the execution algorithm to be used. In the versions that followed, and mostly in 2.1 big optimizations have been done to increase execution speed, so be sure to be running the latest possible version.

2. Disable the "**useDNS**" option is the SSHd configuration of all your machines

3. Enable **pipelining** in your ansible.cfg file by adding "pipelining = True"

4. Tweak the number of **forks**. Ansible will operate on multiple controlled systems at once, and the exact amount is defined with the forks variable. You can change this value adding a "forks = X" line in your ansible.cfg file. By default this value is 5.

5. If you are using **Paramiko mode** (aka: you are running Ansible from a machine that has EL6 or lower) every task will require a new SSH connection to be created. To reuse the same SSH connection, use the **accelerated mode**, by adding "accelerate: True" in your Playbooks. If you are running Ansible on Enterprise Linux 7 or newer, this is not needed since by default SSH connections are reused.

6. Use **cycles** to improve speed. Some tasks have embedded optimizations if are called with an "with_items" parameter instead of called multiple times. Examples of this are the tasks to install packages, in fact you will call them with "with_items", they will perform one single transaction with all required packages together speeding up the execution.

7. Start from a **golden image** to reduce the amount of installations and upgrades you'll need to perform.

8. Be aware that **some tasks are inherited slow** (ie: installing packages, creating cloud instances synchronously, etc). In the installing packaging case, a local repository can speed up the operations, reducing the networking time

9. Consider the **pull mode**. Ansible is able to operate in pull mode (like Puppet). The upside is that every host will be able to apply changes at the same time. The downside is that you'll loose centralized logs, making it harder to have a clear picture of the situation.

Some of those things will give you higher gain and other lower, based on multiple factors including the specifics of your deployment and your Playbooks.
