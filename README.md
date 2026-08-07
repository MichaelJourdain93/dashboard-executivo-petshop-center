# Dashboard Executivo Petshop Center (AWS QuickSight)

## Desafio do Projeto — One Page: Resultados e Satisfação do Cliente

**Contexto:** A Caramelo Pet Center (rede omnichannel com +150 lojas, ecossistema de varejo, clínicas e estética, e +2 milhões de clientes ativos) enfrenta um cenário de "muitos dados, poucos insights", marcado por divergência de números, sobrecarga de relatórios sem fonte oficial da verdade e falta de conexão entre indicadores macro e causa raiz.

**Objetivo:** Construir um relatório one page que reúna, em uma única tela, os principais indicadores de vendas/resultados e satisfação do cliente, dando à diretoria uma visão confiável e integrada do negócio.

O painel é dividido em três blocos:

### Bloco 1 — Visão Geral
- Big numbers de faturamento, ticket médio e atingimento de meta.
- Meta editável (atualmente R$ 4 mi, recalculada mensalmente pelo financeiro).
- Gráfico de pizza com faturamento por categoria de produto.
- Evolução mensal do faturamento: valor absoluto (R$) e barra 100% por categoria.
- Gráfico de linhas com a evolução do ticket médio.

### Bloco 2 — Performance por Região
- Mapa de faturamento por estado, destacando estados de melhor performance.
- Interatividade: ao selecionar um estado, a tabela ao lado deve refletir o filtro.
- Tabela de quantidade vendida e faturamento por tipo de animal (cão, gato, coelho etc.) por estado.

### Bloco 3 — Satisfação do Cliente (NPS)
- Nuvem de palavras com principais elogios e reclamações dos comentários.
- Gráfico de pizza com distribuição de promotores, neutros e detratores.
- Indicadores de total de respondentes e nota média.
- Filtro por classificação do cliente (ex.: isolar detratores e ver suas palavras mais frequentes).

### Requisitos-chave
- Consolidar múltiplas fontes em uma única fonte da verdade.
- Garantir parâmetros editáveis (meta).
- Interatividade entre visuais (seleção de estado → tabela; filtro de classificação → nuvem de palavras).

## Arquitetura do Projeto

**1. Armazenamento (Amazon S3)**
Os arquivos brutos das fontes de dados foram carregados no Amazon S3, que atua como camada de storage do projeto.

**2. Conexão e ingestão (Datasets — AWS QuickSight)**
A conexão com o S3 é feita na aba *Datasets* do QuickSight, onde os arquivos são importados e conectados como fontes de dados.

**3. Tratamento na camada de Datasets**
Ainda na camada de *Datasets*, foram aplicados:
- **Campos calculados a nível de linha** (não agregados), que retornam a informação em cada registro sem afetar a granularidade das análises feitas depois.
- **Propriedades de geolocalização**, atribuindo o tipo geográfico correto a campos como nome de estado e nome de país, habilitando os visuais de mapa.
- **Joins entre tabelas**, cruzando informações de diferentes fontes para compor as visões estratégicas.

**4. Camada de Análise (Analyses)**
As *analyses* consomem múltiplos *datasets* e concentram a modelagem analítica. Nesta camada foram criados:
- **Campos calculados** para construir os indicadores principais (KPIs) e os demais blocos.
- **Parâmetros** com dois papéis: dar agilidade à interface e alimentar filtros que personalizam a visualização e orientam as análises, deixando a experiência mais dinâmica e direcionada.
- **Actions e configurações** para adicionar interatividade entre os visuais e enriquecer a experiência de visualização.

**5. Publicação (Deploy do Dashboard)**
Por fim, o *deploy* do dashboard fecha o fluxo, entregando a visão consolidada em uma única tela — o *one page* de resultados e satisfação do cliente.

## Estrutura do Repositório

```
.
├── dados/                    # Fontes de dados brutas (CSV) carregadas no Amazon S3
│   ├── caramelo_fato_vendas.csv      # Tabela fato de vendas
│   ├── caramelo_dim_produtos.csv     # Dimensão de produtos
│   ├── caramelo_nps.csv              # Respostas da pesquisa de NPS
│   └── caramelo_wordcloud.csv        # Termos para a nuvem de palavras
│
├── campos-calculados/        # Expressões de campos calculados do QuickSight
│   └── campo_estado_calculado.txt    # Sigla da UF → nome do estado (geolocalização/mapa)
│
├── visuais-customizados/     # Código dos visuais customizados (Highcharts)
│   ├── nps_variablepie_original.js   # Exemplo base da documentação Highcharts
│   └── nps_variablepie_ajustado.json # Versão adaptada ao NPS (volume vs. qualidade)
│
├── configuracoes-aws/        # Configurações de infraestrutura AWS
│   └── s3_bucket_policy.json         # Bucket policy de leitura pública dos objetos
│
└── imagens/                  # Imagens usadas no dashboard
    ├── cachorro.png
    ├── gato.png
    ├── coelho.png
    ├── passaro.png
    ├── porquinho.png
    └── pet.jpg
```
