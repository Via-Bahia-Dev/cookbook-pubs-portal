pubs-portal Cookbook
====================
Provides and provisions development environment for Pubs Portal.

Requirements
------------
#### Platforms
* Ubuntu 12.04

#### Cookbooks
Requires `ssh_known_hosts` cookbook for adding hosts and keys to known_hosts file.

Requires `rbenv` cookbook for ruby installation

Usage
-----
pubs-portal::default
-Includes pubs-portal::setup

