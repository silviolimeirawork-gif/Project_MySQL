#!/bin/bash
# ==========================================
# Script de Backup MySQL com Criptografia
# ==========================================
# Uso:
#   ./backup_mysql.sh --backup      # Faz backup (cria senha se não existir)
#   ./backup_mysql.sh --restore     # Restaura o último backup
#   ./backup_mysql.sh --create-pass # Cria/atualiza o arquivo de senha
#   ./backup_mysql.sh --help        # Ajuda
# ==========================================

BACKUP_DIR="/backup"
PASS_FILE="$HOME/.backup_pass"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql.gz.enc"
MYSQL_USER="root"
MYSQL_HOST="localhost"

# Verifica se o diretório de backup existe
mkdir -p "$BACKUP_DIR"

# Função para criar arquivo de senha
create_pass() {
    echo "🔑 Criando arquivo de senha para criptografia..."
    read -s -p "Digite a senha (será usada para criptografar o backup): " PASS
    echo
    read -s -p "Confirme a senha: " PASS2
    echo
    if [ "$PASS" != "$PASS2" ]; then
        echo "❌ As senhas não coincidem. Tente novamente."
        return 1
    fi
    echo "$PASS" > "$PASS_FILE"
    chmod 600 "$PASS_FILE"
    echo "✅ Arquivo de senha criado em $PASS_FILE (permissões 600)."
}

# Função para fazer backup
do_backup() {
    # Verifica se o arquivo de senha existe
    if [ ! -f "$PASS_FILE" ]; then
        echo "⚠️  Arquivo de senha não encontrado. Vamos criar um agora."
        create_pass || exit 1
    fi

    echo "🔄 Iniciando backup do MySQL..."
    echo "Banco: todos os bancos"
    echo "Arquivo: $BACKUP_FILE"

    mysqldump -u "$MYSQL_USER" -p -h "$MYSQL_HOST" \
        --all-databases --single-transaction --quick --skip-lock-tables | \
    gzip | \
    openssl enc -aes-256-cbc -pbkdf2 -salt -out "$BACKUP_FILE" \
        -pass "file:$PASS_FILE"

    if [ $? -eq 0 ]; then
        echo "✅ Backup concluído com sucesso!"
        echo "📁 Arquivo: $BACKUP_FILE"
        echo "📏 Tamanho: $(du -h "$BACKUP_FILE" | cut -f1)"
    else
        echo "❌ Erro durante o backup. Verifique as credenciais do MySQL."
        exit 1
    fi
}

# Função para restaurar (descriptografar e importar)
do_restore() {
    # Procura o último backup
    LATEST=$(ls -t "$BACKUP_DIR"/backup_*.sql.gz.enc 2>/dev/null | head -n1)
    if [ -z "$LATEST" ]; then
        echo "❌ Nenhum backup encontrado em $BACKUP_DIR"
        exit 1
    fi

    if [ ! -f "$PASS_FILE" ]; then
        echo "⚠️  Arquivo de senha não encontrado. Você precisa fornecer a senha interativamente."
        echo "Será solicitada a senha do OpenSSL e a senha do MySQL."
        echo
        read -s -p "Digite a senha de criptografia: " DECRYPT_PASS
        echo
        echo "🔄 Restaurando o backup: $LATEST"
        openssl enc -d -aes-256-cbc -pbkdf2 -in "$LATEST" -pass "pass:$DECRYPT_PASS" | \
        gunzip | \
        mysql -u "$MYSQL_USER" -p -h "$MYSQL_HOST"
    else
        echo "🔄 Restaurando o backup: $LATEST"
        openssl enc -d -aes-256-cbc -pbkdf2 -in "$LATEST" -pass "file:$PASS_FILE" | \
        gunzip | \
        mysql -u "$MYSQL_USER" -p -h "$MYSQL_HOST"
    fi

    if [ $? -eq 0 ]; then
        echo "✅ Restauração concluída com sucesso!"
    else
        echo "❌ Erro durante a restauração. Verifique a senha e as credenciais."
        exit 1
    fi
}

# Função de ajuda
show_help() {
    cat << EOF
Uso: $0 [OPÇÃO]

Opções:
  --backup         Faz um backup completo de todos os bancos, compacta e criptografa.
  --restore        Restaura o último backup encontrado (descriptografa e importa).
  --create-pass    Cria ou atualiza o arquivo de senha (sem fazer backup).
  --help           Mostra esta mensagem de ajuda.

Observações:
  - O arquivo de senha é armazenado em ~/.backup_pass (permissões 600).
  - A senha do MySQL é solicitada interativamente a cada execução.
  - O backup é salvo em /backup/backup_YYYYMMDD_HHMMSS.sql.gz.enc.
EOF
}

# ==========================================
# Lógica principal
# ==========================================
case "$1" in
    --backup)
        do_backup
        ;;
    --restore)
        do_restore
        ;;
    --create-pass)
        create_pass
        ;;
    --help|*)
        show_help
        ;;
esac
