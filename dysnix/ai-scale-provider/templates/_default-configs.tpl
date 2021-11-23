{{- define "default.service.configs" -}}
debugMode: true
profiling:
  enabled: true
monitoring:
  enabled: true
single:
  enabled: true
  host: localhost
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
metricsSource:
  metricsSourceType: Prometheus
  prometheus:
    url: http://localhost:9090
    concurrency: 10
    httpTransport:
      maxIdleConnDuration: 1m
      readTimeout: 7s
      writeTimeout: 7s
grpc:
  enabled: true
  useReflection: true
  compression:
    enabled: true
    type: Zstd
  connection:
    host: 0.0.0.0
    port: 8091
    readBufferSize: 100MiB
    writeBufferSize: 100MiB
    maxMessageSize: 30MiB
    insecure: true
    timeout: 15s
  keepalive:
    time: 5m
    timeout: 5m
    enforcementPolicy:
      minTime: 20m
      permitWithoutStream: false
{{- end }}