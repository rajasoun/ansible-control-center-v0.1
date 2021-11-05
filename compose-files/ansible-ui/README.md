# asnible-ui

UI for running Ansible playbooks

## Pre Requisites

* Docker Ready Host

## Getting Started 

1. Prepare env files 

```
cp config/templates/db.env.sample config/db.env
cp config/templates/semaphore.env.sample config/semaphore.env
```

Edit the `config/db.env` and `config/semaphore.env`

2. Run [semaphore](https://docs.ansible-semaphore.com/) 

```
./assist.bash up  
./assist.bash status
```