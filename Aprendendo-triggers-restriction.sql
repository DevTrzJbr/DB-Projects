-- Cria a tabela alunos com as restrições
DROP TABLE alunos CASCADE CONSTRAINTS;
CREATE TABLE alunos 
   ( idAluno    NUMBER(8) NOT NULL
   , nome        VARCHAR2(100) NOT NULL
   , nota        NUMBER(4,2)
   , finalizado  CHAR(1) DEFAULT 'N' NOT NULL
  );

ALTER TABLE alunos  
ADD CONSTRAINT pk_alunos PRIMARY KEY(idAluno);

ALTER TABLE alunos
ADD CONSTRAINT alunos_finalizado_ck
CHECK (finalizado IN ('S', 'N'));


--Criação da sequencia Alunos
DROP SEQUENCE seq_alunos;
CREATE SEQUENCE seq_alunos
    START WITH 20230001
    INCREMENT BY 1
    MAXVALUE 20239999
    MINVALUE 1
;

--Criação do Trigger para inserir código autimaticamente
CREATE OR REPLACE TRIGGER trg_alunos
BEFORE INSERT ON alunos
FOR EACH ROW
BEGIN
    :new.idAluno := seq_alunos.nextval;
END;
/

INSERT INTO alunos(nome, nota) VALUES('Joao Tarzan',10);
INSERT INTO alunos(nome, nota) VALUES('Daniel Valadares',10);
INSERT INTO alunos(nome, nota) VALUES('Andre Prado',9.9);
INSERT INTO alunos(nome, nota) VALUES('Caio Castro',5);

UPDATE alunos
SET finalizado = 'S'
WHERE idAluno = 20230001
;
/*
UPDATE alunos
SET nome = 'CABRITO'
WHERE idAluno = 20230001
;*/

DROP TABLE usuarios CASCADE CONSTRAINTS;
CREATE TABLE usuarios
    (username   VARCHAR2(25)  NOT NULL
    ,permissao  VARCHAR2(1)   NOT NULL
    );
    
ALTER TABLE usuarios
ADD CONSTRAINT usuarios_pk PRIMARY KEY (username);

ALTER TABLE usuarios
ADD CONSTRAINT usuarios_permissao_ck
CHECK(permissao IN('C', 'A'));

ALTER TABLE usuarios
ADD CONSTRAINT usuario_cargo_ck
CHECK (username in('HR', 'ADMIN'));

INSERT INTO usuarios(username, permissao) VALUES('ADMIN','A');
INSERT INTO usuarios(username, permissao) VALUES('HR','C');

CREATE OR REPLACE TRIGGER trg_usuarios_permissao
BEFORE UPDATE OR DELETE ON alunos
FOR EACH ROW
DECLARE
    permissao_sessao VARCHAR2(1);
BEGIN
    SELECT 
        permissao
    INTO
        permissao_sessao
    FROM 
        usuarios
    WHERE
        upper(username) = upper(user);
        
        IF permissao_sessao = 'C' and :old.finalizado = 'S'  THEN
        raise_application_error(-20000, 'Você não tem permissao para alterar ou atualizar a tabela alunos.');
        
        ELSIF permissao_sessao = 'A' and :old.finalizado = 'S' AND DELETING THEN
        raise_application_error(-20002, 'Você não pode deletar esse estudante.');
    END IF;
END;
/

-- Deve dar erro!
DELETE alunos 
WHERE idAluno = 20230001 ;
