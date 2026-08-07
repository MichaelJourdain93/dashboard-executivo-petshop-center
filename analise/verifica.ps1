$ErrorActionPreference = "Stop"
$inv = [Globalization.CultureInfo]::InvariantCulture
function N([string]$s) { [double]::Parse($s, $inv) }
$D = Join-Path (Split-Path $PSScriptRoot -Parent) "dados"
$vendas = Import-Csv "$D\caramelo_fato_vendas.csv"
$nps    = Import-Csv "$D\caramelo_nps.csv"

"### A) Definicao de TICKET MEDIO - Dez/2025 e Nov/2025"
foreach ($m in @("2025-12","2025-11")) {
  $g = $vendas | Where-Object { $_.Data_Venda.StartsWith($m) }
  $f = ($g | ForEach-Object { N $_.Faturamento_Bruto } | Measure-Object -Sum).Sum
  $q = ($g | Measure-Object Quantidade -Sum).Sum
  "{0}: Fat={1:N2} | Pedidos={2} | Itens={3} | Fat/Pedido={4:N2} | Fat/Item={5:N2}" -f $m, $f, $g.Count, $q, ($f/$g.Count), ($f/$q)
}
""
"### B) Estados: vendas vs NPS"
$eV = $vendas | Select-Object -ExpandProperty Estado -Unique | Sort-Object
$eN = $nps    | Select-Object -ExpandProperty Estado -Unique | Sort-Object
"Estados em VENDAS ({0}): {1}" -f $eV.Count, ($eV -join ",")
"Estados em NPS    ({0}): {1}" -f $eN.Count, ($eN -join ",")
"So em NPS (sem venda): {0}" -f (($eN | Where-Object { $_ -notin $eV }) -join ",")
"So em VENDAS (sem NPS): {0}" -f (($eV | Where-Object { $_ -notin $eN }) -join ",")
""
"### C) Faixas de nota por classificacao (checar regra NPS padrao 0-6/7-8/9-10)"
$nps | Group-Object Classificacao_NPS | ForEach-Object {
  $ns = $_.Group | ForEach-Object { [int]$_.Nota_NPS }
  "{0}: min={1} max={2} n={3}" -f $_.Name, ($ns | Measure-Object -Minimum).Minimum, ($ns | Measure-Object -Maximum).Maximum, $_.Count
}
""
"### D) Distribuicao de notas 0-10"
$nps | Group-Object Nota_NPS | Sort-Object { [int]$_.Name } | ForEach-Object {
  "Nota {0,2}: {1,5} ({2,4:N1}%)" -f $_.Name, $_.Count, ($_.Count/$nps.Count*100)
}
""
"### E) Integridade: produtos sem match, nulos, duplicidade"
$prod = Import-Csv "$D\caramelo_dim_produtos.csv"
$ids = $prod.ID_Produto
$semMatch = $vendas | Where-Object { $_.ID_Produto -notin $ids }
"Vendas sem produto correspondente: {0}" -f $semMatch.Count
"Pedidos duplicados: {0}" -f ($vendas.Count - ($vendas.ID_Pedido | Select-Object -Unique).Count)
"Pesquisas duplicadas: {0}" -f ($nps.Count - ($nps.ID_Pesquisa | Select-Object -Unique).Count)
"Faturamento <= 0: {0}" -f ($vendas | Where-Object { (N $_.Faturamento_Bruto) -le 0 }).Count
"Margem negativa (linhas): {0}" -f ($vendas | Where-Object { (N $_.Faturamento_Bruto) - (N $_.Custo_Total) - ((N $_.Faturamento_Bruto)*(N $_.Comissao_Percentual)) -lt 0 }).Count
""
"### F) Periodo do NPS"
"NPS de {0} a {1}" -f ($nps.Data_Resposta | Measure-Object -Minimum).Minimum, ($nps.Data_Resposta | Measure-Object -Maximum).Maximum
"Vendas de {0} a {1}" -f ($vendas.Data_Venda | Measure-Object -Minimum).Minimum, ($vendas.Data_Venda | Measure-Object -Maximum).Maximum
