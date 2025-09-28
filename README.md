# 🚀 Desafio Esfera Solar

Sistema completo de consulta e gerenciamento de CNPJ com integração à API OpenCNPJ, desenvolvido com Flutter Web e Node.js.

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Tecnologias](#-tecnologias)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Configuração](#-configuração)
- [Execução](#-execução)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [API Endpoints](#-api-endpoints)
- [Desenvolvimento](#-desenvolvimento)
- [Troubleshooting](#-troubleshooting)

## 🎯 Visão Geral

O **Desafio Esfera Solar** é uma aplicação web que permite:

- ✅ **Consulta de CNPJ** - Busca dados de empresas via API OpenCNPJ
- ✅ **Validação** - Validação completa de CNPJ com dígitos verificadores
- ✅ **Salvamento** - Armazenamento de empresas consultadas no banco de dados
- ✅ **Listagem** - Visualização de empresas salvas com paginação

## 🛠 Tecnologias

### Frontend (Flutter Web)
- **Flutter** 3.9.2+ - Framework de desenvolvimento
- **Dart** 3.9.2+ - Linguagem de programação
- **Material Design 3** - Sistema de design
- **HTTP** - Cliente HTTP para API
- **Mask Text Input Formatter** - Máscaras de entrada

### Backend (Node.js)
- **Node.js** 20.0.0+ - Runtime JavaScript
- **Express.js** 4.18.2+ - Framework web
- **PostgreSQL** 16 - Banco de dados
- **Axios** - Cliente HTTP
- **Zod** - Validação de schemas
- **Pino** - Logging estruturado

### Infraestrutura
- **Docker** - Containerização do banco
- **Docker Compose** - Orquestração de containers

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

### Obrigatórios
- [**Git**](https://git-scm.com/) - Controle de versão
- [**Node.js**](https://nodejs.org/) 20.0.0+ - Runtime JavaScript
- [**Flutter**](https://flutter.dev/) 3.9.2+ - Framework Flutter
- [**Docker**](https://www.docker.com/) - Containerização
- [**Docker Compose**](https://docs.docker.com/compose/) - Orquestração

### Opcionais
- [**VS Code**](https://code.visualstudio.com/) - Editor recomendado
- [**Flutter Extension**](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) - Extensão Flutter para VS Code

## 🚀 Instalação

### 1. Clone o Repositório

```bash
git clone https://github.com/Giuseph66/Desafio_projeto_esfera.git
cd Desafio_projeto_esfera
```

### 2. Estrutura do Projeto

```
Desafio_projeto_esfera/
├── front/                 # Aplicação Flutter Web
│   ├── lib/
│   ├── web/
│   └── pubspec.yaml
├── back/                  # API Node.js
│   ├── src/
│   ├── sql/
│   ├── docker-compose.yml     # Configuração do banco
│   └── package.json
└── README.md
```

## ⚙️ Configuração

### 1. Configurar Banco de Dados

#### Opção A: Usando Docker (Recomendado)

```bash
# Navegar para o diretório do projeto
cd Desafio_projeto_esfera

# Navegar ate o backend
cd back
# Subir o container do PostgreSQL
docker-compose up -d

# Verificar se o container está rodando
docker ps
```

**Configurações do Banco (Docker):**
- **Host:** localhost
- **Porta:** 5432
- **Database:** esfera
- **Usuário:** postgres
- **Senha:** postgres

#### Opção B: PostgreSQL Local

Se preferir usar PostgreSQL instalado localmente:

1. **Instalar PostgreSQL:**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install postgresql postgresql-contrib
   
   # macOS (com Homebrew)
   brew install postgresql
   
   # Windows
   Baixar do site oficial: https://www.postgresql.org/download/windows/
   ```

2. **Criar banco de dados:**
   ```bash
   # Conectar como usuário postgres
   sudo -u postgres psql
   
   # Criar banco e usuário
   CREATE DATABASE esfera;
   CREATE USER esfera_user WITH PASSWORD 'esfera_password';
   GRANT ALL PRIVILEGES ON DATABASE esfera TO esfera_user;
   \q
   ```

3. **Executar script de inicialização:**
   ```bash
   # Executar o script SQL
   psql -h localhost -U esfera_user -d esfera -f back/sql/001_init.sql
   ```

### 2. Configurar Variáveis de Ambiente

Crie o arquivo `.env` no diretório `back/` baseado no arquivo de exemplo:

```bash
# Copiar arquivo de exemplo
cp back/env.exemple back/.env
```

**Arquivo `.env` (Docker):**
```env
PORT=3001
DATABASE_URL=postgres://postgres:postgres@localhost:5432/esfera
OPEN_CNPJ_BASE_URL=https://api.opencnpj.org
```

**Arquivo `.env` (PostgreSQL Local):**
```env
PORT=3001
DATABASE_URL=postgres://esfera_user:esfera_password@localhost:5432/esfera
OPEN_CNPJ_BASE_URL=https://api.opencnpj.org
```

### 3. Configurar Backend

```bash
# Navegar para o diretório do backend
cd back

# Instalar dependências
npm install

# Verificar se as dependências foram instaladas
npm list
```

### 4. Configurar Frontend

```bash
# Navegar para o diretório do frontend
cd front

# Instalar dependências Flutter
flutter pub get

# Verificar se o Flutter está configurado corretamente
flutter doctor
```

## 🚀 Execução

### 1. Iniciar o Banco de Dados

#### Opção A: Docker (Recomendado)

```bash

# Navega ate a pasta correta
cd back

# Inicializ o banco 
docker-compose up -d

# Verificar logs do banco (opcional)
docker-compose logs postgres
```

#### Opção B: PostgreSQL Local

```bash
# Iniciar serviço PostgreSQL
# Ubuntu/Debian
sudo systemctl start postgresql

# macOS (com Homebrew)
brew services start postgresql

# Windows
Iniciar via Services ou pgAdmin
```

### 2. Iniciar o Backend

```bash
# No diretório back/
cd back

# Modo desenvolvimento (com hot reload)
npm run dev

# OU modo produção
npm start
```

**Backend estará disponível em:** `http://localhost:3001`

### 3. Iniciar o Frontend

```bash
# No diretório front/
cd front

# Executar em modo desenvolvimento
flutter run -d web-server --web-port 3000

# OU compilar para produção
flutter build web
```

**Frontend estará disponível em:** `http://localhost:3000`

## 📁 Estrutura do Projeto

### Frontend (Flutter)
```
front/
├── lib/
│   ├── core/              # Funcionalidades centrais
│   │   ├── api/           # Cliente HTTP
│   │   ├── models/        # Modelos de dados
│   │   ├── theme/         # Tema da aplicação
│   │   └── utils/         # Utilitários
│   ├── features/          # Funcionalidades específicas
│   │   ├── search/        # Consulta de CNPJ
│   │   └── list/          # Listagem de empresas
│   └── main.dart          # Ponto de entrada
└── pubspec.yaml           # Dependências Flutter
```

### Backend (Node.js)
```
back/
├── src/
│   ├── routes/            # Rotas da API
│   ├── services/          # Serviços de negócio
│   ├── middlewares/       # Middlewares Express
│   ├── utils/             # Utilitários
│   ├── db.js              # Conexão com banco
│   └── server.js          # Servidor principal
├── sql/                   # Scripts SQL
│   └── 001_init.sql       # Inicialização do banco
├── docker-compose.yml     # Configuração do banco
└── package.json           # Dependências Node.js
```

## 🔌 API Endpoints

### Verificar status
```bash
curl http://localhost:3001/
```

### Consulta de CNPJ
```bash
# Buscar dados de um CNPJ
curl http://localhost:3001/cnpj/11222333000181
```

### Salvar Empresa
```bash
# Salvar empresa no banco de dados
curl -X POST http://localhost:3001/companies \
  -H "Content-Type: application/json" \
  -d '{"cnpj": "11222333000181"}'
```

### Listar Empresas
```bash
# Listar todas as empresas (primeira página)
curl http://localhost:3001/companies

# Listar com paginação
curl "http://localhost:3001/companies?page=1&limit=5"

# Buscar empresas por termo
curl "http://localhost:3001/companies?search=esfera"

# Buscar com paginação e filtro
curl "http://localhost:3001/companies?page=2&limit=10&search=solar"
```

### Exemplos de Resposta

#### Consulta de CNPJ (Sucesso)
```json
{
  "cnpj": "11222333000181",
  "nome": "Esfera Solar Ltda",
  "fantasia": "Esfera Solar",
  "situacao": "ATIVA",
  "logradouro": "Rua das Flores, 123",
  "municipio": "São Paulo",
  "uf": "SP",
  "cep": "01234-567"
}
```

#### Lista de Empresas
```json
{
  "companies": [
    {
      "id": 1,
      "cnpj": "11222333000181",
      "nome": "Esfera Solar Ltda",
      "fantasia": "Esfera Solar",
      "situacao": "ATIVA",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "totalPages": 1
  }
}
```

## 🛠 Desenvolvimento

### Scripts Disponíveis

#### Backend
```bash
npm run dev          # Desenvolvimento com hot reload
npm start            # Produção
```

#### Frontend
```bash
flutter run -d web-server --web-port 3000    # Desenvolvimento
flutter build web                            # Compilar para produção
```

### Hot Reload

- **Backend:** Alterações são refletidas automaticamente com `npm run dev`
- **Frontend:** Use `r` no terminal para hot reload ou `R` para hot restart

### Debugging

- **Backend:** Use `console.log()` ou debugger do Node.js
- **Frontend:** Use `debugPrint()` ou debugger do Flutter Web

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Erro de Conexão com Banco

**Docker:**
```bash
# Verificar se o container está rodando
docker ps

# Reiniciar o container
docker-compose restart postgres

# Verificar logs
docker-compose logs postgres
```

**PostgreSQL Local:**
```bash
# Verificar se o serviço está rodando
sudo systemctl status postgresql

# Reiniciar o serviço
sudo systemctl restart postgresql

# Verificar logs
sudo journalctl -u postgresql -f
```

#### 2. Erro de Dependências Flutter
```bash
# Limpar cache
flutter clean

# Reinstalar dependências
flutter pub get

# Verificar versão do Flutter
flutter doctor
```

#### 3. Erro de Dependências Node.js
```bash
# Limpar cache
npm cache clean --force

# Deletar node_modules e reinstalar
rm -rf node_modules package-lock.json
npm install
```

#### 4. Porta já em uso
```bash
# Verificar processos nas portas
netstat -tlnp | grep -E ':(3000|3001|5432)'

# Matar processo específico
kill -9 <PID>
```

### Logs e Debug

#### Backend
```bash
# Ver logs em tempo real
docker-compose logs -f postgres

# Logs do servidor Node.js
npm run dev
```

#### Frontend
```bash
# Executar com logs detalhados
flutter run -d web-server --web-port 3000 --verbose
```

## 📱 Acesso à Aplicação

Após seguir todos os passos:

1. **Frontend:** [http://localhost:3000](http://localhost:3000)
2. **Backend API:** [http://localhost:3001](http://localhost:3001)
3. **Banco de Dados:** localhost:5432

## 🧪 Teste Rápido da API

Para testar se a API está funcionando corretamente:

```bash
# 1. Testar health check
curl http://localhost:3001/

# 2. Testar consulta de CNPJ (exemplo com CNPJ válido)
curl http://localhost:3001/cnpj/11222333000181

# 3. Testar listagem de empresas
curl http://localhost:3001/companies

# 4. Testar salvamento de empresa
curl -X POST http://localhost:3001/companies \
  -H "Content-Type: application/json" \
  -d '{"cnpj": "11222333000181"}'
```

**Resposta esperada do health check:**
```json
{
  "status": "ok",
  "message": "API Desafio Esfera Solar funcionando!",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## ⚙️ Resumo das Configurações

### Docker (Recomendado)
```env
PORT=3001
DATABASE_URL=postgres://postgres:postgres@localhost:5432/esfera
OPEN_CNPJ_BASE_URL=https://api.opencnpj.org
```

### PostgreSQL Local
```env
PORT=3001
DATABASE_URL=postgres://esfera_user:esfera_password@localhost:5432/esfera
OPEN_CNPJ_BASE_URL=https://api.opencnpj.org
```

### Comandos Rápidos

**Setup completo (Docker):**
```bash
git clone https://github.com/Giuseph66/Desafio_projeto_esfera.git
cd Desafio_projeto_esfera
cp back/env.exemple back/.env
cd back
docker-compose up -d
npm install && npm run dev
cd ../front && flutter pub get && flutter run -d web-server --web-port 3000
```

**Setup completo (PostgreSQL Local):**
```bash
git clone https://github.com/Giuseph66/Desafio_projeto_esfera.git
cd Desafio_projeto_esfera
cp back/env.exemple back/.env
# Editar back/.env com credenciais locais
psql -h localhost -U esfera_user -d esfera -f back/sql/001_init.sql
cd back && npm install && npm run dev
cd ../front && flutter pub get && flutter run -d web-server --web-port 3000
```

## 🎨 Funcionalidades

### Consulta de CNPJ
- ✅ Validação completa de CNPJ
- ✅ Máscara automática de entrada
- ✅ Busca via Enter ou botão
- ✅ Tratamento de erros

### Gerenciamento de Empresas
- ✅ Salvamento no banco de dados
- ✅ Listagem com paginação
- ✅ Busca por nome/CNPJ
- ✅ Interface responsiva


## 👥 Autores

- **Desafio Esfera Solar** - [GitHub](https://github.com/Giuseph66)


**Desenvolvido com ❤️ para o Desafio Esfera Solar**