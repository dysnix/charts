{{- define "ai-auth.defaultServiceConfigs" -}}
debugMode: true
profiling:
  enabled: true
monitoring:
  enabled: true
single:
  enabled: true
  host: 0.0.0.0
  port: 8097
  name: pprof/monitoring server
  concurrency: 100000
  buffer:
    readBufferSize: 4MiB
    writeBufferSize: 4MiB
  tcpKeepalive:
    enabled: true
    period: 1s
  httptransport:
    maxIdleConnDuration: 15s
    readTimeout: 7s
    writeTimeout: 7s
postgres:
  username: ai-scale
  password: ""
  database: ai-scale
  host: localhost
  port: 5432
  schema: public
  sslmode: disable
  pool:
    maxIdleConns: 1
    maxOpenConns: 10
    connMaxLifetime: 1m
grpc:
  enabled: true
  useReflection: true
  compression:
    enabled: false
    type: Zstd
  connection:
    host: 0.0.0.0
    port: 8091
    readBufferSize: 4MiB
    writeBufferSize: 4MiB
    maxMessageSize: 1MiB
    insecure: true
    timeout: 15s
  keepalive:
    time: 5m
    timeout: 5m
    enforcementPolicy:
      minTime: 20m
      permitWithoutStream: false
{{- end }}