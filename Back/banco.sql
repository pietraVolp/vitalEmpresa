CREATE DATABASE db_vital;
USE db_vital;

 drop database db_vital;

-- Tabela de sexos
CREATE TABLE tbl_sexo (
    id_sexo INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(20) NOT NULL UNIQUE
);

select * from tbl_sexo where descricao = 'Feminino';

select * from tbl_sexo where id_sexo = 1;

-- Inserir sexos padrão
INSERT INTO tbl_sexo (descricao) VALUES ('Masculino');
INSERT INTO tbl_sexo (descricao) VALUES ('Feminino');



-- Tabela de empresas
CREATE TABLE tbl_empresa (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    nome_empresa VARCHAR(100) NOT NULL,
    nome_proprietario VARCHAR(100) NOT NULL,
    senha VARCHAR(255) NOT NULL,      -- Certifique-se de hashear as senhas (ex: bcrypt)
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    email VARCHAR(320) NOT NULL UNIQUE,
    telefone VARCHAR(30) NOT NULL,
    telefone_clinica VARCHAR(30) NOT NULL
);

select * from tbl_empresa;

select id_empresa from tbl_empresa where cnpj = 12345678910 and senha = 'Vini123';


DELIMITER $$

CREATE PROCEDURE sp_inserir_empresa_com_endereco(
IN p_nome_empresa VARCHAR(255),
    IN p_nome_proprietario VARCHAR(255),
    IN p_email VARCHAR(320),
    IN p_senha VARCHAR(15),
    IN p_cnpj VARCHAR(255),
    IN p_telefone VARCHAR(20),
    IN p_telefone_clinica VARCHAR(255),
IN p_cep VARCHAR(20),
    IN p_logradouro VARCHAR(255),
    IN p_bairro VARCHAR(255),
    IN p_cidade VARCHAR(150),
    IN p_estado VARCHAR(20)
)
BEGIN
    -- A declaração de variáveis deve vir logo após o BEGIN
    DECLARE last_user_id INT;

    -- Inserindo o usuário
    INSERT INTO tbl_empresa (nome_empresa,  nome_proprietario, senha, cnpj, email, telefone, telefone_clinica)
    VALUES (p_nome_empresa, p_nome_proprietario, p_senha, p_cnpj, p_email, p_telefone, p_telefone_clinica);
   
    -- Obtendo o ID do usuário recém-inserido
    SET last_user_id = LAST_INSERT_ID();
   
    -- Inserindo o endereço do usuário
    INSERT INTO tbl_endereco_empresa (cep, logradouro, bairro, cidade, estado, id_empresa)
    VALUES (p_cep, p_logradouro, p_bairro, p_cidade, p_estado, last_user_id);
END$$



DELIMITER ;
CALL sp_inserir_empresa_com_endereco(
'VITAL+',
    'João Silva',
    'joão@gmail.com',
    'joão123',
    '1234567891011',
    '11986311407',
    '11956781208',
    '0680030',
    '',
    'Vila Mêrces',
    'Carapicuiba',
    'São Paulo'
);

drop view vw_empresas_enderecos;
CREATE VIEW vw_empresas_enderecos AS
SELECT
    u.id_empresa,
    u.nome_empresa,
    u.nome_proprietario,
    u.email,
    u.senha,
    u.cnpj,
    u.telefone,
    u.telefone_clinica,
    e.cep,
    e.logradouro,
    e.bairro,
    e.cidade,
    e.estado
FROM
    tbl_empresa u
JOIN
    tbl_endereco_empresa e ON u.id_empresa = e.id_empresa;
   
    select * from vw_empresas_enderecos;



CREATE TABLE tbl_endereco_empresa(
id_endereco_empresa INT PRIMARY KEY AUTO_INCREMENT,
 cep VARCHAR(20),
 logradouro VARCHAR(255),
 bairro VARCHAR(255),
 cidade VARCHAR(150),
 estado VARCHAR(20),
 id_empresa INT,
 CONSTRAINT FK_ENDERECO_EMPRESA
 FOREIGN KEY (id_empresa) REFERENCES tbl_empresa (id_empresa)
);


-- Tabela de usuários
CREATE TABLE tbl_usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(320) NOT NULL UNIQUE,      -- Aumentado para suportar emails mais longos
    cpf VARCHAR(15) NOT NULL UNIQUE,  -- CPF único para garantir consistência
    id_sexo INT NOT NULL,
    senha VARCHAR(255) NOT NULL,      -- Certifique-se de hashear as senhas
    data_nascimento DATE NOT NULL,    -- Data de nascimento
    FOREIGN KEY (id_sexo) REFERENCES tbl_sexo(id_sexo)
);


drop table tbl_enderecos;

select * from tbl_enderecos where id_endereco = 2;

-- Tabela de médicos
CREATE TABLE tbl_medicos (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    id_empresa INT,  -- Relaciona com a empresa
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(320) NOT NULL,      -- Aumentado para suportar emails mais longos
    senha VARCHAR(255) NOT NULL,      -- Certifique-se de hashear as senhas
    telefone VARCHAR(20) NOT NULL,
    crm VARCHAR(20) NOT NULL UNIQUE,  -- CRM único
    data_nascimento DATE NOT NULL,    -- Data de nascimento
    FOREIGN KEY (id_empresa) REFERENCES tbl_empresa(id_empresa) ON DELETE CASCADE -- Se empresa for excluída, médicos são excluídos
);


-- Procedure Cadastrar médico na última empresa cadastrada
DELIMITER $$


CREATE PROCEDURE sp_inserir_medico_ultima_empresa(
    IN p_nome VARCHAR(255),
    IN p_email VARCHAR(320),
    IN p_senha VARCHAR(255),
    IN p_telefone VARCHAR(20),
    IN p_crm VARCHAR(20),
    IN p_data_nascimento DATE
)
BEGIN
    DECLARE last_empresa_id INT;


    -- Obtém o id da última empresa cadastrada
    SELECT MAX(id_empresa) INTO last_empresa_id FROM tbl_empresa;


    -- Verifica se existe ao menos uma empresa cadastrada
    IF last_empresa_id IS NOT NULL THEN


        -- Insere o médico associado à última empresa cadastrada
        INSERT INTO tbl_medicos (id_empresa, nome, email, senha, telefone, crm, data_nascimento)
        VALUES (last_empresa_id, p_nome, p_email, p_senha, p_telefone, p_crm, p_data_nascimento);


    ELSE
        -- Se não houver nenhuma empresa cadastrada, gera um erro
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhuma empresa encontrada para associar o médico';
    END IF;
END$$


DELIMITER ;

drop procedure sp_inserir_medico_ultima_empresa;

CALL sp_inserir_medico_ultima_empresa(
    'Dra. Ana Pereira',            -- Nome do médico
    'dra.ana@email.com',           -- Email do médico
    'senhaSegura456',              -- Senha do médico (não se esqueça de hashear na aplicação)
    '11912345678',                 -- Telefone do médico
    'CRM987654',                   -- CRM do médico
    '1980-05-15'                   -- Data de nascimento
);

CREATE VIEW vw_medico_empresa AS
SELECT
    m.id_medico,
    m.nome AS nome_medico,
    m.email AS email_medico,
    m.telefone AS telefone_medico,
    m.crm,
    m.data_nascimento AS data_nascimento_medico,
    e.id_empresa,
    e.nome_empresa,
    e.nome_proprietario,
    e.cnpj,
    e.email AS email_empresa,
    e.telefone,
    e.telefone_clinica
   
FROM
    tbl_medicos m
JOIN
    tbl_empresa e ON m.id_empresa = e.id_empresa;
    
    drop view vw_medico_empresa;
    
    CREATE VIEW vw_medico_empresa AS
SELECT
    m.id_medico,
    m.nome AS nome_medico,
    m.email AS email_medico,
    m.telefone AS telefone_medico,
    m.crm,
    m.data_nascimento AS data_nascimento_medico,
    e.id_empresa,
    e.nome_empresa,
    e.nome_proprietario,
    e.cnpj,
    e.email AS email_empresa,
    e.telefone,
    e.telefone_clinica,
    es.nome -- mostra as especialidades
FROM
    tbl_medicos m
JOIN
    tbl_empresa e ON m.id_empresa = e.id_empresa
JOIN
    tbl_medico_especialidade me ON m.id_medico = me.id_medico
JOIN
    tbl_especialidades es ON me.id_especialidade = es.id_especialidade;

    
    
   
 
   
    select * from vw_medico_empresa;
   
    desc tbl_empresa;


DELIMITER $$

CREATE PROCEDURE sp_inserir_medico_com_especialidades(
    IN p_nome VARCHAR(255),
    IN p_email VARCHAR(320),
    IN p_senha VARCHAR(255),
    IN p_telefone VARCHAR(20),
    IN p_crm VARCHAR(20),
    IN p_data_nascimento DATE,
    IN p_especialidades VARCHAR(255) -- Lista de especialidades separadas por vírgula
)
BEGIN
    DECLARE last_medico_id INT;
    DECLARE especialidade_nome VARCHAR(255);
    DECLARE especialidade_id INT;

    -- Inserir o médico na tabela tbl_medicos, associado à última empresa cadastrada
    CALL sp_inserir_medico_ultima_empresa(p_nome, p_email, p_senha, p_telefone, p_crm, p_data_nascimento);
   
    -- Pegar o ID do médico recém-cadastrado
    SET last_medico_id = LAST_INSERT_ID();

    -- Loop para dividir as especialidades separadas por vírgula e associá-las ao médico
    WHILE LENGTH(p_especialidades) > 0 DO
        -- Pegar a primeira especialidade da lista
        SET especialidade_nome = TRIM(SUBSTRING_INDEX(p_especialidades, ',', 1));
       
        -- Remover essa especialidade da lista
        SET p_especialidades = TRIM(SUBSTRING(p_especialidades, LENGTH(especialidade_nome) + 2));

        -- Verificar se a especialidade existe na tabela tbl_especialidades
        SELECT id_especialidade INTO especialidade_id
        FROM tbl_especialidades
        WHERE nome = especialidade_nome
        LIMIT 1;

        -- Se a especialidade existir, associá-la ao médico
        IF especialidade_id IS NOT NULL THEN
            INSERT INTO tbl_medico_especialidade (id_medico, id_especialidade)
            VALUES (last_medico_id, especialidade_id);
        END IF;
    END WHILE;

END$$

DELIMITER ;


CALL sp_inserir_medico_com_especialidades(
    'Dr. João Silva',
    'joao.silva@hospital.com',
    'senhaSegura123',
    '(11) 99999-9999',
    '126541-SP',
    '1980-05-20',
    'Dermatologista' -- Especialidades separadas por vírgula
);

select * from tbl_especialidades;








SELECT
    m.nome AS nome_medico,
    e.nome AS especialidade,
    emp.nome_empresa AS nome_empresa
FROM
    tbl_medico_especialidade me
JOIN
    tbl_medicos m ON me.id_medico = m.id_medico
JOIN
    tbl_especialidades e ON me.id_especialidade = e.id_especialidade
JOIN
    tbl_empresa emp ON m.id_empresa = emp.id_empresa;





-- Tabela de especialidades
CREATE TABLE tbl_especialidades (
    id_especialidade INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT NOT NULL,         -- Descrição da especialidade
    imagem_url VARCHAR(255) NOT NULL -- URL da imagem armazenada no Firebase
);

select * from tbl_especialidades;

select * from tbl_especialidades where nome like "%Ort%";

show tables;

insert into tbl_especialidades(nome, descricao, imagem_url)values
(
"Cardiologista",
"Um cardiologista é um médico que trata doenças do coração e vasos sanguíneos.",
"https://vitaclinica.com.br/wp-content/uploads/2019/08/Cardiologista-1-1200x800.jpg"
);

select * from tbl_medico_especialidade;

-- Tabela intermediária médico-especialidade
CREATE TABLE tbl_medico_especialidade (
id_medico_especialidade INT PRIMARY KEY AUTO_INCREMENT,
    id_medico INT,
    id_especialidade INT,
    FOREIGN KEY (id_medico) REFERENCES tbl_medicos(id_medico) ON DELETE CASCADE, -- Exclui especialidades associadas se médico for removido
    FOREIGN KEY (id_especialidade) REFERENCES tbl_especialidades(id_especialidade) ON DELETE CASCADE -- Exclui associações se especialidade for removida
);

-- Tabela intermediária empresa-especialidade
CREATE TABLE tbl_empresa_especialidade (
    id_empresa INT,
    id_especialidade INT,
    PRIMARY KEY (id_empresa, id_especialidade),
    FOREIGN KEY (id_empresa) REFERENCES tbl_empresa(id_empresa) ON DELETE CASCADE, -- Exclui especialidades associadas se empresa for removida
    FOREIGN KEY (id_especialidade) REFERENCES tbl_especialidades(id_especialidade) ON DELETE CASCADE -- Exclui associações se especialidade for removida
);

DELIMITER $$

CREATE PROCEDURE sp_inserir_especialidade_com_empresa(
    IN p_nome_especialidade VARCHAR(255),
    IN p_descricao_especialidade TEXT,
    IN p_imagem_url VARCHAR(255)
)
BEGIN
    DECLARE last_empresa_id INT;

    -- Inserir a especialidade na tabela tbl_especialidades
    INSERT INTO tbl_especialidades (nome, descricao, imagem_url)
    VALUES (p_nome_especialidade, p_descricao_especialidade, p_imagem_url);

    -- Pegar o ID da última empresa cadastrada
    SELECT MAX(id_empresa) INTO last_empresa_id FROM tbl_empresa;

    -- Verificar se existe pelo menos uma empresa cadastrada
    IF last_empresa_id IS NOT NULL THEN
        -- Pegar o ID da última especialidade inserida
        SET @last_especialidade_id = LAST_INSERT_ID();

        -- Associar a especialidade à última empresa
        INSERT INTO tbl_empresa_especialidade (id_empresa, id_especialidade)
        VALUES (last_empresa_id, @last_especialidade_id);
    ELSE
        -- Se não houver empresas cadastradas, lança um erro
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhuma empresa encontrada para associar a especialidade';
    END IF;
END$$

DELIMITER ;

CALL sp_inserir_especialidade_com_empresa(
    'Ortopedista',
    'Especialista em problemas ósseos e musculares.',
    'https://link_da_imagem.com/ortopedista.jpg'
);
select * from tbl_empresa_especialidade;




-- Tabela de avaliações
CREATE TABLE tbl_avaliacoes (
    id_avaliacao INT AUTO_INCREMENT PRIMARY KEY,
    id_medico INT,
    id_usuario INT,
    nota TINYINT NOT NULL CHECK (nota BETWEEN 1 AND 5), -- Nota de 1 a 5
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_medico) REFERENCES tbl_medicos(id_medico) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES tbl_usuarios(id_usuario) ON DELETE CASCADE
);

-- Tabela de vídeos
CREATE TABLE tbl_videos (
    id_video INT AUTO_INCREMENT PRIMARY KEY,
    id_empresa INT,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    url VARCHAR(255) NOT NULL,         -- URL do vídeo armazenada no Firebase
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_empresa) REFERENCES tbl_empresa(id_empresa) ON DELETE CASCADE -- Se empresa for excluída, vídeos são excluídos
);

DELIMITER $$

CREATE PROCEDURE sp_inserir_video_ultima_empresa(
    IN p_titulo VARCHAR(255),
    IN p_descricao TEXT,
    IN p_url VARCHAR(255)
)
BEGIN
    DECLARE last_empresa_id INT;

    -- Obtém o id da última empresa cadastrada
    SELECT MAX(id_empresa) INTO last_empresa_id FROM tbl_empresa;

    -- Verifica se existe ao menos uma empresa cadastrada
    IF last_empresa_id IS NOT NULL THEN
        -- Insere o vídeo associado à última empresa cadastrada
        INSERT INTO tbl_videos (id_empresa, titulo, descricao, url)
        VALUES (last_empresa_id, p_titulo, p_descricao, p_url);
    ELSE
        -- Se não houver nenhuma empresa cadastrada, gera um erro
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhuma empresa encontrada para associar o vídeo';
    END IF;
END$$

DELIMITER ;


CALL sp_inserir_video_ultima_empresa(
    'Exercícios Físicos',
    'Este vídeo apresenta alguns exercícios físicos.',
    'https://url_do_video.com/video.mp4'
);


CREATE VIEW vw_videos_empresas AS
SELECT
    v.id_video,
    v.titulo AS titulo_video,
    v.descricao AS descricao_video,
    v.url AS url_video,
    v.data_publicacao,
    e.id_empresa,
    e.nome_empresa,
    e.cnpj,
    e.email AS email_empresa,
    e.telefone AS telefone_empresa,
    e.telefone_clinica
FROM
    tbl_videos v
JOIN
    tbl_empresa e ON v.id_empresa = e.id_empresa;


select * from vw_videos_empresas;




-- Índices para melhorar a performance de buscas frequentes
CREATE INDEX idx_email_usuario ON tbl_usuarios(email);
CREATE INDEX idx_crm_medico ON tbl_medicos(crm);






CREATE VIEW vw_usuarios_enderecos AS
SELECT
    u.id_usuario,
    u.nome,
    u.email,
    u.senha,
    u.cpf,
    s.descricao AS sexo,
    u.data_nascimento
FROM
    tbl_usuarios u
JOIN
    tbl_sexo s ON u.id_sexo = s.id_sexo;
   
   

DELIMITER $$

CREATE TRIGGER trg_delete_usuario_endereco
BEFORE DELETE ON tbl_usuarios
FOR EACH ROW
BEGIN
    -- Deletar o endereço associado ao usuário
    DELETE FROM tbl_enderecos
    WHERE id_usuario = OLD.id_usuario;
END$$

DELIMITER ;



-- Deletar um usuário (e automaticamente seu endereço será deletado)
DELETE FROM tbl_usuarios
WHERE id_usuario = 1;

SELECT * FROM tbl_usuarios;









           









CREATE VIEW vw_empresa_completa AS
SELECT
    e.id_empresa,
    e.nome_empresa,
    e.nome_proprietario,
    e.cnpj,
    e.email AS email_empresa,
    e.telefone AS telefone_empresa,
    e.telefone_clinica,
    med.id_medico,
    med.nome AS nome_medico,
    med.email AS email_medico,
    med.crm,
    med.telefone AS telefone_medico,
    med.data_nascimento AS data_nascimento_medico,
    esp.nome AS especialidade,
    esp.descricao AS descricao_especialidade,
    esp.imagem_url AS url_imagem_especialidade,
    ende.cep,
    ende.logradouro,
    ende.bairro,
    ende.cidade,
    ende.estado
FROM
    tbl_empresa e
LEFT JOIN
    tbl_endereco_empresa ende ON e.id_empresa = ende.id_empresa
LEFT JOIN
    tbl_medicos med ON e.id_empresa = med.id_empresa
LEFT JOIN
    tbl_medico_especialidade me ON med.id_medico = me.id_medico
LEFT JOIN
    tbl_especialidades esp ON me.id_especialidade = esp.id_especialidade;

select * from vw_empresa_completa;

DELIMITER $$

CREATE TRIGGER trg_delete_empresa_endereco
BEFORE DELETE ON tbl_empresa
FOR EACH ROW
BEGIN
    -- Deletar o endereço associado à empresa
    DELETE FROM tbl_endereco_empresa
    WHERE id_empresa = OLD.id_empresa;
END$$

DELIMITER ;