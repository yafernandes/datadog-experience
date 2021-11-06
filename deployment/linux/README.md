# Basic Linux monitoring

## Agent - [datadog.yaml](https://github.com/DataDog/datadog-agent/blob/master/pkg/config/config_template.yaml)

```yaml
api_key: <API-KEY>
env: <ENVIRONMENT>
apm_config:
  enabled: true
logs_enabled: true
process_config:
  enabled: true
```

## journald - [journald.d/conf.yaml](https://github.com/DataDog/integrations-core/blob/master/journald/datadog_checks/journald/data/conf.yaml.example)

```yaml
logs:
  - type: journald
    container_mode: true
```

Individual units can be included/excluded using `include_units`/`exclude_units`.

Journal files are, by default, owned and readable by the systemd-journal system group. To start collecting your journal logs, you need to add the `dd-agent` user to the `systemd-journal` group.

```bash
usermod -aG systemd-journal dd-agent
```

## Docker - [docker_daemon.d/conf.yaml](https://github.com/DataDog/integrations-core/blob/master/docker_daemon/datadog_checks/docker_daemon/data/conf.yaml.example)

If using Docker, merge the lines below to `datadog.yaml`.

```yaml
logs_config:
  container_collect_all: true
config_providers:
  - name: docker
    polling: true
listeners:
  - name: docker
```

You will need to make sure the `dd-agent` has access to the Docker socket. Add the user `dd-agent` to the `docker` group.

```bash
usermod -aG docker dd-agent
```
