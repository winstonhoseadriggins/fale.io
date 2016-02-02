---
title: "Pretty Good Privacy (PGP)"
no_comments: true
---

## Keys

I declare to be the solely owner of the following keys.

    pub   rsa4096/709A7851 2014-10-31 [expires: 2017-01-01]
          Key fingerprint = B960 BE9D E7A8 FA12 273A  98BB 6D6A 29D6 709A 7851

    pub   rsa4096/B2DC9C1B 2015-12-27 [expires: 2017-01-01]
          Key fingerprint = E815 3C49 2A8D FD8B 1CBD  BC85 FDB3 DF20 B2DC 9C1B

    pub   rsa4096/2E7B4E1B 2015-12-27 [expires: 2017-01-01]
          Key fingerprint = 472C 6E72 4479 A277 6FA9  BE19 8482 76F9 2E7B 4E1B

The following policy is valid for all signatures made by the keys mentioned above.

The latest version of this key is available from a keyserver near you, such as:

   pool.sks-keyservers.net

## Key signing policy

### Summary
To sign a key with my OpenPGP key I require that:

* the key owner (signee) and I meet in person
* during this meeting:
  * signee provides at least one valid, government issued, photo identification document
  * signee verifies and confirms the fingerprint of the key to be signed
  * signee confirms ownership of the key to be signed
* the UIDs/UATs of the key to be signed and the photo identification documents provided by signee meet all of the requirements listed in the Identification documents section and UIDs/UATs section below.

### Identification documents
I require signee to provide at least one valid, government issued, photo identification document.

Identification documents must include all of the following features:

* a photo of signee bearing a clear resemblance to signee
* the full real name of signee
* the date and place of birth of signee
* the nationality of signee
* an issue date in the past
* an expiry date in the future
* forgery-protection features

Identification documents must not show any clear signs of tampering, forgery or excessive or unrealistic traces of wear.

Identification documents must be identical regarding real name, date and place of birth and nationality of signee.

Acceptable photo identification documents include all passports and national identity cards that are issued throughout the European Economic Space (EES).

**Driver's licenses are not considered acceptable as primary photo identification documents.**

### UIDs/UATs
All UIDs/UATs that signee wants me to sign should be available from a well connected public keyserver.

UIDs do not need to contain full names but every part of the name of the UID must be backed by the identification documents that signee provides.
At least one given name must be used completely and the family name must not be abbreviated.
All diacritical marks of the names used for the UIDs must match the diacritical marks of those names in the identification documents, [see here](https://wiki.cacert.org/PracticeOnNames).

I allow "go-by names" if they are in double quotes or equivalent and I allow comments if they are in parentheses or equivalent at the end of the name.

I sign pictures (UATs), provided that:

* I make the signature with signee present, so I may compare the picture to the actual person, or
* signee hands out a clearly resembling photocopy of the picture that the signee wants me to sign.

For all email-bound UIDs, I will email my encrypted signature to the specified email-address.

After I send the email, I will remove the signature from my keyrings.
This ensures that the only way the signature can be introduced to the Web of Trust is if the owner of the email-address has possession of the corresponding private key.

For keys that have no support for encryption, I will issue a challenge that signee needs to sign in order to prove that he/she actually owns the private key.

### Signature levels
A key signature level conveys my personal assessment of how carefully I have
verified that the key claimed by signee actually belongs to signee.

I use the following signature levels.

#### 0x10 - Generic certification
I reserve the use of this signature level exclusively for reciprocity signing of root keys that belong to WoTs such as the CAcert WoT (CWoT).

#### 0x11 - Persona certification
I do not use this signature level.

#### 0x12 - Casual certification
I have met signee in person and verified that:

* signee has verified and confirmed the fingerprint of the key to be signed
* signee has confirmed ownership of the key to be signed
* the identification documents that signee provides meet the criteria listed in the Identification documents section
* all UIDs/UATs that signee wants me to sign meet the criteria listed in the UIDs/UATs section.

#### 0x13: Positive certification
As in signature type 0x12, with at least one of the following addition:

* at least one photo identification document passes verification of the forgery-protection and other security features of that document as listed on the [PRADO website](http://www.consilium.europa.eu/prado/en/).
* I've known the person for at least five years.

### Signature expiration
I may limit the validity of my certification if I have been unable to (thoroughly) assess the authenticity of the identification documents provided by signee, due to:

* poor circumstances
* lack of familiarity with the identification documents provided by signee

### Signature revocation
I may revoke my signature from the key of signee for the following reasons:

* signee fails to sign my key in return (lack of reciprocity)
* the key of signee has expired.
* there has been reasons to make me doubt about the validity of the document shown to me
* there has been reasons to make me doubt about the identity of the person

### Key transition
If I have signed your key in the past and you create a new key, e.g. because your old key is set to expire in the near future or you are transitioning to a new key, I will not consider signing your new key unless we meet in person.

### WoT compliance notice
Compliance with the certification policies and other policies for members of WoTs may in some cases lead to minor deviations from some of the policies mentioned earlier in this document.

### Changes
This policy may be replaced with a newer version at any time.
