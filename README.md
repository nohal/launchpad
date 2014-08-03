Scripts and configuration to produce Launchpad PPA Packages for OpenCPN
=======================================================================

Configuration
-------------
You must have the keys registered on Launchpad

~/.dput.cf (/etc/dput.cf):
```
[ppa]
fqdn            = ppa.launchpad.net
method          = ftp
incoming        = ~nohal/opencpn
login           = anonymous

[ppa-data]
fqdn            = ppa.launchpad.net
method          = ftp
incoming        = ~nohal/opencpn-data
login           = anonymous
```
