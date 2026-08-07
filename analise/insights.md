# Análise e Insights — One Page: Resultados e Satisfação do Cliente

Análise das perguntas de negócio do desafio, feita sobre os dados brutos em [`dados/`](../dados/)
(15.000 pedidos, 5.000 respostas de NPS, 36 produtos, ano de 2025) e sobre o painel publicado
no AWS QuickSight.

Os números foram recalculados de forma independente a partir dos CSVs — o script está em
[`analise.ps1`](analise.ps1) e pode ser reexecutado. Onde o resultado diverge do que o painel
exibe, a divergência está apontada explicitamente.

---

## Sumário executivo

| Indicador | Valor |
|---|---|
| Faturamento bruto (2025) | R$ 3.282.372,74 |
| Atingimento da meta (R$ 4 mi) | 82,06% |
| Margem de contribuição | R$ 899.185,64 (**27,39%**) |
| Pedidos | 15.000 · 31.258 itens |
| Ticket médio por pedido | R$ 218,82 |
| Respostas de NPS | 5.000 · nota média **4,94** · 64,2% na faixa de detrator |

**As três conclusões que mudam decisão:**

1. As duas categorias que mais faturam são as que menos entregam margem. Ração e Farmácia são
   61,3% do faturamento e apenas 41,3% da margem. Um painel que ranqueia só por faturamento
   aponta o investimento para o lado errado.
2. A queda de 11,27% no ticket médio de dezembro, que o painel sinaliza em vermelho, **não é
   deterioração** — é efeito de cesta. O faturamento por pedido subiu 32,6% no mesmo mês.
3. Espírito Santo aparece com 330 respostas de NPS e **zero vendas** — o estado não existe na
   tabela fato. No mapa ele fica em branco, indistinguível de "vendeu pouco".

---

## Bloco 1 — Visão Geral

### Faturamento e meta

O ano fechou em **R$ 3.282.372,74** contra meta de R$ 4.000.000, ou seja **82,06%** — exatamente
o que o gauge do painel mostra. Faltaram R$ 717.627,26 para a meta.

> **Ponto de atenção sobre a meta.** O enunciado descreve a meta como "atualmente R$ 4 mi,
> recalculada mensalmente pelo financeiro", mas o gauge compara o **acumulado do ano** contra os
> R$ 4 mi. Se a meta fosse de fato mensal, o atingimento seria de ~6,8% ao mês, não 82%. Vale
> alinhar com o financeiro se o parâmetro representa meta anual ou mensal — a leitura do
> indicador muda completamente.

### Sazonalidade: dezembro é um mês estruturalmente diferente

| Mês | Faturamento | Pedidos | Itens/pedido | R$/pedido | R$/item | Margem % |
|---|---|---|---|---|---|---|
| Jan–Nov (média) | ~R$ 265 mil | ~1.246 | **2,00** | ~R$ 213 | ~R$ 106 | 27,1% |
| **Dez** | **R$ 358.622,18** | 1.297 | **2,98** | **R$ 276,50** | **R$ 92,93** | **29,9%** |

Dezembro faturou **+41,6% sobre novembro**. O número de pedidos praticamente não mudou
(1.297 vs 1.215): o que mudou foi a **cesta**, que saltou de 2 para quase 3 itens por pedido.

### O alerta vermelho do ticket médio está enganando

O painel mostra ticket médio de **92,93 em dezembro contra 104,73 em novembro (−11,27%)**, com
seta vermelha. Reproduzi o cálculo: o painel define ticket médio como **faturamento ÷ quantidade
de itens**, isto é, o *preço médio por item*.

Pela definição convencional — **faturamento ÷ número de pedidos** — dezembro foi assim:

| Definição | Nov | Dez | Variação |
|---|---|---|---|
| Faturamento ÷ itens (painel) | 104,73 | 92,93 | **−11,3%** 🔴 |
| Faturamento ÷ pedidos (convencional) | 208,52 | 276,50 | **+32,6%** 🟢 |

**O mesmo mês aparece como queda ou como crescimento dependendo da definição.** O que aconteceu
em dezembro foi o cliente levando 50% mais itens por compra a um preço unitário menor — padrão
clássico de promoção/kit de fim de ano, e o resultado é o melhor mês do ano em faturamento *e*
em margem. Sinalizar isso em vermelho leva a diretoria a tentar "corrigir" algo que funcionou.

**Recomendação:** exibir os dois indicadores com rótulos distintos — "Ticket médio (por pedido)"
e "Preço médio por item" — ou renomear o atual para "Preço médio por item". Como o desafio pede
uma fonte única da verdade, essa ambiguidade é justamente o tipo de divergência de números que
o projeto quer eliminar.

### Categoria: onde está o faturamento ≠ onde está o lucro

| Categoria | Faturamento | % Fat | Margem % | % da margem total |
|---|---|---|---|---|
| Ração | R$ 1.023.305,80 | 31,2% | **18,4%** | 21,0% |
| Farmácia | R$ 988.061,77 | 30,1% | **18,5%** | 20,3% |
| Acessórios | R$ 339.573,43 | 10,3% | **41,6%** | 15,7% |
| Brinquedos | R$ 330.417,65 | 10,1% | **41,5%** | 15,3% |
| Higiene | R$ 301.354,06 | 9,2% | **41,5%** | 13,9% |
| Alimentação | R$ 299.660,03 | 9,1% | **41,5%** | 13,8% |

Existem dois negócios dentro da operação, com estruturas econômicas opostas:

- **Ração + Farmácia** — 61,3% do faturamento, margem de ~18%, respondem por 41,3% da margem.
  São produtos de recorrência e alta comparabilidade de preço.
- **Acessórios + Brinquedos + Higiene + Alimentação** — 38,7% do faturamento, margem de ~41,5%,
  respondem por **58,7% da margem**.

Ou seja: **as quatro categorias "pequenas" já geram mais lucro que as duas grandes.** Um ponto
percentual de crescimento nelas vale mais que dois nas categorias de volume.

O painel atual só mostra faturamento por categoria. **Recomendação:** acrescentar margem — como
segunda métrica no gráfico de rosca ou como gráfico de dispersão faturamento × margem %. É a
adição de maior impacto no bloco 1.

### Forma de pagamento: sem alavanca

Os quatro meios de pagamento estão empatados (24,7% a 25,4% do faturamento) com comissão média
de ~3,5% cada. Não há aqui nenhuma oportunidade de migração de mix — a comissão total do ano foi
de R$ 115.265,15 (3,5% do faturamento). Registro para poupar a análise a quem for procurar.

---

## Bloco 2 — Performance por Região

### Concentração

| Região | Faturamento | % | Margem % |
|---|---|---|---|
| Sudeste | R$ 1.490.598,15 | 45,4% | 27,4% |
| Sul | R$ 660.022,02 | 20,1% | 27,3% |
| Nordeste | R$ 482.036,92 | 14,7% | 27,8% |
| Centro-Oeste | R$ 331.022,42 | 10,1% | 27,3% |
| Norte | R$ 318.693,23 | 9,7% | 27,1% |

**SP, MG e RJ concentram 45,3% do faturamento** (R$ 500.374 / R$ 497.220 / R$ 493.004 — os três
praticamente empatados). A margem é homogênea entre regiões (27,1% a 27,8%), então a diferença
regional é de **volume**, não de rentabilidade. O ticket por pedido também varia pouco
(R$ 214 a R$ 228).

Isso simplifica a leitura estratégica: não há região "cara" ou "barata" de operar. Ganho regional
vem de penetração, não de correção de mix.

### Tipo de animal: mesma inversão da categoria

| Animal | Itens | Faturamento | % Fat | Margem % |
|---|---|---|---|---|
| Gato | 10.309 | R$ 1.324.241,41 | 40,3% | **24,0%** |
| Cachorro | 10.281 | R$ 1.318.897,87 | 40,2% | **24,0%** |
| Pássaro | 5.192 | R$ 311.176,90 | 9,5% | **41,5%** |
| Coelho | 2.865 | R$ 173.472,63 | 5,3% | **41,5%** |
| Porquinho da Índia | 2.611 | R$ 154.583,93 | 4,7% | **41,5%** |

Cão e gato são 80,5% do faturamento a 24% de margem. Os três pets "alternativos" são 19,5% do
faturamento a 41,5% de margem — reflexo do mix de categorias que cada um consome (cão e gato
puxam ração e farmácia).

---

## Bloco 3 — Satisfação do Cliente (NPS)

O bloco mede duas coisas: **volume de respostas** e **nota média**. É sobre isso que a análise
abaixo se limita a falar.

### Volume e nota por classificação

Base: **5.000 respostas** no ano de 2025, com notas de 0 a 10. A classificação segue o padrão
0–6 (detrator), 7–8 (neutro) e 9–10 (promotor).

| Classificação | Respostas | % do total | Nota média |
|---|---|---|---|
| Detrator (0–6) | 3.210 | 64,2% | 2,97 |
| Neutro (7–8) | 916 | 18,3% | 7,49 |
| Promotor (9–10) | 874 | 17,5% | 9,49 |

Nota média geral: **4,94**.

A leitura direta: **quase dois terços das respostas estão na faixa de detrator**, e é esse o
grupo de maior volume — a barra mais longa do gráfico é também a de pior nota.

### Volume e nota por motivo

| Motivo | Respostas | % | Nota média |
|---|---|---|---|
| Atendimento | 1.063 | 21,3% | 5,17 |
| Preço | 1.024 | 20,5% | 4,83 |
| Variedade | 987 | 19,7% | 4,78 |
| Tempo de Entrega | 971 | 19,4% | 4,96 |
| Qualidade do Produto | 955 | 19,1% | 4,94 |

Os cinco motivos aparecem em volume praticamente igual (19,1% a 21,3%) e com notas médias
próximas (4,78 a 5,17 — amplitude de 0,39 ponto numa escala de 0 a 10). Nenhum motivo se destaca
como o problema principal; a distribuição é equilibrada.

### Volume e nota por estado

| Estado | Respostas | Nota média |
|---|---|---|
| GO | 374 | 5,06 |
| MS | 355 | 5,12 |
| PR | 344 | 4,97 |
| RS | 342 | 5,02 |
| CE | 341 | 4,74 |
| SC | 339 | 4,53 |
| BA | 339 | 5,06 |
| MG | 336 | 4,98 |
| PA | 335 | 4,98 |
| ES | 330 | 5,05 |
| PE | 319 | 5,05 |
| SP | 319 | 5,06 |
| MT | 312 | 4,90 |
| RJ | 311 | 4,69 |
| AM | 304 | 4,84 |

Quinze estados, com volume de respostas entre 304 e 374 — cobertura equilibrada, sem estado
sub ou super-representado. As notas médias ficam entre **4,53 (SC)** e **5,12 (MS)**, uma
amplitude de 0,59 ponto. Também aqui a distribuição é plana.

---

## Achados de qualidade de dados

### 1. Espírito Santo tem NPS mas não tem vendas

ES aparece com **330 respostas de NPS** e faturamento **zero** — não existe uma única venda para
o estado na tabela fato. Os outros 14 estados aparecem nas duas bases.

Ou faltou carga das vendas de ES, ou a pesquisa foi aplicada em um estado onde a rede não opera.
No mapa do painel o ES fica em branco, o que se confunde visualmente com "vendeu pouco" em vez
de "não tem dado". **Recomendação:** tratar explicitamente, com cor de "sem dado" distinta de
valor baixo.

### 2. Cobertura de período difere entre as bases

Vendas vão de 01/01/2025 a **26/12/2025**; NPS vai de 01/01/2025 a **31/12/2025**. Diferença de
cinco dias, irrelevante para os totais, mas registrada para quem for comparar séries diárias.

### 3. Integridade: sem problemas

Verifiquei e **não há** pedidos duplicados, pesquisas duplicadas, vendas órfãs sem produto
correspondente, faturamento nulo ou negativo, nem linha com margem negativa. Os joins da camada
de dataset estão consistentes.

---

## ⚠️ Ressalva metodológica sobre a base de NPS

As notas de 0 a 10 estão distribuídas de forma **praticamente uniforme** — cada nota concentra
entre 8,6% e 9,7% das respostas, quando o esperado seria ~9,1% em uma distribuição
perfeitamente uniforme:

```
Nota  0: 9,7%   Nota  4: 9,4%   Nota  8: 9,0%
Nota  1: 8,7%   Nota  5: 9,3%   Nota  9: 8,9%
Nota  2: 9,4%   Nota  6: 8,7%   Nota 10: 8,6%
Nota  3: 8,9%   Nota  7: 9,4%
```

Isso explica por que os cortes do bloco 3 saem todos parecidos: a proporção de 64,2% na faixa de
detrator é o resultado mecânico de 7 das 11 notas caírem entre 0 e 6, e as notas médias por motivo
(4,78 a 5,17) e por estado (4,53 a 5,12) orbitam o ponto médio da escala.

Por isso a análise do bloco 3 se limita a **descrever volume e nota**, sem ranquear motivos ou
estados: as diferenças observadas são pequenas demais para sustentar priorização.

A base de **vendas**, ao contrário, tem estrutura real e consistente: a diferença de margem entre
categorias, a concentração regional e o efeito de cesta de dezembro são padrões deliberados nos
dados e sustentam as conclusões dos blocos 1 e 2.

---

## Recomendações priorizadas

| # | Ação | Bloco | Esforço | Por quê |
|---|---|---|---|---|
| 1 | Adicionar margem por categoria ao lado do faturamento | 1 | Baixo | Revela que 61% da receita gera 41% do lucro |
| 2 | Renomear "Ticket médio" para "Preço médio por item" e criar o ticket por pedido | 1 | Baixo | Elimina o falso alerta de queda em dezembro |
| 3 | Definir com o financeiro se a meta é anual ou mensal | 1 | Baixo | Muda a interpretação do gauge |
| 4 | Tratar ES como "sem dado" no mapa | 2 | Baixo | Evita confundir ausência com baixo desempenho |

---

## Reprodutibilidade

Os números deste documento são gerados por [`analise.ps1`](analise.ps1) e
[`verifica.ps1`](verifica.ps1), que leem diretamente os CSVs de [`dados/`](../dados/):

```powershell
./analise/analise.ps1    # métricas dos três blocos
./analise/verifica.ps1   # checagens de integridade e definição de ticket médio
```
