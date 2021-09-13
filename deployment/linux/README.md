# Basic Linux monitoring

## Agent - [datadog.yaml](https://github.com/DataDog/datadog-agent/blob/master/pkg/config/config_template.yaml)

```yaml
api_key: <API-KEY>
env: <ENVIRONMENT>
apm_config:
    enabled: true
logs_enabled: true
logs_config:
    compression_level: 6
    use_compression: true
    use_http: true
    container_collect_all: true
process_config:
    enabled: true
```

## journald - [journald.d/conf.yaml](https://github.com/DataDog/integrations-core/blob/master/journald/datadog_checks/journald/data/conf.yaml.example)

```yaml
logs:
  - type: journald
    container_mode: true
```

Journal files are, by default, owned and readable by the systemd-journal system group. To start collecting your journal logs, you need to add the `dd-agent` user to the `systemd-journal` group.

```bash
usermod -a -G systemd-journal dd-agent
```
