---
date: 2017-05-31
title: PostgreSQL streaming replication for Ansible Tower
aggregators:
  - Fedora
  - KDE
categories:
  - Database
  - Ansible
tags:
  - PostgreSQL
---

Ansible Tower 3.1 has recently been released, and it does implement real HA.
In fact, up to version 3.0, Ansible Tower multi-node installation, only allowed a single machine to be _primary_ and the switch was not possible in an automated fashion, so if the primary Ansible Tower would have collapsed, an operator should have promoted one of the _secondary_ Ansible Tower to be _primary_ to be able to carry on the work.
With Ansible Tower 3.1 this is no longer the case, since all Ansible Tower machines are active all the time.

Now that Ansible Tower is fully HA, is more important than ever to discuss the availability of the PostgreSQL database that is supporting the Ansible Tower installation.
There are three possible ways to implement a PostgreSQL database from an availability standpoint:

* Single node
* Streaming replication
* Multi-master

As you can imagine, the **single node** installation does not provide any availability guarantees, but it's surely the easiest one to setup.

The **streaming replication** setup allows you to have a slave server that is slightly behind the master and that is ready to kick in in case the master will fail.
Unless custom code is written, the slave server will require human intervention to be promoted to master role.

The **multi-master** setup allows multiple servers to be master, and therefore you'll not need any human intervention in case of a failure.

As you may have guessed from the title of this article, we are going to discuss only streaming-replication in this article.

## Simple schema and limits

A simple streaming-replication setup resembles something like the following:

~~~
+-----------+
|  Client   |
+-----------+
      ^
      |
      v
+-----------+    +-----------+
|  Master   |<-->|   Slave   |
+-----------+    +-----------+
~~~

As you can see, the client only interacts with the _master_ and never with the _slave_.
This means, that if the _master_ dies, the client application will need to be reconfigured or some networking magic will be required to make everything work as expected.
To avoid this problem, often a **virtual IP** or a proxy is used.

Also, as a side-effect of the missing communication between the client and the slave server, all the load will be handled by the _master_ and not shared with the _slave_.

Having said so, clearly the big advantae of such solution is simplicity.

## Implementation
To install PostgreSQL on the two DB servers, we can trick the Ansible Tower installer, or do it manually.
If we decide to trick the installer, this is the procedure, otherwise the first 3 steps will be replaced by performing a standard installation of PostgreSQL.

* Install PostgreSQL in the primary server with the Tower installer
* Modify the inventory substituting the primary database with the secondary database in the `[database]` section
* Re-run the Ansible Tower installer so that it will setup the secondary database as the first one 
* Connect to the primary database with the `postgres` user (`sudo su - postgres` from a privileged account), launch `psql` and create an user named replication with REPLICATION privileges.

~~~sql
    CREATE ROLE replication WITH REPLICATION PASSWORD 'password' LOGIN;
~~~

* Stop both databases if they are running with `systemctl stop postgresql-9.4.service`
* Set up connections and authentication so that the standby server can successfully connect to the ''replication'' pseudo-database on the primary. Change the file `/var/lib/pgsql/9.4/data/pg_hba.conf` on the primary adding the following lines:

~~~
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    host    replication     replication     192.168.0.10/32         md5
    host    replication     replication     192.168.0.20/32         md5
~~~

* Set up replication configurations. Change the file `/var/lib/pgsql/9.4/data/postgresql.conf` on the primary adding or altering the following lines:

~~~
    # Enable read-only queries on the standby server. But if wal_level is ''archive''
    # on the primary, leave hot_standby unchanged (i.e., off)
    hot_standby = on
    # To enable read-only queries on a standby server, wal_level must be set to
    # "hot_standby". But you can choose "archive" if you never connect to the
    # server in standby mode.
    wal_level = hot_standby
    # Set the maximum number of concurrent connections from the standby servers.
    max_wal_senders = 5
    # To prevent the primary server from removing the WAL segments required for
    # the standby server before shipping them, set the minimum number of segments
    # retained in the pg_xlog directory. At least wal_keep_segments should be
    # larger than the number of segments generated between the beginning of
    # online-backup and the startup of streaming replication. If you enable WAL
    # archiving to an archive directory accessible from the standby, this may
    # not be necessary.
    wal_keep_segments = 32
    # Enable WAL archiving on the primary to an archive directory accessible from
    # the standby. If wal_keep_segments is a high enough number to retain the WAL
    # segments required for the standby server, this is not necessary.
    archive_mode    = on
    archive_command = 'cd .'
~~~

* Create a recovery configuration file on the primary server creating `/var/lib/pgsql/9.4/data/recovery.done` with the following content:

~~~
    # Specifies whether to start the server as a standby. In streaming replication,
    # this parameter must to be set to on.
    standby_mode          = 'on'
    # Specifies a connection string which is used for the standby server to connect
    # with the primary.
    primary_conninfo      = 'host=192.168.0.10 port=5432 user=replication password=password'
    # Specifies a trigger file whose presence should cause streaming replication to
    # end (i.e., failover).
    trigger_file = '/var/lib/pgsql/9.4/trigger'
    # Specifies a command to load archive segments from the WAL archive. If
    # wal_keep_segments is a high enough number to retain the WAL segments
    # required for the standby server, this may not be necessary. But
    # a large workload can cause segments to be recycled before the standby
    # is fully synchronized, requiring you to start again from a new base backup.
    restore_command = 'cd .'
~~~

* Start PostgreSQL on the primary server: `systemctl start postgresql-9.4.service`
* On the secondary server ensure that the data folder is free: `rm /var/lib/pgsql/9.4/data`
* Use the `pg_basebackup` on the secondary to copy the state from the primary `pg_basebackup -h 192.168.0.10 -D /var/lib/pgsql/9.4/data -P -U replication --xlog-method=stream`
* On the secondary put the recovery file in the expected position: `mv /var/lib/pgsql/9.4/data/recovery.done /var/lib/pgsql/9.4/data/recovery.conf`
* On the secondary replace the IP in the `/var/lib/pgsql/9.4/data/revocery.conf` file to match the primary host IP
* Start PostgreSQL on the secondary server: `systemctl start postgresql-9.4.service`

As you can see, this is a fairly straight forward process!


## Failover
### Virtual IP
In case of failover, if a Virtual IP (vIP) is used, the following steps are necessary:

* move the vIP to point to the new _master_
* touch trigger on the _slave_ to promote it to master
* restart Ansible Tower to reset database connections

### No Virtual IP
If no Virtual IP (vIP) is used, the following process will be necessary:

* Reconfigure Ansible Tower to use the machine that was _slave_
* touch trigger on the _slave_ to promote it to master
* restart Ansible Tower to reset database connections

## Failback
To perform a failback, the same operations needed for failover can be used, but I suggest against using a failback mechanism since this would create one additional downtime.
If you have equal machines for _master_ and _slave_ database, there is no reason to failback and you can continue working with the secondary machine until it breaks, and at that point you'll perform another failover.

## Restore replication
After the failover, or in case the secondary server has to be re-initialized, the following operations are needed:

* Stop PostgreSQL on the secondary server: `systemctl stop postgresql-9.4.service`
* On the secondary server ensure that the data folder is free: `rm /var/lib/pgsql/9.4/data`
* Use the `pg_basebackup` on the secondary to copy the state from the primary `pg_basebackup -h 192.168.0.10 -D /var/lib/pgsql/9.4/data -P -U replication --xlog-method=stream`
* On the secondary put the recovery file in the expected position: `mv /var/lib/pgsql/9.4/data/recovery.done /var/lib/pgsql/9.4/data/recovery.conf`
* On the secondary replace the IP in the `/var/lib/pgsql/9.4/data/revocery.conf` file to match the primary host IP
* Start PostgreSQL on the secondary server: `systemctl start postgresql-9.4.service`

## PostgreSQL check replication delay
Now that we have two PostgreSQL databases that are syncronizeing, it's important how to ensure that they are effectively in-sync.
There are many ways to check the replication delay, the main ones are the following.

### Method 1
Use a third party tool like Bucardo (https://bucardo.org/check_postgres/check_postgres.pl.html#replicate_row).

### Method 2
Perform on the slave the following query:

~~~sql
  SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))::INT;
~~~

This query works great and it is a very good query to give you the lag in seconds.
The problem is if the master is not very active, you will have a very high time even if the two databases are perfectly synchronized.
So you need to first check if two servers are in sync and if they are, return 0.

### Method 3
This can be achieved by comparing pg_last_xlog_receive_location() and pg_last_xlog_replay_location() on the slave, and if they are the same it returns 0, otherwise it runs the above query again:

~~~sql
  SELECT
    CASE
      WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location() THEN 0
~~~

### Method 4
Giving a `ps -aux` on the servers there is a replication process that will report the xlog location toward the end of the name.
Comparing those on the two servers it's possible to determine how the replication is proceeding.
