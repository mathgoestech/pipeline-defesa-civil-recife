# pipeline-defesa-civil-recife

Data Warehouse com os atendimentos da Defesa Civil do Recife (2022 a 2024), modelado em esquema estrela no PostgreSQL. O mesmo modelo é construído de duas formas: ETL com pandas e ELT com dbt.

Fonte dos dados: [Registro de atendimentos da Defesa Civil – Portal de Dados Abertos do Recife](https://dados.recife.pe.gov.br/dataset/registro-de-atendimentos-da-defesa-civil)

## Estrutura do repositório

- `notebooks/`: notebooks `ETL.ipynb` e `ELT.ipynb`, com os CSVs de origem em `notebooks/data/`.
- `transformacao_atendimentos/`: projeto dbt que transforma as tabelas brutas no esquema estrela (ELT).
- `analises/`: consultas SQL e notebook das análises feitas sobre o Data Warehouse.
- `consultas/`: consulta que compara o resultado do ETL com o do ELT.

## Como rodar

### Pré-requisitos

- Python 3.12+
- PostgreSQL com a extensão `unaccent` disponível (o dbt cria a extensão sozinho)

### Ambiente Python

Na raiz do repositório:

```bash
python3 -m venv .venv          # no Windows: python -m venv .venv

source .venv/bin/activate      # Linux/Mac
.venv\Scripts\activate         # Windows

pip install -r requirements.txt
```

### Arquivo .env

Copie o modelo e preencha com os dados do seu banco:

```bash
cp .env.example .env           # no Windows: copy .env.example .env
```

O banco indicado em `DB_NAME` precisa existir antes de rodar os notebooks.

### ETL (pandas)

Execute todas as células de `notebooks/ETL.ipynb` com a pasta `notebooks/` como diretório de trabalho (os caminhos do notebook são relativos a ela). Ele cria o schema `etl` com as dimensões e a tabela fato.

### ELT (dbt)

1. Execute todas as células de `notebooks/ELT.ipynb`, também a partir da pasta `notebooks/`. Ele carrega os CSVs sem tratamento nas tabelas `raw_atendimentos_2022`, `raw_atendimentos_2023` e `raw_atendimentos_2024` do schema `public`.

2. Crie o arquivo `~/.dbt/profiles.yml` (no Windows: `C:\Users\SEU_USUARIO\.dbt\profiles.yml`):

   ```yaml
   transformacao_atendimentos:
     target: dev
     outputs:
       dev:
         type: postgres
         host: localhost
         port: 5432
         user: postgres
         password: sua_senha
         dbname: defesa_civil
         schema: elt
         threads: 4
   ```

3. Rode o dbt:

   ```bash
   cd transformacao_atendimentos
   dbt build
   ```

   O `dbt build` carrega os seeds, cria os modelos no schema `elt` e executa os testes.

### Comparação ETL x ELT

Com os dois schemas criados, rode na raiz do repositório:

```bash
psql -h localhost -U postgres -d defesa_civil -f consultas/comparacao_etl_elt.sql
```

A consulta compara a quantidade de linhas de cada tabela nos schemas `etl` e `elt` e o conteúdo da tabela fato (ignorando as chaves substitutas); se as duas cargas forem iguais, o segundo resultado não retorna nenhuma linha.
