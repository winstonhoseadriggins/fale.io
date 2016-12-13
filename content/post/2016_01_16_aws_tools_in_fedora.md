---
date: 2016-01-16
title: The AWS tools are approaching Fedora
aggregators:
  - Fedora
categories:
  - Linux
  - Fedora
  - CLI
  - AWS
---
In the last few weeks I've worked toward bringing the Amazon Web Services tools in Fedora.
The three AWS tools that are coming in the next few days in Fedora are:

* **botocore**: a low level Python library to interact with Amazon Web Services APIs
* **boto3**: a high level Python library to interact with Amazon Web Services APIs
* **awscli**: a Command Line Interface to interact with Amazon Web Services APIs

Botocore just landed in Fedora *updates* repositories while boto3 and awscli will be pushed to the *updates* repository tomorrow or Monday morning.
If you want to see them in the repo even sooner test them and give feedbacks, in this way Bodhi will allow those packages to be pushed to the stable repository if feedbacks are positive.

This should make easier for both developers and administrators to work with the AWS infrastructure having all the tools available directly from the package manager system.
Since the Fedora policy requires the packages to stay 7 days in testing or receive enough Karma (whichever comes first) before they can be pushed to stable, it's probable that the versions that will land in Fedora are, on average, one week old.
I really hope that many people will test those updates so the waiting time will be lower.

I hope those packages are bug-free, but it's possible that they aren't.
If this is the case, please report the bugs you encounter on the [bug tracker](https://bugzilla.redhat.com/) providing as much information as possible to speed-up the fixing process.

I'm working to bring those packages to EL (RHEL/CentOS/Scientific Linux/Oracle Linux/...) as well, because in my experience are very useful for server applications as well.

I'm also working to make **aws-shell** available as well.
This is proving pretty difficult since at the moment it requires **python-prompt_toolkit** 0.52, while in Fedora we provide 0.57.
I've tried to ask upstream to fix this, but they seem not very responsive.
This is probably linked to the fact that **aws-shell** is published in the `awslabs` GitHub account instead of the official `aws` account, so it's still an evaluation.
