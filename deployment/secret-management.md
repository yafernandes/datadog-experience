# [Secrets Management](https://docs.datadoghq.com/agent/guide/secrets-management)

## Windows - PowerShell example

Make a copy of `powershell.exe` so we can set its persimissions without affecting anyone else.

```cmd
copy C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe <PATH>\
icacls <PATH>\powershell.exe /grant:r ddagentuser:RX /grant:r SYSTEM:F /grant:r Administrators:F /inheritancelevel:r
```

Copy the PowerShell scripts below to `sm.ps1`.

```powershell
$secrets = ($input | ConvertFrom-Json).secrets

$output = @{}

foreach ($secret in $secrets) {
    $value =  @{
                 value = "passw0rd"
                 error = $null
               }
    $output.add($secret, $value)
}

$output | ConvertTo-Json -Compress
```

Set the backend propertly on [datadog.yaml](https://docs.datadoghq.com/agent/basic_agent_usage/windows/?tab=gui#configuration).

```yaml
secret_backend_command: <PATH>\powershell.exe
secret_backend_arguments: -File <PATH>\sm.ps1
```
