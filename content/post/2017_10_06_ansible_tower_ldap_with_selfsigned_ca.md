---
date: 2017-10-06
title: Ansible Tower LDAP with self signed CA
aggregators:
  - Fedora
  - KDE
categories:
  - Ansible
tags:
  - Ansible Tower
---

One of the big advantages that Ansible Tower and AWX (the open source and upstream version of Ansible Tower) bring to the table is the Role Base Access Control (RBAC).
This will allow you to select which users (or teams) will be able to see which objects in Ansible Tower as well as which jobs they will be able to run.

Obviously to leverage the RBAC, you will have to have personal accounts for every user of your platform.
Now, this can be very complex to do when you have hundreds of users, if you consider than you should then manage those users.
Also, you probably already have those information in your company LDAP or Active Directory.

Ansible Tower is able to query an LDAP server, so that you don't have to keep two replicated dataset.

LDAP is a clear text format, which is not something you want to have in your network.
LDAPS is LDAP with TLS (in the same way that HTTPS is HTTP with TLS) and can help to ensure confidentiality of your LDAP information.

To be able to use LDAPS, you will need an X509 certificate (as you need for HTTPS).
Those certificates need to be signed by a Certificate Authority.
You can use a public CA or your own CA.

By default, Ansible Tower will try to validate the LDAPS TLS certificate using the default Certificate Authority list, where only public CAs are present.
This means that if you signed your LDAPS certificate with your own CA, this will not work.
Although this is a sane behaviour - at least in my opinion - this might be different from what you may want to do.
This is also a fairly common way of handling CAs.
The problem is that Ansible Tower will not look for the system trusted CA, but will use it's own ones, so you can not add your CA to the system to make it work.

To make it work, the first thing to do is creating a file which contains the public part of the CA.
In our example, this file has been created in `/etc/pki/ca.crt`.

At this time (Ansible Tower 3.2, AWX 1.0.0), there is no option in Ansible Tower User Interface to change the CA, but it's possible using an API request.
It will be necessary to update the `AUTH_LDAP_CONNECTION_OP` object that lives in the `https://<tower-fqdn>/api/v1/settings/ldap` endpoint.
By default, the `AUTH_LDAP_CONNECTION_OP` object looks like:

```
    "AUTH_LDAP_CONNECTION_OPTIONS": {
        "OPT_NETWORK_TIMEOUT": 30,
        "OPT_REFERRALS": 0
    },
```

To update it, we will need to perform a `PATCH` request, by adding the following attributes:

```
    "OPT_X_TLS_CACERTFILE": "/etc/pki/ca.crt"
    "OPT_X_TLS_NEWCTX": 0,
```

If then you query the `https://<tower-fqdn>/api/v1/settings/ldap` with a `GET` request, you should be able to see that the `AUTH_LDAP_CONNECTION_OPTIONS` will look something like:

```
    "AUTH_LDAP_CONNECTION_OPTIONS": {
        "OPT_X_TLS_CACERTFILE": "/etc/pki/ca.crt"
        "OPT_NETWORK_TIMEOUT": 30,
        "OPT_X_TLS_NEWCTX": 0,
        "OPT_REFERRALS": 0
    },
```

As you can notice, we added two attributes.
The first one is `OPT_X_TLS_CACERTFILE` and is used to specify the public CA location.
The second one is `OPT_X_TLS_NEWCTX` and it's required due to how `python-ldap` (the library that Ansible Tower and AWX use) works.
If you forget to add the `OPT_X_TLS_NEWCTX` property, the TLS connection will not use the CA file you specified and will fail.

You will now be able to use a certificate for LDAPS that has been signed with the CA whose public part is in the `/etc/pki/ca.crt` file.
