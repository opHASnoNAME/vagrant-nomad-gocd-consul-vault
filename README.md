# Playground VM 

## Whats inside, and some infos

VM to test out some Tools from Hashicorp and Docker based on Centos7

- Nomad
- GoCD
- Consul
- Vault
- Docker
- Docker-Registry

All tools are integrated, you can use vault with nomad and nomad with consul :-) To use vault
you have to initalize first:

`vault operator init`

## Setup

Change IP in Vagrantfile if you don't want to use: 172.20.20.10

- Run `vagrant up` 
- Use `vagrant ssh` and reboot once `sudo reboot` to finish setup

Now you should be able to test out the included tools.