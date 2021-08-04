/*
Just load current (proxysql.cnf) config to runtime and save it to
update the internal runtime_checksums_values, in order for satellites to pick up any changes.
*/
LOAD ADMIN VARIABLES TO RUNTIME;
SAVE ADMIN VARIABLES TO DISK;

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;

LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;

LOAD PROXYSQL SERVERS TO RUNTIME;
SAVE PROXYSQL SERVERS TO DISK;

/*
Get current version and checksums
*/
SELECT * FROM stats_proxysql_servers_checksums ORDER BY name,hostname;
