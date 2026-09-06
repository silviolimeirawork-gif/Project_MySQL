#!/bin/bash
# verify_backup.sh - Verifica se o backup pode ser descriptografado e descompactado

if [ -z "$BACKUP_PASS" ]; then
    echo "❌ Erro: A variável de ambiente BACKUP_PASS não está definida."
    exit 1
fi

LATEST=$(ls -t /backup/backup_*.sql.gz.enc 2>/dev/null | head -1)
if [ -z "$LATEST" ]; then
    echo "❌ Nenhum backup encontrado."
    exit 1
fi

echo "🔍 Verificando integridade de: $LATEST"
# Tenta descriptografar e descompactar, enviando saída para /dev/null
openssl enc -d -aes-256-cbc -pbkdf2 -in "$LATEST" -pass "env:BACKUP_PASS" 2>/dev/null | \
gunzip -t 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Backup íntegro (descriptografia e descompressão OK)."
else
    echo "❌ Falha na verificação. Senha incorreta ou arquivo corrompido."
    exit 1
fi
