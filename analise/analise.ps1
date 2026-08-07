$ErrorActionPreference = "Stop"
$inv = [Globalization.CultureInfo]::InvariantCulture
function N([string]$s) { if ([string]::IsNullOrWhiteSpace($s)) { 0.0 } else { [double]::Parse($s, $inv) } }

$D = Join-Path (Split-Path $PSScriptRoot -Parent) "dados"
$vendas = Import-Csv "$D\caramelo_fato_vendas.csv"
$prod   = Import-Csv "$D\caramelo_dim_produtos.csv"
$nps    = Import-Csv "$D\caramelo_nps.csv"

$pmap = @{}
foreach ($p in $prod) { $pmap[$p.ID_Produto] = $p }

# enriquecer
$rows = foreach ($v in $vendas) {
  $p = $pmap[$v.ID_Produto]
  $fat = N $v.Faturamento_Bruto
  $cst = N $v.Custo_Total
  $com = N $v.Comissao_Percentual
  [pscustomobject]@{
    Data      = [datetime]::ParseExact($v.Data_Venda, "yyyy-MM-dd", $inv)
    Mes       = $v.Data_Venda.Substring(0,7)
    Qtd       = [int]$v.Quantidade
    Fat       = $fat
    Custo     = $cst
    Comissao  = $fat * $com
    Margem    = $fat - $cst - ($fat * $com)
    Regiao    = $v.Regiao
    Estado    = $v.Estado
    Pgto      = $v.Forma_Pagamento
    Categoria = if ($p) { $p.Categoria } else { "?" }
    Animal    = if ($p) { $p.Animal } else { "?" }
    Pedido    = $v.ID_Pedido
  }
}

"=============== 1. VISAO GERAL ==============="
$totFat = ($rows | Measure-Object Fat -Sum).Sum
$totMar = ($rows | Measure-Object Margem -Sum).Sum
$totCus = ($rows | Measure-Object Custo -Sum).Sum
$totCom = ($rows | Measure-Object Comissao -Sum).Sum
$totQtd = ($rows | Measure-Object Qtd -Sum).Sum
$pedidos = ($rows | Select-Object -ExpandProperty Pedido -Unique).Count
"Periodo: {0:yyyy-MM-dd} a {1:yyyy-MM-dd}" -f ($rows | Measure-Object Data -Minimum).Minimum, ($rows | Measure-Object Data -Maximum).Maximum
"Linhas...............: {0:N0}" -f $rows.Count
"Pedidos unicos.......: {0:N0}" -f $pedidos
"Faturamento total....: {0:N2}" -f $totFat
"Custo total..........: {0:N2}" -f $totCus
"Comissao total.......: {0:N2}" -f $totCom
"Margem total.........: {0:N2}  ({1:N2}% do faturamento)" -f $totMar, ($totMar/$totFat*100)
"Itens vendidos.......: {0:N0}" -f $totQtd
"Ticket medio (linha).: {0:N2}" -f ($totFat/$rows.Count)
"Ticket medio (pedido): {0:N2}" -f ($totFat/$pedidos)
""

"--- Faturamento e margem por CATEGORIA ---"
$rows | Group-Object Categoria | ForEach-Object {
  $f = ($_.Group | Measure-Object Fat -Sum).Sum
  $m = ($_.Group | Measure-Object Margem -Sum).Sum
  [pscustomobject]@{
    Categoria = $_.Name
    Fat = [math]::Round($f,2)
    PctFat = [math]::Round($f/$totFat*100,1)
    Margem = [math]::Round($m,2)
    MargemPct = [math]::Round($m/$f*100,1)
    PctMargemTotal = [math]::Round($m/$totMar*100,1)
  }
} | Sort-Object Fat -Descending | Format-Table -AutoSize | Out-String -Width 200

"--- Faturamento e margem por ANIMAL ---"
$rows | Group-Object Animal | ForEach-Object {
  $f = ($_.Group | Measure-Object Fat -Sum).Sum
  $m = ($_.Group | Measure-Object Margem -Sum).Sum
  $q = ($_.Group | Measure-Object Qtd -Sum).Sum
  [pscustomobject]@{
    Animal = $_.Name
    Qtd = $q
    Fat = [math]::Round($f,2)
    PctFat = [math]::Round($f/$totFat*100,1)
    MargemPct = [math]::Round($m/$f*100,1)
  }
} | Sort-Object Fat -Descending | Format-Table -AutoSize | Out-String -Width 200

"--- Evolucao MENSAL ---"
$rows | Group-Object Mes | Sort-Object Name | ForEach-Object {
  $f = ($_.Group | Measure-Object Fat -Sum).Sum
  $m = ($_.Group | Measure-Object Margem -Sum).Sum
  $n = $_.Group.Count
  [pscustomobject]@{
    Mes = $_.Name
    Fat = [math]::Round($f,2)
    Ticket = [math]::Round($f/$n,2)
    Linhas = $n
    MargemPct = [math]::Round($m/$f*100,1)
  }
} | Format-Table -AutoSize | Out-String -Width 200

"--- Forma de PAGAMENTO ---"
$rows | Group-Object Pgto | ForEach-Object {
  $f = ($_.Group | Measure-Object Fat -Sum).Sum
  $c = ($_.Group | Measure-Object Comissao -Sum).Sum
  [pscustomobject]@{
    Pagamento = $_.Name
    Fat = [math]::Round($f,2)
    PctFat = [math]::Round($f/$totFat*100,1)
    ComissaoPct = [math]::Round($c/$f*100,2)
    TicketMedio = [math]::Round($f/$_.Group.Count,2)
  }
} | Sort-Object Fat -Descending | Format-Table -AutoSize | Out-String -Width 200

"=============== 2. REGIAO ==============="
"--- Por REGIAO ---"
$rows | Group-Object Regiao | ForEach-Object {
  $f = ($_.Group | Measure-Object Fat -Sum).Sum
  $m = ($_.Group | Measure-Object Margem -Sum).Sum
  [pscustomobject]@{
    Regiao = $_.Name
    Fat = [math]::Round($f,2)
    PctFat = [math]::Round($f/$totFat*100,1)
    MargemPct = [math]::Round($m/$f*100,1)
    Ticket = [math]::Round($f/$_.Group.Count,2)
  }
} | Sort-Object Fat -Descending | Format-Table -AutoSize | Out-String -Width 200

"--- TOP 12 ESTADOS ---"
$estFat = @{}
$rows | Group-Object Estado | ForEach-Object {
  $f = ($_.Group | Measure-Object Fat -Sum).Sum
  $estFat[$_.Name] = $f
  [pscustomobject]@{
    Estado = $_.Name
    Fat = [math]::Round($f,2)
    PctFat = [math]::Round($f/$totFat*100,1)
    Ticket = [math]::Round($f/$_.Group.Count,2)
    Linhas = $_.Group.Count
  }
} | Sort-Object Fat -Descending | Select-Object -First 12 | Format-Table -AutoSize | Out-String -Width 200

"=============== 3. NPS ==============="
$notas = $nps | ForEach-Object { [int]$_.Nota_NPS }
"Respostas............: {0:N0}" -f $nps.Count
"Nota min/max.........: {0} / {1}" -f ($notas | Measure-Object -Minimum).Minimum, ($notas | Measure-Object -Maximum).Maximum
"Nota MEDIA real......: {0:N2}" -f (($notas | Measure-Object -Average).Average)
"Nota SOMA............: {0:N0}" -f (($notas | Measure-Object -Sum).Sum)
""
"--- Distribuicao por CLASSIFICACAO ---"
$nps | Group-Object Classificacao_NPS | ForEach-Object {
  $ns = $_.Group | ForEach-Object { [int]$_.Nota_NPS }
  [pscustomobject]@{
    Classificacao = $_.Name
    Respostas = $_.Count
    Pct = [math]::Round($_.Count/$nps.Count*100,1)
    NotaMedia = [math]::Round(($ns | Measure-Object -Average).Average,2)
    NotaSoma = ($ns | Measure-Object -Sum).Sum
  }
} | Sort-Object Respostas -Descending | Format-Table -AutoSize | Out-String -Width 200

$promo = ($nps | Where-Object { $_.Classificacao_NPS -eq "Promotor" }).Count
$detra = ($nps | Where-Object { $_.Classificacao_NPS -eq "Detrator" }).Count
"NPS SCORE = %Promotores - %Detratores = {0:N1}% - {1:N1}% = {2:N1}" -f ($promo/$nps.Count*100), ($detra/$nps.Count*100), (($promo-$detra)/$nps.Count*100)
""

"--- MOTIVO PRINCIPAL (geral) ---"
$nps | Group-Object Motivo_Principal | ForEach-Object {
  [pscustomobject]@{ Motivo = $_.Name; Respostas = $_.Count; Pct = [math]::Round($_.Count/$nps.Count*100,1) }
} | Sort-Object Respostas -Descending | Format-Table -AutoSize | Out-String -Width 200

"--- MOTIVO x CLASSIFICACAO ---"
$nps | Group-Object Motivo_Principal | ForEach-Object {
  $g = $_.Group
  $d = ($g | Where-Object { $_.Classificacao_NPS -eq "Detrator" }).Count
  $n = ($g | Where-Object { $_.Classificacao_NPS -eq "Neutro" }).Count
  $p = ($g | Where-Object { $_.Classificacao_NPS -eq "Promotor" }).Count
  [pscustomobject]@{
    Motivo = $_.Name
    Total = $g.Count
    Detrator = $d
    PctDetrator = [math]::Round($d/$g.Count*100,1)
    Neutro = $n
    Promotor = $p
    NPS = [math]::Round(($p-$d)/$g.Count*100,1)
  }
} | Sort-Object NPS | Format-Table -AutoSize | Out-String -Width 200

"--- NPS por ESTADO (min 100 respostas) x FATURAMENTO ---"
$nps | Group-Object Estado | Where-Object { $_.Count -ge 100 } | ForEach-Object {
  $g = $_.Group
  $d = ($g | Where-Object { $_.Classificacao_NPS -eq "Detrator" }).Count
  $p = ($g | Where-Object { $_.Classificacao_NPS -eq "Promotor" }).Count
  $ns = $g | ForEach-Object { [int]$_.Nota_NPS }
  [pscustomobject]@{
    Estado = $_.Name
    Respostas = $g.Count
    NPS = [math]::Round(($p-$d)/$g.Count*100,1)
    NotaMedia = [math]::Round(($ns | Measure-Object -Average).Average,2)
    Faturamento = [math]::Round($estFat[$_.Name],2)
    PctFatTotal = [math]::Round($estFat[$_.Name]/$totFat*100,1)
  }
} | Sort-Object NPS | Format-Table -AutoSize | Out-String -Width 200

"--- NPS por MES ---"
$nps | Group-Object { $_.Data_Resposta.Substring(0,7) } | Sort-Object Name | ForEach-Object {
  $g = $_.Group
  $d = ($g | Where-Object { $_.Classificacao_NPS -eq "Detrator" }).Count
  $p = ($g | Where-Object { $_.Classificacao_NPS -eq "Promotor" }).Count
  [pscustomobject]@{
    Mes = $_.Name
    Respostas = $g.Count
    NPS = [math]::Round(($p-$d)/$g.Count*100,1)
  }
} | Format-Table -AutoSize | Out-String -Width 200
