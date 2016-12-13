---
date: 2014-08-24
title: Innotop fixed for MariaDB 10
aggregators:
  - Fedora
categories:
  - Database
  - CLI
  - Fedora
  - Enterprise Linux
tags:
  - Innotop
  - MySQL
  - MariaDB
---
One of my clients asked me to upgrade their MySQL 5.1 installation to MariaDB 10.
This caused some problems mainly due to the fact that many MySQL clients are not MariaDB 10 ready.
An example of a MySQL client not yet ready for MariaDB 10 is Innotop.

Innotop is a widely used client for MySQL/MariaDB that shows you an interface similar to the “top” Unix command.
To solve this, I found a patch online and, after some testing, I’ve added it to the Fedora package.

As I write, Innotop 1.9.1-6 (the patched version) is already available for Fedora 20, Fedora 21, Fedora rawhide and EPEL 7.
Is still in testing on Fedora 19, EPEL 5 and EPEL 6.
If you can, please, do test those packages so they will take less time to become stable and available to all users :-).
