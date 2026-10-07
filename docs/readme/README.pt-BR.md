# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · **Português (Brasil)** · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Última versão](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Licença: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Downloads](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Um pequeno app para a barra de menus do macOS que melhora teclas, janelas e o Dock: bloqueia os atalhos com Control, protege ⌘Q e ⌘W, troca o idioma com Option+Shift do jeito que o Alt+Shift funciona no Windows, repete a tecla segurada como no Windows, desativa a aceleração do mouse, rola a roda do mouse por linhas como no Windows, faz os botões laterais do mouse voltarem e avançarem, encerra os apps quando você fecha a última janela, oculta um app com um clique no Dock e mantém seu Mac acordado.

## Instalação

Com o [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Sem o Homebrew, abra o Terminal, cole esta linha e pressione Return:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Ou baixe o [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), abra-o e arraste o app para a pasta Aplicativos.

Tanto o Homebrew quanto o script colocam o app em `/Applications`, abrem o app, pedem as permissões e ativam a abertura ao iniciar sessão. Depois disso, o app se atualiza sozinho; veja [Atualizações](#atualizações). Para removê-lo, veja [Desinstalação](#desinstalação).

## Primeira abertura

O pika-tools precisa de duas permissões. Na primeira vez, ele abre os ajustes na página Permissões, que guia você passo a passo, e o macOS mostra os próprios avisos. Vá em **Ajustes do Sistema › Privacidade e Segurança** e ative o pika-tools em:

- **Acessibilidade**, para que o app possa alterar um toque de tecla ou um clique antes que ele chegue a outros apps.
- **Monitoração de Entrada**, para que o app possa ver os toques de tecla e os cliques.

O app percebe a mudança em um ou dois segundos, sem precisar reiniciar.

O pika-tools não grava, não guarda e não envia nada do que você digita ou clica. Os eventos são tratados na memória e repassados na hora. A única conexão de rede é a busca por atualizações, que pergunta ao GitHub qual é a versão mais recente.

## Recursos

**Bloquear atalhos com Control.** Control vira uma tecla comum. Os apps ainda veem que ela está pressionada, mas o macOS não a transforma mais em atalhos: Control+Espaço não troca a fonte de entrada, Control+setas não trocam de mesa e Control+clique é um clique normal em vez de abrir um menu de contexto. O clique secundário e o toque com dois dedos funcionam como sempre. Útil em jogos e em sessões de área de trabalho remota, onde o Control tem uma função própria. Você pode listar apps em que o Control deve funcionar como de costume, por exemplo um cliente de área de trabalho remota: o bloqueio não vale para eles.

**Proteger ⌘Q e ⌘W.** ⌘Q e ⌘W sozinhos não fazem nada, então você não encerra um app nem fecha uma janela sem querer. Adicione Shift para fazer isso de propósito: ⇧⌘Q encerra, ⇧⌘W fecha. Funciona em todos os apps. Cada tecla tem a própria chave. Desativado por padrão.

**Trocar de idioma com Option+Shift.** Mantenha Option pressionada e toque em Shift: o macOS passa para a próxima fonte de entrada. Continue segurando Option e toque em Shift de novo para avançar. Mantenha Shift pressionada e toque em Option para voltar. Se nesse meio-tempo você pressionar outra tecla, clicar ou adicionar Command, Control ou Fn, nada muda, então atalhos como Option+Shift+seta funcionam como antes. Desativado por padrão.

**Repetir tecla segurada.** Segure uma tecla e a letra é digitada várias e várias vezes, como no Windows, em vez de aparecer o menu de acentos. Ótimo em jogos e na hora de digitar. Os apps que já estão abertos aplicam isso depois de reiniciados. Desative e o macOS volta ao comportamento de sempre. Desativado por padrão.

**Desativar a aceleração do cursor.** O ponteiro se move exatamente o quanto o mouse se move, não importa a velocidade, como no LinearMouse. Um controle **Velocidade do rastreamento** define a rapidez dele. Funciona só com mouses; o trackpad fica como está. Desative a opção ou encerre o pika-tools e o macOS volta aos próprios ajustes. Desativado por padrão.

**Rolar por linhas.** Cada clique da roda do mouse rola o mesmo número de linhas, por mais rápido que você a gire, como no Windows. Escolha de 1 a 10 linhas por clique, 3 por padrão. A rolagem natural continua como você definiu nos Ajustes do Sistema. Funciona só para mouses, o trackpad continua como está. Desativado por padrão. Ao lado do controle deslizante **Distância por clique**, uma página pequena rola a distância escolhida, e um ponto marca o valor padrão.

Alguns apps e jogos contam a rolagem em pixels exatos: para eles, mude a mesma opção para pixels e escolha de 1 a 200 pixels por clique, 40 por padrão. O controle também mostra que parte da altura da tela isso representa.

**Direção de rolagem para o trackpad e o mouse.** O macOS tem um só ajuste de rolagem natural para o trackpad e o mouse ao mesmo tempo. Ative este recurso e escolha uma direção para cada um: **Natural**, em que a página acompanha os dedos como no iPhone, ou **Clássica**, como no Windows. A escolha do trackpad também vale para a rolagem lateral e para o deslize depois que você tira os dedos. O Magic Mouse rola pelo toque, por isso segue a escolha do trackpad. Escolha o mesmo em cada Mac e a rolagem fica igual em todos, mesmo quando você leva o mouse para outro Mac com o Universal Control. Desativado por padrão. Ao ativar, os dois começam como em Ajustes do Sistema, então nada muda até você escolher outra coisa.

**Botões laterais para voltar e avançar.** Os botões 4 e 5 do mouse voltam e avançam no Safari, no Finder e em outros apps da Apple, no Firefox, no Opera e no ForkLift, como um gesto de deslizar no trackpad. Outros apps, como os IDEs da JetBrains, recebem os botões do jeito que são e os tratam à própria maneira. Se o seu mouse tem esses botões ao contrário, ative **Inverter os botões laterais**. Desativado por padrão.

**Encerrar ao fechar a última janela.** Feche a última janela de um app e o app é encerrado, como no Windows. O Finder continua aberto, assim como os apps com janelas em outras mesas ou no Dock. Você pode listar os apps que nunca devem ser encerrados assim. Desativado por padrão.

**Ocultar com um clique no Dock.** Clique no ícone do Dock do app que você está usando e ele é ocultado. Clique de novo para trazê-lo de volta. Desativado por padrão.

**O botão verde amplia a janela.** Clique no botão verde de uma janela e ela cresce até ocupar a tela, sem entrar em tela inteira. Clique de novo para voltar ao tamanho anterior. Segure ⌥ e o botão funciona como sempre. A tela inteira continua no menu do botão e em ⌃⌘F. Você pode listar os apps em que o botão verde deve funcionar como sempre. Desativado por padrão.

**Novo arquivo no Finder.** Clique com o botão direito numa janela do Finder ou na mesa, escolha **Novo arquivo**, digite um nome e aparece um arquivo vazio, como Novo › Documento de Texto no Windows. .txt por padrão. Desativado por padrão.

**Enter abre arquivos no Finder.** Selecione arquivos numa janela do Finder ou na mesa e pressione Return ou Enter: eles abrem, como no Windows. F2 ou fn F2 renomeia o arquivo selecionado. Em campos de texto, por exemplo enquanto você digita um nome, as teclas funcionam como sempre. Desativado por padrão.

**⌘X corta arquivos no Finder.** Selecione arquivos e pressione ⌘X, abra a pasta de destino e pressione ⌘V: os arquivos são movidos para lá em vez de copiados, como Recortar e Colar no Windows. ⌘C cancela o corte. Desativado por padrão.

**Cópia menor no Finder.** Clique com o botão direito num arquivo no Finder e escolha **Criar cópia menor**. Ao lado aparece uma versão mais leve de uma foto, GIF, PDF ou vídeo, muitas vezes várias vezes menor. Som sem compressão, como WAV ou AIFF, vira um M4A compacto. Se o arquivo não puder ficar menor, nenhuma cópia é criada e o pika-tools avisa. O original continua igual e nada sai do seu Mac. Desativado por padrão.

**Conversão no Finder.** Clique com o botão direito num arquivo no Finder e escolha **Converter para** para salvá-lo em outro formato: uma imagem como JPEG, PNG, HEIC, TIFF ou PDF, um vídeo como MP4, MOV ou só o som, música como M4A, WAV ou AIFF. O original continua igual e nada sai do seu Mac. Liga separadamente da cópia menor. Desativado por padrão.

Cada ferramenta tem a própria chave no menu e nos ajustes. Precisa do Control+C normal de volta? Desative essa ferramenta.

O ícone na barra de menus mostra o estado num relance: uma seta com um clique quando as ferramentas estão funcionando, uma seta riscada quando tudo está desativado e um triângulo de aviso quando uma ferramenta está ativada, mas faltam permissões.

O painel da barra de menus começa com poucas linhas. Você escolhe quais ele mostra: clique no botão de lápis na parte de baixo, marque o que quer ver e clique em **Concluir**. As linhas ocultas continuam funcionando e ficam nos Ajustes. Se o painel não couber na tela, ele rola.

O app segue o idioma do sistema ou o que você escolher nos ajustes. Estão disponíveis os 23 idiomas da lista no topo desta página.

## Manter Ativo

Impede que o Mac entre em repouso enquanto você está longe do teclado: por qualquer tempo de 1 segundo a 365 dias, ou até você desativar. Ative no menu e defina a duração nos ajustes: digite dias, horas, minutos e segundos, use ↑ e ↓ ou clique em uma opção pronta de 15 minutos a 8 horas. O menu mostra quanto tempo falta e quando termina. **Manter a tela ligada** também impede que a tela escureça. Ao encerrar o pika-tools, o Manter Ativo termina.

Em um MacBook você também pode ativar **Funcionar com a tampa fechada**. O macOS não tem um ajuste para isso, então o pika-tools executa `pmset -a disablesleep 1` e pede uma senha de administrador: só um administrador pode mudar como o Mac entra em repouso. O ajuste volta ao normal sozinho quando o Manter Ativo termina, quando você encerra o app ou se ele travar. Se você não digitar a senha, nada muda. Mantenha o Mac bem ventilado com a tampa fechada. **Parar com bateria abaixo de 20%** termina a sessão antes que a bateria acabe.

Manter ativo, os modos de tela e de tampa fechada podem virar um botão na Central de Controle, na barra de menus ou em um widget na mesa pelo app Atalhos, com links que você copia em Ajustes › Manter Ativo.

## Ajustes

Abra os ajustes pelo menu com **Ajustes…** ou ⌘, ou abra o pika-tools de novo pelo Finder, Launchpad ou Spotlight. Enquanto a janela estiver aberta, o app aparece no Dock e no ⌘Tab.

- **Geral**: abrir ao iniciar sessão, aparência (Sistema, Claro ou Escuro), idioma, atualizações e backup: exportar e importar os ajustes como arquivo, ou sincronizá-los pelo iCloud Drive.
- **Manter Ativo**: duração e opções de tela e de tampa.
- **Teclado**: atalhos com Control, troca de idioma, repetição de teclas.
- **Mouse**: aceleração do ponteiro e velocidade do rastreamento, rolagem por linhas, direção de rolagem, botões laterais.
- **Janelas**: ampliar com o botão verde (com uma lista de exceções), proteção de ⌘Q e ⌘W, e encerrar ao fechar a última janela (com uma lista de exceções).
- **Dock**: ocultar com um clique no Dock.
- **Finder**: novo arquivo, cópia menor e conversão, abrir com Return e recortar com ⌘X.
- **Permissões**: o estado das duas permissões, e do iCloud Drive quando a sincronização está ligada, com botões que abrem o lugar certo nos Ajustes do Sistema.
- **Sobre**: versão, links para o histórico de mudanças e para relatar um problema.

Muitos ajustes vêm com uma imagem pequena que mostra o que eles fazem, como um Mac que continua ativo ou uma janela que se esconde atrás do Dock. A imagem muda junto com o interruptor e fica parada quando “Reduzir movimento” está ativado em Ajustes do Sistema.

Cada página tem um botão **Restaurar Padrões…** na parte de baixo. Ele pergunta antes, depois desativa as ferramentas da página e devolve as opções ao que eram, como se o pika-tools nunca tivesse mexido nelas.

**Sincronizar ajustes com o iCloud** mantém o pika-tools igual em todos os seus Macs. Os ajustes ficam na pasta pika-tools do iCloud Drive, e vale a alteração mais recente. Vem desativado por padrão e precisa do iCloud Drive ligado. As permissões não são sincronizadas: cada Mac pede as suas.

## Atualizações

O pika-tools procura novas versões ao abrir e a cada 6 horas. Você pode desativar isso em Ajustes › Geral. Quando sai uma nova versão, aparece no menu o botão **Atualizar para …**: um clique e o app baixa a atualização, instala e reinicia. Você também pode verificar manualmente com **Verificar Agora** em Ajustes › Geral.

Com o Homebrew, você também pode executar `brew upgrade --cask pika-tools`.

A partir da versão 1.3, as permissões continuam valendo depois das atualizações.

## Desinstalação

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Se você instalou com o Homebrew: `brew uninstall --cask --zap pika-tools`.

Os dois encerram o app, removem o app dos itens de início e o apagam. O script também redefine as permissões dele.

## Perguntas frequentes

**Por que são necessárias duas permissões?**
O macOS divide o acesso ao teclado e ao mouse em dois. A Monitoração de Entrada permite que o app veja os eventos, e a Acessibilidade permite que ele os altere. Para bloquear um atalho são necessárias as duas.

**O macOS diz que o app é de um desenvolvedor não identificado.**
O pika-tools é assinado, mas não é notarizado pela Apple. O Homebrew e o script de instalação cuidam disso para você. Se você usou o dmg, abra **Ajustes do Sistema › Privacidade e Segurança** e clique em **Abrir Mesmo Assim**, ou execute:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Funciona em Macs com Intel?**
Sim. É um app universal para Apple Silicon e Intel, com macOS 14 Sonoma ou posterior.

**A permissão está ativada, mas nada funciona.**
Em **Ajustes do Sistema › Privacidade e Segurança**, remova o pika-tools das duas listas com o botão − e adicione-o de novo. A página Permissões nos ajustes do pika-tools tem botões que abrem o lugar certo.

## Como contribuir

Como compilar a partir do código-fonte e publicar versões está explicado em [CONTRIBUTING.md](../../CONTRIBUTING.md). As mudanças estão listadas em [CHANGELOG.md](../../CHANGELOG.md).

## Licença

MIT, © 2026 pikapik. Veja [LICENSE](../../LICENSE).
