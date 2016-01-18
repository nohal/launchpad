Scripts and configuration to produce Launchpad PPA Packages for OpenCPN
=======================================================================

```sudo apt-get install devscripts cdbs```

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

TODO
----
before uploading the sources, strip the stuff irrelevant on linux to save space, time and make it more Debian like.
