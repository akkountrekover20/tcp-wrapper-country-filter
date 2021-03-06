<h1 align="center">
        <a href="https://github.com/WolfSoftware">
                <img src="https://raw.githubusercontent.com/WolfSoftware/branding/master/images/general/banners/64/black-and-white.png " alt="Wolf Software Logo" />
        </a>
        <br>
        TCP wrapper to filter by country
</h1>


<p align="center">
        <a href="https://travis-ci.com/SecOpsToolbox/tcp-wrapper-country-filter">
                <img src="https://img.shields.io/travis/com/SecOpsToolbox/tcp-wrapper-country-filter/master?style=for-the-badge&logo=travis" alt="Build Status">
        </a>
        <a href="https://github.com/SecOpsToolbox/tcp-wrapper-country-filter/releases/latest">
                <img src="https://img.shields.io/github/v/release/SecOpsToolbox/tcp-wrapper-country-filter?color=blue&style=for-the-badge&logo=github&logoColor=white&label=Latest%20Release" alt="Release">
        </a>
        <a href="LICENSE.md">
                <img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" alt="Software License">
        </a>
        <a href="https://www.gnu.org/software/bash/">
                <img src="https://img.shields.io/badge/Developed%20in-bash-blue?logo=gnu-bash&logoColor=white&style=for-the-badge" />
        </a>
	<br>
        <a href=".github/CODE_OF_CONDUCT.md">
                <img src="https://img.shields.io/badge/Code%20of%20Conduct-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
        </a>
        <a href=".github/CONTRIBUTING.md">
                <img src="https://img.shields.io/badge/Contributing-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
        </a>
        <a href=".github/SECURITY.md">
                <img src="https://img.shields.io/badge/Report%20Security%20Concern-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
        </a>
        <a href=".github/SUPPORT.md">
                <img src="https://img.shields.io/badge/Get%20Support-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
        </a>
</p>

## Overview

This is a simple TCP wrapper which will allow you filter connections to your server based on the country of origin. It can be configured in 2 different ways:
1. To only allow connections from a specified list of countries.
2. To allow all connection EXCEPT those from a specified list of countries.

This was developed due to a need to be able to block countries from being able to attack our servers. The issue is that some of the countries have in excess of 8000+ ip blocks so adding them all to IPTables wasn't a very scalable solution. We wanted something where we could specify a country and the rest would be automatic.

Although this was developed to be used for ssh (sshd) connections, the same principle and configuration can be applied to any service that is supported by tcp wrappers. For example:
```
ftpd:
imapd:
popd:
sendmail:
sshd:
ALL:
```

### Prerequisites

This script relies on `geoiplookup`, if it is not installed then the script will log an error and `accept` the connection, even if the default [`ACTION`](src/country-filter.sh#L26) is `DENY`. Without this ALL connections would be blocked including your own (which would be bad)

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

### Configuration

Although this was developed for use with shhd, the principle should work for any service that is supported by TCP wrappers, however in this example we will stick to sshd.

#### Install the filter

Simply copy the [script](src/country-filter.sh) to /usr/sbin/country-filter (and ensure that it is executable [chmod +x]).

Out of the box the country list is empty and the script has the default action of DENY (only block countries in the list), so the net effect at this point is to block nothing.

##### Adding countries

To add countries to the list simple add them to the [`COUNTRIES`](src/country-filter.sh#L23) variable, this is a space seperated list of country codes (2 letter codes). 

If you want to block all entries where a country cannot be found simple add `--` to the [`COUNTRIES`](src/country-filter.sh#L23) variable.

##### Allow or Deny

By default the script will deny connections from any country listed in the [`COUNTRIES`](src/country-filter.sh#L23) variable, however you can invert this logic and only allow connections from these countries, by setting the [`ACTION`](src/country-filter.sh#L26) variable to `ALLOW`.

#### /etc/hosts.allow
```shell
sshd: ALL: aclexec /usr/sbin/country-filter %a 
```

#### /etc/hosts.deny
```shell
sshd: ALL
````
> Allow acceptance/rejection should be handle in /etc/hosts.allow so the entry in hosts.deny is purely a catchall safety net.

## Testing

This script has been tested with a large number of IP addresses to ensure that it works as expected, it has also been tested of multiple OS flavours and versions, as long as the prerequisites are met then it should function as desired.

It is also being actively used on all of my servers and rejecting hundreds of connections daily.

## Alternatives to blocking whole country

If you do not want to block the entire country just because of a few dodgy people then how about [filtering connections based on AS Number?](https://github.com/SecOpsToolbox/tcp-wrapper-asn-filter).


## Tech Stack

[![Bash](https://img.shields.io/badge/bash-blue?logo=gnu-bash&logoColor=white&style=for-the-badge)](https://www.gnu.org/software/bash/)


## Contributors

<p>
        <a href="https://github.com/TGWolf">
                <img src="https://img.shields.io/badge/Wolf-black?style=for-the-badge&logo=baidu&logoColor=white" />
        </a>
</p>

## Show Support

<p>
        <a href="https://ko-fi.com/wolfsoftware">
                <img src="https://img.shields.io/badge/Ko%20Fi-blue?style=for-the-badge&logo=ko-fi&logoColor=white" />
        </a>
</p>
