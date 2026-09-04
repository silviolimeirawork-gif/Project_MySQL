# Teste com mysql (cliente tradicional)
mysql -u root -p

# Se funcionar, configure .my.cnf
cat > ~/.my.cnf << 'EOF'
[client]
user=root
password=SUA_SENHA
EOF
chmod 600 ~/.my.cnf

# Teste com mysqlsh no modo SQL (recomendado)
mysqlsh --uri root@localhost --sql --execute 'SELECT 1'

# Ou no modo Python com session.run_sql
mysqlsh --uri root@localhost --py --execute 'session.run_sql("SELECT 1")'
