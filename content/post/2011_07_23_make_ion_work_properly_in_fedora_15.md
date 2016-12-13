---
date: 2012-07-23
title: Make ION work properly in Fedora 15
aggregators:
  - Fedora
categories:
  - Fedora
tags:
  - nVidia ION
---
The EeePc 1015PN, at least the European version, comes with these two video cards:

* 00:02.0 VGA compatible controller: Intel Corporation N10 Family Integrated Graphics Controller (rev 02)
* 04:00.0 VGA compatible controller: nVidia Corporation GT218 [ION] (rev ff)

The first one is a nice Intel integrated card that allows you to have good performance in the 99.9% of the typical netbook user-cases.

In the other hand, the Nvidia ION is way more powerful than the integrated Intel card.
ION is capable of running HD videos, full-screen Youtube HD videos, games, and much more.
The downside of the nVidia card is the power drain.
This version of ION does drain ~600mA more than the Intel integrated card.
These 600mA, as you can imagine, need also to be dissipated, forcing the vent to spin at its maximum speed.
Even with the vent at the maximum speed, the temperature increases from the 40~55°C (idle with ION deactivated) to 65~80° (idle with ION active).
Therefore I've created a script that keeps ION deactivated by default and allows the user to active it when is needed and stop it when is no more needed.

The procedure I've used is pretty easy (I love the KISS principle) and it should work on 99.9% of Linux distributions and with 99.9% of computer mounting ION (so not only 1015PN).
I can't grant it because I only tried this on Fedora 15 with the 1015PN.
Since we are using global paths, every command has to be run with "su" or "sudo".
My suggestion is to start a root shell (open a normal shell, type "su", type the root password) and exec all commands in that shell.

Firstly, we need to install some software that are mandatory like: stuff to compile (gcc), kernel sources (kernel-devel), git (git) and dkms (dkms):

~~~bash
yum install dkms git gcc kernel-devel
~~~

We need to active dkms daemon:

~~~bash
chkconfig dkms_autoinstaller on
~~~

 Go to the right folder, download the sources, rename the folder according to dkms naming system and go into the folder:

~~~bash
cd /usr/src/
git clone http://github.com/mkottman/acpi_call.git
mv acpi_call/ acpi_call-git/
cd acpi_call-git
~~~

Create the file **/usr/src/acpi_call-git/dkms.conf** with the following text:

~~~bash
PACKAGE_NAME="acpi_call"
PACKAGE_VERSION="git"
BUILD_MODULE_NAME[0]="acpi_call"
DEST_MODULE_LOCATION[0]="/kernel/acpi/"
AUTOINSTALL="yes"
~~~

Teach to dkms to administer what we have just created:

~~~bash
dkms add -m acpi_call -v git
dkms build -m acpi_call -v git
dkms install -m acpi_call -v git</code></pre>
~~~

Create the file **/etc/init.d/ion** with the following text:

~~~bash
#!/bin/sh
#
# Startup/shutdown script for Nvidia ION.
#
# Linux chkconfig stuff:
#
# chkconfig: 12345 05 95
# description: Startup/shutdown script for Nvidia ION.
#
# Copyright (C) 2011 by Fabio Alessandro Locati
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see .
#
### BEGIN INIT INFO
# Provides: ion
# Default-Start: 1 2 3 4 5
# Short-Description: The ION Manager
# Description: The ION Manager
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

prog=ion

check() {
    echo "\AMW0.DSTS 0x90013" &gt; /proc/acpi/call
    result=$(cat /proc/acpi/call)
    case "$result" in
        0x30003)
            echo "Both Videocard recognised"
        ;;
        *)
            echo "Oops, something went wrong"
        ;;
    esac
}

init() {
    echo "\OSGS 0x03" &gt; /proc/acpi/call
    return 0
}

on() {
    echo "\_SB.PCI0.P0P4.DGPU.DON" &gt; /proc/acpi/call
    return 0
}

off() {
    echo "\_SB.PCI0.P0P4.DGPU.DOFF" &gt; /proc/acpi/call
    return 0
}

load() {
    modprobe acpi_call
    return 0
}

start () {
    load
    init
    off
}

status() {
    echo "I haven't found a way to check if ION is ON, yet. Sorry :(."
    echo "You may understand it from the speed of the vent"
    echo "or the battery drain."
    return 0
}

case $1 in
    check)
        check
    ;;
    init)
        init
    ;;
    on)
        on
    ;;
    off)
        off
    ;;
    load)
        load
    ;;
    start)
        start
    ;;
    status)
        status
    ;;
    *)
        echo $"Usage: $prog {check|init|on|off|load|start|status}"
    exit 2
esac

exit $RETVAL
~~~

Make the script executable:

~~~bash
chmod +x /etc/init.d/ion
~~~

Tell chkconfig to take care of our script:

~~~bash
chkconfig --add ion
~~~

The first reboot will be quite the same as the previous ones. You need to reboot twice to make everything working.
To see if the computer sees both video cards, you need to execute (until you make the whole procedure and reboot twice, this check will fail) as normal user or root user:

~~~bash
service ion check
~~~

To power up ION execute as normal user or root user:

~~~bash
service ion on
~~~

To stop ION execute as normal user or root user:

~~~bash
service ion off
~~~

I've not yet developed a function to check if ION is on or off, but you can easily understand it putting your hand over the vent. If the temperature is some degrees higher than the room temperature ION is off. If the air is really hot, ION is on ;).
