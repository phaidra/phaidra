CREATE USER IF NOT EXISTS 'grafana' IDENTIFIED BY 'grafana';
GRANT SELECT ON phaidradb.* to 'grafana';
