<h1 align="center">
        <a href="https://github.com/TGWolf">
                <img src="https://github.com/TGWolf/branding/blob/master/images/general/logos/128/without-name/white.png?raw=true" alt="TGwolf" />
        </a>
        <br>
        A short description
</h1>


<p align="center">
        <a href="https://github.com/SecOpsToolkit/tcp-wrappers-country-filter">
                <img src="https://img.shields.io/travis/com/SecOpsToolkit/tcp-wrappers-country-filter/master?style=for-the-badge&logo=travis" alt="Build Status">
        </a>
        <a href="https://github.com/SecOpsToolkit/tcp-wrappers-country-filter/releases/latest">
                <img src="https://img.shields.io/github/release/SecOpsToolkit/tcp-wrappers-country-filter?color=black&style=for-the-badge&logo=github&logoColor=white&label=Latest%20Release" alt="Release">
        </a>
        <a href="LICENSE.md">
                <img src="https://img.shields.io/badge/license-MIT-black?style=for-the-badge&logo=read-the-docs&logoColor=white" alt="Software License">
        </a>
        <a href="https://www.gnu.org/software/bash/">
                <img src="https://img.shields.io/badge/Developed%20in-bash-black?logo=gnu-bash&logoColor=white&style=for-the-badge" />
        </a>
	<br>
        <a href=".github/CODE_OF_CONDUCT.md">
                <img src="https://img.shields.io/badge/Code%20of%20Conduct-black?style=for-the-badge&logo=read-the-docs&logoColor=white" />
        </a>
        <a href=".github/CONTRIBUTING.md">
                <img src="https://img.shields.io/badge/Contributing-black?style=for-the-badge&logo=read-the-docs&logoColor=white" />
        </a>
        <a href=".github/SECURITY.md">
                <img src="https://img.shields.io/badge/Report%20Security%20Concern-black?style=for-the-badge&logo=read-the-docs&logoColor=white" />
        </a>
        <a href=".github/SUPPORT.md">
                <img src="https://img.shields.io/badge/Get%20Support-black?style=for-the-badge&logo=read-the-docs&logoColor=white" />
        </a>
</p>

## Overview

This is a simple TCP wrapper which will allow you filter connections to your server based on the country of origin. It can be configured in 2 different ways:
1. To only allow connections from a specified list of countries.
2. To allow all connection EXCEPT those from a specified list of countries.

### Prerequisites

This script relies on `geoiplookup`.

#### Installing the Prerequisites

<b>Debian/Ubuntu</b>
```shell
# apt-get install geoip-bin geoip-database
```

<b>CentOS/RHEL</b>
```shell
# yum install GeoIP GeoIP-data
```

By default these install the free version of the GeoLite Country binary database (GeoIP.dat) usually in the /usr/local/share or /usr/share directory. You can either copy in a custom version of the database or edit your GeoIP.conf file to enter in your license information if you have a paid subscription.

#### Testing the Prerequisites

To perform a lookup you would simply type geoiplookup followed by an IP address, for example let’s look up one of google’s IPs.

```shell
geoiplookup 74.125.225.33
GeoIP Country Edition: US, United States
```
> If you see the above or similiar then geoiplookup is installed and working on your server.

### Configuration for the wrappers

Although this was developed for use with shhd, the principle should work for any service that is supported by TCP wrappers, however in this example we will stick to sshd.

#### /etc/hosts.allow
```shell
sshd: ALL: aclexec /usr/sbin/sshd-filter %a 
```

#### /etc/hosts.deny
```shell
sshd: ALL
````
> Allow acceptance/rejection should be handle in /etc/hosts.allow so the entry in hosts.deny is purely a catchall safety net.

## Tech Stack

[![Bash](https://img.shields.io/badge/bash-black?logo=gnu-bash&logoColor=white&style=for-the-badge)](https://www.gnu.org/software/bash/)
[![Travis CI](https://img.shields.io/badge/travis-black?logo=travis&logoColor=white&style=for-the-badge)](https://travis-ci.com/)

## Contributors

<p>
        <a href="https://github.com/TGWolf">
                <img src="https://img.shields.io/badge/Wolf-black?style=for-the-badge&logo=baidu&logoColor=white" />
        </a>
</p>
