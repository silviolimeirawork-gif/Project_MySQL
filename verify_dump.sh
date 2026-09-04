#!/bin/bash

export LC_ALL=C

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
print_ok() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Localiza o alvo
if [ -n "$1" ]; then
    TARGET="$1"
else
    TARGET=$(ls -t ./dumps/*.sql 2>/dev/null | head -n 1)
    if [ -z "$TARGET" ]; then
        TARGET=$(ls -td ./dumps/instance_dump_* 2>/dev/null | head -n 1)
        if [ -z "$TARGET" ]; then
            TARGET=$(ls -td /tmp/dump_* 2>/dev/null | head -n 1)
            if [ -z "$TARGET" ]; then
                print_error "Nenhum dump encontrado."
                echo "Uso: $0 [caminho_do_arquivo.sql | caminho_do_diretorio]"
                exit 1
            else
                print_warn "Usando o dump mais recente em /tmp/: $TARGET"
            fi
        else
            print_warn "Usando o dump mais recente em ./dumps/: $TARGET"
        fi
    else
        print_warn "Usando o arquivo SQL mais recente: $TARGET"
    fi
fi

echo "========================================"
echo "🔍 Verificando: $TARGET"
echo "========================================"

# --- Arquivo SQL ---
if [ -f "$TARGET" ] && [[ "$TARGET" == *.sql ]]; then
    FILE_SIZE=$(stat -c%s "$TARGET" 2>/dev/null || stat -f%z "$TARGET" 2>/dev/null)
    if [ "$FILE_SIZE" -eq 0 ]; then
        print_error "O arquivo SQL está vazio."
        exit 1
    fi
    print_ok "Arquivo SQL encontrado (tamanho: $(numfmt --to=iec $FILE_SIZE 2>/dev/null || echo "$FILE_SIZE bytes"))."

    # Verifica a primeira linha – se contém aviso
    FIRST_LINE=$(head -n 1 "$TARGET")
    if [[ "$FIRST_LINE" == *"Warning"* ]]; then
        print_warn "A primeira linha contém um aviso do mysqldump."
        echo "   Isso pode causar erro na restauração."
        echo "   Para corrigir, remova a primeira linha com:"
        echo "   sed -i '1d' $TARGET"
        echo ""
    fi

    echo "📄 Primeiras 5 linhas:"
    head -n 5 "$TARGET"
    echo ""

    # Verifica cabeçalho do mysqldump
    if grep -q "MySQL dump" "$TARGET"; then
        print_ok "Cabeçalho do mysqldump detectado."
    else
        print_warn "Cabeçalho do mysqldump NÃO detectado – pode ser de outra ferramenta."
    fi

    # Conta CREATE TABLE e INSERT
    CREATE_COUNT=$(grep -c -i "CREATE TABLE" "$TARGET")
    INSERT_COUNT=$(grep -c -i "INSERT INTO" "$TARGET")
    echo ""
    echo "📊 Estatísticas do arquivo SQL:"
    echo "   CREATE TABLE: $CREATE_COUNT"
    echo "   INSERT INTO : $INSERT_COUNT"
    if [ "$CREATE_COUNT" -eq 0 ] && [ "$INSERT_COUNT" -eq 0 ]; then
        print_warn "Nenhum comando CREATE TABLE ou INSERT encontrado. Pode ser apenas comentários."
    else
        print_ok "O arquivo parece conter estrutura e/ou dados."
    fi

    echo ""
    echo "🔍 Para restaurar este dump (ignorando a primeira linha, se necessário):"
    echo "   tail -n +2 $TARGET | mysql -u root -p [banco]"
    echo ""
    echo "   Ou edite o arquivo: sed -i '1d' $TARGET"
    exit 0
fi

# --- Diretório (dump do mysqlsh) ---
if [ ! -d "$TARGET" ]; then
    print_error "O caminho não é um arquivo SQL nem um diretório."
    exit 1
fi

echo "📄 Conteúdo do diretório:"
ls -lah "$TARGET"
echo ""

if [ -f "$TARGET/@.json" ] && [ -f "$TARGET/@.done.json" ]; then
    print_ok "Arquivos de metadados (@.json e @.done.json) presentes."
else
    print_error "Arquivos essenciais não encontrados. Dump incompleto."
    exit 1
fi

echo ""
echo "📊 Resumo do dump:"
if command -v python3 &> /dev/null; then
    cat "$TARGET/@.done.json" | python3 -m json.tool | grep -E '(schemasDumped|tablesDumped|rowsWritten|uncompressedDataSize|compressedDataSize|duration)'
elif command -v jq &> /dev/null; then
    jq '.[] | select(.schemasDumped or .tablesDumped or .rowsWritten or .uncompressedDataSize or .compressedDataSize or .duration)' "$TARGET/@.done.json"
else
    cat "$TARGET/@.done.json"
fi

DATA_FILES=$(find "$TARGET" -type f \( -name "*.tsv" -o -name "*.zst" -o -name "*.sql" \) 2>/dev/null | wc -l)
echo ""
echo "📁 Total de arquivos de dados: $DATA_FILES"
echo "💾 Tamanho total: $(du -sh "$TARGET" | cut -f1)"

read -p "🔍 Deseja executar dry-run com mysqlsh? [s/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    if ! command -v mysqlsh &> /dev/null; then
        print_error "mysqlsh não encontrado."
    else
        mysqlsh --uri root@localhost --py --execute "util.load_dump('$TARGET', {'dryRun': True})"
        if [ $? -eq 0 ]; then
            print_ok "Verificação concluída: dump íntegro."
        else
            print_error "Problemas detectados."
        fi
    fi
fi

echo ""
echo "========================================"
echo "✅ Verificação finalizada."
