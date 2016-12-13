---
date: 2016-12-13
title: Avoid Ansible Galaxy (as default option)
aggregators:
  - Fedora
  - KDE
categories:
  - Ansible
tags:
  - Ansible Galaxy
---
When I speak with people that are starting with Ansible from Puppet, the first thing they want to experiment is Ansible Galaxy.

This leaves me very skeptical, since I think the default mode in Ansible should be DIY.
Since I've found myself in this situation far to many times, I decided to write down all the reasons why you should avoid Ansible Galaxy in the majority of situations.

1. Using Ansible Galaxy often violates the ***Ansible way***.
My interpretation of the *Ansible Way*, is do not do adopt overkill solution (also known as the classic "Keep It Simple Stupid" principle).
Many times the Ansible Roles you can find in Ansible Galaxy are completely overkill because are created by people coming from the Puppet world (that has a completely different approach).
Modules that install for you and configure NTP or Java for any possible distribution (and sometimes even different OS) means that you substitute a couple of Tasks with hundreds of lines of code.
Often the majority of the code can be stripped because is not applicable to the specific environment.

2. If you use an Ansible Galaxy Role, **review it**.
The idea that Ansible Galaxy is a repository of trusted modules is completely wrong.
Ansible Galaxy is community driven and the modules on it comes with no warranty nor check, so - by default - don't trust them.
Remember that for the biggest majority of cases, Ansible Tasks are run as root or can obtain root powers via become methods (ie: sudo on the majority of Linux installations).

3. The majority of Ansible Galaxy Roles uses **bad patterns**.
Every time I open an Ansible Role coming from Ansible Galaxy, I see a big number of bad practices being used.
From "key=value" usage, to sleeps, and other weird things.
I'm sure that there are some Ansible Roles in Ansible Galaxy which are very well written, but the majority of them are not.

4. Many Ansible Galaxy Roles are **not idempotent**.
Ansible Roles should be idempotent, but many people still write non idempotent Ansible Roles, and the ones on Ansible Galaxy make no exception.

5. Some Ansible Galaxy Roles could conflict with your own roles.
Sometimes an Ansible Galaxy Role will set a specific line in a file or a file from a template, but that configuration does not really suit you, and somewhere else in your codebase you change that same line or file.
This will force Ansible to change that file twice for every execution, and this will result in continuous changes being present, even if the state at the end of your execution is not different from the one at the beginning.

6. Many Ansible Galaxy Roles are **unmaintained**.
As for many other similar registries and repositories, Ansible Galaxy does not remove unmaintained Roles.
This probably because it would be hard to identify when an Ansible Galaxy Role is unmaintained and also removing Ansible Galaxy Roles would brake the workflow of the people using such Roles.
This means that you need to check if the Role you are looking is maintained enough for your standards and you will also need to check it over the life-cycle of the Ansible Galaxy Role usage in your codebase.

7. Many Ansible Galaxy Roles have **very poor documentation**.
As for the majority of the code out there, the documentation is often lacking and if you are looking for a complete documentation, often the best way is to just read the code.

8. Implementing your own Roles is often **faster to implement**.
Very often, due to all the previous points, it is far easier and faster to write it from scratch than review the module, understand how to use it, write the code to use the module, and check that it did not conflicted with other parts of your configuration.

9. If you **know what you are doing** you do not need roles.
Linux system administration boils down to install packages and modify files in a proper way (yes, I know there are other things, but the huge majority of tasks really boil down to this).
Many times we use tools to edit files because edit files directly requires higher level of knowledge and carefulness since a wrong character can create you big problems. Some examples?
  * You don't need an Ansible Galaxy Role to set the Message of the Day (motd), you just need to change the */etc/motd* file.
  * Same applies for NTP, that usually requires to be installed and configured simply changing the */etc/ntp.conf* file.

Am I saying that Ansible Galaxy should be dropped and never looked at again?
Obviously not.
I think Ansible Galaxy has 2 very useful user cases:

1. Ansible Galaxy is a **big library** of implementation examples.
Ansible Galaxy allows to search among tens of thousands of Ansible Roles.
This can definitely help you in case you want to be inspired.

2. Some Ansible Galaxy Roles are very well written, well maintained, and solving really complex problems.
There are some actions, such as installing a Java middleware server, that can be very painful.
Luckily there are some Ansible Galaxy Roles that do it and allow you to automate such process in a very short amount of time.

Ansible Galaxy CLI can also be used with internal written Ansible Roles, to share Ansible Roles among multiple repositories and teams within your organization.
If your organization has an internal GitHub Enterprise installation, you can also [install Ansible Galaxy](https://github.com/ansible/galaxy) internally.
Both those ways to use Ansible Galaxy solve the majority of the previously listed problems and therefore this whole post do not apply to such usage.
