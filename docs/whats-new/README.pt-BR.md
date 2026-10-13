<p align="center"><a href="../readme/README.pt-BR.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Novidades do pikapik</h1>
<p align="center">Cada atualização em poucas palavras e uma imagem, da mais recente para a mais antiga.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <b>Português (Brasil)</b> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.47.0"></a>Mesa limpa com um clique

<sub>1.47.0 · 13 de outubro de 2026</sub>

Duas novas opções no pikapik ocultam os ícones da Mesa e mostram os arquivos que o macOS esconde.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/desktop-icons-dark.png"><img src="../media/desktop-icons-light.png" width="340" alt=""></picture>

**Ocultar ícones da Mesa.** Ative antes de uma chamada, uma gravação ou uma captura de tela, e os arquivos e pastas da Mesa somem. Desative e eles voltam para os mesmos lugares. Nada é movido: os arquivos continuam na pasta Mesa do Finder. É o ajuste **Mostrar itens › Na Mesa** de Ajustes do Sistema › Mesa e Dock, só que mais à mão, então os dois sempre combinam. Na versão da Mac App Store, esta linha abre essa página dos Ajustes do Sistema.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hidden-files-dark.png"><img src="../media/hidden-files-light.png" width="340" alt=""></picture>

**Mostrar arquivos ocultos.** Arquivos e pastas que o macOS oculta, como a Biblioteca na sua pasta pessoal ou arquivos cujo nome começa com um ponto, aparecem esmaecidos no Finder e na Mesa. É o mesmo que pressionar ⇧⌘. no Finder, só que você vê de relance se está ativado. Para aplicar a mudança, o Finder reinicia por um instante e abre as janelas e abas de novo. Se o Finder estiver copiando ou movendo arquivos, ele só reinicia quando terminar. Os dois ficam em Ajustes › Finder. Para tê-los no painel da barra de menus, clique no botão de lápis na parte de baixo e marque-os. Na versão da Mac App Store, Ajustes › Finder mostra no lugar as teclas ⇧⌘. do Finder.

---

## <a id="v1.46.1"></a>A página “Permissões” conta tudo

<sub>1.46.1 · 13 de outubro de 2026</sub>

Quando uma ferramenta ainda precisa de uma permissão da lista abaixo, a página agora avisa.

Antes, assim que as duas permissões do topo estavam ativas, a página prometia que todas as ferramentas funcionavam, mesmo que uma ferramenta em “Para alguns recursos” ainda esperasse a permissão dela. Agora ela diz que algumas ferramentas também precisam de uma permissão da lista abaixo, e só promete que tudo funciona quando isso é verdade.

**Experimente:** Ajustes › Permissões

**Corrigido**

- Na versão da Mac App Store, “Agradecer” na página “Sobre” só aparece quando as gorjetas estão prontas para escolher. Antes, uma roda girava enquanto elas carregavam, e a seção sumia se a App Store não respondesse.
- Se o disco encher enquanto um arquivo compactado é extraído, “Espaço insuficiente” agora mostra o espaço realmente livre, depois que os arquivos extraídos pela metade são apagados. Antes, podia dizer que quase nada estava livre.

---

## <a id="v1.46.0"></a>Oculte o app da frente com um botão do mouse

<sub>1.46.0 · 13 de outubro de 2026</sub>

Pressione o botão do meio ou um botão lateral, e o app em que você está sai da frente, do mesmo jeito que com ⌘H.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/hide-app-dark.png"><img src="../media/hide-app-light.png" width="340" alt=""></picture>

Abra Ajustes › Mouse, ative “Ocultar o app atual com um botão do mouse” e pressione o botão que você quer usar. Com “Alterar…” você escolhe outro depois. O app continua aberto, e um clique no ícone dele no Dock o traz de volta. Enquanto você joga com o Modo Jogo ligado, o botão faz no jogo o que sempre fez. Se “Botões laterais para voltar e avançar” também estiver ativado, o botão lateral escolhido passa a ocultar apps. Precisa da permissão “Acessibilidade” e vem desativado por padrão.

Na versão da Mac App Store, ⌘X recorta arquivos no Finder: selecione os arquivos, pressione ⌘X, abra outra pasta e escolha “Mover Itens para Cá” no menu do pikapik ou pressione ⌥⌘V. “Animações” e “Desativar a aceleração do cursor” estão de volta, e a página “Permissões” ganhou uma seção nova, “Restos de apps apagados”. Esta versão não consegue mudar esses ajustes sozinha, então cada linha explica o que mudar e abre o lugar certo nos Ajustes do Sistema. O bichinho agora passeia por toda a largura da tela, acima do Dock.

**Experimente:** Ajustes › Mouse › Ocultar o app atual com um botão do mouse

**Corrigido**

- Os desenhos da página “Mouse” estão nítidos de novo.
- Os recursos de teclado e mouse pedem só a permissão que realmente usam. A maioria só precisa de “Acessibilidade”; antes, também pediam “Monitoração de Entrada” e ficavam cinza sem ela.
- “Trocar de idioma” avisa quando precisa de “Monitoração de Entrada”, e um clique nele abre a página “Permissões”. Antes, ficava ligado sem funcionar.
- “Encerrar ao fechar a última janela” espera você permitir “Monitoração de Entrada”, em vez de fazer o macOS pedir isso quando o pikapik abre.
- No macOS 27, “Acessibilidade” aparece com o novo nome, “Controle do Dispositivo e Acesso a Dados”, como nos Ajustes do Sistema.
- Com o VoiceOver, agora você pode escolher as roupas e os looks do bichinho em “Guarda-roupa” e “Looks” e abrir os prêmios dele em “Prêmios”. Antes, esses quadradinhos não respondiam.

---

## <a id="v1.45.0"></a>Cada app tem seu próprio volume

<sub>1.45.0 · 13 de outubro de 2026</sub>

Diminua uma chamada alta demais, silencie um jogo barulhento e deixe sua música como está.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.45.0/app-volume-dark.png"><img src="../media/whats-new/1.45.0/app-volume-light.png" width="340" alt=""></picture>

Abra Ajustes › Som e ative “Volume dos apps”. Cada app que toca som ganha seu próprio controle deslizante e um botão para silenciar, nos Ajustes e no menu. O volume do seu Mac e dos outros apps não muda, e o pikapik lembra o nível de cada app. Um app que você deixa no volume máximo nunca é tocado.

Para alterar o volume de um app, o pikapik faz o som dele passar por ele mesmo, por isso precisa da permissão “Gravação do áudio do sistema”, que você concede na página “Permissões”. O som só é repassado: não é gravado, salvo nem enviado a lugar nenhum, e o microfone não é usado. Exige macOS 14.2 ou posterior (no macOS 14.0 e 14.1 fica oculto) e vem desativado por padrão.

**Experimente:** Ajustes › Som › Volume dos apps

---

## <a id="v1.44.3"></a>Palavras digitadas no layout errado se corrigem sozinhas

<sub>1.44.3 · 13 de outubro de 2026</sub>

Digite uma palavra no layout de teclado errado, pressione Espaço e o pikapik a digita de novo no layout certo e troca o layout para você.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/layout-fix-dark.png"><img src="../media/layout-fix-light.png" width="340" alt=""></picture>

Ative o recurso em Ajustes › Teclado. Quando uma palavra vira uma sopa de letrinhas, como ghbdtn em vez de привет, o pikapik a digita de novo assim que você pressiona Espaço ou Return, e troca o layout para que a próxima palavra saia certa. Funciona com todos os layouts de teclado que você adicionou no seu Mac, em qualquer um dos seus idiomas.

O texto normal fica exatamente como você digitou. O pikapik só troca uma palavra quando ela não existe em nenhum dos seus idiomas e as mesmas teclas em outro layout formam uma palavra comum. Nomes, erros de digitação e palavras raras ficam como estão, assim como campos de senha, o Terminal e os apps que você escolher.

Alguma palavra passou sem correção ou você quer uma de volta como era? Pressione ⌃⇧Espaço para corrigir a última palavra ou o texto selecionado, e pressione de novo para testar seus outros layouts. Logo após uma correção, as mesmas teclas a desfazem, e o pikapik não vai mais corrigir essa palavra sozinho. Na versão da Mac App Store, selecione o texto e escolha “Corrigir layout do teclado” no menu Serviços.

**Experimente:** Ajustes › Teclado › Corrigir palavras digitadas no layout errado

---

## <a id="v1.44.2"></a>O VoiceOver volta a abrir o menu do pikapik

<sub>1.44.2 · 13 de outubro de 2026</sub>

No macOS 27, você pode abrir de novo o menu do pikapik na barra de menus com o VoiceOver.

Antes, nada acontecia quando você ativava o ícone do pikapik com o VoiceOver ou outro recurso de acessibilidade. Agora o menu abre, e ativar o ícone de novo o fecha, como um clique.

---

## <a id="v1.44.0"></a>Veja qual programa está usando uma porta

<sub>1.44.0 · 13 de outubro de 2026</sub>

Uma nova página Portas nos Ajustes mostra qual programa ocupa cada porta do seu Mac e libera a porta quando você precisa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/ports-dark.png"><img src="../media/ports-light.png" width="340" alt=""></picture>

Quando um programa diz que a porta dele já está em uso, abra Ajustes › Portas. Ali aparece cada programa que ocupou uma porta, com o ícone, as portas que ele usa e se outros dispositivos da sua rede podem se conectar. Digite o número de uma porta para descobrir quem a está usando ou para ver que ela está livre.

Clique em uma linha para ver os endereços que abrem no navegador, o arquivo do programa, o comando que o iniciou, a pasta dele e o número do processo. “Liberar” pede ao programa que se feche, para que ele possa salvar o trabalho. Se ele não fechar, o pikapik oferece forçar o encerramento. Cada passo pede sua confirmação antes.

Partes do macOS e programas de outros usuários ficam intocados. Para Receptor de AirPlay, Compartilhar Arquivos, Compartilhar Tela e Acesso Remoto, o pikapik mostra qual chave nos Ajustes do Sistema libera a porta. Na versão da Mac App Store, “Liberar” mostra o programa, copia um comando que o encerra no Terminal ou abre o Monitor de Atividade.

---

## <a id="v1.43.0"></a>Veja o que roda em segundo plano

<sub>1.43.0 · 13 de outubro de 2026</sub>

O pikapik agora mostra tudo o que começa sozinho e qual app adicionou cada coisa, e desliga suas próprias tarefas sem apagar nada.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.43.0/background-dark.png"><img src="../media/whats-new/1.43.0/background-light.png" width="340" alt=""></picture>

Nos Ajustes, a nova página Tarefas em Segundo Plano lista os apps que abrem ao iniciar sessão, os serviços em segundo plano, os ajudantes guardados dentro de apps e as sobras de apps removidos. Em cada tarefa você vê qual app a adicionou, se ela está rodando agora e onde fica o arquivo dela. Um clique mostra o arquivo no Finder.

Suas próprias tarefas desligam e religam com um botão. Nada é apagado. Nas tarefas para todos os usuários e para o Mac inteiro, o botão abre Itens de Início em Ajustes do Sistema.

Na versão da Mac App Store, a página mostra as tarefas, e os botões dela abrem Itens de Início.

---

## <a id="v1.42.0"></a>Veja o quanto o Mac está quente por dentro

<sub>1.42.0 · 13 de outubro de 2026</sub>

Uma nova página Temperatura nos Ajustes mostra a temperatura do processador, dos gráficos, da memória, do armazenamento, da bateria e do Wi-Fi, e diz em palavras simples se está tudo bem.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/temperatures-dark.png"><img src="../media/temperatures-light.png" width="340" alt=""></picture>

Abra Ajustes › Temperatura. No alto, uma só palavra resume tudo: “Normal”, “Um pouco quente”, “Quente” ou “Muito quente”, e uma linha curta logo abaixo diz se o Mac está funcionando na velocidade máxima ou ficando mais lento para esfriar. Mais abaixo, cada componente que o Mac consegue medir tem sua própria linha com a temperatura e uma barra colorida: verde se está tudo bem, amarela se está um pouco quente e laranja se está quente, de acordo com o que é normal para aquele componente.

Quer ficar de olho nela? Clique no lápis na parte de baixo do menu do pikapik e marque “Temperatura”. O menu passa a mostrar a mesma palavra e a temperatura do processador, e um clique na linha abre a página.

As temperaturas são atualizadas a cada dois segundos, mas só enquanto a página ou o menu estão abertos, então nada é verificado em segundo plano. O pikapik só lê as temperaturas: não precisa de senha e não muda nada.

**Corrigido**

- Se você escolheu quais linhas o menu do pikapik mostra, a linha “Manter o Dock em uma só tela” não aparece mais sozinha nele. Para mostrá-la, clique no lápis e marque-a.
- Quando você fecha os Ajustes, o pikapik agora para na hora de verificar as ventoinhas e a bateria, em vez de continuar em segundo plano.

---

## <a id="v1.41.1"></a>O controle das ventoinhas não pede mais sua senha

<sub>1.41.1 · 13 de outubro de 2026</sub>

O ajudante que define a velocidade das ventoinhas agora se atualiza junto com o pikapik, então as novas versões não pedem mais a senha de administrador.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Esta atualização pede a senha uma última vez. Se você usa o controle das ventoinhas, abra Ajustes › Permissões, clique em “Permitir” ao lado de “Controle das ventoinhas” e digite a senha. Daí em diante, o pikapik atualiza o ajudante sozinho e só aceita um ajudante que realmente venha do pikapik.

**Corrigido**

- Em Ajustes do Sistema › Geral › Itens de Início, o ajudante das ventoinhas agora aparece como pikapik, com o ícone do app.

---

## <a id="v1.41.0"></a>Veja como está a sua bateria

<sub>1.41.0 · 13 de outubro de 2026</sub>

Uma nova página Bateria nos Ajustes mostra o quanto a bateria está desgastada, o que a carrega e como fazer com que ela dure mais.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/battery-dark.png"><img src="../media/battery-light.png" width="340" alt=""></picture>

Abra Ajustes › Bateria. Você vê a carga e o que está acontecendo com a bateria agora, a condição dela, a capacidade máxima em comparação com a bateria nova e o número de ciclos que ela já fez dos 1.000 para os quais foi projetada.

Quando o Mac está conectado, a página mostra o adaptador de energia e a potência dele e, durante a carga, também a potência de carga, ou seja, o que está entrando na bateria agora. Quando o Mac funciona com a bateria, a página mostra quanta energia ele está usando agora.

As dicas no fim ajudam a bateria a durar mais, e “Ajustes da Bateria…” abre Bateria nos Ajustes do Sistema, onde você escolhe como o macOS a carrega. A página não altera nada e não precisa de nenhuma permissão, nem na versão da Mac App Store. Ela só aparece em Macs com bateria.

**Corrigido**

- Ao remover o pikapik com o Homebrew, agora também é desativado “Abrir ao Iniciar Sessão”, e os ajustes do sistema alterados pelo app, como animações, repetição de teclas e cantos ativos, voltam ao que eram. Se o pikapik vinha se atualizando sozinho, execute uma vez brew upgrade --cask pikapik antes de removê-lo.

---

## <a id="v1.40.2"></a>Atualizar com o Homebrew não reinicia mais o Dock

<sub>1.40.2 · 13 de outubro de 2026</sub>

Quando você atualiza o pikapik com o Homebrew, o Dock não some mais por um instante.

A atualização para esta versão ainda pode reiniciar o Dock uma última vez, porque essa etapa ainda é feita pela versão que você tinha antes. As próximas atualizações não mexem mais nele.

---

## <a id="v1.40.1"></a>Um clique no Dock guarda as janelas

<sub>1.40.1 · 13 de outubro de 2026</sub>

Clique no ícone do Dock do app em que você está trabalhando, e todas as janelas dele são minimizadas no Dock. Clique de novo, e todas voltam.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.40.1/dock-minimize-dark.png"><img src="../media/whats-new/1.40.1/dock-minimize-light.png" width="340" alt=""></picture>

Abra Ajustes › Dock e ative “Minimizar ou ocultar com um clique no Dock”. As janelas voltam na mesma ordem, com aquela em que você estava trabalhando por cima. Um clique em outro app, manter um ícone pressionado para abrir o menu dele e arrastar ícones funcionam como antes.

Prefere ocultar o app inteiro, como com ⌘H? Abaixo da chave, mude “Um clique no ícone” para “Oculta o app”. Se você já ocultava apps com um clique no Dock, nada muda para você. A chave precisa da permissão “Acessibilidade”, não está na versão da Mac App Store e vem desativada por padrão.

---

## <a id="v1.40.0"></a>O Dock fica em uma só tela

<sub>1.40.0 · 13 de outubro de 2026</sub>

O Dock não pula mais para outra tela quando o ponteiro empurra a borda dessa tela: ele fica onde você o colocou.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Abra Ajustes › Dock e ative “Manter o Dock em uma só tela”. O Dock passa a ficar na tela dele, embaixo ou na lateral, e os cantos ativos continuam funcionando. Não é preciso nenhuma permissão, nem na versão da Mac App Store.

Para mover o Dock de propósito, mantenha ⌥ pressionada e empurre o ponteiro contra a borda da outra tela. O Dock passa para essa tela e, dali em diante, fica nela.

Uma segunda chave, “Trazer o Dock de volta”, devolve o Dock à tela dele automaticamente depois do repouso ou quando as telas mudam. Ela precisa da permissão “Acessibilidade” e não está na versão da Mac App Store. As duas chaves vêm desativadas por padrão.

---

## <a id="v1.39.4"></a>O botão vermelho não trava mais os arquivos compactados

<sub>1.39.4 · 13 de outubro de 2026</sub>

Antes, se você fechasse a janela da senha pelo botão vermelho, o pikapik parava de abrir e criar arquivos compactados até ser reiniciado. Isso foi corrigido.

Agora o botão vermelho na janela da senha e na janela de um novo arquivo compactado funciona exatamente como “Cancelar”, e o próximo arquivo abre na hora. O VoiceOver agora lê o botão de atualização em Ajustes › Sobre pelo próprio nome.

---

## <a id="v1.39.3"></a>Seu bichinho segue o seu ritmo

<sub>1.39.3 · 13 de outubro de 2026</sub>

Enquanto você digita, o bichinho fica animado e anda todo saltitante. Quando você se afasta do Mac, ele fica com sono, se senta e cochila.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.3/pet-rhythm-dark.png"><img src="../media/whats-new/1.39.3/pet-rhythm-light.png" width="340" alt=""></picture>

Depois de uns 40 segundos sem você tocar no teclado nem no mouse, os olhinhos dele começam a pesar, e passado um minuto e meio, ele já está dormindo pesado, com letrinhas z subindo no ar. Aperte uma tecla ou mexa o mouse, e ele acorda, se levanta e volta a andar. Enquanto cochila, ele fica quietinho e gasta menos energia.

O pikapik nunca olha o que você digita. Ele só verifica quanto tempo passou desde a última tecla pressionada ou o último movimento do mouse, do mesmo jeito que o macOS faz antes de escurecer a tela, então não precisa de nenhuma permissão. Prefere que seu bichinho esteja sempre animado? Desligue “Segue o seu ritmo” nos ajustes do bichinho.

**Experimente:** Ajustes › Bichinho › Segue o seu ritmo

---

## <a id="v1.39.2"></a>Os ajustes sincronizados agora ficam numa pasta pikapik

<sub>1.39.2 · 13 de outubro de 2026</sub>

Se você sincroniza os ajustes com o iCloud, eles agora ficam no iCloud Drive, numa pasta chamada pikapik em vez de pika-tools, e o pikapik os move para lá sozinho.

<img src="../media/icon.png" width="128" height="128" alt="">

Você não precisa fazer nada: seus ajustes continuam iguais, e a pasta antiga some depois que eles são movidos. Se você colocou arquivos seus nela, ela fica onde está. Se você sincroniza vários Macs, atualize o pikapik em cada um para que continuem compartilhando os ajustes.

**Corrigido**

- Remover o pikapik por completo com o Homebrew (brew uninstall --zap) agora também apaga a lista de apps removidos recentemente.
- Os posts anteriores desta página agora chamam o app de pikapik.

---

## <a id="v1.39.1"></a>A barra de título de sempre nas janelas de arquivos compactados

<sub>1.39.1 · 13 de outubro de 2026</sub>

As janelas de arquivos compactados voltaram a ter a barra de título de sempre do macOS, com três botões redondos à esquerda.

Você pode arrastar uma janela pela parte de cima, como em qualquer lugar do Mac. Na janela de um novo arquivo compactado e na janela da senha, o botão vermelho fecha a janela sem criar nem descompactar nada. Os botões que não têm função em uma janela ficam cinza. A janela que mostra o andamento de uma cópia menor ou da conversão de um arquivo também ganhou esses botões. Agora a chave “Abrir arquivos compactados com este app” lembra qual app abria os arquivos ZIP e 7Z antes e os devolve a ele quando você a desativa.

---

## <a id="v1.39.0"></a>Novas janelas de arquivos compactados e a senha digitada duas vezes

<sub>1.39.0 · 13 de outubro de 2026</sub>

Quando você põe senha em um novo arquivo compactado, agora a digita duas vezes, para que um erro de digitação não tranque você fora dos seus próprios arquivos.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Embaixo dos campos aparece uma linha verde quando as senhas coincidem, ou vermelha quando não, e “Criar” espera até que elas sejam iguais.

Todas as janelas de arquivos compactados ganharam um visual novo: um ícone grande, um único botão para ativar a senha e uma linha curta que diz se os nomes dos arquivos continuam visíveis, como no ZIP, ou também ficam ocultos, como no 7Z. No macOS 26 os botões são de Liquid Glass.

Instalar também ficou mais fácil: o comando no topo da página do pikapik no GitHub não precisa de mais nada no seu Mac. Ele só instala o pikapik se o download for assinado pelo desenvolvedor e tiver passado na verificação de malware da Apple.

---

## <a id="v1.38.2"></a>Atualizações mais seguras ao lado da versão da App Store

<sub>1.38.2 · 12 de outubro de 2026</sub>

Se o pikapik da App Store também estiver no seu Mac, a versão do GitHub agora se atualiza no próprio lugar e não mexe na versão da App Store.

Antes, se a versão do GitHub ainda tinha o nome antigo, pika-tools, e não estava instalada com o Homebrew, a atualização não era instalada, a versão da App Store abria no lugar dela e a abertura do pikapik ao iniciar a sessão era desativada.

---

## <a id="v1.38.1"></a>Um menu do Finder mais confiável

<sub>1.38.1 · 12 de outubro de 2026</sub>

Os itens que o pikapik adiciona ao Finder com o botão direito não somem mais quando você conecta um disco, abre uma imagem de disco, reativa o Mac ou muda para o Finder.

Em casos raros, o assistente que os mostra fechava justamente nesse momento.

---

## <a id="v1.38.0"></a>Abra e crie arquivos compactados no Finder

<sub>1.38.0 · 12 de outubro de 2026</sub>

Os novos “Arquivos compactados no Finder” abrem RAR e outros arquivos que o macOS não abre, e criam ZIP e 7Z com o botão direito.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Abra Ajustes › Finder e ative “Arquivos compactados no Finder”. Clique com o botão direito em um arquivo compactado e escolha “Extrair”, e os arquivos dele aparecem ao lado. Clique com o botão direito em qualquer outro arquivo ou pasta e escolha “Criar arquivo compactado…” para gerar um ZIP, 7Z, TAR.GZ ou TAR.XZ. ZIP e 7Z podem ter senha, e qualquer arquivo compactado pode ser dividido em partes, por exemplo de 15 MB para e-mail. Um ZIP criado assim não tem arquivos de serviço ocultos e mantém legíveis os nomes em qualquer idioma.

O pikapik também abre o que o macOS não abre: RAR, até dividido em vários arquivos, 7Z protegido por senha, ZIPX, CAB, LZH, ARJ, ZST, WIM e mais. Clicar duas vezes neles os abre no pikapik. Os nomes de arquivos em ZIPs antigos, por exemplo em cirílico, japonês ou chinês, agora aparecem legíveis. A opção “Abrir arquivos compactados com este app” também entrega ZIP e 7Z ao pikapik, enquanto TAR e GZ ficam com o app de arquivos compactados do sistema, que já cuida bem deles.

Uma janela pede a senha, “Parar” cancela qualquer tarefa e, de um arquivo compactado danificado, o pikapik tira o que ainda dá para ler. Antes de extrair um arquivo compactado que cresceria até um tamanho enorme, o pikapik pergunta, e arquivos que tentam gravar fora da própria pasta são bloqueados. Não está na versão da Mac App Store. Selecione um arquivo compactado e aperte Espaço para ver o que há dentro.

---

## <a id="v1.37.3"></a>A etiqueta de FPS pede permissão no lugar certo

<sub>1.37.3 · 12 de outubro de 2026</sub>

A Gravação de Tela para a etiqueta de FPS agora é permitida na página Permissões, junto com todas as outras permissões.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Para contar os quadros de um jogo, “Mostrar FPS” pode precisar da Gravação de Tela. Antes, o pikapik pedia isso na própria página Jogos. Agora ela fica junto com todas as outras permissões: quando “Mostrar FPS” precisa dela, uma linha “Gravação de Tela” aparece em Ajustes › Permissões, e você clica em “Permitir” ali.

Na página Jogos você agora vê só a linha de sempre embaixo da chave: “Precisa de uma permissão. Clique para permitir.” O botão “Permitir” dela leva direto à linha “Gravação de Tela”. Ligar “Mostrar FPS” não abre mais uma pergunta sozinho, e o pikapik continua sem pedir nada enquanto você joga.

---

## <a id="v1.37.2"></a>Verificado pela Apple

<sub>1.37.2 · 12 de outubro de 2026</sub>

O pikapik agora é assinado por um desenvolvedor verificado da Apple e checado pela Apple. Por isso o macOS não avisa mais na primeira vez que você o abre.

Depois desta atualização, o macOS pode pedir de novo as permissões que você deu ao pikapik, como Acessibilidade, Monitoramento de entrada ou Acesso total ao disco. Permita-as mais uma vez em Ajustes do Sistema › Privacidade e segurança. Se você usa o controle dos ventiladores, permita-o de novo nos ajustes do pikapik, e o macOS pedirá a senha uma vez.

---

## <a id="v1.37.1"></a>A etiqueta de FPS acompanha seu jogo sem atraso

<sub>1.37.1 · 12 de outubro de 2026</sub>

Mova a janela do jogo e a etiqueta de FPS agora se move junto com ela.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Antes, a etiqueta só alcançava uma janela em movimento cerca de uma vez por segundo, então ficava para trás. Agora ela confere a janela a cada quadro da tela e nunca fica mais do que alguns milésimos de segundo atrás. Quando a janela está parada, ela confere com menos frequência, por isso quase não pesa no seu Mac enquanto você joga. Ela também não pula mais para outro lugar quando parte da janela passa da borda da tela.

Se um jogo calmo como xadrez mostra 0, está tudo certo: jogos assim só desenham uma nova imagem quando algo se move. O número sobe enquanto uma peça desliza e volta a 0 quando o tabuleiro fica parado.

---

## <a id="v1.37.0"></a>Veja a fluidez do seu jogo

<sub>1.37.0 · 12 de outubro de 2026</sub>

O novo “Mostrar FPS” coloca um pequeno contador em um canto do seu jogo, e você vê na hora o quanto ele roda com fluidez.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Abra Ajustes › Jogos e ative “Mostrar FPS”. Enquanto o Modo Jogo estiver ligado, uma pequena etiqueta escura com um número aparece em um canto de qualquer jogo. FPS significa quadros por segundo: quantas imagens o jogo desenha a cada segundo, e quanto maior o número, mais fluido é o jogo. Clique em um canto da imagem acima da chave para escolher onde a etiqueta fica.

Os cliques atravessam a etiqueta, que acompanha a janela do jogo. Um traço significa que os primeiros quadros ainda não chegaram, e um 0 esmaecido, que o jogo parou de desenhar. “Mostrar FPS” vem desligado até você ligar.

No macOS 27, o próprio macOS conta a maioria dos jogos, então não é preciso nenhuma permissão. Alguns jogos, em geral os mais antigos, só podem ser contados pela gravação de tela, e então o número não pode passar da taxa de atualização da tela. No macOS 14 a 26 e na versão da Mac App Store, todos os jogos são contados assim, por isso, ao ligar “Mostrar FPS”, o pikapik pede “Gravação de Tela”. Nenhuma imagem é guardada nem enviada.

---

## <a id="v1.36.0"></a>Remova apps sem medo

<sub>1.36.0 · 12 de outubro de 2026</sub>

O novo Remover apps tira um app com todos os arquivos e devolve tudo se você mudar de ideia.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Abra Ajustes › Remover apps e escolha um app, ou solte um sobre a imagem. O pikapik mostra tudo o que o app guarda no seu Mac, com o motivo de cada arquivo. Os arquivos que claramente pertencem ao app vêm marcados, e os que só talvez tenham relação, não. Clique em “Mover para o Lixo” e tudo vai para o Lixo, então nada é apagado de vez.

Mudou de ideia? Clique em “Devolver” e tudo volta para onde estava. As dez últimas remoções ficam em “Removidos recentemente” enquanto os arquivos delas estiverem no Lixo. “Redefinir app” mantém o app e remove só os dados salvos, os ajustes e os arquivos temporários dele, caso ele dê problema.

Moveu um app para o Lixo por conta própria? A página lista esses apps e os arquivos que eles deixaram, e você pode ligar uma chave que oferece limpeza sempre que um app for para o Lixo. Nada é removido até você escolher. Para ver tudo, a página precisa do Acesso Total ao Disco.

---

## <a id="v1.35.0"></a>Vista o seu bichinho

<sub>1.35.0 · 12 de outubro de 2026</sub>

O bichinho agora tem um guarda-roupa, e você ganha peças novas enquanto vocês brincam juntos.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Abra Ajustes › Bichinho e escolha o que o bichinho vai vestir: chapéus, óculos, cachecóis, camisetas, sapatos, capas e até asas. Ele coloca na hora. Algumas peças são grátis e o resto são prêmios que chegam enquanto vocês brincam juntos: pegue o bichinho e jogue para o alto, chute a bola, veja ele subir nas janelas e conversar, ou simplesmente faça companhia a ele dia após dia. Quando você ganhar um prêmio, o bichinho avisa.

Looks prontos vestem o bichinho da cabeça aos pés com um clique: mago, pirata, astronauta, super-herói, rei e mais. Um look fica pronto quando você ganha todas as peças dele.

Só números simples são guardados, como passos, arremessos e dias juntos. Eles ficam no seu Mac, nada é enviado para lugar nenhum e você pode apagá-los quando quiser em Ajustes › Bichinho.

---

## <a id="v1.34.0"></a>Mouse e trackpad nos jogos

<sub>1.34.0 · 12 de outubro de 2026</sub>

Gestos de deslizar, pinça e cantos ativos não tiram mais você do jogo, assim como os atalhos de teclado.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

Em Ajustes › Jogos › Mais ajustes do jogo há um grupo chamado “Mouse e trackpad”. Ele mostra só o que está ativado no macOS no seu Mac, com os nomes da Apple e um pequeno desenho para cada item: atalhos em um botão do mouse, deslizar entre mesas e apps em tela inteira, Mission Control e App Exposé, pinça para apps e afastar os dedos para a mesa, deslizar a partir da borda direita para a Central de Notificações e cada canto ativo com a ação que ele executa. Enquanto um jogo está em primeiro plano, eles ficam pausados, então um deslize acidental ou um toque no canto da tela não tira você do jogo. Os gestos dentro do jogo continuam funcionando. Cada item pode ser configurado para funcionar como de costume.

---

## <a id="v1.33.2"></a>Grupos de atalhos abrem na hora

<sub>1.33.2 · 11 de outubro de 2026</sub>

Até o grupo mais longo de atalhos do sistema abre logo, e cada linha tem um nome claro.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Antes, a janela de ajustes travava por um instante ao abrir um grupo com dezenas de linhas, porque todas as linhas e suas prévias animadas eram montadas de uma vez. Agora só são montadas as linhas visíveis e algumas próximas. As linhas “Ação do sistema” com um número também sumiram: Ditado, Siri e as teclas de brilho e zoom mostram o nome real, e as ações que o macOS não nomeia ficam ocultas, mas continuam pausadas nos jogos como antes.

---

## <a id="v1.33.1"></a>Grupos de atalhos abrem sem travar

<sub>1.33.1 · 11 de outubro de 2026</sub>

A página Jogos continua fluida ao abrir uma lista longa de prévias.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Abrir um grupo de atalhos de teclado do sistema travava a janela de ajustes por até três segundos, porque cada linha com sua prévia era calculada várias vezes. Agora cada linha é calculada uma única vez, então os grupos abrem quase na hora.

---

## <a id="v1.33.0"></a>Todas as permissões em um só lugar

<sub>1.33.0 · 11 de outubro de 2026</sub>

Ajustes › Permissões agora lista tudo o que o pikapik usa e deixa você retirar qualquer permissão.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Ajustes › Permissões agora mostra cada permissão que o pikapik usa, de Acessibilidade e Monitoramento de Entrada até Controle das ventoinhas, Extensões do Finder, iCloud Drive e Acesso Total ao Disco. Cada linha diz em uma frase para que serve, com um sinal de verificação verde quando está ativa e uma cruz laranja quando falta.

Cada linha tem um só botão: Permitir quando falta, Desligar quando está ativa. Assim você retira qualquer permissão ali mesmo, sem procurar em Ajustes do Sistema. Em Acessibilidade e Monitoramento de Entrada, o pikapik pergunta antes e depois reinicia sem elas.

Uma ferramenta que precisa de uma permissão que você ainda não deu aparece em cinza. Clique nela e Permissões abre com a linha certa em destaque, pronta para um clique em Permitir.

**Experimente:** Abra Ajustes › Permissões e olhe cada linha. Clique em uma ferramenta em cinza para ir direto à permissão de que ela precisa.

---

## <a id="v1.32.2"></a>Instalação mais segura e atualizações que nunca perdem o app

<sub>1.32.2 · 11 de outubro de 2026</sub>

Uma rodada de correções para instalar, atualizar e desinstalar com mais segurança.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

O assistente dos ventiladores agora é instalado com mais cuidado e verificado antes de iniciar. Se uma atualização não puder ser copiada, o seu pikapik atual continua onde está. Ao desinstalar, o assistente dos ventiladores também é removido e a sua configuração de repetição de teclas, os cantos do Dock e os atalhos do sistema voltam ao que eram.

Teclas seguradas não ficam mais presas quando uma ferramenta reinicia, e ao desligar “Repetir uma tecla segurada” você recupera a sua própria configuração do menu de acentos. O bichinho descansa enquanto a tela está em repouso ou bloqueada, e uma cópia de archive.tar.gz agora se chama archive 2.tar.gz.

---

## <a id="v1.32.1"></a>A velocidade manual dos ventiladores vale já na primeira vez

<sub>1.32.1 · 11 de outubro de 2026</sub>

Escolher Manual em Ventiladores não volta mais para Automático.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Às vezes o primeiro toque em Manual devolvia os ventiladores para Automático com um aviso de segurança, e só o segundo funcionava. Agora o Manual vale já na primeira tentativa.

Se um ventilador sair do modo Manual sozinho, o pikapik o devolve para Automático de verdade, então o que você vê sempre corresponde ao que o seu Mac está fazendo.

Você não precisa permitir nada de novo. Atualize e pronto.

**Experimente:** Abra Ajustes › Ventiladores e escolha Manual.

---

## <a id="v1.32.0"></a>Veja a que velocidade suas ventoinhas giram

<sub>1.32.0 · 11 de outubro de 2026</sub>

Uma nova aba Ventoinhas mostra cada ventoinha ao vivo e deixa você escolher a velocidade.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

As ventoinhas agora têm uma aba própria em Ajustes e uma linha no menu. Você vê em tempo real a que velocidade cada uma está girando, com uma ventoinha pequena girando junto.

Deixe em Auto e o Mac decide, como sempre. Ou escolha Manual e arraste um único controle para definir a velocidade que quiser. Na primeira vez, você permite uma única vez com a senha de administrador, e pronto.

Tudo foi feito para ser seguro. As ventoinhas voltam para Auto quando você sai do pikapik, quando o Mac entra em repouso, se o pikapik fechar por um erro ou quando o Mac esquenta demais.

**Experimente:** Abra Ajustes › Ventoinhas e veja a velocidade. Escolha Manual para testar o controle.

---

## <a id="v1.31.4"></a>Detalhes quando você precisa

<sub>1.31.4 · 11 de outubro de 2026</sub>

Uma página de jogos mais tranquila e uma única busca.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Cada modo explica seu efeito na lista suspensa. Quando ela está fechada, só o nome escolhido fica na página.

As descrições que repetem o nome da ação foram removidas. As informações adicionais úteis continuam disponíveis.

A busca global encontra ações do sistema por nome, função e teclas. Um resultado abre e destaca o ajuste exato.

**Experimente:** Encontre uma ação na busca global e abra sua lista de modos.

---

## <a id="v1.31.3"></a>Um só estilo para os ajustes de jogo

<sub>1.31.3 · 11 de outubro de 2026</sub>

Prévias uniformes e escolhas mais claras.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Cada atalho agora tem a mesma prévia ampla das proteções do jogo e das outras páginas de ajustes. A descrição, os controles e a explicação da opção escolhida ficam abaixo.

«Seguir as regras do Modo de Jogo». Um atalho breve muda o idioma sem menu. As teclas de jogo mantidas pressionadas evitam trocas acidentais.

«Desativar nos jogos». Esta ação do macOS fica desativada quando o jogo está em primeiro plano. Ao sair, ela funciona como antes. «Permitir nos jogos». O macOS executa a ação normalmente, mesmo que abra uma janela ou tire o foco do jogo.

**Experimente:** Abra Mais ajustes de jogo, expanda os controles do sistema e escolha como uma ação funciona enquanto você joga.

---

## <a id="v1.31.2"></a>Ajustes de jogo mais claros

<sub>1.31.2 · 11 de outubro de 2026</sub>

Ajuste a proteção e explore os atalhos do Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Oito temas claros substituem as pastas repetidas. Cada título tem nome, explicação, ícone e contagem. Clique em qualquer ponto da linha para abrir a seção.

Cada ação explica o que faz ao lado da prévia animada. As teclas atuais e o comportamento nos jogos têm sua própria linha. A busca também encontra descrições.

As teclas não definidas têm um link claro para os Ajustes do Sistema. As proteções gerais do jogo ficam em uma seção separada, e suas escolhas são preservadas.

**Experimente:** Abra Mais ajustes de jogo, expanda um tema e compare a descrição de uma ação com a prévia.

---

## <a id="v1.31.1"></a>Gestos de idioma nos jogos

<sub>1.31.1 · 11 de outubro de 2026</sub>

Simples por padrão, com o catálogo completo do sistema quando precisar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

O gesto de idioma do pikapik funciona no jogo mesmo quando os atalhos de idioma do macOS não estão definidos ou estão desativados.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automático pausa ações que abrem janelas ou mudam o foco. Um atalho de idioma rápido e intencional troca a fonte sem janela do sistema. Teclas de movimento mantidas têm prioridade para que correr e pular não troquem o idioma por acidente.

Cada ação pode ser ajustada no catálogo com busca. O idioma pode mudar em segundo plano; outras ações podem ser pausadas ou permitidas normalmente. As escolhas sincronizam. Outros apps observando o teclado aparecem à parte. Forçar Encerrar continua disponível.

**Experimente:** Segure ⌥ e toque em ⇧: próximo idioma. Segure ⇧ e toque em ⌥: anterior

---

## <a id="v1.31.0"></a>O Modo Jogo conhece os atalhos do seu Mac

<sub>1.31.0 · 11 de outubro de 2026</sub>

Simples por padrão, com o catálogo completo do sistema quando precisar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Ligue o Modo Jogo e jogue. Mais ajustes do jogo tem o catálogo publicado pelo Mac, com teclas atuais e uma prévia animada para cada ação.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automático pausa ações que abrem janelas ou mudam o foco. Um atalho de idioma rápido e intencional troca a fonte sem janela do sistema. Teclas de movimento mantidas têm prioridade para que correr e pular não troquem o idioma por acidente.

Cada ação pode ser ajustada no catálogo com busca. O idioma pode mudar em segundo plano; outras ações podem ser pausadas ou permitidas normalmente. As escolhas sincronizam. Outros apps observando o teclado aparecem à parte. Forçar Encerrar continua disponível.

**Experimente:** Abra os ajustes adicionais, busque um atalho de captura ou idioma e compare a prévia com e sem proteção.

---

## <a id="v1.30.14"></a>Links de atalhos abrem sem travar

<sub>1.30.14 · 11 de outubro de 2026</sub>

Clicar em um atalho desligado não fecha mais o pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Na página Jogos, você pode clicar em um atalho mesmo sem teclas atribuídas. Ajustes do Sistema abre com segurança.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Antes pikapik podia ler duas vezes a mesma linha que mudava enquanto a janela abria. Se o texto sumisse entre as leituras, o app travava.

Cada linha agora é lida uma vez. O texto ausente é ignorado. A correção também vale para links de atalhos em outras páginas.

**Experimente:** Clique em um atalho desligado na página Jogos.

---

## <a id="v1.30.13"></a>Segure Control e continue jogando

<sub>1.30.13 · 10 de outubro de 2026</sub>

Control não deixa mais a troca de idioma roubar o Espaço do jogo.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Segure Control para correr e pressione Espaço para pular. No Modo Jogo, a troca de idioma com Control+Espaço ou Control+Option+Espaço fica pausada.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Outros atalhos do macOS com Control, ou Shift e Option sem Command, também ficam pausados, incluindo suas próprias escolhas. Pressionar, soltar e manter teclas acontece junto no jogo.

O gesto de idioma do pikapik e os atalhos de saída com modificadores de jogo também não atrapalham. Ao sair do jogo, os atalhos do sistema voltam exatamente como estavam.

**Experimente:** Segure Control, mova-se e pressione Espaço várias vezes. Depois saia do jogo e troque o idioma como sempre.

---

## <a id="v1.30.12"></a>Arraste o jogo do Monitor de Atividade

<sub>1.30.12 · 10 de outubro de 2026</sub>

O Modo Jogo aceita processos arrastados do Monitor de Atividade.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Encontre o processo do jogo e arraste a linha para Seus jogos em Ajustes → Jogos.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Jogos Java funcionam mesmo sem um ícone comum no Dock. Antes essas linhas eram ignoradas porque contêm o número e nome do processo, não um arquivo.

O jogo fica salvo para próximas vezes. Minecraft aparece com seu nome. O número e nome precisam corresponder a um processo em execução.

**Experimente:** Arraste a linha java do Minecraft aberto para Seus jogos.

---

## <a id="v1.30.11"></a>Adicione seu jogo enquanto ele está aberto

<sub>1.30.11 · 10 de outubro de 2026</sub>

Os jogos abertos aparecem primeiro ao adicionar um jogo.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Abra Ajustes → Jogos → Adicionar um jogo e clique no jogo em execução. Jogos que usam Java e outros ambientes também aparecem, mesmo sem arquivo .app. Minecraft aparece como Minecraft em vez de java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Os apps do Dock agora têm sua própria lista expansível, para você encontrar logo o jogo aberto.

Outro… e arrastar e soltar também aceitam o arquivo executável do jogo, além dos apps. Depois de adicionar, o Modo Jogo liga quando você muda para o jogo.

**Experimente:** Deixe o jogo aberto, escolha Adicionar um jogo e clique no ícone. Sem procurar pastas.

---

## <a id="v1.30.10"></a>O bichinho fica à vista quando pula

<sub>1.30.10 · 10 de outubro de 2026</sub>

O bichinho não some mais atrás das janelas quando pula numa tela sem Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, se o Dock estava em outra tela ou oculto, o bichinho pulava atrás das janelas e sumia até aterrissar. Agora, assim que sai do chão, ele aparece na frente das janelas em qualquer tela, com ou sem Dock. A bola também.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Uma janela que só encosta na borda do bichinho não o esconde mais durante o pulo. Ele fica atrás de uma janela só quando ela o cobre de verdade, como um vídeo que você está vendo.

No chão, o bichinho e a bola passeiam atrás das suas janelas, como antes.

**Experimente:** Deixe o Dock se ocultar ou leve-o para outra tela e aperte Espaço ao lado de uma janela. O bichinho pula na frente dela.

---

## <a id="v1.30.9"></a>A tela cheia é sua, e a bola joga limpo

<sub>1.30.9 · 10 de outubro de 2026</sub>

O bichinho não aparece mais num vídeo em tela cheia, e a bola não bate mais em coisas que não estão lá.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, enquanto você assistia a um vídeo em tela cheia, o bichinho às vezes aparecia. Agora o pikapik pergunta direto ao macOS se uma tela está em tela cheia e confere de novo quando a troca termina. O bichinho e a bola ficam escondidos até você sair da tela cheia.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

A bola não quica mais no vazio. Ela voa por cima do Dock em vez de bater numa parede invisível. O mouse agora acerta a bola só quando o ponteiro realmente encosta nela. Um toque leve faz ela rolar, um movimento rápido faz ela voar. E se o bichinho ou a bola estão escondidos atrás de uma janela, o mouse sobre essa janela deixa eles em paz.

Arrastar um arquivo pela mesa não cria mais um degrau para o bichinho. Só um quadro de seleção faz isso.

**Experimente:** Assista a um vídeo em tela cheia e pause algumas vezes com a barra de espaço. O bichinho não aparece. Depois dê um peteleco com o mouse na bola.

---

## <a id="v1.30.8"></a>Os cantos da tela ficam quietos enquanto você joga

<sub>1.30.8 · 10 de outubro de 2026</sub>

No Modo Jogo, o mouse nas bordas e nos cantos da tela não aciona mais os cantos ativos nem puxa o Dock oculto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Antes, no meio da partida, levar o mouse a um canto ou à borda da tela podia acionar um canto ativo ou puxar o Dock oculto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Agora o Modo Jogo desliga os cantos ativos e o Dock oculto enquanto você joga. Alguns segundos depois que você sai do jogo, ou quando fecha o pikapik, eles voltam exatamente como estavam.

E o ponteiro não engasga mais na borda da tela do jogo.

**Experimente:** Ative o Modo Jogo, abra um jogo e leve o mouse a um canto da tela. Nada aparece.

---

## <a id="v1.30.7"></a>Seu bichinho não entra mais no seu vídeo

<sub>1.30.7 · 10 de outubro de 2026</sub>

Quando o bichinho ou a bola estão atrás de uma janela, eles ficam lá mesmo quando pulam ou voam.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, se o bichinho ou a bola estavam escondidos atrás de um vídeo ou jogo, um pulo ou um voo podia jogá-los bem por cima do que você estava vendo. Apertar Espaço para pausar um vídeo também fazia o bichinho aparecer.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Agora eles ficam atrás da janela que os cobre, façam o que fizerem. E um vídeo em tela cheia no Firefox os esconde na hora.

Atrás de janelas comuns eles continuam se escondendo como antes.

**Experimente:** Abra um vídeo numa janela grande que cubra a parte de baixo da tela e aperte Espaço para pausar. O bichinho fica atrás do vídeo.

---

## <a id="v1.30.6"></a>Em tela cheia, seu bichinho descansa em todas as telas

<sub>1.30.6 · 10 de outubro de 2026</sub>

Enquanto qualquer app está em tela cheia, o bichinho e a bola agora se escondem em todos os monitores.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, quando você abria um vídeo ou jogo em tela cheia, o bichinho e a bola às vezes fugiam para outro monitor e continuavam brincando lá.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Agora, enquanto qualquer app está em tela cheia, eles se escondem em todos os seus monitores. Saia da tela cheia e eles voltam na hora.

Atrás de janelas comuns eles continuam se escondendo como antes.

**Experimente:** Se você tem dois monitores, abra um vídeo em tela cheia em um deles. O bichinho e a bola somem dos dois e voltam quando você sai da tela cheia.

---

## <a id="v1.30.5"></a>Seu bichinho sai da frente enquanto você assiste ou joga

<sub>1.30.5 · 10 de outubro de 2026</sub>

Seu bichinho e a bola agora se escondem enquanto um app está em tela cheia, inclusive nos Macs com notch.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, num Mac com notch, o bichinho podia ficar por cima de um vídeo ou jogo em tela cheia, e a bola às vezes aparecia sobre um app em tela cheia em outro monitor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Agora, enquanto um app ocupa a tela inteira, o bichinho e a bola esperam fora de vista. Saia da tela cheia e eles voltam na hora.

Atrás de janelas comuns eles continuam se escondendo como antes.

**Experimente:** Abra um vídeo em tela cheia ou comece um jogo. O bichinho e a bola não atrapalham até você terminar.

---

## <a id="v1.30.4"></a>Seu bichinho fica à vista quando pula ou pega carona numa seleção

<sub>1.30.4 · 10 de outubro de 2026</sub>

Seu bichinho e a bola não somem mais atrás das janelas enquanto estão no ar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, quando o bichinho pulava por cima do ponteiro ou subia num retângulo de seleção, uma janela maximizada o cobria, e parecia que ele tinha sumido.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Agora, enquanto o bichinho ou a bola estão mais altos que o Dock, eles aparecem na frente das suas janelas. De volta ao chão, vão para trás delas de novo.

E o bichinho pode passear atrás do Dock de novo, como antes.

**Experimente:** Maximize uma janela, comece um retângulo de seleção na mesa ao lado do Dock para o bichinho subir nele e arraste devagar para cima. O bichinho pega carona nele na frente da janela.

---

## <a id="v1.30.3"></a>Seu bichinho e a bola não ficam mais embaixo do Dock

<sub>1.30.3 · 9 de outubro de 2026</sub>

Seu bichinho não passeia nem dorme mais embaixo do Dock, então você sempre o vê.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, o bichinho e a bola muitas vezes passeavam e descansavam bem embaixo do Dock, onde ninguém os via. Com uma janela maximizada, parecia que o bichinho tinha sumido de vez.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Agora o Dock é como uma parede para eles. O bichinho dá meia-volta na borda dele, e a bola quica nele.

Assim o bichinho sempre fica visível ao lado do Dock, mesmo quando uma janela ocupa a tela toda.

**Experimente:** Maximize uma janela e observe por alguns minutos. O bichinho fica sempre visível à esquerda ou à direita do Dock.

---

## <a id="v1.30.2"></a>Seu bichinho não some mais atrás das janelas

<sub>1.30.2 · 9 de outubro de 2026</sub>

Mesmo quando uma janela cobre o bichinho, ele continua vivo e cai no chão quando você solta a seleção.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Quando as janelas cobriam toda a faixa onde o bichinho vive, o pikapik o pausava, e ele podia ficar parado no ar. Agora o bichinho e a bola continuam vivos atrás da janela: andam, caem e brincam. Só o desenho faz uma pausa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Se um retângulo de seleção levantar o bichinho atrás de uma janela, ele cai assim que você solta e aparece de novo perto do Dock.

E um retângulo de seleção não levanta mais o bichinho acima da faixa dele.

**Experimente:** Maximize uma janela, levante o bichinho com um retângulo de seleção atrás dela e solte. Ele cai e aparece perto do Dock.

---

## <a id="v1.30.1"></a>As seleções na mesa voltaram a funcionar

<sub>1.30.1 · 9 de outubro de 2026</sub>

Seu bichinho e a bola voltam a pular nos retângulos de seleção, e as listas de apps só se acendem para apps.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Quando o Dock ou um app de acesso remoto cobria a tela inteira, o pikapik não percebia o retângulo de seleção que você desenha na mesa. Agora ele percebe de novo, e seu bichinho e a bola pulam nele como antes.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

As listas de apps nos ajustes só se acendem quando você arrasta um app por cima. Outros arquivos são ignorados: nenhuma moldura aparece e nada a mais é adicionado. Se você arrastar um app junto com outros arquivos, só o app é adicionado.

E a moldura se apaga assim que você solta o app ou afasta o ponteiro.

**Experimente:** Desenhe um retângulo de seleção na mesa e veja seu bichinho pular nele.

---

## <a id="v1.30.0"></a>Encerrar não desliga mais o pikapik

<sub>1.30.0 · 9 de outubro de 2026</sub>

Clicou em Encerrar por hábito? Seus atalhos, o «Manter Ativo» e seu bichinho continuam funcionando.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

Quando você escolhe «Encerrar», pressiona ⌘Q ou encerra o pikapik pelo Dock, ele fecha as janelas e esconde o ícone da barra de menus, mas continua trabalhando em silêncio em segundo plano: os atalhos, o «Manter Ativo» e seu bichinho continuam ligados. Para trazer o ícone de volta, é só abrir o pikapik de novo.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Quer encerrar de verdade? Segure Option (⌥) e escolha «Encerrar», ou pressione ⌥⌘Q. Na primeira vez que o pikapik vai para segundo plano, ele explica o que aconteceu e oferece encerrar por completo ali mesmo.

Prefere como antes? Desative «Continuar em segundo plano ao encerrar» em Ajustes › Geral. Atualizações, troca de idioma, sair da conta, reiniciar e desligar sempre encerram o pikapik por completo, então nunca precisam esperar por ele.

**Experimente:** Pressione ⌘Q e depois abra o pikapik de novo para trazer o ícone de volta.

---

## <a id="v1.29.1"></a>Seu bichinho passeia por todas as telas

<sub>1.29.1 · 9 de outubro de 2026</sub>

Tem mais de um monitor? Seu bichinho e a bola agora vão para onde você olhar, e nunca se perdem.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Ao chegar na borda de uma tela, o bichinho simplesmente passa para a próxima, e a bola rola atrás dele. Você também pode pegar o bichinho ou a bola com o mouse e levar para qualquer tela. Se um app entra em tela cheia, eles vão para outra tela para não atrapalhar, e se você desconectar um monitor, eles voltam para a principal.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

A bola não fica mais presa no canto. O bichinho corre até ela, joga a bola para trás por cima da cabeça e continua brincando.

E seu bichinho não some mais. A cada dois segundos ele confere se ainda está na tela, e se algo deu errado, depois do repouso, do bloqueio do Mac, da troca de mesa ou da tela cheia, ele volta sozinho na hora.

**Experimente:** Leve o bichinho para outra tela ou role a bola até um canto.

**Corrigido**

- Um bichinho arremessado não pousa mais num retângulo de seleção mais alto do que ele alcança, e não some mais por causa disso.

---

## <a id="v1.29.0"></a>Seu bichinho ganhou uma bola

<sub>1.29.0 · 9 de outubro de 2026</sub>

Agora uma bolinha de futebol rola pela parte de baixo da tela. Seu bichinho brinca com ela, e você também pode.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

A bola rola e quica como uma de verdade. O bichinho corre atrás dela, chuta e corre atrás de novo. Passe o ponteiro rápido pela bola para chutar você mesmo, ou pegue, carregue e jogue a bola, igual ao bichinho.

Um truque: clique num lugar vazio da mesa e arraste para desenhar um retângulo de seleção, com ou sem Shift. Enquanto você segura o botão do mouse, o retângulo vira uma prateleira: o bichinho pula em cima, e a bola também pode cair ali. Solte, e a prateleira some.

Prefere a mesa tranquila? Desligue Bola nos ajustes do bichinho, e ele volta a passear sozinho.

**Experimente:** Ajustes › Bichinho › Bola

**Corrigido**

- Ao lado do Dock, o bichinho volta a pular tão alto quanto quiser. Ele só fica baixinho quando está bem em cima do Dock, então nunca aparece por trás dele.

---

## <a id="v1.28.0"></a>Adicione apps com um clique ou arrastando

<sub>1.28.0 · 9 de outubro de 2026</sub>

Toda lista de apps nos Ajustes agora mostra o que está no seu Dock e o que está aberto, e você pode arrastar apps do Finder para ela.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Alguns recursos deixam você escolher apps em que eles ficam de lado, como o botão verde ou Home e End. Antes, “Adicionar app…” só abria uma pasta comprida com tudo o que você tem. Agora aparece uma prateleira com os apps do seu Dock e os que estão abertos agora. Clique em um app para adicioná-lo e clique de novo para tirá-lo. Para todo o resto existe “Outro…”.

Você também pode arrastar um app do Finder direto para uma lista. A lista se ilumina para mostrar onde o app vai entrar. Seus jogos funcionam do mesmo jeito, com a mesma prateleira.

E se algo der errado, o formulário de relato de bug no GitHub agora deixa você escolher a versão do pikapik e do macOS numa lista, então contar para a gente fica mais rápido.

**Experimente:** Ajustes › Janelas, depois “Adicionar app…”

**Corrigido**

- A rolagem pelo AnyDesk ou outro app de acesso remoto não é mais invertida duas vezes quando os dois Macs usam a direção clássica. Agora o pikapik inverte só a rolagem de um mouse ou trackpad de verdade. Se um app faz a própria rolagem suave, como o Mos, escolha a direção nesse app.
- O bichinho fica atrás do Dock quando pula, igual quando anda, e volta sozinho quando você sai de um app em tela cheia ou de um jogo.
- As molduras finas em volta das pequenas imagens dos Ajustes não somem mais em telas comuns, sem Retina.

---

## <a id="v1.27.3"></a>O bichinho sempre à vista, e as janelas abrem prontas

<sub>1.27.3 · 9 de outubro de 2026</sub>

O bichinho não se esconde mais atrás das janelas no meio do pulo, e as janelas do pikapik abrem prontas para usar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Quando o bichinho pulava por cima do ponteiro ou dava uma cambalhota, ele podia escorregar para trás das janelas de outros apps e sumir no ar. Agora ele fica na frente durante todo o pulo e volta para trás das suas janelas assim que pousa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Quando o pikapik abria quietinho em segundo plano, ao iniciar a sessão, depois de uma atualização ou por um link pikapik://, as janelas dele podiam abrir cinzas e ficar atrás das outras até você clicar nelas. Agora os Ajustes e a janela Novo arquivo vêm para a frente, prontos para digitar.

O mesmo vale para a mensagem depois de Criar cópia menor e para a lista em que você escolhe um app para adicionar. Você não precisa fazer nada.

**Experimente:** Ajustes › Bichinho

---

## <a id="v1.27.2"></a>Novo arquivo voltou, e os Ajustes ficaram ainda mais leves

<sub>1.27.2 · 9 de outubro de 2026</sub>

Novo arquivo está de volta ao menu do clique direito do Finder para todos, e os Ajustes pedem ainda menos do seu Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Depois da última atualização, o Finder podia reiniciar o Novo arquivo em segundo plano e esquecer em quais pastas ele funciona, e o item sumia sem aviso do menu do clique direito. Agora o Novo arquivo lembra o Finder das suas pastas toda vez que inicia, e o pikapik confere, logo depois de abrir, que o Finder recebeu o recado. Você não precisa fazer nada.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

As imagens animadas dos Ajustes agora só se movem enquanto pelo menos metade da imagem está na tela. Nas imagens de jogos, o pequeno herói continua se movendo 30 vezes por segundo, e as colinas e o chão atrás dele, 15. Assim a página Jogos pede muito menos do seu Mac. Tudo continua com a mesma cara.

Depois de uma atualização, o pikapik não adiciona de novo os seus itens do Finder, a menos que o app tenha mudado de lugar de verdade, e o Finder não precisa recarregá-los toda vez.

**Experimente:** Ajustes › Jogos

---

## <a id="v1.27.1"></a>Mais silencioso, mais leve e o Finder pronto na hora

<sub>1.27.1 · 9 de outubro de 2026</sub>

Os Ajustes quase não pesam no seu Mac, e os itens do clique direito no Finder funcionam logo depois da mudança para pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

As pequenas imagens animadas dos Ajustes redesenhavam a página inteira muitas vezes por segundo, então uma janela aberta deixava o Mac ocupado. Agora cada imagem redesenha só a si mesma, no máximo 30 vezes por segundo, e descansa quando você rola para longe dela ou oculta a janela. Elas continuam iguaizinhas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Depois da mudança de pika-tools para pikapik, o Finder podia continuar procurando o app antigo, e “Novo arquivo”, “Converter para” e os outros itens do clique direito não faziam nada. Agora o pikapik percebe isso na primeira abertura e reinicia o Finder sozinho quando não há janelas do Finder abertas e nada está sendo copiado. Se não, uma linha curta na página Finder oferece o botão “Reiniciar o Finder”.

Nos Ajustes do Sistema, entre os apps que abrem no início da sessão, o app agora aparece com o novo nome, pikapik, e continua ativado.

**Experimente:** Ajustes › Finder

---

## <a id="v1.27.0"></a>Conheça seu bichinho de mesa

<sub>1.27.0 · 9 de outubro de 2026</sub>

Agora um amiguinho mora na parte de baixo da sua tela, e o app tem um nome novo: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Ligue em Ajustes › Bichinho. Ele passeia atrás das suas janelas e do Dock, pula por cima do ponteiro quando ele está no caminho e dá um pulo quando você aperta Espaço. Dá para pegar, carregar, jogar para o alto e pegar de novo no meio do pulo.

De vez em quando ele senta e fala alguma coisa curtinha. Quando sai mesmo uma versão nova, ele avisa uma vez, e um clique nele abre os Ajustes, onde a atualização está esperando.

pika-tools agora se chama pikapik. Suas permissões, ajustes e links do Atalhos continuam como estavam. Se você instalou pelo Homebrew, rode uma vez `brew update && brew upgrade --cask pikapik`.

**Experimente:** Ajustes › Bichinho

**Corrigido**

- A verificação de atualizações dizia que havia uma versão nova mesmo quando você já tinha a mais recente.
- A página Permissões deixava o Mac ocupado enquanto estava aberta.

---

## <a id="v1.26.2"></a>Novidades no seu idioma

<sub>1.26.2 · 8 de outubro de 2026</sub>

“Novidades” nos ajustes agora abre esta página, no mesmo idioma do app.

<img src="../media/icon.png" width="128" height="128" alt="">

Abra Ajustes › Sobre e clique em “Novidades”. Você chega direto aqui, na página com uma imagem para cada atualização, no idioma que o pikapik fala.

A lista completa de mudanças também ficou mais organizada. Cada versão mostra o dia em que saiu, e cada número de versão abre a página de download dela.

Nada muda no funcionamento do pikapik. As atualizações chegam como antes, sozinhas ou pelo Homebrew.

**Experimente:** Ajustes › Sobre › Novidades

**Corrigido**

- “Novidades” abria uma longa lista técnica em inglês em vez desta página.
- Os links da lista de mudanças que não levavam a lugar nenhum agora abrem a página certa.

---

## <a id="v1.26.1"></a>As imagens dos jogos ganham vida

<sub>1.26.1 · 8 de outubro de 2026</sub>

As imagens da página “Jogos” agora se mexem, e você vê o que cada chave impede.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Atrás de cada chave da página “Jogos” agora roda um joguinho. Aparecem teclas, elas são pressionadas, e você vê o que pularia por cima do seu jogo, como o Spotlight ou o Mission Control, enquanto o jogo para. Com a chave ligada, as teclas só brilham de leve e o jogo continua. Mude uma chave e a imagem mostra a diferença na hora.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

O joguinho acompanha a aparência do seu Mac: um dia de sol no modo claro e uma noite calma com lua e estrelas no modo escuro.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Em todas as imagens do app, o ponteiro agora se move como uma mão: leva um pouco mais de tempo nos caminhos longos, para e só então clica. Quando uma imagem recomeça, ela volta suavemente ao início em vez de pular. As imagens descansam enquanto a janela está escondida, e com “Reduzir movimento” ficam paradas.

**Experimente:** Ajustes › Jogos

---

## <a id="v1.26.0"></a>Um ícone novo e uma faxina nas permissões antigas

<sub>1.26.0 · 8 de outubro de 2026</sub>

O pikapik ganhou cara nova e agora remove as permissões que os apps apagados deixam para trás.

<img src="../media/icon.png" width="128" height="128" alt="">

O ícone novo é a marca do pikapik em azul, violeta e coral sobre um bloco escuro. A barra de menus mostra a mesma forma, que acompanha uma barra clara ou escura. Quando todas as ferramentas estão desativadas, a forma fica pálida.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Quando você apaga um app, o macOS guarda as permissões que você deu a ele, e os Ajustes do Sistema não têm como removê-las. Agora a página “Permissões” tem uma lista chamada “Restos de apps apagados”: cada app com seu ícone, o que ele podia fazer e quando. “Remover” limpa um app, “Remover Tudo” limpa todos, e um app que você instalar de novo simplesmente vai pedir outra vez. Para ver a lista, dê ao pikapik Acesso Total ao Disco: ele só olha e não muda nada até você clicar em “Remover”.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

As imagens das páginas “Animações” e “Jogos” foram redesenhadas para o tamanho real, por isso ficam nítidas. Uma janela encolhe para o Dock com cantos arredondados, e o ponteiro clica primeiro, só depois um menu abre. E no fim de “Sobre” agora há uma linha discreta: “Feito com carinho · Me pague um café”. Nada aparece de repente, e nada fica lembrando você.

**Experimente:** Ajustes › Permissões, depois “Restos de apps apagados”

**Corrigido**

- Clicar num atalho do sistema abre direto a seção dele nos Ajustes do Sistema, como Mission Control, e não só “Teclado”.
- A dica ao lado das teclas não some mais assim que os Ajustes do Sistema abrem.

---

## <a id="v1.25.2"></a>Os atalhos abrem onde você os muda

<sub>1.25.2 · 8 de outubro de 2026</sub>

Clique em um atalho nos Ajustes, e os Ajustes do Sistema abrem no lugar certo.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Antes, clicar em um atalho, como o do Spotlight, sempre levava a “Teclas Modificadoras”. Agora as teclas do Spotlight abrem direto no Spotlight.

Para os outros atalhos, os Ajustes do Sistema abrem em “Teclado”, e uma dica curta ao lado das teclas mostra onde clicar: “Atalhos de Teclado…”, depois “Mission Control” ou outra seção.

Funciona igual na página Jogos e em “Recortar arquivos no Finder”. Para recortar arquivos, a dica leva a “Atalhos de Apps”.

**Experimente:** Ajustes › Jogos, depois clique nas teclas ao lado de “A busca não aparece”

**Corrigido**

- Clicar em um atalho não abre mais “Teclas Modificadoras”.

---

## <a id="v1.25.1"></a>Imagens grandes e jogos direto do Dock

<sub>1.25.1 · 8 de outubro de 2026</sub>

Cada chave agora tem uma imagem grande, e “Adicionar jogo…” mostra o que está no seu Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Nas páginas Animações e Jogos, todas as imagens agora são grandes, como a do topo da página. Dá para ver na hora o que cada chave faz, e as imagens continuam se movendo na velocidade que você escolheu.

Clique em “Adicionar jogo…” e você vê o seu Dock: os apps que você mantém lá e os que estão abertos agora, na mesma ordem. Um jogo do Dock aparece mesmo fechado, o Minecraft também. Um clique adiciona, e uma marca mostra que ele já está na lista. Clique de novo para tirá-lo.

Você ainda pode arrastar um jogo para cá a partir do Finder. Não é mais preciso puxá-lo para fora do Dock, então o Dock não oferece removê-lo.

**Experimente:** Ajustes › Jogos, depois “Adicionar jogo…”

**Corrigido**

- Um jogo que está no Dock, mas fechado, agora aparece na lista para adicionar.

---

## <a id="v1.25.0"></a>Adicione um jogo com um clique e escolha suas próprias teclas

<sub>1.25.0 · 8 de outubro de 2026</sub>

Escolha um jogo entre o que está aberto agora e defina do seu jeito as teclas para encerrar e fechar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Clique em “Adicionar jogo…”, e os apps abertos agora aparecem com ícones grandes, como no Dock. Um clique adiciona um jogo, ou arraste o ícone para a lista. Você também pode soltar um jogo direto do Finder ou do Dock. Agora qualquer app pode ser um jogo, até o Minecraft que roda em Java, e os jogos que você adicionou antes continuam lá.

As chaves do Modo Jogo agora falam de um jeito simples, como “O jogo não fecha” ou “A busca não aparece”, e cada uma tem uma pequena imagem do que ela impede. O nome no sistema, como Spotlight, fica ao lado em cinza.

Em Ajustes › Janelas, clique nas teclas ao lado de “Encerrar app” ou “Fechar janela” e pressione novas. ⌫ traz de volta ⇧⌘Q e ⇧⌘W, e se as teclas já estiverem em uso, o pikapik pergunta antes. O Modo Jogo também usa suas teclas. E cada atalho nos Ajustes agora mostra como ele está realmente configurado no seu Mac: suas teclas ou Desativado.

**Experimente:** Ajustes › Jogos, depois “Adicionar jogo…”

**Corrigido**

- Recortar arquivos no Finder segue o atalho de Recortar que você definiu para o Finder nos Ajustes do Sistema.
- Os nomes dos apps nas listas aparecem sem “.app”.

---

## <a id="v1.24.1"></a>Uma velocidade que você vê na hora

<sub>1.24.1 · 8 de outubro de 2026</sub>

A página Animações agora mostra onde cada mudança aparece e protege os seus próprios valores.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

O Dock só desliza mais rápido quando se oculta. Se o seu fica sempre à vista, a chave “Ocultar o Dock automaticamente” agora fica logo abaixo do controle de velocidade.

Depois de uma mudança, uma linha no fim da página avisa que os apps passam a usá-la quando você os abrir de novo. O Finder só mostra a nova velocidade da Visualização Rápida e das colunas depois de reiniciar, por isso a linha tem um botão “Reiniciar o Finder”.

O controle nunca deixa mais lento o que você já tinha acelerado, por exemplo com comandos no Terminal. E “Restaurar Padrões” ou desinstalar o pikapik traz de volta os valores que você tinha antes, em vez de apagá-los.

**Experimente:** Ajustes › Animações

**Corrigido**

- O Dock não reinicia mais à toa quando não se oculta.

---

## <a id="v1.24.0"></a>Escolha a velocidade do seu Mac

<sub>1.24.0 · 8 de outubro de 2026</sub>

A nova página Animações define a rapidez com que tudo abre, desliza e aparece no seu Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Um controle só resolve. Mova-o, e o Dock oculto, as novas janelas, os diálogos de salvar, a Visualização Rápida e as colunas do Finder ficam mais rápidos juntos, de “Como no macOS” até “Instantâneo”.

Quer ajustar só uma coisa? Cada efeito tem seu próprio ajuste, assim como o efeito ao minimizar, os ícones que pulam no Dock e as animações do Finder. Ao lado de cada ajuste, uma pequena imagem se move exatamente na velocidade que você escolheu.

“Restaurar Padrões” desfaz só o que o pikapik mudou, e desinstalá-lo faz o mesmo. Se um dia você mesmo definiu um desses valores no Terminal, o pikapik mostra esse valor como está.

**Experimente:** Ajustes › Animações

---

## <a id="v1.23.2"></a>Uma chave para cada atalho no Modo Jogo

<sub>1.23.2 · 8 de outubro de 2026</sub>

Agora você decide, atalho por atalho, o que o Modo Jogo silencia enquanto você joga.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q e ⌘W agora têm chaves separadas, assim como Spotlight, Siri, ⌘Tab, Mission Control, os gestos, o ponteiro, a tela e todo o resto. Suas escolhas anteriores continuam valendo.

Cada linha mostra exatamente as teclas que ela bloqueia, então você sempre sabe o que uma chave faz.

O ajuste do idioma do teclado saiu do Modo Jogo. ⌃Espaço e as outras formas de trocar de idioma sempre funcionam, até dentro de um jogo.

**Experimente:** Ajustes › Jogos

**Corrigido**

- As teclas de um mesmo atalho ficam mais juntas, com um pouco mais de espaço entre atalhos diferentes, então dá para ver fácil onde um termina e o próximo começa.

---

## <a id="v1.23.1"></a>A velocidade da sua internet, em palavras simples

<sub>1.23.1 · 8 de outubro de 2026</sub>

O Teste de velocidade verifica sua conexão e diz, de um jeito simples, para que ela serve.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Clique em “Testar velocidade” e, em cerca de meio minuto, você vê download, upload, ping e responsividade. Abaixo dos números, palavras simples dizem se dá para filmes em 4K, videochamadas, jogos online e downloads grandes.

O teste roda nos servidores da Apple, e o último resultado fica até o próximo. O Teste de velocidade tem página própria nos Ajustes, uma linha no painel da barra de menus e um link para o app Atalhos: `pikapik://speed-test`.

O Modo Jogo aprendeu duas coisas. O bloqueio dos atalhos com Control agora faz parte dele: no jogo, ⌃-clique continua sendo um clique e os atalhos com ⌃ não disparam; fora dele, ⌃ funciona como sempre. E ele reconhece o Minecraft: adicione o Minecraft Launcher ou o CurseForge aos seus jogos, e o Modo Jogo liga quando o próprio Minecraft está na frente.

**Experimente:** Ajustes › Teste de velocidade, depois “Testar velocidade”

**Corrigido**

- Versões de teste do pikapik que as pessoas compilam por conta própria guardam seus ajustes separados no iCloud Drive e não mexem mais nos seus.

---

## <a id="v1.23.0"></a>Modo Jogo: jogue sem interrupções

<sub>1.23.0 · 7 de outubro de 2026</sub>

Adicione seus jogos, e o Mac para de tirar você deles.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Enquanto você joga, Spotlight, Siri, ⌘Tab, Mission Control e os gestos entre mesas não abrem por cima do jogo. ⌘Q e ⌘W não o fecham sem querer, o ponteiro fica na tela do jogo e a tela continua ligada.

Para sair de um jogo, pressione ⇧⌘Q; para fechar a janela dele, ⇧⌘W. ⌥⌘Esc sempre funciona. O pikapik sugere os jogos que encontra no seu Mac. O Modo Jogo fica desligado até você ligá-lo.

O Manter Ativo deixa você escolher o que a tela faz: ficar ligada, sem protetor de tela nem tela de bloqueio, ou desligar como sempre enquanto o Mac continua trabalhando. O novo botão “Desligar a tela agora” apaga a tela na hora; mexa o mouse ou pressione uma tecla para ela voltar.

**Experimente:** Ajustes › Jogos, depois “Adicionar jogo…”

**Corrigido**

- Em Macs sem tampa, o Manter Ativo não mostra mais as opções de tampa fechada.

---

<p align="center"><sub>As versões anteriores estão no <a href="../../CHANGELOG.md">registro de mudanças</a> (em inglês).</sub></p>
