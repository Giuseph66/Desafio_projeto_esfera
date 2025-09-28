-- Descrição: Tabela para armazenar dados de empresas consultadas via OpenCNPJ

-- Criar extensão para UUID (se não existir)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Criar extensão para busca de texto (trigram)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Criar tabela companies
CREATE TABLE IF NOT EXISTS companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cnpj CHAR(14) NOT NULL UNIQUE,
    razao_social TEXT,
    nome_fantasia TEXT,
    situacao_cadastral TEXT,
    data_situacao_cadastral DATE,
    matriz_filial TEXT,
    data_inicio_atividade DATE,
    cnae_principal_code VARCHAR(7),
    cnaes_secundarios JSONB,
    cnaes_secundarios_count INTEGER,
    natureza_juridica TEXT,
    logradouro TEXT,
    numero TEXT,
    complemento TEXT,
    bairro TEXT,
    cep CHAR(8),
    uf CHAR(2),
    municipio TEXT,
    email TEXT,
    telefones JSONB,
    capital_social NUMERIC(16,2),
    porte_empresa TEXT,
    opcao_simples TEXT,
    data_opcao_simples DATE,
    opcao_mei TEXT,
    data_opcao_mei DATE,
    qsa JSONB,
    raw JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_companies_cnpj ON companies(cnpj);
CREATE INDEX IF NOT EXISTS idx_companies_razao_social ON companies USING gin(razao_social gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_companies_municipio ON companies(municipio);
CREATE INDEX IF NOT EXISTS idx_companies_uf ON companies(uf);
CREATE INDEX IF NOT EXISTS idx_companies_situacao ON companies(situacao_cadastral);
CREATE INDEX IF NOT EXISTS idx_companies_created_at ON companies(created_at);
CREATE INDEX IF NOT EXISTS idx_companies_updated_at ON companies(updated_at);

-- Criar função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar trigger para atualizar updated_at
DROP TRIGGER IF EXISTS update_companies_updated_at ON companies;
CREATE TRIGGER update_companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
