# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · **Français** · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Dernière version](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Licence : MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Téléchargements](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Une petite app pour la barre des menus de macOS qui corrige le comportement des touches, des fenêtres et du Dock : elle protège ⌘Q et ⌘W, change de langue avec Option+Maj, répète une touche maintenue, désactive l’accélération de la souris, fait défiler la molette de la souris ligne par ligne, fait des boutons latéraux de la souris des boutons Précédent et Suivant, quitte les apps quand vous fermez leur dernière fenêtre, masque une app d’un clic dans le Dock et garde votre Mac éveillé.

## Installation

Avec [Homebrew](https://brew.sh) :

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Sans Homebrew, ouvrez Terminal, collez cette ligne et appuyez sur Retour :

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Ou téléchargez [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), ouvrez-le et faites glisser l’app dans le dossier Applications.

Homebrew et le script placent tous deux l’app dans `/Applications`, la lancent, demandent les autorisations et activent l’ouverture à la connexion. Ensuite, l’app se met à jour toute seule, voir [Mises à jour](#mises-à-jour). Pour la supprimer, voir [Désinstallation](#désinstallation).

## Premier lancement

pika-tools a besoin de deux autorisations. Au premier lancement, elle ouvre les réglages sur la page Autorisations, qui vous guide pas à pas, et macOS affiche ses propres demandes. Allez dans **Réglages Système › Confidentialité et sécurité** et activez pika-tools dans :

- **Accessibilité**, pour que l’app puisse modifier une frappe ou un clic avant qu’il n’atteigne les autres apps.
- **Surveillance de l’entrée**, pour que l’app puisse tout simplement voir les frappes et les clics.

L’app détecte le changement en une ou deux secondes, sans redémarrage.

pika-tools n’enregistre, ne conserve et n’envoie rien de ce que vous tapez ou cliquez. Les évènements sont traités en mémoire et transmis immédiatement. La seule requête réseau est la recherche de mises à jour, qui demande à GitHub la dernière version.

## Fonctionnalités

**Protéger ⌘Q et ⌘W.** ⌘Q et ⌘W seuls ne font rien, vous ne quittez donc pas une app ni ne fermez une fenêtre par accident. Ajoutez Maj pour le faire exprès : ⇧⌘Q quitte, ⇧⌘W ferme. Fonctionne dans toutes les apps. Chaque touche a son propre interrupteur. Désactivé par défaut.

**Changer de langue avec Option+Maj.** Maintenez Option et touchez Maj : macOS passe à la source de saisie suivante. Gardez Option enfoncée et touchez de nouveau Maj pour continuer. Maintenez Maj et touchez Option pour revenir en arrière. Si vous appuyez entre-temps sur une autre touche, cliquez ou ajoutez Commande, Contrôle ou Fn, rien ne change, donc les raccourcis comme Option+Maj+flèche fonctionnent comme avant. Désactivé par défaut.

**Répéter une touche maintenue.** Maintenez une touche et la lettre se tape encore et encore au lieu d’afficher le menu des accents. Pratique dans les jeux et pour écrire. Les apps déjà ouvertes en tiennent compte après un redémarrage. Désactivez-le et macOS retrouve son comportement habituel. Désactivé par défaut.

**Home et End vont au début et à la fin de la ligne.** Pendant la saisie, Home place le curseur au début de la ligne et End à la fin, au lieu de faire défiler la page. Avec ⇧, elles sélectionnent jusque-là, avec ⌘, elles vont au début ou à la fin du texte entier. Hors des champs de texte, ainsi que dans les terminaux, les machines virtuelles et les apps de bureau à distance, les touches fonctionnent comme avant. Vous pouvez ajouter d’autres apps où elles doivent fonctionner comme d’habitude. Désactivé par défaut.

**Désactiver l’accélération du pointeur.** Le pointeur se déplace exactement autant que la souris, quelle que soit la vitesse de votre geste, comme avec LinearMouse. Un curseur **Vitesse de déplacement** règle sa rapidité. Fonctionne uniquement avec les souris, le trackpad reste tel quel. Désactivez l’option ou quittez pika-tools, et macOS retrouve ses propres réglages. Désactivé par défaut.

**Défiler par lignes.** Chaque cran de la molette de la souris fait défiler le même nombre de lignes, quelle que soit la vitesse à laquelle vous la tournez. Choisissez de 1 à 10 lignes par cran, 3 par défaut. Le défilement naturel reste tel que vous l’avez réglé dans Réglages Système. Ne concerne que les souris, le trackpad reste comme il est. Désactivé par défaut. À côté du curseur **Distance par cran**, une petite page défile de la distance choisie, et un point marque la valeur par défaut.

Certaines apps et certains jeux comptent le défilement en pixels exacts : pour eux, passez ce même réglage en pixels et choisissez de 1 à 200 pixels par cran, 40 par défaut. Le curseur indique aussi quelle part de la hauteur de l’écran cela représente.

**Sens de défilement pour le trackpad et la souris.** macOS n’a qu’un seul réglage de défilement naturel pour le trackpad et la souris à la fois. Active cette fonction et choisis un sens pour chacun : **Naturel**, la page suit tes doigts comme sur iPhone, ou **Classique**, où la page va dans l’autre sens. Le choix du trackpad vaut aussi pour le défilement horizontal et pour l’élan après avoir levé les doigts. La Magic Mouse défile au toucher, elle suit donc le choix du trackpad. Choisis la même chose sur chacun de tes Mac et le défilement sera le même partout, même quand tu passes la souris sur un autre Mac avec Commande universelle. Désactivé par défaut. À l’activation, les deux sont réglés comme dans Réglages Système, donc rien ne change tant que tu ne choisis pas autre chose.

**Boutons latéraux pour Précédent et Suivant.** Les boutons 4 et 5 de la souris font précédent et suivant dans Safari, le Finder et les autres apps Apple, dans Firefox, Opera et ForkLift, comme un balayage sur le trackpad. Les autres apps, comme les IDE JetBrains, reçoivent les boutons tels quels et les gèrent à leur façon. Si votre souris les a dans l’autre sens, activez **Inverser les boutons latéraux**. Désactivé par défaut.

**Quitter à la fermeture de la dernière fenêtre.** Fermez la dernière fenêtre d’une app et l’app se ferme. Le Finder reste ouvert, tout comme les apps qui ont des fenêtres sur d’autres bureaux ou dans le Dock. Vous pouvez dresser la liste des apps qui ne doivent jamais se fermer ainsi. Désactivé par défaut.

**Masquer d’un clic dans le Dock.** Cliquez sur l’icône de l’app que vous utilisez dans le Dock, et elle se masque. Cliquez de nouveau pour la faire revenir. Désactivé par défaut.

**Le bouton vert agrandit la fenêtre.** Cliquez sur le bouton vert d’une fenêtre : elle remplit l’écran sans passer en plein écran. Un autre clic rétablit la taille précédente. Si vous maintenez ⌥, le bouton fonctionne comme d’habitude. Le plein écran reste dans le menu du bouton et sur ⌃⌘F. Vous pouvez lister les apps où le bouton vert doit fonctionner comme d’habitude. Désactivé par défaut.

**Nouveau fichier dans le Finder.** Clic droit dans une fenêtre du Finder ou sur le bureau, choisissez **Nouveau fichier**, tapez un nom, et un fichier vide apparaît. En .txt par défaut. Désactivé par défaut.

**Entrée ouvre les fichiers dans le Finder.** Sélectionnez des fichiers dans une fenêtre du Finder ou sur le bureau et appuyez sur Retour ou Entrée : ils s’ouvrent. F2 ou fn F2 renomme le fichier sélectionné. Dans les champs de texte, par exemple quand vous saisissez un nom, les touches fonctionnent comme d’habitude. Désactivé par défaut.

**⌘X coupe les fichiers dans le Finder.** Sélectionnez des fichiers et appuyez sur ⌘X, ouvrez le dossier voulu et appuyez sur ⌘V : les fichiers y sont déplacés au lieu d’être copiés. ⌘C annule la coupe. Désactivé par défaut.

**Supprimer efface les fichiers dans le Finder.** Sélectionnez des fichiers et appuyez sur ⌫ ou ⌦ (fn ⌫ sur un portable) : ils vont à la Corbeille, comme avec ⌘⌫. Quand vous renommez un fichier, faites une recherche ou tapez dans un autre champ, les touches effacent les lettres comme d’habitude. Désactivé par défaut.

**Copie allégée dans le Finder.** Clic droit sur un fichier dans le Finder, puis **Créer une copie allégée**. Une version plus légère d’une photo, d’un GIF, d’un PDF ou d’une vidéo apparaît juste à côté, souvent plusieurs fois plus petite. Le son non compressé, comme WAV ou AIFF, devient un M4A compact. Si le fichier ne peut pas être plus léger, aucune copie n’est créée et pika-tools vous le dit. L’original reste intact, et rien ne quitte votre Mac. Désactivé par défaut.

**Conversion dans le Finder.** Clic droit sur un fichier dans le Finder, puis **Convertir en** pour l’enregistrer dans un autre format : une image en JPEG, PNG, HEIC, GIF, TIFF ou PDF, une vidéo en MP4, MOV ou seulement le son, de la musique en M4A, WAV ou AIFF. L’original reste intact, et rien ne quitte votre Mac. S’active séparément de la copie allégée. Désactivé par défaut.

**Mode Jeu.** Ajoutez vos jeux, et pendant que vous jouez, votre Mac ne vous fait pas sortir du jeu. Spotlight, Siri, ⌘Tab, Mission Control et les balayages entre bureaux ne s’ouvrent pas par-dessus le jeu, ⌘Q et ⌘W ne le ferment pas par accident, le pointeur ne glisse pas vers le Dock, la barre des menus ou un autre écran, la langue du clavier ne change pas et l’écran reste allumé. Chacun de ces réglages a son propre interrupteur sur la page Jeux, et pika-tools vous propose les jeux qu’il trouve sur votre Mac. Dans un jeu, Contrôle devient une touche ordinaire : Contrôle-clic reste un simple clic, et Contrôle+Espace ou Contrôle avec les flèches ne changent ni la langue ni le bureau. Minecraft est reconnu aussi : ajoutez Minecraft Launcher ou CurseForge, et le mode s’active dans Minecraft lui-même. Pour quitter un jeu, appuyez sur ⇧⌘Q ; pour fermer sa fenêtre, sur ⇧⌘W. ⌥⌘Esc fonctionne toujours. Dès que vous quittez le jeu, tout fonctionne comme d’habitude. Désactivé par défaut.

Chaque outil a son propre interrupteur dans le menu et dans les réglages.

L’icône dans la barre des menus montre l’état d’un coup d’œil : une flèche avec un clic quand les outils fonctionnent, une flèche barrée quand tout est désactivé et un triangle d’avertissement quand un outil est activé mais que des autorisations manquent.

Le panneau de la barre des menus démarre avec seulement quelques lignes. Vous choisissez celles qu’il affiche : cliquez sur le bouton en forme de crayon en bas, cochez ce que vous voulez voir, puis cliquez sur **Terminé**. Les lignes masquées continuent de fonctionner et restent dans les Réglages. Si le panneau ne tient pas à l’écran, il défile.

L’app suit la langue du système ou celle que vous choisissez dans les réglages. Les 23 langues de la liste en haut de cette page sont toutes disponibles.

## Rester éveillé

Empêche votre Mac de se mettre en veille pendant que vous n’êtes pas devant le clavier : pour n’importe quelle durée de 1 seconde à 365 jours, ou jusqu’à ce que vous le désactiviez. Activez-le depuis le menu et réglez la durée dans les réglages : saisissez les jours, heures, minutes et secondes, utilisez ↑ et ↓, ou cliquez sur une durée prédéfinie de 15 minutes à 8 heures. Le menu indique le temps restant et l’heure de fin. Pour l’**Écran**, deux choix. **Toujours allumé** : il ne s’éteint pas, sans économiseur d’écran ni écran verrouillé. **S’éteint comme d’habitude** : il s’éteint selon son propre délai pendant que votre Mac continue de fonctionner. **Éteindre l’écran maintenant** (aussi dans le menu) l’éteint tout de suite et le Mac continue de fonctionner : bougez la souris ou appuyez sur une touche pour le rallumer. Quitter pika-tools met fin à Rester éveillé.

Sur un MacBook, vous pouvez aussi activer **Fonctionner écran rabattu**. macOS n’a pas de réglage pour cela, donc pika-tools exécute `pmset -a disablesleep 1` et demande un mot de passe administrateur : seul un administrateur peut modifier la mise en veille du Mac. Le réglage revient à la normale tout seul quand Rester éveillé se termine, quand vous quittez l’app ou si elle plante. Si vous ne saisissez pas le mot de passe, rien ne change. Veillez à ce que le Mac reste bien ventilé écran rabattu. **Arrêter sous 20 % de batterie** met fin à la session avant que la batterie ne soit vide.

Rester éveillé, les modes écran et capot fermé peuvent devenir un bouton du Centre de contrôle, de la barre des menus ou un widget du bureau grâce à l’app Raccourcis, avec des liens que tu copies dans Réglages › Rester éveillé.

## Test de débit

Montre la vitesse de ta connexion en ce moment. Clique sur **Tester le débit** dans Réglages › Test de débit, ou sur **Tester** dans le menu une fois la ligne ajoutée avec le bouton crayon. En une demi-minute environ, tu vois le débit en téléchargement et en envoi, le ping et la réactivité : la rapidité de réaction quand la connexion est chargée. En dessous, en mots simples, ce qu’elle permet : films en 4K, appels vidéo, jeux en ligne et gros téléchargements. Le test utilise networkQuality, intégré à macOS, et les serveurs d’Apple. Le dernier résultat reste jusqu’au test suivant, et un lien pour Raccourcis le lance depuis le Centre de contrôle.

## Réglages

Ouvrez les réglages depuis le menu avec **Réglages…** ou ⌘, ou relancez simplement pika-tools depuis le Finder, Launchpad ou Spotlight. Tant que la fenêtre est ouverte, l’app apparaît dans le Dock et dans ⌘Tab.

- **Général** : ouverture à la connexion, apparence (Système, Clair ou Sombre), langue, mises à jour et sauvegarde : exporter et importer les réglages sous forme de fichier, ou les synchroniser avec iCloud Drive.
- **Rester éveillé** : durée, options d’écran et de capot.
- **Test de débit** : mesurer la connexion et voir ce qu’elle permet.
- **Clavier** : changement de langue, répétition des touches, Home et End.
- **Souris ** : accélération du pointeur et vitesse de déplacement, défilement par lignes, sens de défilement, boutons latéraux.
- **Fenêtres** : agrandir avec le bouton vert (avec une liste d’exceptions), protection de ⌘Q et ⌘W, et quitter à la dernière fenêtre (avec une liste d’exceptions).
- **Dock** : masquer d’un clic dans le Dock.
- **Finder** : nouveau fichier, copie allégée et conversion, ouvrir avec Entrée, couper avec ⌘X et supprimer avec ⌫.
- **Autorisations** : l’état des deux autorisations, et d’iCloud Drive quand la synchronisation est activée, avec des boutons qui ouvrent le bon endroit dans Réglages Système.
- **À propos** : version, liens vers l’historique des changements et pour signaler un problème.

De nombreux réglages s’accompagnent d’une petite image qui montre ce qu’ils font, par exemple un Mac qui reste éveillé ou une fenêtre qui se cache derrière le Dock. L’image change avec l’interrupteur et reste fixe quand « Réduire les animations » est activé dans Réglages Système.

Chaque page comporte en bas un bouton **Rétablir les réglages par défaut…**. Il demande d’abord confirmation, puis désactive les outils de la page et rétablit leurs options, comme si pika-tools n’y avait jamais touché.

**Synchroniser les réglages avec iCloud** garde pika-tools identique sur tous vos Mac. Les réglages se trouvent dans le dossier pika-tools d’iCloud Drive, et la modification la plus récente l’emporte. Désactivé par défaut, et iCloud Drive doit être activé. Les autorisations ne sont pas synchronisées : chaque Mac les demande lui-même.

## Mises à jour

pika-tools recherche les nouvelles versions au lancement et toutes les 6 heures. Vous pouvez désactiver cela dans Réglages › Général. Quand une nouvelle version sort, un bouton **Mettre à jour vers …** apparaît dans le menu : un clic, et l’app télécharge la mise à jour, l’installe et redémarre. Vous pouvez aussi vérifier vous-même avec **Rechercher** dans Réglages › Général.

Avec Homebrew, vous pouvez aussi lancer `brew upgrade --cask pika-tools`.

Depuis la version 1.3, les autorisations sont conservées après les mises à jour.

## Désinstallation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Si vous avez installé avec Homebrew : `brew uninstall --cask --zap pika-tools`.

Les deux quittent l’app, la retirent des éléments d’ouverture et la suppriment. Le script réinitialise aussi ses autorisations.

## Questions fréquentes

**Pourquoi faut-il deux autorisations ?**
macOS sépare l’accès au clavier et à la souris en deux. La surveillance de l’entrée permet à l’app de voir les évènements, l’accessibilité lui permet de les modifier. Pour bloquer un raccourci, il faut les deux.

**macOS indique que l’app provient d’un développeur non identifié.**
pika-tools est signée, mais pas notarisée par Apple. Homebrew et le script d’installation s’en chargent pour vous. Si vous avez utilisé le dmg, ouvrez **Réglages Système › Confidentialité et sécurité** et cliquez sur **Ouvrir quand même**, ou exécutez :

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Fonctionne-t-elle sur les Mac Intel ?**
Oui. C’est une app universelle pour Apple Silicon et Intel, à partir de macOS 14 Sonoma.

**L’autorisation est activée, mais rien ne fonctionne.**
Dans **Réglages Système › Confidentialité et sécurité**, retirez pika-tools des deux listes avec le bouton −, puis ajoutez-la de nouveau. La page Autorisations des réglages de pika-tools a des boutons qui ouvrent le bon endroit.

## Contribuer

La compilation depuis les sources et la publication sont décrites dans [CONTRIBUTING.md](../../CONTRIBUTING.md). Les changements sont listés dans [CHANGELOG.md](../../CHANGELOG.md).

## Licence

MIT, © 2026 pikapik. Voir [LICENSE](../../LICENSE).
