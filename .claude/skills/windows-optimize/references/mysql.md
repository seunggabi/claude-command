# MySQL Optimization Reference (Windows)

## Config File Location

MySQL 8.x on Windows reads from:
- `C:\ProgramData\MySQL\MySQL Server 8.x\my.ini`  ← primary
- `C:\my.ini`
- `%WINDIR%\my.ini`

**Important:** Always edit the ProgramData path. Writing to other locations will NOT be picked up.

## Recommended Settings by RAM

### 64 GB RAM (high-write server)

```ini
[mysqld]
datadir=D:/MySQL/data

# Buffer Pool - 75% of RAM
innodb_buffer_pool_size=48G
innodb_buffer_pool_instances=16

# Redo Log - large write workloads
innodb_redo_log_capacity=4G

# SSD I/O
innodb_io_capacity=4000
innodb_io_capacity_max=8000
innodb_flush_neighbors=0

# Performance (single server, no replication)
innodb_flush_log_at_trx_commit=2
sync_binlog=0

# Disable binary log (no replication)
skip_log_bin

# Connections
max_connections=300
thread_cache_size=16
table_open_cache=4000
```

### 32 GB RAM

```ini
innodb_buffer_pool_size=24G
innodb_buffer_pool_instances=8
innodb_redo_log_capacity=2G
innodb_io_capacity=2000
innodb_io_capacity_max=4000
```

### 16 GB RAM

```ini
innodb_buffer_pool_size=12G
innodb_buffer_pool_instances=4
innodb_redo_log_capacity=1G
innodb_io_capacity=1000
innodb_io_capacity_max=2000
```

## Key Settings Explained

| Setting | Purpose |
|---------|---------|
| `innodb_buffer_pool_size` | Main memory cache for InnoDB. Set to 70-75% of RAM. |
| `innodb_buffer_pool_instances` | Splits buffer pool to reduce mutex contention. Use 1 per GB up to 16. |
| `innodb_redo_log_capacity` | Size of redo log. Larger = better write throughput, slower crash recovery. |
| `innodb_io_capacity` | IOPS hint for background tasks. 4000 = typical SSD. |
| `innodb_flush_neighbors` | Set to 0 for SSD (no benefit flushing adjacent pages). |
| `innodb_flush_log_at_trx_commit=2` | Flush to OS buffer each commit, disk once/sec. Risk: 1s data loss on crash. |
| `skip_log_bin` | Disables binary logging. Only safe when no replication. |

## After Editing

Always restart MySQL after changing `my.ini`:

```powershell
# Find service name
sc query type= all state= all | findstr -i mysql

# Restart
net stop MySQL && net start MySQL

# Verify
mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"
```
