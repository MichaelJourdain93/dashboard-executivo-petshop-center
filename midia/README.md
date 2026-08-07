# Mídia

Registro visual do dashboard, preservado antes do encerramento da assinatura do QuickSight.
Todos os arquivos refletem a **versão corrigida** do painel, com a nota média do NPS já agregada
como `average` (2.97 / 7.49 / 9.49).

| Arquivo | Conteúdo |
|---|---|
| `dashboard-one-page.pdf` | Export em PDF do one page completo |
| `dashboard-passeio.mp4` | Gravação de tela do dashboard em uso (50 s, sem áudio) |
| `gifs/dashboard-passeio.gif` | Mesma gravação em GIF, para renderizar inline no README |

## Notas técnicas

- O GIF é derivado do MP4 (`fps=9`, 920 px de largura, paleta de 128 cores) e fica em ~6 MB — abaixo do limite de ~10 MB que o GitHub respeita para renderizar inline.
- A gravação bruta foi cortada em `crop=1600:914:0:82`, removendo as faixas pretas superior e inferior e o pop-up de "Your PDF is ready" que ficava na lateral direita durante todo o vídeo. O áudio foi removido (trilha em silêncio, -91 dB).
- MP4 commitado **não toca inline** no markdown do GitHub — serve como arquivo em qualidade cheia para download. Quem toca inline é o GIF.
