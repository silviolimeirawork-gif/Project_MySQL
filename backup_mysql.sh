#!/bin/bash
# backup_mysql.sh - Faz backup criptografado usando senha da variável de ambiente

# Verifica se a variável está definida
if [ -z "$BACKUP_PASS" ]; then
    echo "❌ Erro: A variável de ambiente BACKUP_PASS não está definida."
    echo "Defina com: export BACKUP_PASS=\"sua_senha\""
    exit 1
fi

# Verifica a senha do MySQL (opcional, use ~/.my.cnf ou export MYSQL_PWD)
if [ -z "$MYSQL_PWD" ]; then
    echo "⚠️  MYSQL_PWD não definida. O script pedirá a senha do MySQL."
    MYSQL_AUTH="-p"
else
    MYSQL_AUTH="-u root"
fi

BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql.gz.enc"

mkdir -p "$BACKUP_DIR"

echo "🔄 Iniciando backup..."
mysqldump $MYSQL_AUTH --all-databases --single-transaction --quick | \
pv -pterb | \
gzip | \
openssl enc -aes-256-cbc -pbkdf2 -out "$BACKUP_FILE" -pass "env:BACKUP_PASS"

if [ $? -eq 0 ]; then
    echo "✅ Backup concluído: $BACKUP_FILE"
else
    echo "❌ Falha no backup."
    exit 1
fi
