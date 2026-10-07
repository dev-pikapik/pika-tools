# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · **Español** · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![Última versión](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Licencia: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Descargas](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Una pequeña app para la barra de menús de macOS que mejora las teclas, las ventanas y el Dock: bloquea los atajos con Control, protege ⌘Q y ⌘W, cambia de idioma con Opción+Mayúsculas como Alt+Mayús en Windows, repite una tecla mantenida como en Windows, desactiva la aceleración del ratón, desplaza la rueda del ratón por líneas como en Windows, hace que los botones laterales del ratón vayan atrás y adelante, cierra las apps cuando cierras su última ventana, oculta una app con un clic en el Dock y mantiene tu Mac despierto.

## Instalación

Con [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Sin Homebrew, abre Terminal, pega esta línea y pulsa Retorno:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

O descarga [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), ábrelo y arrastra la app a la carpeta Aplicaciones.

Tanto Homebrew como el script colocan la app en `/Applications`, la abren, piden los permisos y activan la apertura al iniciar sesión. Después, la app se actualiza sola; consulta [Actualizaciones](#actualizaciones). Para eliminarla, consulta [Desinstalación](#desinstalación).

## Primer inicio

pika-tools necesita dos permisos. La primera vez que se abre, muestra los ajustes en la página Permisos, que te guía paso a paso, y macOS muestra sus propios avisos. Ve a **Ajustes del Sistema › Privacidad y seguridad** y activa pika-tools en:

- **Accesibilidad**, para que la app pueda cambiar una pulsación o un clic antes de que llegue a otras apps.
- **Monitorización de entrada**, para que la app pueda ver las pulsaciones y los clics.

La app detecta el cambio en un par de segundos, sin necesidad de reiniciar.

pika-tools no graba, no guarda ni envía nada de lo que escribes o pulsas. Los eventos se procesan en memoria y se transmiten al instante. La única conexión de red es la búsqueda de actualizaciones, que pregunta a GitHub cuál es la última versión.

## Funciones

**Bloquear atajos con Control.** Control se convierte en una tecla normal. Las apps siguen viendo que está pulsada, pero macOS ya no la convierte en atajos: Control+Espacio no cambia la fuente de entrada, Control+flechas no cambian de escritorio y Control+clic es un clic normal en vez de abrir un menú contextual. El clic secundario y el toque con dos dedos funcionan como siempre. Útil en juegos y en sesiones de escritorio remoto, donde Control tiene su propia función. Puedes añadir las apps en las que Control debe funcionar como siempre, por ejemplo un cliente de escritorio remoto: el bloqueo no les afecta.

**Proteger ⌘Q y ⌘W.** ⌘Q y ⌘W por sí solos no hacen nada, así que no cerrarás una app ni una ventana por accidente. Añade Mayúsculas para hacerlo a propósito: ⇧⌘Q sale de la app y ⇧⌘W cierra la ventana. Funciona en todas las apps. Cada tecla tiene su propio interruptor. Desactivado por omisión.

**Cambiar de idioma con Opción+Mayúsculas.** Mantén pulsada Opción y toca Mayúsculas: macOS pasa a la siguiente fuente de entrada. Sigue manteniendo Opción y vuelve a tocar Mayúsculas para avanzar más. Mantén pulsada Mayúsculas y toca Opción para retroceder. Si entre medias pulsas otra tecla, haces clic o añades Comando, Control o Fn, no cambia nada, así que atajos como Opción+Mayúsculas+flecha siguen funcionando como antes. Desactivado por omisión.

**Repetir una tecla mantenida.** Mantén pulsada una tecla y la letra se escribe una y otra vez, como en Windows, en lugar de abrir el menú de acentos. Viene genial en juegos y al escribir. Las apps que ya están abiertas lo aplican tras reiniciarlas. Si lo desactivas, macOS vuelve a funcionar como siempre. Desactivado por omisión.

**Desactivar la aceleración del puntero.** El puntero se mueve exactamente lo mismo que el ratón, por rápido que lo muevas, como con LinearMouse. Un regulador **Velocidad del cursor** ajusta lo rápido que va. Solo funciona con ratones; el trackpad se queda como está. Desactívalo o sal de pika-tools y macOS recupera sus propios ajustes. Desactivado por omisión.

**Desplazarse por líneas.** Cada clic de la rueda del ratón desplaza el mismo número de líneas, por rápido que la gires, como en Windows. Elige de 1 a 10 líneas por clic, 3 por omisión. El desplazamiento natural se queda como lo hayas ajustado en Ajustes del Sistema. Solo funciona con ratones, el trackpad no cambia. Desactivado por omisión. Junto al control deslizante **Distancia por clic**, una página pequeña se desplaza la distancia que elijas, y un punto marca el valor predeterminado.

Algunas apps y juegos cuentan el desplazamiento en píxeles exactos: para ellos, cambia este mismo ajuste a píxeles y elige de 1 a 200 píxeles por clic, 40 por omisión. El control también indica qué parte de la altura de la pantalla supone.

**Dirección de desplazamiento para el trackpad y el ratón.** macOS tiene un solo interruptor de desplazamiento natural para el trackpad y el ratón a la vez. Actívalo y elige una dirección para cada uno: **Natural**, donde la página sigue a tus dedos como en el iPhone, o **Clásica**, como en Windows. La opción del trackpad también vale para el desplazamiento lateral y para la inercia al levantar los dedos. El Magic Mouse se desplaza al tacto, así que sigue la opción del trackpad. Elige lo mismo en cada uno de tus Mac y el desplazamiento será igual en todos, incluso cuando pasas el ratón a otro Mac con Control universal. Desactivado por omisión. Al activarlo, los dos empiezan como en Ajustes del Sistema, así que nada cambia hasta que elijas otra cosa.

**Botones laterales para atrás y adelante.** Los botones 4 y 5 del ratón van atrás y adelante en Safari, el Finder y otras apps de Apple, en Firefox, Opera y ForkLift, igual que deslizar el dedo en el trackpad. Otras apps, como los IDE de JetBrains, reciben los botones tal cual y los gestionan a su manera. Si tu ratón los tiene al revés, activa **Intercambiar los botones laterales**. Desactivado por omisión.

**Salir al cerrar la última ventana.** Cierra la última ventana de una app y la app se cierra, como en Windows. El Finder sigue abierto, igual que las apps con ventanas en otros escritorios o en el Dock. Puedes hacer una lista de apps que nunca deben cerrarse así. Desactivado por omisión.

**Ocultar con un clic en el Dock.** Haz clic en el icono del Dock de la app que estás usando y se ocultará. Vuelve a hacer clic para que reaparezca. Desactivado por omisión.

**El botón verde amplía la ventana.** Haz clic en el botón verde de una ventana y esta crece hasta llenar la pantalla, sin pasar a pantalla completa. Otro clic devuelve el tamaño anterior. Si mantienes pulsado ⌥, el botón funciona como siempre. La pantalla completa sigue en el menú del botón y con ⌃⌘F. Puedes indicar las apps en las que el botón verde debe funcionar como siempre. Desactivado por omisión.

**Archivo nuevo en el Finder.** Haz clic derecho en una ventana del Finder o en el escritorio, elige **Archivo nuevo**, escribe un nombre y aparece un archivo vacío, como Nuevo › Documento de texto en Windows. .txt por omisión. Desactivado por omisión.

**Intro abre los archivos en el Finder.** Selecciona archivos en una ventana del Finder o en el escritorio y pulsa Retorno o Intro: se abren, como en Windows. F2 o fn F2 renombra el archivo seleccionado. En los campos de texto, por ejemplo mientras escribes un nombre, las teclas funcionan como siempre. Desactivado por omisión.

**⌘X corta archivos en el Finder.** Selecciona archivos y pulsa ⌘X, abre la carpeta de destino y pulsa ⌘V: los archivos se mueven allí en lugar de copiarse, como Cortar y Pegar en Windows. ⌘C cancela el corte. Desactivado por omisión.

**Copia más ligera y conversión en el Finder.** Haz clic derecho en un archivo en el Finder. **Crear copia más ligera** guarda al lado una versión más ligera de una foto, un PDF o un vídeo, a menudo varias veces más pequeña. **Convertir a** guarda el archivo en otro formato: una imagen como JPEG, PNG, HEIC, TIFF o PDF, un vídeo como MP4, MOV o solo su sonido, la música como M4A, WAV o AIFF. El original se queda tal cual y nada sale de tu Mac. Desactivado por omisión.

Cada herramienta tiene su propio interruptor en el menú y en los ajustes. ¿Necesitas recuperar el Control+C normal? Desactiva esa herramienta.

El icono de la barra de menús muestra el estado de un vistazo: una flecha con un clic cuando las herramientas funcionan, una flecha tachada cuando todo está desactivado y un triángulo de aviso cuando una herramienta está activada pero faltan permisos.

El panel de la barra de menús empieza con solo unas pocas filas. Tú eliges cuáles muestra: haz clic en el botón del lápiz de abajo, marca lo que quieras ver y haz clic en **Hecho**. Las filas ocultas siguen funcionando y se quedan en Ajustes. Si el panel no cabe en la pantalla, se desplaza.

La app usa el idioma del sistema o el que elijas en los ajustes. Están disponibles los 23 idiomas de la lista al principio de esta página.

## Mantener activo

Evita que tu Mac entre en reposo mientras no estás frente al teclado: durante cualquier tiempo de 1 segundo a 365 días, o hasta que lo desactives. Actívalo desde el menú y define la duración en los ajustes: escribe días, horas, minutos y segundos, usa ↑ y ↓ o haz clic en una opción rápida de 15 minutos a 8 horas. El menú muestra cuánto tiempo queda y cuándo termina. **Mantener la pantalla encendida** evita además que la pantalla se atenúe. Al salir de pika-tools, Mantener activo termina.

En un MacBook también puedes activar **Funcionar con la tapa cerrada**. macOS no tiene un ajuste para esto, así que pika-tools ejecuta `pmset -a disablesleep 1` y pide una contraseña de administrador: solo un administrador puede cambiar cómo entra en reposo el Mac. El ajuste vuelve a la normalidad por sí solo cuando termina Mantener activo, cuando sales de la app o si se cierra inesperadamente. Si no introduces la contraseña, no cambia nada. Mantén el Mac bien ventilado con la tapa cerrada. **Detener con la batería por debajo del 20 %** termina la sesión antes de que se agote la batería.

Mantener activo, el modo de pantalla y el de tapa cerrada se pueden poner en un botón del Centro de control, de la barra de menús o en un widget del escritorio con la app Atajos, con enlaces que copias en Ajustes › Mantener activo.

## Ajustes

Abre los ajustes desde el menú con **Ajustes…** o ⌘, o vuelve a abrir pika-tools desde el Finder, Launchpad o Spotlight. Mientras la ventana está abierta, la app aparece en el Dock y en ⌘Tab.

- **General**: abrir al iniciar sesión, aspecto (Sistema, Claro u Oscuro), idioma, actualizaciones y copia de seguridad: exportar e importar los ajustes como archivo, o sincronizarlos con iCloud Drive.
- **Mantener activo**: duración y opciones de pantalla y de tapa.
- **Teclado**: atajos con Control, cambio de idioma, repetición de teclas.
- **Ratón**: aceleración del puntero y velocidad del cursor, desplazamiento por líneas, dirección de desplazamiento, botones laterales.
- **Ventanas**: ampliar con el botón verde (con una lista de excepciones), protección de ⌘Q y ⌘W, y salir al cerrar la última ventana (con una lista de excepciones).
- **Dock**: ocultar con un clic en el Dock.
- **Finder**: archivo nuevo, copia más ligera y conversión, abrir con Intro y cortar con ⌘X.
- **Permisos**: el estado de ambos permisos, y de iCloud Drive cuando la sincronización está activada, con botones que abren el lugar adecuado en Ajustes del Sistema.
- **Acerca de**: versión, enlaces al historial de cambios y para informar de un problema.

Muchos ajustes incluyen una imagen pequeña que muestra lo que hacen, como un Mac que no se duerme o una ventana que se oculta tras el Dock. La imagen cambia junto con el interruptor y se queda quieta cuando «Reducir movimiento» está activado en Ajustes del Sistema.

Cada página tiene abajo un botón **Restaurar valores por omisión…**. Primero pregunta y luego desactiva las herramientas de esa página y devuelve sus opciones a como estaban, como si pika-tools nunca las hubiera tocado.

**Sincronizar ajustes con iCloud** mantiene pika-tools igual en todos tus Mac. Los ajustes viven en la carpeta pika-tools de iCloud Drive y gana el cambio más reciente. Está desactivado por omisión y necesita iCloud Drive activado. Los permisos no se sincronizan: cada Mac los pide por su cuenta.

## Actualizaciones

pika-tools busca nuevas versiones al abrirse y cada 6 horas. Puedes desactivarlo en Ajustes › General. Cuando sale una nueva, aparece en el menú un botón **Actualizar a …**: con un clic, la app descarga la actualización, la instala y se reinicia. También puedes comprobarlo tú con **Buscar ahora** en Ajustes › General.

Con Homebrew también puedes ejecutar `brew upgrade --cask pika-tools`.

Desde la versión 1.3, los permisos se conservan tras las actualizaciones.

## Desinstalación

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Si instalaste con Homebrew: `brew uninstall --cask --zap pika-tools`.

Ambos cierran la app, la quitan de los ítems de inicio y la eliminan. El script además restablece sus permisos.

## Preguntas frecuentes

**¿Por qué necesita dos permisos?**
macOS divide el acceso al teclado y al ratón en dos. La monitorización de entrada permite a la app ver los eventos, y la accesibilidad le permite cambiarlos. Para bloquear un atajo hacen falta los dos.

**macOS dice que la app es de un desarrollador no identificado.**
pika-tools está firmada, pero Apple no la ha notarizado. Homebrew y el script de instalación se encargan de esto por ti. Si usaste el dmg, abre **Ajustes del Sistema › Privacidad y seguridad** y haz clic en **Abrir igualmente**, o ejecuta:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**¿Funciona en Mac con Intel?**
Sí. Es una app universal para Apple Silicon e Intel, con macOS 14 Sonoma o posterior.

**El permiso está activado, pero nada funciona.**
En **Ajustes del Sistema › Privacidad y seguridad**, elimina pika-tools de ambas listas con el botón − y vuelve a añadirla. La página Permisos de los ajustes de pika-tools tiene botones que abren el lugar adecuado.

## Contribuir

Cómo compilar desde el código fuente y publicar versiones se explica en [CONTRIBUTING.md](../../CONTRIBUTING.md). Los cambios se recogen en [CHANGELOG.md](../../CHANGELOG.md).

## Licencia

MIT, © 2026 pikapik. Consulta [LICENSE](../../LICENSE).
