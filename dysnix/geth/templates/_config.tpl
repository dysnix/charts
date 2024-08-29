{{- with .Values.config.eth -}}
[Eth]
SyncMode = {{ .syncMode | quote }}
EthDiscoveryURLs = []
SnapDiscoveryURLs = []
NoPruning = {{ eq .gcMode "archive" | ternary true false }}
NoPrefetch = false
TxLookupLimit = {{ int .txLookupLimit }}
TransactionHistory = {{ int .transactionHistory }}
StateHistory = {{ int .stateHistory }}
StateScheme = {{ .stateScheme | quote }}
LightPeers = 100
DatabaseCache = 512
DatabaseFreezer = ""
TrieCleanCache = 154
TrieDirtyCache = 256
TrieTimeout = 3600000000000
SnapshotCache = 102
Preimages = {{ .preimages }}
FilterLogCacheSize = 32
EnablePreimageRecording = false
VMTrace = ""
VMTraceJsonConfig = ""
RPCGasCap = 50000000
RPCEVMTimeout = 5000000000
RPCTxFeeCap = 1e+00
{{- end }}

[Eth.Miner]
GasCeil = 30000000
GasPrice = 1000000000
Recommit = 2000000000

[Eth.TxPool]
Locals = []
NoLocals = false
Journal = "transactions.rlp"
Rejournal = 3600000000000
PriceLimit = 1
PriceBump = 10
AccountSlots = 16
GlobalSlots = 5120
AccountQueue = 64
GlobalQueue = 1024
Lifetime = 10800000000000

[Eth.BlobPool]
Datadir = "blobpool"
Datacap = 2684354560
PriceBump = 100

[Eth.GPO]
Blocks = 20
Percentile = 60
MaxHeaderHistory = 1024
MaxBlockHistory = 1024
MaxPrice = 500000000000
IgnorePrice = 2

{{ with .Values.config.node -}}
[Node]
DataDir = "{{ $.Values.config.datadir }}"
IPCPath = {{ .ipc.enabled | ternary .ipc.path "" | quote }}
HTTPHost = {{ .http.enabled | ternary "0.0.0.0" "" | quote }}
HTTPPort = {{ .http.port }}
HTTPVirtualHosts = {{ include "toml.list" .http.vhosts }}
HTTPModules = {{ include "toml.list" .http.modules }}
HTTPCors = {{ include "toml.list" .http.cors }}
AuthAddr = "0.0.0.0"
AuthPort = {{ .authrpc.port }}
AuthVirtualHosts = {{ include "toml.list" .authrpc.vhosts }}
WSHost = {{ .ws.enabled | ternary "0.0.0.0" "" | quote }}
WSPort = {{ .ws.port }}
WSModules = {{ include "toml.list" .ws.modules }}
WSOrigins = {{ include "toml.list" .ws.origins }}
GraphQLVirtualHosts = ["localhost"]
BatchRequestLimit = 1000
BatchResponseMaxSize = 25000000
JWTSecret = "/secrets/jwt.hex"
{{- end }}

{{ with .Values.config.node.p2p -}}
[Node.P2P]
MaxPeers = {{ int .maxPeers }}
NoDiscovery = {{ .noDiscovery }}
DiscoveryV4 = true
{{- if .bootstrapNodes }}
BootstrapNodes = {{ include "toml.list" .bootstrapNodes }}
{{- end }}
{{- if .bootstrapNodesV5 }}
BootstrapNodesV5 = {{ include "toml.list" .bootstrapNodesV5 }}
{{- end }}
StaticNodes = {{ include "toml.list" .staticNodes }}
TrustedNodes = {{ include "toml.list" .trustedNodes }}
ListenAddr = ":{{ .port }}"
DiscAddr = ":{{ .discoveryPort }}"
EnableMsgEvents = false
{{- end }}

[Node.HTTPTimeouts]
ReadTimeout = 30000000000
ReadHeaderTimeout = 30000000000
WriteTimeout = 30000000000
IdleTimeout = 120000000000

{{/*

https://github.com/ethereum/go-ethereum/issues/24178
Metrics section in TOML config does not work, so use only CLI flags

[Metrics]
Enabled = {{ .enabled }}
EnabledExpensive = {{ .expensive }}
HTTP = "0.0.0.0"
Port = {{ .port }}
InfluxDBEndpoint = "http://localhost:8086"
InfluxDBDatabase = "geth"
InfluxDBUsername = "test"
InfluxDBPassword = "test"
InfluxDBTags = "host=localhost"
InfluxDBToken = "test"
InfluxDBBucket = "geth"
InfluxDBOrganization = "geth"

*/}}