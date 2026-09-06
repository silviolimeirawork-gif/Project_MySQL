#!/bin/bash
# restore_mysql.sh - Restaura usando variáveis de ambiente

if [ -z "$BACKUP_PASS" ]; then
    echo "❌ BACKUP_PASS não definida"
    exit 1
fi

# Define a senha do MySQL pela variável (se existir)
if [ -n "$MYSQL_PWD" ]; then
    MYSQL_CMD="mysql -u root"
else
    MYSQL_CMD="mysql -u root -p"
fi

LATEST=$(ls -t /backup/backup_*.sql.gz.enc | head -1)
[ -z "$LATEST" ] && echo "❌ Nenhum backup" && exit 1

echo "🔄 Restaurando: $LATEST"
openssl enc -d -aes-256-cbc -pbkdf2 -in "$LATEST" -pass "env:BACKUP_PASS" | \
pv -pterb | \
gunzip | \
$MYSQL_CMD

[ $? -eq 0 ] && echo "✅ Restauração concluída." || echo "❌ Falha."
