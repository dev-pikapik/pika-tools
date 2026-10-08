<p align="center"><a href="../readme/README.fr.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Quoi de neuf dans pikapik</h1>
<p align="center">Chaque mise à jour en quelques mots et une image, la plus récente en premier.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <b>Français</b> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.27.0"></a>Voici votre compagnon de bureau

<sub>1.27.0 · 8 octobre 2026</sub>

Un petit ami vit désormais en bas de votre écran, et l’app porte un nouveau nom : pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Activez-le dans Réglages › Compagnon. Il se promène derrière vos fenêtres et le Dock, saute par-dessus le pointeur s’il lui barre la route et bondit quand vous appuyez sur Espace. Attrapez-le, promenez-le, lancez-le et rattrapez-le en plein saut.

De temps en temps, il s’assoit et dit un petit mot. Quand une nouvelle version sort vraiment, il vous le dit une fois, et un clic sur lui ouvre les Réglages, où la mise à jour vous attend.

pika-tools s’appelle maintenant pikapik. Vos autorisations, vos réglages et vos liens dans Raccourcis restent tels quels. Si vous l’avez installée avec Homebrew, lancez une fois `brew update && brew upgrade --cask pikapik`.

**Pour essayer :** Réglages › Compagnon

**Corrigé**

- La vérification des mises à jour annonçait une nouvelle version alors que vous aviez déjà la dernière.
- La page Autorisations occupait votre Mac tant qu’elle était ouverte.

---

## <a id="v1.26.2"></a>Les nouveautés dans votre langue

<sub>1.26.2 · 8 octobre 2026</sub>

« Nouveautés » dans les réglages ouvre maintenant cette page, dans la même langue que l’app.

<img src="../media/icon.png" width="128" height="128" alt="">

Ouvrez Réglages › À propos et cliquez sur « Nouveautés ». Vous arrivez directement ici, sur la page avec une image pour chaque mise à jour, dans la langue que parle pika-tools.

La liste complète des changements est aussi mieux rangée. Chaque version indique le jour de sa sortie, et chaque numéro de version ouvre sa page de téléchargement.

Rien ne change dans le fonctionnement de pika-tools. Les mises à jour arrivent comme avant, toutes seules ou via Homebrew.

**Pour essayer :** Réglages › À propos › Nouveautés

**Corrigé**

- « Nouveautés » ouvrait une longue liste technique en anglais au lieu de cette page.
- Les liens de la liste des changements qui ne menaient nulle part ouvrent maintenant la bonne page.

---

## <a id="v1.26.1"></a>Les images de jeu prennent vie

<sub>1.26.1 · 8 octobre 2026</sub>

Les images de la page « Jeux » bougent maintenant : vous voyez ce que chaque interrupteur arrête.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Derrière chaque interrupteur de la page « Jeux », un petit jeu tourne maintenant. Des touches apparaissent et sont pressées, et vous voyez ce qui surgirait par-dessus votre jeu, comme Spotlight ou Mission Control, pendant que le jeu s’arrête. Quand l’interrupteur est activé, les touches brillent juste doucement et le jeu continue. Basculez un interrupteur, et l’image montre aussitôt la différence.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Le petit jeu suit l’apparence de votre Mac : une journée ensoleillée en mode clair et une nuit calme avec la lune et les étoiles en mode sombre.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Dans toutes les images de l’app, le pointeur bouge maintenant comme une main : il prend un peu plus de temps pour les longs trajets, se pose, puis seulement clique. Quand une image recommence, elle revient en douceur au début au lieu de sauter. Les images se reposent quand la fenêtre est cachée, et avec « Réduire les animations » elles restent immobiles.

**Pour essayer :** Réglages › Jeux

---

## <a id="v1.26.0"></a>Une nouvelle icône, et place nette pour les anciennes autorisations

<sub>1.26.0 · 8 octobre 2026</sub>

pika-tools change de visage et efface désormais les autorisations que laissent les apps supprimées.

<img src="../media/icon.png" width="128" height="128" alt="">

La nouvelle icône est le symbole pikapik en bleu, violet et corail sur une tuile sombre. La barre des menus affiche la même forme, qui s’adapte à une barre claire ou sombre. Quand tous les outils sont désactivés, la forme pâlit.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Quand vous supprimez une app, macOS garde les autorisations que vous lui aviez données, et Réglages Système ne permet pas de les retirer. La page « Autorisations » a maintenant une liste « Laissées par des apps supprimées » : chaque app avec son icône, ce qu’elle avait le droit de faire et quand. « Supprimer » efface une app, « Tout supprimer » les efface toutes, et une app que vous réinstallez redemandera simplement. Pour voir la liste, donnez à pika-tools l’accès complet au disque : il ne fait que regarder et ne change rien tant que vous n’appuyez pas sur « Supprimer ».

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Les images des pages « Animations » et « Jeux » sont redessinées pour leur vraie taille, elles sont donc nettes. Une fenêtre se range dans le Dock avec des coins arrondis, et le pointeur clique d’abord, puis seulement un menu s’ouvre. Et en bas de « À propos », il y a maintenant une ligne discrète : « Fait avec soin · Offrez-moi un café ». Rien ne s’affiche tout seul, et rien ne vous le rappelle.

**Pour essayer :** Réglages › Autorisations, puis « Laissées par des apps supprimées »

**Corrigé**

- Un clic sur un raccourci système ouvre directement sa section dans Réglages Système, comme Mission Control, et pas seulement « Clavier ».
- L’astuce à côté des touches ne disparaît plus dès que Réglages Système s’ouvre.

---

## <a id="v1.25.2"></a>Les raccourcis s’ouvrent là où on les modifie

<sub>1.25.2 · 8 octobre 2026</sub>

Cliquez sur un raccourci dans Réglages, et Réglages Système s’ouvre au bon endroit.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Avant, un clic sur un raccourci, comme celui de Spotlight, menait toujours à « Touches de modification ». Désormais, les touches de Spotlight ouvrent directement Spotlight.

Pour les autres raccourcis, Réglages Système s’ouvre sur « Clavier », et une courte astuce à côté des touches indique où cliquer : « Raccourcis clavier… », puis « Mission Control » ou une autre section.

C’est pareil sur la page Jeux et pour « Couper des fichiers dans le Finder ». Pour couper des fichiers, l’astuce mène à « Raccourcis de l’application ».

**Pour essayer :** Réglages › Jeux, puis cliquez sur les touches à côté de « La recherche ne surgit pas »

**Corrigé**

- Un clic sur un raccourci n’ouvre plus « Touches de modification ».

---

## <a id="v1.25.1"></a>De grandes images, et vos jeux depuis le Dock

<sub>1.25.1 · 8 octobre 2026</sub>

Chaque interrupteur a maintenant une grande image, et « Ajouter un jeu… » montre ce qu’il y a dans votre Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Sur les pages Animations et Jeux, toutes les images sont maintenant grandes, comme celle en haut de la page. On voit tout de suite ce que fait chaque interrupteur, et les images bougent toujours à la vitesse que vous avez choisie.

Cliquez sur « Ajouter un jeu… » et vous voyez votre Dock : les apps que vous y gardez et celles ouvertes en ce moment, dans le même ordre. Un jeu du Dock apparaît même s’il est fermé, Minecraft aussi. Un clic l’ajoute, et une coche montre qu’il est dans la liste. Cliquez encore une fois pour le retirer.

Vous pouvez toujours faire glisser un jeu ici depuis le Finder. Plus besoin de le tirer hors du Dock, donc le Dock ne propose plus de le supprimer.

**Pour essayer :** Réglages › Jeux, puis « Ajouter un jeu… »

**Corrigé**

- Un jeu qui est dans le Dock mais fermé apparaît maintenant dans la liste pour l’ajouter.

---

## <a id="v1.25.0"></a>Ajoutez un jeu en un clic, et choisissez vos touches

<sub>1.25.0 · 8 octobre 2026</sub>

Choisissez un jeu parmi ce qui est ouvert, et décidez des touches pour quitter et fermer.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Cliquez sur « Ajouter un jeu… » : les apps ouvertes en ce moment apparaissent en grandes icônes, comme dans le Dock. Un clic ajoute un jeu, ou faites glisser son icône dans la liste. Vous pouvez aussi déposer un jeu directement depuis le Finder ou le Dock. Toute app peut désormais être un jeu, même Minecraft qui tourne sous Java, et les jeux ajoutés auparavant restent là.

Les interrupteurs du Mode Jeu parlent désormais simplement, comme « Le jeu ne se ferme pas » ou « La recherche ne surgit pas », et chacun a une petite image de ce qu’il bloque. Le nom système, comme Spotlight, figure à côté en gris.

Dans Réglages › Fenêtres, cliquez sur les touches à côté de « Quitter l’app » ou « Fermer la fenêtre » et appuyez sur les nouvelles. ⌫ rétablit ⇧⌘Q et ⇧⌘W, et si les touches sont déjà prises, pika-tools vous demande d’abord. Le Mode Jeu utilise aussi vos touches. Et chaque raccourci des Réglages montre désormais comment il est vraiment configuré sur votre Mac : vos touches, ou Désactivé.

**Pour essayer :** Réglages › Jeux, puis « Ajouter un jeu… »

**Corrigé**

- Couper des fichiers dans le Finder suit le raccourci Couper que vous avez défini pour le Finder dans Réglages Système.
- Les noms d’apps dans les listes s’affichent sans « .app ».

---

## <a id="v1.24.1"></a>Une vitesse que vous voyez tout de suite

<sub>1.24.1 · 8 octobre 2026</sub>

La page Animations indique maintenant où un changement apparaît, et elle protège vos propres valeurs.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Le Dock ne peut glisser plus vite que s’il se masque. Si le vôtre reste toujours en place, l’interrupteur « Masquer automatiquement le Dock » se trouve maintenant juste sous le curseur de vitesse.

Après un changement, une ligne en bas de la page vous dit que les apps le prennent en compte quand vous les rouvrez. Le Finder n’affiche les nouvelles vitesses de Coup d’œil et des colonnes qu’après un redémarrage : la ligne propose donc un bouton « Redémarrer le Finder ».

Le curseur ne ralentit jamais ce que vous aviez déjà accéléré, par exemple avec des commandes dans Terminal. Et « Rétablir les réglages par défaut » ou la désinstallation de pika-tools remettent les valeurs que vous aviez avant, au lieu de les effacer.

**Pour essayer :** Réglages › Animations

**Corrigé**

- Le Dock ne redémarre plus pour rien quand il ne se masque pas.

---

## <a id="v1.24.0"></a>Choisissez la vitesse de votre Mac

<sub>1.24.0 · 8 octobre 2026</sub>

Une nouvelle page Animations règle la vitesse à laquelle tout s’ouvre, glisse et apparaît sur votre Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Un seul curseur suffit. Déplacez-le, et le Dock masqué, les nouvelles fenêtres, les dialogues d’enregistrement, Coup d’œil et les colonnes du Finder accélèrent ensemble, de « Comme dans macOS » à « Instantané ».

Vous voulez régler une seule chose ? Chaque effet a son propre réglage, tout comme l’effet de réduction, les icônes qui rebondissent dans le Dock et les animations du Finder. À côté de chaque réglage, une petite image bouge exactement à la vitesse choisie.

« Rétablir les réglages par défaut » ne remet que ce que pika-tools a modifié, et la désinstallation fait de même. Si vous aviez réglé vous-même une de ces valeurs dans Terminal, pika-tools l’affiche telle quelle.

**Pour essayer :** Réglages › Animations

---

## <a id="v1.23.2"></a>Un interrupteur pour chaque raccourci du Mode Jeu

<sub>1.23.2 · 8 octobre 2026</sub>

Vous décidez maintenant, raccourci par raccourci, ce que le Mode Jeu fait taire pendant que vous jouez.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q et ⌘W ont désormais chacun leur interrupteur, tout comme Spotlight, Siri, ⌘Tab, Mission Control, les balayages, le pointeur, l’écran et le reste. Vos choix précédents sont conservés.

Chaque ligne montre exactement les touches qu’elle bloque : vous savez toujours ce que fait un interrupteur.

Le réglage de la langue du clavier a quitté le Mode Jeu. ⌃Espace et les autres façons de changer de langue fonctionnent toujours, même en jeu.

**Pour essayer :** Réglages › Jeux

**Corrigé**

- Les touches d’un même raccourci sont plus serrées, et il y a un peu plus d’espace entre deux raccourcis : on voit facilement où l’un finit et où l’autre commence.

---

## <a id="v1.23.1"></a>La vitesse de votre connexion, en mots simples

<sub>1.23.1 · 8 octobre 2026</sub>

Test de débit vérifie votre connexion et vous dit simplement à quoi elle suffit.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Cliquez sur « Tester le débit » et, en une trentaine de secondes, vous voyez le téléchargement, l’envoi, le ping et la réactivité. Sous les chiffres, des mots simples disent si cela suffit pour des films en 4K, des appels vidéo, des jeux en ligne et de gros téléchargements.

La mesure passe par les serveurs d’Apple, et le dernier résultat reste affiché jusqu’au suivant. Test de débit a sa propre page dans les Réglages, une ligne dans le panneau de la barre des menus et un lien pour l’app Raccourcis : `pika-tools://speed-test`.

Le Mode Jeu a appris deux choses. Le blocage des raccourcis Contrôle en fait maintenant partie : en jeu, ⌃-clic reste un clic et les raccourcis avec ⌃ ne se déclenchent pas ; partout ailleurs, ⌃ fonctionne comme d’habitude. Et il reconnaît Minecraft : ajoutez Minecraft Launcher ou CurseForge à vos jeux, et le Mode Jeu s’active quand Minecraft lui-même est au premier plan.

**Pour essayer :** Réglages › Test de débit, puis « Tester le débit »

**Corrigé**

- Les versions de test de pika-tools que l’on compile soi-même gardent leurs réglages à part dans iCloud Drive et ne touchent plus aux vôtres.

---

## <a id="v1.23.0"></a>Mode Jeu : jouez sans interruption

<sub>1.23.0 · 7 octobre 2026</sub>

Ajoutez vos jeux, et votre Mac cesse de vous en faire sortir.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Pendant que vous jouez, Spotlight, Siri, ⌘Tab, Mission Control et les balayages entre bureaux ne s’ouvrent pas par-dessus le jeu. ⌘Q et ⌘W ne le ferment pas par accident, le pointeur reste sur l’écran du jeu et l’écran reste allumé.

Pour quitter un jeu, appuyez sur ⇧⌘Q ; pour fermer sa fenêtre, sur ⇧⌘W. ⌥⌘Échap fonctionne toujours. pika-tools vous propose les jeux qu’il trouve sur votre Mac. Le Mode Jeu reste désactivé tant que vous ne l’activez pas.

Rester éveillé vous laisse choisir ce que fait l’écran : rester allumé, sans économiseur d’écran ni écran de verrouillage, ou s’éteindre comme d’habitude pendant que votre Mac continue de travailler. Le nouveau bouton « Éteindre l’écran maintenant » l’éteint aussitôt ; bougez la souris ou appuyez sur une touche pour le rallumer.

**Pour essayer :** Réglages › Jeux, puis « Ajouter un jeu… »

**Corrigé**

- Sur les Mac sans capot, Rester éveillé n’affiche plus les options capot fermé.

---

<p align="center"><sub>Les versions précédentes sont dans le <a href="../../CHANGELOG.md">journal des modifications</a> (en anglais).</sub></p>
