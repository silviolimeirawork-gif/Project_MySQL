#!/bin/bash

export LC_ALL=C

# Configurações
MYSQL_USER="root"
DUMP_DIR="./dumps"

mkdir -p "$DUMP_DIR"

# Função para testar conexão
test_connection() {
    local pass="$1"
    if [ -n "$pass" ]; then
        mysql -u "$MYSQL_USER" -p"$pass" -e "SELECT 1" > /dev/null 2>&1
    else
        mysql -u "$MYSQL_USER" -e "SELECT 1" > /dev/null 2>&1
    fi
    return $?
}

echo "========================================"
echo "Testando conexão com o MySQL..."
if test_connection ""; then
    MYSQL_PASS=""
    echo "✅ Conectado sem senha."
elif test_connection "$MYSQL_PASS" 2>/dev/null; then
    echo "✅ Conectado com a senha fornecida."
else
    echo "⚠️  Senha não configurada."
    read -s -p "Digite a senha do usuário $MYSQL_USER: " MYSQL_PASS
    echo
    if ! test_connection "$MYSQL_PASS"; then
        echo "❌ Senha incorreta. Saindo."
        exit 1
    fi
    echo "✅ Conectado com sucesso."
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DUMP_FILE="$DUMP_DIR/all_databases_$TIMESTAMP.sql"

echo "========================================"
echo "Iniciando dump com mysqldump..."
echo "Arquivo: $DUMP_FILE"
echo "========================================"

# Executa o dump – stderr redirecionado para /dev/null
if [ -n "$MYSQL_PASS" ]; then
    mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASS" \
        --all-databases \
        --single-transaction \
        --routines \
        --triggers \
        --events 2> /dev/null > "$DUMP_FILE"
else
    mysqldump -u "$MYSQL_USER" \
        --all-databases \
        --single-transaction \
        --routines \
        --triggers \
        --events 2> /dev/null > "$DUMP_FILE"
fi

if [ -f "$DUMP_FILE" ] && [ -s "$DUMP_FILE" ]; then
    SIZE=$(stat -c%s "$DUMP_FILE" 2>/dev/null || stat -f%z "$DUMP_FILE" 2>/dev/null)
    echo "✅ Dump gerado com sucesso!"
    echo "📁 Arquivo: $DUMP_FILE"
    echo "📊 Tamanho: $(numfmt --to=iec $SIZE 2>/dev/null || echo "$SIZE bytes")"
    echo "========================================"
else
    echo "❌ Falha ao gerar o dump."
    exit 1
fi
