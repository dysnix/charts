{{- with .Values.config.eth -}}
[Eth]
SyncMode = {{ .syncMode | quote }}
EthDiscoveryURLs = ["enrtree://AKA3AM6LPBYEUDMVNU3BSVQJ5AD45Y7YPOHJLEF6W26QOE4VTUDPE@all.mainnet.ethdisco.net"]
SnapDiscoveryURLs = ["enrtree://AKA3AM6LPBYEUDMVNU3BSVQJ5AD45Y7YPOHJLEF6W26QOE4VTUDPE@all.mainnet.ethdisco.net"]
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
RPCGasCap = 50000000
RPCEVMTimeout = 5000000000
RPCTxFeeCap = 1e+00
{{- end }}

[Eth.Miner]
GasFloor = 0
GasCeil = 30000000
GasPrice = 1000000000
Recommit = 2000000000
NewPayloadTimeout = 2000000000

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
Datacap = 10737418240
PriceBump = 100

[Eth.GPO]
Blocks = 20
Percentile = 60
MaxHeaderHistory = 1024
MaxBlockHistory = 1024
MaxPrice = 500000000000
IgnorePrice = 2

{{- with .Values.config.node }}
[Node]
DataDir = "/root/.ethereum"
IPCPath = {{ .ipc.enabled | ternary .ipc.path "" | quote }}
HTTPHost = {{ .http.enabled | ternary "0.0.0.0" "" | quote }}
HTTPPort = {{ .http.port }}
HTTPVirtualHosts = {{ include "geth.tomlList" .http.vhosts }}
HTTPModules = {{ include "geth.tomlList" .http.modules }}
HTTPCors = {{ include "geth.tomlList" .http.cors }}
AuthAddr = "0.0.0.0"
AuthPort = {{ .authrpc.port }}
AuthVirtualHosts = {{ include "geth.tomlList" .authrpc.vhosts }}
WSHost = {{ .ws.enabled | ternary "0.0.0.0" "" | quote }}
WSPort = {{ .ws.port }}
WSModules = {{ include "geth.tomlList" .ws.modules }}
WSOrigins = {{ include "geth.tomlList" .ws.origins }}
GraphQLVirtualHosts = ["localhost"]
BatchRequestLimit = 1000
BatchResponseMaxSize = 25000000
JWTSecret = "/secrets/jwt.hex"
{{- end }}

{{- with .Values.config.node.p2p }}
[Node.P2P]
MaxPeers = {{ int .maxPeers }}
NoDiscovery = {{ .noDiscovery }}
DiscoveryV4 = true
BootstrapNodes = {{ include "geth.tomlList" .bootstrapNodes }}
BootstrapNodesV5 = {{ include "geth.tomlList" .bootstrapNodesV5 }}
StaticNodes = {{ include "geth.tomlList" .staticNodes }}
TrustedNodes = {{ include "geth.tomlList" .trustedNodes }}
ListenAddr = ":{{ .port }}"
DiscAddr = ""
EnableMsgEvents = false
{{- end }}

[Node.HTTPTimeouts]
ReadTimeout = 30000000000
ReadHeaderTimeout = 30000000000
WriteTimeout = 30000000000
IdleTimeout = 120000000000

{{- with .Values.config.metrics }}
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
{{- end }}