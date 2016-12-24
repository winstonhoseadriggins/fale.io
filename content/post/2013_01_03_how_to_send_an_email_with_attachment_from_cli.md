---
date: 2013-01-03
title: How to send an e-mail with attachment from the command line
categories:
  - Linux
  - CLI
  - Programming
tags:
  - Mails
  - Attachments
  - Shell
  - UNIX
---
<img class="alignleft  wp-image-1092" alt="konsole" src="http://fabiolocati.com/wp-content/uploads/2013/01/konsole-300x300.png" width="180" height="180" />

Have you ever had to develop a script in UNIX that has to send an email?

If you have, probably you have used the "mail" function since this program is the standard program to send e-mails in UNIX environments if you are using the CLI (Command Line Interface).

The manual for mail reports this as mail usage prototype:

    mail -r [sender] -s [subject] receiver-1[,receiver-2,...,receiver-n] &lt; [File with the body]

I think all the parameters are pretty straightforward except the "File with the body" one. This has to be an ASCII file (ie: .txt) with the e-mail body content in the text-only mode.

Until here is normal mail usage. If we want to the send an attachment in the email, this method will not work.

The right tool for the job is uuencode which allows us to send an email with attachment from the command line (CLI).

    uuencode [InFile] [FileName] | mail -r [sender] -s [subject] receiver-1[,receiver-2,...,receiver-n]

Where InFile is the file to attach and FileName the name of the file that the receiver will see.

As we can notice, in the last command I used the e-mail body disappeared.

The "obvious" command

    uuencode [InFile] [FileName] | mail -r [sender] -s [subject] receiver-1[,receiver-2,...,receiver-n] &lt; [File with the body]

Will NOT work properly.

This because both uuencode and the "&lt;" function work on the Standard Input of the same command.

We can fix this with this simple command:

    (cat [File with the body] ; uuencode [InFile] [FileName]) | mail -r [sender] -s [subject] receiver-1[,receiver-2,...,receiver-n]

In this way the mail command will use properly both the attachment and the body text.
