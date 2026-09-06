#!/bin/bash
# ==========================================
# Script de Backup MySQL com Criptografia Assimétrica (RSA)
# ==========================================
# Uso:
#   ./backup_mysql_asym.sh --backup       # Faz backup usando chave pública
#   ./backup_mysql_asym.sh --restore      # Restaura usando chave privada
#   ./backup_mysql_asym.sh --create-keys  # Gera par de chaves RSA
#   ./backup_mysql_asym.sh --help         # Ajuda
# ==========================================

BACKUP_DIR="/backup"
KEY_DIR="$HOME/.mysql_backup_keys"
PUBLIC_KEY="$KEY_DIR/backup.pub"
PRIVATE_KEY="$KEY_DIR/backup.pem"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql.gz.enc"
SYMMETRIC_KEY_FILE="$BACKUP_DIR/backup_$DATE.key.enc"  # chave simétrica criptografada
MYSQL_USER="root"
MYSQL_HOST="localhost"

mkdir -p "$BACKUP_DIR" "$KEY_DIR"

# ==========================================
# Gerar par de chaves RSA (4096 bits)
# ==========================================
create_keys() {
    echo "🔑 Gerando par de chaves RSA de 4096 bits..."
    if [ -f "$PRIVATE_KEY" ] || [ -f "$PUBLIC_KEY" ]; then
        echo "⚠️  Já existem chaves em $KEY_DIR"
        read -p "Deseja sobrescrevê-las? (s/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            echo "Operação cancelada."
            return
        fi
        rm -f "$PRIVATE_KEY" "$PUBLIC_KEY"
    fi

    # Gerar chave privada (sem senha - você pode adicionar -aes256 se quiser proteger com senha)
    openssl genrsa -out "$PRIVATE_KEY" 4096
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao gerar chave privada."
        return 1
    fi

    # Extrair chave pública
    openssl rsa -in "$PRIVATE_KEY" -pubout -out "$PUBLIC_KEY"
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao extrair chave pública."
        return 1
    fi

    chmod 600 "$PRIVATE_KEY"
    chmod 644 "$PUBLIC_KEY"
    echo "✅ Chaves geradas com sucesso!"
    echo "   Chave privada: $PRIVATE_KEY (mantenha em segurança!)"
    echo "   Chave pública:  $PUBLIC_KEY (compartilhe com quem fizer backup)"
}

# ==========================================
# Backup usando chave pública (criptografia híbrida)
# ==========================================
do_backup() {
    if [ ! -f "$PUBLIC_KEY" ]; then
        echo "❌ Chave pública não encontrada em $PUBLIC_KEY"
        echo "Execute $0 --create-keys primeiro."
        exit 1
    fi

    echo "🔄 Iniciando backup do MySQL..."
    echo "Arquivo: $BACKUP_FILE"

    # 1. Gerar uma chave simétrica temporária (256 bits, aleatória)
    SYM_KEY=$(openssl rand -base64 32)

    # 2. Fazer dump + compactar + criptografar com AES-256 usando a chave simétrica
    mysqldump -u "$MYSQL_USER" -p -h "$MYSQL_HOST" \
        --all-databases --single-transaction --quick --skip-lock-tables | \
    gzip | \
    openssl enc -aes-256-cbc -pbkdf2 -salt -out "$BACKUP_FILE" \
        -pass "pass:$SYM_KEY"

    if [ $? -ne 0 ]; then
        echo "❌ Erro no dump ou criptografia simétrica."
        exit 1
    fi

    # 3. Criptografar a chave simétrica com a chave pública RSA
    echo "$SYM_KEY" | openssl pkeyutl -encrypt -pubin -inkey "$PUBLIC_KEY" -out "$SYMMETRIC_KEY_FILE"
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao criptografar a chave simétrica com RSA."
        # Remove o backup parcial
        rm -f "$BACKUP_FILE"
        exit 1
    fi

    echo "✅ Backup concluído com sucesso!"
    echo "📁 Dados criptografados: $BACKUP_FILE"
    echo "🔑 Chave simétrica (criptografada com RSA): $SYMMETRIC_KEY_FILE"
    echo "📏 Tamanho do backup: $(du -h "$BACKUP_FILE" | cut -f1)"
}

# ==========================================
# Restaurar usando chave privada
# ==========================================
do_restore() {
    if [ ! -f "$PRIVATE_KEY" ]; then
        echo "❌ Chave privada não encontrada em $PRIVATE_KEY"
        exit 1
    fi

    # Encontrar o backup mais recente
    LATEST_DATA=$(ls -t "$BACKUP_DIR"/backup_*.sql.gz.enc 2>/dev/null | head -n1)
    LATEST_KEY=$(ls -t "$BACKUP_DIR"/backup_*.key.enc 2>/dev/null | head -n1)

    if [ -z "$LATEST_DATA" ] || [ -z "$LATEST_KEY" ]; then
        echo "❌ Nenhum backup completo encontrado (faltando arquivo de dados ou de chave)."
        exit 1
    fi

    echo "🔄 Restaurando o backup:"
    echo "   Dados: $LATEST_DATA"
    echo "   Chave: $LATEST_KEY"

    # 1. Descriptografar a chave simétrica usando a chave privada RSA
    SYM_KEY=$(openssl pkeyutl -decrypt -inkey "$PRIVATE_KEY" -in "$LATEST_KEY" 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$SYM_KEY" ]; then
        echo "❌ Erro ao descriptografar a chave simétrica. Chave privada incorreta?"
        exit 1
    fi

    # 2. Descriptografar os dados com a chave simétrica e importar para o MySQL
    openssl enc -d -aes-256-cbc -pbkdf2 -in "$LATEST_DATA" -pass "pass:$SYM_KEY" | \
    gunzip | \
    mysql -u "$MYSQL_USER" -p -h "$MYSQL_HOST"

    if [ $? -eq 0 ]; then
        echo "✅ Restauração concluída com sucesso!"
    else
        echo "❌ Erro durante a restauração. Verifique as credenciais do MySQL."
        exit 1
    fi
}

# ==========================================
# Ajuda
# ==========================================
show_help() {
    cat << EOF
Uso: $0 [OPÇÃO]

Opções:
  --backup          Faz backup usando criptografia assimétrica (RSA).
                    Requer chave pública em $PUBLIC_KEY.
  --restore         Restaura o último backup (requer chave privada).
  --create-keys     Gera um novo par de chaves RSA (4096 bits).
  --help            Mostra esta ajuda.

Fluxo típico:
  1. Execute --create-keys para gerar as chaves.
  2. Compartilhe a chave pública (backup.pub) com quem fará backups.
  3. Execute --backup regularmente.
  4. Para restaurar, use --restore (com a chave privada).

Segurança:
  - A chave privada fica em ~/.mysql_backup_keys/backup.pem (permissões 600).
  - Nunca compartilhe a chave privada.
  - A chave simétrica é gerada aleatoriamente a cada backup e descartada.
EOF
}

# ==========================================
# Lógica principal
# ==========================================
case "$1" in
    --backup)       do_backup ;;
    --restore)      do_restore ;;
    --create-keys)  create_keys ;;
    --help|*)       show_help ;;
esac
