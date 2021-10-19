# [Squid](http://www.squid-cache.org/)

## [Ubuntu install](https://ubuntu.com/server/docs/proxy-servers-squid)

```bash
sudo apt install squid
```

## Configuration

Squid is configured by editing the directives contained within the `/etc/squid/squid.conf` configuration file. The following examples illustrate some of the directives which may be modified to affect the behavior of the Squid server. For more in-depth configuration of Squid, see the [References section](http://www.squid-cache.org/Doc/config/).

### Basic permissive

```squid
http_port 3128

http_access allow all
```

### Datadog proxy

Allows only Datadog as a destination and allows metrics collection only from the localhost.

```squid
http_port 0.0.0.0:3128

acl local src 127.0.0.1/32

acl Datadog dstdomain .datadoghq.com
acl Datadog dstdomain .datadoghq.eu

http_access allow Datadog
http_access allow local manager
```

## Datadog monitoring

Add `dd-agent` to the `proxy` group so we can read Squid logs.

```bash
usermod -aG proxy dd-agent
```

Create `/etc/datadog-agent/conf.d/squid.d/conf.yaml` with the content below and restart the agent. Check [conf.yaml.example](https://github.com/DataDog/integrations-core/blob/master/squid/datadog_checks/squid/data/conf.yaml.example) for the full set of configuration options.

```yaml
init_config:
instances:
- name: squid
  service: squid
logs:
- type: file
  path: /var/log/squid/cache.log
  service: squid
  source: squid
- type: file
  path: /var/log/squid/access.log
  service: squid
  source: squid
# Exclude agent metrics requests
  log_processing_rules:
  - type: exclude_at_match
    name: agent_checks
    pattern: /squid-internal-mgr/counters
```

## Tips and tricks

- Tailing the access log can show you what request are going through your proxy. You can find Squid log format [here](https://wiki.squid-cache.org/Features/LogFormat).

```bash
sudo tail -f /var/log/squid/access.log
```

- You can test request using, or not, the proxy with [curl](https://everything.curl.dev/usingcurl/proxies).

```bash
# Using the proxy
curl -v --proxy proxy:3128 http://ipv4.icanhazip.com

# Ignoring the proxy
curl -v --noproxy * http://ipv4.icanhazip.com
```

- Be aware of the case sensitivity of proxy environment variables. <sup>[1](https://everything.curl.dev/usingcurl/proxies#http_proxy-in-lower-case-only), [2](https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy/)</sup>
