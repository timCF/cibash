CI bash scripts for build and deploy
====================================

Configure your .gitlab-ci.yml file like this (example is elixir app)

```
elixir:
  script:
  - echo "getting cibash scripts"
  - wget https://github.com/timCF/cibash/archive/0.0.1.tar.gz
  - tar xvzf ./0.0.1.tar.gz
  - echo "START elixir build script"
  - ./cibash-0.0.1/elixir.sh app_name erlang_nodename user@my-prod-server.com run
  - echo "END elixir build script"
  tags:
  - elixir
  except:
  - tags
```

Where

- app_name is name of your elixir main application
- erlang_nodename is name of release erlang node you wish
- user@my-prod-server.com is your deploy server name and user name
- last param can be "run" (will run erlang node with supervisord) or "build" (just build release)

Requirements

- define ID_RSA variable in your CI, it's your ssh key private value
- add public ssh key to ~/.ssh/authorized_keys in deploy server
- mkdir releases directory in deploy server, for example for elixir it's ~/elixir_releases
- if you want use "run" cmd, you should install and configure supervisord app in in deploy server
- comment line with "requiretty" in file /etc/sudoers in deploy server

Elixir releases requirements

- [exrm ~> 0.19.9](https://github.com/bitwalker/exrm) is tool to build standalone elixir releases, add to app deps
- it's good (but not required) to use code analysis tool [silverb ~> 0.0.1](https://github.com/timCF/silverb)

To get yandex token, go [here](https://oauth.yandex.ru/authorize?response_type=token&client_id=7ef348d4d4da4559be55d0bfeb92eef7)

mac.sh
======

script installs dev env for elixir development, needs xcode installed and activated!
