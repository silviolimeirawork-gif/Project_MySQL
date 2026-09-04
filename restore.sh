#!/bin/bash

export LC_ALL=C

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
print_ok() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

if [ -z "$1" ]; then
    echo "Uso: $0 <arquivo.sql> [banco_destino]"
    echo "   Se banco_destino for omitido, restaura todos os bancos."
    echo "   Se banco_destino for informado, tenta extrair e restaurar apenas o banco 'empresa' para ele."
    exit 1
fi

SQL_FILE="$1"
TARGET_DB="$2"

if [ ! -f "$SQL_FILE" ]; then
    print_error "Arquivo não encontrado: $SQL_FILE"
    exit 1
fi

# Remove avisos da primeira linha (se houver)
if head -n 1 "$SQL_FILE" | grep -q "Warning"; then
    print_warn "Removendo aviso da primeira linha..."
    sed -i '1d' "$SQL_FILE"
fi

if [ -z "$TARGET_DB" ]; then
    # Restaura todos os bancos
    echo "Restaurando todos os bancos..."
    mysql -u root -p < "$SQL_FILE"
    if [ $? -eq 0 ]; then
        print_ok "Restauração completa concluída."
    else
        print_error "Falha na restauração."
    fi
else
    # Restaura apenas o banco 'empresa' para o destino
    echo "Extraindo banco 'empresa' do dump e restaurando em '$TARGET_DB'..."
    # Cria o banco de destino se não existir
    mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS \`$TARGET_DB\`;"
    # Extrai a seção do banco empresa e restaura
    sed -n '/^CREATE DATABASE \`empresa\`/,/^CREATE DATABASE \`/p' "$SQL_FILE" | \
    mysql -u root -p "$TARGET_DB"
    if [ $? -eq 0 ]; then
        print_ok "Banco 'empresa' restaurado em '$TARGET_DB'."
    else
        print_error "Falha na restauração do banco 'empresa'."
    fi
fi
