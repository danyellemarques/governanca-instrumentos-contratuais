-- =============================================
-- SISTEMA DE GOVERNANÇA DE INSTRUMENTOS
-- Script de criação do banco de dados
-- PostgreSQL 15+
-- =============================================

-- Criar o schema (opcional)
CREATE SCHEMA IF NOT EXISTS governanca;
SET search_path TO governanca;

-- 1. ORGANIZACAO
CREATE TABLE organizacao (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(200) NOT NULL,
    cnpj            VARCHAR(18) UNIQUE NOT NULL,
    tipo            VARCHAR(50) NOT NULL
                    CHECK (tipo IN ('Prefeitura','ONG',
                    'Empresa','Universidade','Outro')),
    contato_nome    VARCHAR(150),
    contato_email   VARCHAR(150),
    contato_telefone VARCHAR(20),
    ativo           BOOLEAN DEFAULT TRUE
);

-- 2. RESPONSAVEL
CREATE TABLE responsavel (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(150) NOT NULL,
    cargo VARCHAR(100),
    setor VARCHAR(100),
    email VARCHAR(150) UNIQUE,
    ativo BOOLEAN DEFAULT TRUE
);

-- 3. INSTRUMENTO
CREATE TABLE instrumento (
    id                  SERIAL PRIMARY KEY,
    numero              VARCHAR(50) UNIQUE NOT NULL,
    tipo                VARCHAR(50) NOT NULL
                        CHECK (tipo IN ('Convenio','Contrato',
                        'Termo de Cooperacao',
                        'Acordo de Cooperacao','Outro')),
    objeto              TEXT NOT NULL,
    organizacao_id      INTEGER REFERENCES organizacao(id),
    responsavel_id      INTEGER REFERENCES responsavel(id),
    data_celebracao     DATE,
    data_vigencia_inicio DATE NOT NULL,
    data_vigencia_fim   DATE NOT NULL,
    valor_total         NUMERIC(15,2) CHECK (valor_total >= 0),
    status              VARCHAR(30) NOT NULL DEFAULT 'Em elaboracao'
                        CHECK (status IN ('Em elaboracao','Ativo',
                        'Suspenso','Encerrado','Cancelado')),
    observacoes         TEXT,
    criado_em           TIMESTAMP DEFAULT NOW(),
    CONSTRAINT chk_vigencia
        CHECK (data_vigencia_fim > data_vigencia_inicio)
);

-- 4. MARCO
CREATE TABLE marco (
    id              SERIAL PRIMARY KEY,
    instrumento_id  INTEGER NOT NULL
                    REFERENCES instrumento(id),
    descricao       VARCHAR(300) NOT NULL,
    data_prevista   DATE NOT NULL,
    data_realizada  DATE,
    status          VARCHAR(30) NOT NULL DEFAULT 'Pendente'
                    CHECK (status IN ('Pendente',
                    'Concluido','Atrasado','Cancelado')),
    valor_parcela   NUMERIC(15,2)
);

-- 5. AUDITORIA
CREATE TABLE auditoria (
    id              SERIAL PRIMARY KEY,
    instrumento_id  INTEGER NOT NULL
                    REFERENCES instrumento(id),
    auditor_id      INTEGER NOT NULL
                    REFERENCES responsavel(id),
    data_auditoria  DATE NOT NULL,
    tipo            VARCHAR(50) NOT NULL
                    CHECK (tipo IN ('Entrada','Periodica',
                    'Encerramento','Extraordinaria')),
    resultado       VARCHAR(30) NOT NULL
                    CHECK (resultado IN ('Conforme',
                    'Nao Conforme','Parcialmente Conforme')),
    parecer         TEXT,
    checklist_score INTEGER,
    checklist_total INTEGER
);

-- 6. CHECKLIST_ITEM
CREATE TABLE checklist_item (
    id            SERIAL PRIMARY KEY,
    auditoria_id  INTEGER NOT NULL
                  REFERENCES auditoria(id),
    criterio      VARCHAR(300) NOT NULL,
    conforme      BOOLEAN NOT NULL,
    observacao    TEXT
);

-- 7. TRAMITACAO
CREATE TABLE tramitacao (
    id              SERIAL PRIMARY KEY,
    instrumento_id  INTEGER NOT NULL
                    REFERENCES instrumento(id),
    etapa_origem    VARCHAR(100) NOT NULL,
    etapa_destino   VARCHAR(100) NOT NULL,
    responsavel_id  INTEGER REFERENCES responsavel(id),
    data_entrada    TIMESTAMP NOT NULL DEFAULT NOW(),
    data_saida      TIMESTAMP,
    dias_na_etapa   INTEGER,
    observacao      TEXT
);

-- 8. ADITIVO
CREATE TABLE aditivo (
    id                  SERIAL PRIMARY KEY,
    instrumento_id      INTEGER NOT NULL
                        REFERENCES instrumento(id),
    tipo_aditivo        VARCHAR(50) NOT NULL
                        CHECK (tipo_aditivo IN ('Prazo',
                        'Valor','Escopo','Misto')),
    justificativa       TEXT NOT NULL,
    valor_aditivo       NUMERIC(15,2),
    prazo_adicional_dias INTEGER,
    data_assinatura     DATE NOT NULL,
    status              VARCHAR(30) NOT NULL DEFAULT 'Em analise'
                        CHECK (status IN ('Em analise',
                        'Aprovado','Rejeitado'))
);

-- 9. DOCUMENTO
CREATE TABLE documento (
    id              SERIAL PRIMARY KEY,
    instrumento_id  INTEGER NOT NULL
                    REFERENCES instrumento(id),
    tipo_documento  VARCHAR(100) NOT NULL,
    nome_arquivo    VARCHAR(255) NOT NULL,
    data_upload     DATE DEFAULT CURRENT_DATE,
    uploaded_por    VARCHAR(150)
);

-- 10. ÍNDICES para performance
CREATE INDEX idx_instrumento_status ON instrumento(status);
CREATE INDEX idx_instrumento_org ON instrumento(organizacao_id);
CREATE INDEX idx_instrumento_resp ON instrumento(responsavel_id);
CREATE INDEX idx_instrumento_vigencia ON instrumento(data_vigencia_fim);
CREATE INDEX idx_auditoria_instrumento ON auditoria(instrumento_id);
CREATE INDEX idx_tramitacao_instrumento ON tramitacao(instrumento_id);
CREATE INDEX idx_marco_instrumento ON marco(instrumento_id);
