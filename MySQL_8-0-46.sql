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
	
	



					
