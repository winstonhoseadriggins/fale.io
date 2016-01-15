---
date: "2016-01-15T09:00:00+02:00"
categories: [ "Linux", "Fedora", "AWS" ]
title: "The AWS tools are approaching Fedora"
---
In the last few weeks I've worked toward bringing the Amazon Web Services tools in Fedora. The three AWS tools that are coming in Fedora are:

* **botocore**: a low level Python library to interact with Amazon Web Services APIs
* **boto3**: a high level Python library to interact with Amazon Web Services APIs
* **awscli**: a Command Line Interface to interact with Amazon Web Services APIs

I've requested the stable status for botocore few hours ago and therefore should be published in the next few hours (you can follow their status for [F22](https://bodhi.fedoraproject.org/updates/FEDORA-2016-449e075222), and [F23](https://bodhi.fedoraproject.org/updates/FEDORA-2016-1cd5133697)) while boto3 and awscli will be pushed during the weekend.

This should make easier for both developers and administrators to work with the AWS infrastructure having all the tools available directly from the package manager system.

I hope those packages are bug-free, but it's possible that they aren't. If this is the case, please report the bugs you encounter on the [bug tracker](https://bugzilla.redhat.com/) providing as much information as possible to speed-up the fixing process.

PS: I'm working to make **aws-shell** avilable too as well as bringing those packages to EL (RHEL/CentOS/Scientific Linux/Oracle Linux/...).
