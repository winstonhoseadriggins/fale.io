---
date: 2016-01-27
tags:
  - EPEL
  - RHEL
  - CentOS
categories:
  - Linux
  - Fedora
  - Enterprise Linux
  - CLI
  - AWS
aggregators:
  - Fedora
title: The AWS tools are approaching EPEL7
---

A couple of weeks ago, I've announced the [availability of AWS tools for Fedora]({{< ref "post/2016_01_16_aws_tools_in_fedora.md" >}}).
I'm very happy to announce that today they are available in the EPEL7 repository as well.

The **Extra Packages for Enterprise Linux** (EPEL) repository is an RPM repository managed by the Fedora community that creates, maintains, and manages a high quality set of additional packages for Enterprise Linux, including, but not limited to, **Red Hat Enterprise Linux** (RHEL), **CentOS**, **Scientific Linux** (SL), and **Oracle Linux** (OL).
As you can imagine, the **7** stays for the version, so only the version 7.x of the named distributions will allow you to install those packages.

If you want to try, you need to have the EPEL repository installed. If you don't have EPEL repository or you aren't sure about it, you can install it running as root:

``` bash
yum install epel-testing
```

And then you can install the AWS tools issuing the following command as root:

``` bash
yum install awscli boto3
```
This will install you the following three programs:

* **botocore**: a low level Python library to interact with Amazon Web Services APIs
* **boto3**: a high level Python library to interact with Amazon Web Services APIs
* **awscli**: a Command Line Interface to interact with Amazon Web Services APIs

I've looked at porting it to **EPEL6** as well, but I have big doubts about it.

In one hand it will be a very time consuming operation for me: many dependencies are present but in the wrong version I'll have to patch the botocore, boto3 and awscli code to make it work with alternative versions and/or repackage the dependencies newer versions with a different name so they do not conflict with the current version released in the main repository.

In the other hand it will not bring a huge improvement (at least from my point of view) since the version **7** of Enterprise Linux has been released more than 1.5 years ago and it seems the market standard today.

If you need those packages in EPEL6 as well, please let me know and I'll consider it.
