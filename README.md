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
