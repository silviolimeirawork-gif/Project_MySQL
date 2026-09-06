SELECT VERSION();

-- Criar o banco de dados
CREATE DATABASE IF NOT EXISTS empresa;
USE empresa;

DROP TABLE funcionarios;
DROP TABLE departamentos;
-- Criar uma tabela de funcionarios
CREATE TABLE IF NOT EXISTS funcionarios (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(100) NOT NULL,
	cargo VARCHAR(50) NOT NULL,
	salario DECIMAL (10,2) NOT NULL,
	data_contratacao DATE NOT NULL,
	ativo BOOLEAN DEFAULT TRUE,
	email VARCHAR(100) UNIQUE,
	criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar uma tabela de departamentos para exemplos com JOIN
CREATE TABLE IF NOT EXISTS departamentos (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(50) NOT NULL UNIQUE,
	orcamento DECIMAL(15,2) NOT NULL
);

-- Adicionar chave estrangeira na tabela funcionarios
ALTER TABLE funcionarios ADD COLUMN departamento_id INT;
ALTER TABLE funcionarios
  	ADD CONSTRAINT fk_departamento
  	FOREIGN KEY (departamento_id) REFERENCES departamentos(id);

SHOW TABLES;
DESC funcionarios;
DESC departamentos;
DESC funcionarios_backup;



-- 2. Inserção de Dados (INSERT)



-- 2.1. Inserção de uma unica linha

INSERT INTO departamentos (nome, orcamento)
VALUES ('Tecnologia', 100000.00);

SELECT * FROM departamentos;

INSERT INTO funcionarios (nome, cargo, salario, data_contratacao, email, departamento_id)
VALUES ('Ana Silva', 'Desenvolvedora', 8500.00, '2023-01-15', 'ana.silva@empresa.com', 1);

SELECT * FROM funcionarios;



-- 2.2. Insersão de múltiplas linhas de uma vez

INSERT INTO funcionarios (nome, cargo, salario, data_contratacao, email, departamento_id)
VALUES
('Carlos Souza', 'Analista de Dados', 6200.00, '2023-03-10', 'carlos.souza@empresa.com', 1),
('Mariana Oliveira', 'Gerente de Projetos', 12000.00, '2022-06-01', 'mariana.oliveira@empresa.com', 1),
('João Pereira', 'Desenvolvedor Júnior', 4500.00, '2024-01-20', 'joao.pereira@empresa.com', 1),
('Fernanda Lima', 'Designer UX', 5800.00, '2023-08-05', 'fernanda.lima@empresa.com', 1),
('Roberto Alves', 'DevOps', 7200.00, '2023-11-01', 'roberto.alves@empresa.com', 1);

-- Múltiplos departamentos
INSERT INTO departamentos (nome, orcamento) VALUES
('Marketing', 75000.00),
('RH', 50000.00),
('Financeiro', 90000.00);



-- Inserção com SELECT (copiando dados de outra tabela)

-- Criar uma tabela de backup de funcionarios
CREATE TABLE funcionarios_backup LIKE funcionarios;

-- Copiar dados de funcionarios para funcionarios_backup
INSERT INTO funcionarios_backup (nome, cargo, salario, data_contratacao, ativo, email, departamento_id)
SELECT nome, cargo, salario, data_contratacao, ativo, email, departamento_id
FROM funcionarios
WHERE salario > 5000;

SELECT * FROM funcionarios_backup;



-- 2.4 Inserção com ON DUPLICATE KEY UPDATE (UPSERT)

-- Se o email já existir, atualiza o cargo e o salário
INSERT INTO funcionarios (nome, cargo, salario, data_contratacao, email, departamento_id)
VALUES ('Ana Silva', 'Arquiteta de Software', 9500.00, '2023-01-15', 'ana.silva@empresa.com', 1)
ON DUPLICATE KEY UPDATE 
  cargo = VALUES(cargo),
  salario = VALUES(salario);

 
 
-- 2.5. Obtendo o ID da última inserção
 
INSERT INTO funcionarios (nome, cargo, salario, data_contratacao, email, departamento_id)
VALUES ('Paulo Mendes', 'Estagiário', 2500.00, '2024-02-01', 'paulo.mendes@empresa.com', 1);

SELECT LAST_INSERT_ID(); -- Retorna o ID gerado automaticamente



-- 3. Seleção com Filtros (SELECT + WHERE)

-- 3.1. Filtros básicos (comparadores)

-- Igualdade
SELECT * FROM funcionarios WHERE cargo = 'Desenvolvedor Sênior';
SELECT * FROM funcionarios WHERE cargo = 'Arquiteta de Software';

-- Diferente
SELECT * FROM funcionarios WHERE cargo != 'Gerente de Projetos';
SELECT * FROM funcionarios;

-- Maior que / Menor que
SELECT * FROM funcionarios WHERE salario > 7000;
SELECT * FROM funcionarios WHERE salario < 5000;

-- Maior ou igual / Menor ou igual
SELECT * FROM funcionarios WHERE salario >= 6000;



-- 3.2 Múltiplas condições (AND / OR)

-- AND: todas as condições devem ser verdadeiras
SELECT * FROM funcionarios
WHERE salario > 4000 AND cargo LIKE '%Desenvolvedor%';

-- OR: pelo menos uma condição deve ser verdadeira
SELECT * FROM funcionarios
WHERE cargo = 'Gerente de Projetos' OR salario > 10000;

-- Combinação de AND e OR (use parênteses para clareza)
SELECT * FROM funcionarios
WHERE (cargo = 'Desenvolvedor Sênior' OR cargo = 'DevOps')
  AND salario > 7000;

 
 
 -- 3.3. Filtro por lista (IN)
 
 SELECT * FROM funcionarios
 WHERE cargo IN ('Desenvolvedor Sênior', 'DevOps', 'Analista de Dados');

-- Equivalente com OR
SELECT * FROM funcionarios
WHERE cargo = 'Desenvolvedor Júnior'
	OR cargo = 'DevOps'
	OR cargo = 'Analista de Dados';


-- 3.4. Filtro por intervalo (BETWEEN)

-- Salário entre 5000 e 8000
SELECT * FROM funcionarios
WHERE salario BETWEEN 5000 AND 8000;

-- Datas entre dois valores
SELECT * FROM funcionarios
WHERE data_contratacao BETWEEN '2023-01-01' AND '2023-12-31';



-- 3.5. Filtro com padrões (LIKE)

-- Começa com "Desenvolvedor"

SELECT * FROM funcionarios WHERE cargo LIKE 'Desenvolvedor%';

-- Termina com "or"
SELECT * FROM funcionarios WHERE cargo LIKE '%or';

-- Contém "Silva" em qualquer posição
SELECT * FROM funcionarios WHERE nome LIKE '%Silva%';

-- Coringas: %(qualquer sequência) e _ (um único caractere)
SELECT * FROM funcionarios WHERE nome LIKE 'A_a%';  -- Ana, Ada, etc.



-- 3.6 Filtro com valores nulos (IS NULL / IS NOT NULL)

-- Funcionários sem email
SELECT * FROM funcionarios WHERE email IS NULL;

-- Funcionários com email cadastrado
SELECT * FROM funcionarios WHERE email IS NOT NULL;



-- 3.7. Filtros com data e hora

-- Funcionários contratados no primeiro semenstre de 2023
SELECT * FROM funcionarios
WHERE data_contratacao >= '2023-01-01' AND data_contratacao <= '2023-06-30';

-- Usando funções de data
SELECT * FROM funcionarios
WHERE YEAR(data_contratacao) = 2023 AND MONTH(data_contratacao) <= 6;

-- Funcionarios contratados nos últimos 30 dias
SELECT * FROM funcionarios
WHERE data_contratacao >= CURDATE() - INTERVAL 30 DAY;

SELECT * FROM funcionarios
WHERE data_contratacao >= '2024-02-28' - INTERVAL 30 DAY;



-- 3.8. Ordenação (ORDER BY) e Limite (LIMIT)

-- Ordenar por salário (crescente)
SELECT * FROM funcionarios ORDER BY salario ASC;

-- Ornedar por salário (decrescente)
SELECT * FROM funcionarios ORDER BY salario DESC;

-- Ordenação múltipla
SELECT * FROM funcionarios ORDER BY departamento_id, salario DESC;

-- Limitar resultados
SELECT * FROM funcionarios ORDER BY salario DESC LIMIT 3; -- Top 3 salários

-- Paginação: pular 2 e pegar 3
SELECT * FROM funcionarios ORDER BY id LIMIT 3 OFFSET 2;
-- ou
SELECT * FROM funcionarios ORDER BY id LIMIT 2, 3;



-- 3.9 Filtros com JOIN

-- Inner Join:  funcionarios com seus departamentos
SELECT f.nome, f.cargo, f.salario, d.nome AS departamento
FROM funcionarios f
INNER JOIN departamentos d ON f.departamento_id = d.id;

-- Left Join: todos os funcionários, mesmo sem departamento
SELECT f.nome, f.cargo, COALESCE(d.nome, 'Sem Departamento') AS departamento
FROM funcionarios f
LEFT JOIN departamentos d ON f.departamento_id = d.id;




-- 3.10. Filtros com subconsultas

-- Funcionários com salário acima da média
SELECT * FROM funcionarios
WHERE salario > (SELECT AVG(salario) FROM funcionarios);

-- Funcionários do departamento com maior orçamento
SELECT f.*
FROM funcionarios f
WHERE f.departamento_id = (
	SELECT id FROM departamentos
	ORDER BY orcamento DESC 
	LIMIT 1
);




-- 3.11 Filtros com funções agregadas (HAVING)

-- Departamentos com mais de 2 funcionarios
SELECT d.nome, COUNT(f.id) AS total_funcionarios
FROM departamentos d
LEFT JOIN funcionarios f ON d.id = f.departamento_id
GROUP BY d.id, d.nome
HAVING total_funcionarios > 2;

-- Departamentos com salário médio acima de 7000
SELECT d.nome, AVG(f.salario) AS media_salarial
FROM departamentos d
JOIN funcionarios f ON d.id = f.departamento_id
GROUP BY d.id, d.nome
HAVING media_salarial > 6500;




-- 4. Exclusão de Dados (DELETE)

-- 4.1. DELETE com filtro (recomendado)

-- Excluir um funcioário específico
DELETE FROM funcionarios WHERE id = 1;

-- Excluir funcionarios com salário abaixo de 3000;
SELECT * FROM funcionarios WHERE salario < 3000;
DELETE FROM funcionarios WHERE salario < 3000;

-- Excluir funcionarios inativos
SELECT * FROM funcionarios WHERE departamento_id IS NULL;
DELETE FROM funcionarios WHERE ativo = FALSE;




-- 4.2. DELETE com múltiplas condições

-- Excluir funcionários de um departamento específico contratados antes de 2023
DELETE FROM funcionarios
WHERE departamento_id = 1 AND data_contratacao < '2023-01-01';

SELECT * FROM funcionarios
WHERE departamento_id = 1 AND data_contratacao < '2023-01-01';




-- 4.3. DELETE com subconsulta

-- Excluir funcionarios de departamentos com orçamento abaixo de 50000
DELETE FROM funcionarios
WHERE departamento_id IN (
	SELECT id FROM departamentos WHERE orcamento < 4500;
);
-- 
SELECT * FROM funcionarios
WHERE departamento_id IN (
	SELECT id FROM departamentos WHERE orcamento < 150000
);




-- 4.4. DELETE com LIMIT (para evitar bloqueios longos)

-- Excluir em lotes de 100 registros
DELETE FROM funcionarios WHERE ativo = FALSE LIMIT 100;
SELECT * FROM funcionarios WHERE ativo = TRUE LIMIT 2;




-- 4.5. DELETE com JOIN (MySQL suporta exclusão em múltiplas tabelas)

-- Excluir funcionários e seus registros relacionados em outra tabela
DELETE f, fb
FROM funcionarios f
JOIN funcionarios_backup fb ON f.id = fb.id
WHERE f.ativo = FALSE;
--
SELECT * 
FROM funcionarios f
JOIN funcionarios_backup fb ON f.id = fb.id
WHERE f.ativo = TRUE;




-- 4.6. TRUNCATE (exclusão rápida de todos os dados)

-- Remove TODOS os registros e reseta o AUTO_INCREMENT
TRUNCATE TABLE funcionarios_backup;

-- Diferença: DELETE sem WHERE remove todos, mas mantém o AUTO_INCREMENT
DELETE FROM funcionarios_backup;




-- 4.7. DELETE com segurança (usando transações)

-- Iniciar transação
START TRANSACTION;

-- Verificar quais registros serão afetados
SELECT * FROM funcionarios WHERE salario < 3000;

-- Executar o DELETE
DELETE FROM funcionarios WHERE salario < 3000;

-- Verificar o resultado
SELECT ROW_COUNT() AS registros_afetados;

-- Se estiver tudo certo, confirma
COMMIT;

-- Se algo deu errado, desfaz
-- ROLLBACK;

-- ⚠️ Cuidados essenciais com DELETE

Cuidado				Explicação					Exemplo

Sempre use WHERE	DELETE sem WHERE remove		x DELETE FROM funcionarios;
					TODOS os registros

Teste com SELECT 	Veja o que será excluído	✅
					antes de deletar			SELECT * FROM funcionarios
												WHERE ...

Use transações		Permite desfazer em caso	START TRANSACTION; ...
					de erro						COMMIT;

Considere FOREIGN KEY
					Pode falhar se houver		Verifique dependências
					registros filhos			antes
					
DELETE é logado		Cada exclusão é registrada	Use LIMIT para grandes
					no binlog (impacto em		volumes
					performance)

					
					
					
-- 5. Backup Lógico (Logical Backup)

Backup lógico consiste em exportar dados e estrutura como comandos SQL que podem
ser executados para recriar o banco. É protátil entre versões e sistemas operacionais.



-- 5.1. mysqldump (ferramenta padrão)

-- O mysqldump é a ferramenta nativa do MySQL para backups lógicos. Produz um
arquivo com instruções CREATE TABLE e INSERT que recriam o banco.



Backup completo de todos os bancos

bash
mysqldump -u root -p --all-databases --single-transaction --master-data=2 > 
	/backup/full_backup_$(date +%Y%m%d).sql


	
Backup apenas da estrutura (sem dados)

bash
mysqldump -u root -p --no-data empresa > /backup/estrutura_empresa.sql



Backup apenas dos dados (sem estrutura)

bash
mysqldump -u root -p --no-create-info empresa > dados_empresa.sql



Backup com compressão em tempo real

bash
mysqldump -u root -p --single-transaction empresa | gzip > empresa_$(date +%Y%m%d).sql.gz



Backup com opções para consistência em replicação

bash
mysqldump -u root -p \
	--all-databases \
	--single-transaction \
	--triggers \
	--routines \
	--events \
	--master-data=2 \
	--flush-logs \
	> full_backup_$(data +%Y%m%d_%H%M).sql

	
	
Restaurando um backup mysqldump

bash
# Restaurar banco de dados
mysql -u root -p empresa < /backup/empresa_20260101.sql

# Retaurar com compressão
gunzip -c /backup/empresa_20260101.sql.gz | mysql -u root -p emrpesa

# Restaurar todos os bancos
mysql -u root -p < /backup/full_backup_20260101.sql




-- 5.2. mysqlpump (paralelização - deprecated)

O mysqlpump foi introduzido para oferecer backup paralelo, mas é deprecated desde o
MySQL 8.0.34 e será removido em versões futuras. A Oracle recomenda usar
mysqlsump ou o MySQL Shell

bash
# Exemplo de mysqlpump (não recomendado para uso futuro)
mysqlpump -u root -p --databases empresa --single-transaction > /backup/empresa.sql




-- 5.3 MySQL Shell Dump Utilities (recomendado)

O MySQL Shell oferece utilitarios modernos com paralelismo, compressão e progresso
em tempo real

# Backup de uma instância inteira
bash
$ ./mysql-shell-8.0.35-linux-glibc2.17-x86-64bit/bin/mysqlsh --uri root@localhost:3306 --js -e "util.dumpInstance('/backup/instance_dump')"

# Restaurar de uma instancia inteira
./mysql-shell-8.0.35-linux-glibc2.17-x86-64bit/bin/mysqlsh --uri root@localhost:3306 --js -e "util.loadDump('/backup/instance_dump', {threads: 4, resetProgress: true})"

# Backup de um schema especifico
./mysql-shell-8.0.35-linux-glibc2.17-x86-64bit/bin/mysqlsh --uri root@localhost:3306 --js \
-e "util.dumpSchemas(['empresa'], '/backup/empresa_dump')"

# Restaurar de um schema especifico
./mysql-shell-8.0.35-linux-glibc2.17-x86-64bit/bin/mysqlsh --uri root@localhost:3306 --js \
-e "util.dumpSchemas(['empresa'], '/backup/empresa_dump')"

# Com compressão e paralelismo de um schema especifico
./mysql-shell-8.0.35-linux-glibc2.17-x86-64bit/bin/mysqlsh --uri root@localhost:3306 --js -e "util.dumpSchemas(['empresa'], '/backup/empresa_dump', {threads: 4, compression: 'gzip'})"

# Restaurar de um schema especifico
./mysql-shell-8.0.35-linux-glibc2.17-x86-64bit/bin/mysqlsh --uri root@localhost:3306 --js -e "util.loadDump('/backup/empresa_dump', {threads: 4})"

CREATE DATABASE empresa;


-- 5.4. Backup de tabelas em formato CSV

-- Exportar para CSV
./mysql-shell-8.0.35-linux-glibc2.17-x86-64bit/bin/mysqlsh --uri root@localhost:3306 --js -e "util.exportTable('empresa.funcionarios', '/tmp/funcionarios.csv', {fieldsTerminatedBy: ',', fieldsEnclosedBy: '\"', linesTerminatedBy: '\\n'})"

-- Importar de CSV
# 1. Cria a tabela manualmente
mysql -u root -p -e "CREATE TABLE IF NOT EXISTS empresa.funcionarios1 (nome VARCHAR(100), cargo VARCHAR(100), salario DECIMAL(10,2));"

# 2. Importa o CSV
./mysql-shell-8.0.35-linux-glibc2.17-x86-64bit/bin/mysqlsh --uri root@localhost:3306 --js -e "util.importTable('/tmp/funcionarios.csv', {schema: 'empresa', table: 'funcionarios1', fieldsTerminatedBy: ',', fieldsEnclosedBy: '\"', linesTerminatedBy: '\\n'})"	




-- 6. Backup Físico (Physical Backup)

Backup físico copia os arquivos do banco de dados no sistema de arquivos. É mais
rápido para restauração, especialmente em bancos grandes, e preserva índices e
estruturas internas

-- 6.1. MySQL Enterprise Backup (MEB) - Solução Comercial

O MySQL Enterprise Backup é a solução oficial da Oracle para backup físico
Suporta backup hot (com o banco em execução) e é obrigatório para tabelas com
tablespace criptografado.

Backup completo (single-file)
bash
mysqlbackup --user=root --password=senha \
  --backup-image=/backup/full_backup.mbi \
  --backup-dir=/backup \
  --show-progress \
  backup-to-image

Backup completo para diretório
bash
mysqlbackup --user=root --password=senha \
  --backup-dir=/backup/$(date +%Y%m%d) \
  --with-timestamp \
  backup

Backup com compressão
bash
mysqlbackup --user=root --password=senha \
  --backup-image=/backup/full_backup_compressed.mbi \
  --compress \
  backup-to-image
  
Backup incremental
bash
# Baseado no último backup completo
mysqlbackup --user=root --password=senha \
  --backup-dir=/backup/incremental_$(date +%Y%m%d) \
  --incremental \
  --incremental-base=dir:/backup/full_20260101 \
  backup
  
Restaurar
bash
# Parar o MySQL primeiro
mysqlbackup --backup-image=/backup/full_backup.mbi \
  --backup-dir=/backup/restore \
  image-to-backup-dir
  
# Depois copiar os arquivos para o datadir

  
  
  
-- 6.2 Percona XtraBackup - Solução Open Source

O Percona XtraBackup (PXB) é uma ferramenta gratuita e open source que faz backup
físico hot (sem bloquear o banco).

⚠️ Importante: O PXB 8.0 só funciona com o MySQL 8.0 devido a mundanças no redo log
e data dictionary.

Instalação
bash
# Ubuntu/Debian_
# Corrige quebras
sudo apt --fix-broken install

# Remove pacote problemático (se existir)
sudo dpkg --remove percona-xtrabackup-80 2>/dev/null
sudo apt autoremove -y

# Instala via repositório (recomendado)
wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo dpkg -i percona-release_latest.generic_all.deb
sudo percona-release enable-only tools release
sudo apt update
sudo apt install percona-xtrabackup-80 -y

# Verifica
xtrabackup --version




Criar usuário para backup
sql
CREATE USER 'xtrabackup'@'localhost' IDENTIFIED BY 'XtraPass123!';
GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT, SELECT ON *.* TO 'xtrabackup'@'localhost';
FLUSH PRIVILEGES;
EXIT;




Backup completo
sql
SHOW VARIABLES LIKE 'datadir';

GRANT BACKUP_ADMIN ON *.* TO 'xtrabackup'@'localhost';
FLUSH PRIVILEGES;
EXIT;

SHOW VARIABLES LIKE 'socket';
/usr/local/mysql/data/


🛠️ Passo 1 – Criar o diretório pai com permissões

bash
sudo mkdir -p /backup/mysql
sudo chown -R $(whoami):$(whoami) /backup

Isso cria a estrutura e garante que o usuário atual tenha permissão de 
escrita (o sudo xtrabackup executará como root, então ele terá acesso).


🧪 Passo 2 – Verificar espaço em disco

bash
df -h /backup
Certifique-se de que há espaço livre suficiente (o backup pode ser grande, 
dependendo do tamanho dos dados).




Para fazer backup incremental com o Percona XtraBackup, você precisa de:

Um backup completo (base).

Um primeiro incremental – baseado no completo.

Um segundo incremental – baseado no primeiro incremental (e não no base).

Todos os comandos usam --backup e o parâmetro --incremental-basedir para 
indicar o diretório do backup anterior.

📦 Estrutura de diretórios sugerida
text
/backup/mysql/
├── base_20260905/          # backup completo
├── inc1_20260905/          # primeiro incremental (baseado no base)
└── inc2_20260905/          # segundo incremental (baseado no inc1)

# Refazer base - backup completo
sudo rm -rf /backup/mysql/base_$(date +%Y%m%d)
sudo xtrabackup --backup --user=xtrabackup --password='XtraPass123!' \
--datadir=/usr/local/mysql/data --target-dir=/backup/mysql/base_$(date +%Y%m%d)

# Primeiro incremental
sudo xtrabackup --backup --user=xtrabackup --password='XtraPass123!' \
--datadir=/usr/local/mysql/data --target-dir=/backup/mysql/inc1_$(date +%Y%m%d) \
--incremental-basedir=/backup/mysql/base_$(date +%Y%m%d)

# Segundo incremental
sudo xtrabackup --backup --user=xtrabackup --password='XtraPass123!' \
--datadir=/usr/local/mysql/data --target-dir=/backup/mysql/inc2_$(date +%Y%m%d) \
--incremental-basedir=/backup/mysql/inc1_$(date +%Y%m%d)

# Preparar base + incrementais
sudo xtrabackup --prepare --apply-log-only --target-dir=/backup/mysql/base_$(date +%Y%m%d)
sudo xtrabackup --prepare --apply-log-only --target-dir=/backup/mysql/base_$(date +%Y%m%d) \
--incremental-dir=/backup/mysql/inc1_$(date +%Y%m%d)
sudo xtrabackup --prepare --target-dir=/backup/mysql/base_$(date +%Y%m%d) \
--incremental-dir=/backup/mysql/inc2_$(date +%Y%m%d)




📌 Resumo dos comandos para restaurar

bash
sudo systemctl stop mysql
sudo mv /usr/local/mysql/data /usr/local/mysql/data_backup  # opcional
sudo xtrabackup --copy-back --target-dir=/backup/mysql/base_$(date +%Y%m%d)
sudo chown -R mysql:mysql /usr/local/mysql/data
sudo systemctl start mysql

Se você não preparou o base com os incrementais, faça isso antes da 
restauração. Se tiver dúvidas sobre qual é o estado atual do base, 
execute o comando de preparação final novamente (sem --apply-log-only) 
para garantir a consistência:

bash
sudo xtrabackup --prepare --target-dir=/backup/mysql/base_20260905

Isso finalizará a preparação e deixará o backup pronto para restauração.




-- 6.3. Backup físico manual (cold backup)

Se você pode parar o MySQL, um backup físico manual é simples:

sql (mostra a localizacao dos dados no MySQL)
SHOW VARIABLES LIKE 'datadir';

bash
# Parar o MySQL
sudo systemctl stop mysql

# Copiar todo o diretório de dados seguindo o link simbólico (-L)
sudo cp -rL /usr/local/mysql /backup/mysql_$(date +%Y%m%d)

# Ou com tar e diretório de dados seguindo o link simbólico (-h)
sudo tar -czhf /backup/mysql_$(date +%Y%m%d).tar.gz /usr/local/mysql

# Iniciar o MySQL novamente
sudo systemctl start mysql

Vantagem: Extremamente simples.
Desvantagem: Requer downtime.




-- 7. Boas Práticas e Recomendações

-- 7.1. Comparativo entre tipos de backup

Característica				Backup Lógico				Backup Físico
							(mysqldump)					(XtraBackup/MEB)

Velocidade de backup		Lento em grandes bases		Rápido (copia arquivos)

Velocidade de restauração	Lenta (re-executa SQL)		Rápida (copia arquivos)

Portabilidade				Alta (qualquer versão/SO)	Baixa (versão específica)

Backup online				Sim (--single-transaction)	Sim (hot backup)

Backup incremental			Limitado					Suportado

Tamanho do backup			Geralmente menor			Geralmente maior

Complexidade				Baixa						Média/Alta




-- 7.2. Estratégia de backup recomendada

bash
# Domingo: Backup completo (físico)
xtrabackup --backup --target-dir=/backups/full_$(date +%Y%m%d)

# Segunda a Sábado: Backup incremental
xtrabackup --backup --target-dir=/backups/incr_$(date +%Y%m%d) \
  --incremental-basedir=/backups/full_$(date +%Y%m%d -d "last sunday")
  
# Diariamente: Backup lógico (para portabilidade)
mysqldump --single-transaction --all-databases | gzip > /backup/logical_$(date +%Y%m%d).sql.gz


# A cada hora: Backup do binlog (point-in-time recovery)
mostra os logs: $ mysql -u root -p -e "SHOW BINARY LOGS;"

mysqlbinlog --read-from-remote-server --host=localhost \
  --user=root --password=SenhaForte! --raw \
  --to-last-log binlog.000028  

  
  
  
-- 7.3. Verificação de backups

bash
# Verificar integridade de um dump SQL (tenta restaurar em um banco de teste)
mysql -u root -p empresa < /backup/instance_dump/empresa.sql 2>&1 | grep -i error  

# Verificar backup físico do XtraBackup
xtrabackup --prepare --target-dir=/backup/full_$(date +%Y%m%d)

# Testar restauração completa em ambiente de homologação periodicamente




-- 7.4. Limpeza de backups antigos

bash
# Manter últimos 7 dias de backups diários
find /backup -name "*.sql.gz" -mtime +7 -delete 
find /backup -name "full_*" -mtime +30 -delete 
find /backup -name "incr_*" -mtime +7 -delete 




-- 7.5. Segurança

bash
# Criptografar backups
mysqldump -u root -p --all-databases | gzip | openssl enc -aes-256-cbc -pbkdf2 \
  -out /backup/backup_$(date +%Y%m%d).sql.gz.enc -pass pass:chave_secreta
  
  
Ou, para evitar a senha no histórico, use -pass stdin:

bash
mysqldump -u root -p --all-databases | gzip | openssl enc -aes-256-cbc -pbkdf2 \
  -out /backup/backup_$(date +%Y%m%d).sql.gz.enc -pass stdin


# Descriptogravar
openssl enc -d -aes-256-cbc -pbkdf2 -in /backup/backup_20260313.sql.gz.enc \
-pass file:/home/sicemal/.backup_pass | gunzip | mysql -u root -p


















