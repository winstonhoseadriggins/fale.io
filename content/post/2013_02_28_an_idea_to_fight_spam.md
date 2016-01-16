---
date: "2013-02-28T15:30:30+02:00"
title: "An idea to fight spam"
categories: [ "Web" ]
tags: [ "Idea", "Spam", "Mails" ]
---
<img class="alignleft" alt="" src="http://pagliaro-udine.blogautore.repubblica.it/files/2012/12/spam.jpeg" width="180" height="180" />
Today I would like to give you an idea on how to implement a spam system that can reduce some kind of spam.

### The problem
Sometimes a company or a politician, that does not respect the usual privacy policy, continues to send e-mails even if the user already tried to unsubscribe.

### My postulates 
1. The people who usually send this kind of e-mail are not very familiar with how e-mail work or how the privacy policy works. Obviously there is the case in which they are malicious, but I prefer to think that the biggest part of these people are in the first two cases.
2. These people probably will have issues removing a person from a mailing list, therefore they will tend not doing it, unless they have an advantage.
3. Is really annoying sending an e-mail to 10 contacts and receive 8 mail-delivery-subsystem errors.

### My approach
My approach is dividable in two directions that have to be implemented as features from the e-mail provider:

1. Be able to filter out all e-mails from a specific account or domain (and a lot of mail-provider already implement this, ie: gmail with filters)
2. Be able to set a "fake" mail-delivery-subsystem error (and this is the innovative part of my idea)

### The "fake" mail-delivery-subsystem error
The e-mail server of the user will have to check the user's "blacklist" before declaring the user as existent. If the user has put the sender e-mail address in the blacklist, the e-mail server will have to decline the e-mail with an error.

### Why will this work
This approach will work for multiple reasons:

1. If the e-mails are sent directly by an operator, he will receive the error and she will understand that something is not right.
2. If the e-mails are sent directly by an operator, she will be bothered by the amount of mail-delivery-subsystem error he will receive and will try to stop sending e-mails that are bounced back
3. If the e-mails are sent by an operator using a mailing-list program, probably the program itself will remove the addresses that return a mail-delivery-subsystem error

### Worthiness
I think it does. We have an overhead for each mail received (and probably this overhead could be reduced due to optimizations) but, in the long run, way less spam e-mails will be sent, so the servers will be less busy parsing spam e-mails.
