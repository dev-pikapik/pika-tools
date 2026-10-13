<p align="center"><a href="../readme/README.es.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Novedades de pikapik</h1>
<p align="center">Cada actualización en pocas palabras y una imagen, la más reciente primero.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <b>Español</b> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.43.0"></a>Mira qué se ejecuta en segundo plano

<sub>1.43.0 · 13 de octubre de 2026</sub>

pikapik ahora muestra todo lo que arranca solo y qué app lo añadió, y apaga tus propias tareas sin borrar nada.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.43.0/background-dark.png"><img src="../media/whats-new/1.43.0/background-light.png" width="340" alt=""></picture>

En Ajustes, la nueva página Tareas en segundo plano muestra las apps que se abren al iniciar sesión, los servicios en segundo plano, los ayudantes metidos dentro de las apps y los restos de apps eliminadas. Cada tarea indica qué app la añadió, si está en marcha ahora y dónde está su archivo. Con un clic ves el archivo en el Finder.

Tus propias tareas se apagan y vuelven a encenderse con un botón. No se borra nada. En las tareas para todos los usuarios y para todo el Mac, el botón abre Ítems de inicio en Ajustes del Sistema.

En la versión de la Mac App Store, la página muestra las tareas, y sus botones abren Ítems de inicio.

---

## <a id="v1.42.0"></a>Mira lo caliente que está tu Mac por dentro

<sub>1.42.0 · 13 de octubre de 2026</sub>

Una nueva página Temperatura en Ajustes muestra la temperatura del procesador, de los gráficos, de la memoria, del almacenamiento, de la batería y del Wi-Fi, y te dice con palabras sencillas si todo va bien.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/temperatures-dark.png"><img src="../media/temperatures-light.png" width="340" alt=""></picture>

Abre Ajustes › Temperatura. Arriba, una sola palabra lo resume: «Normal», «Algo caliente», «Caliente» o «Muy caliente», y una línea corta debajo te dice si tu Mac funciona a toda velocidad o va más lento para enfriarse. Más abajo, cada componente que tu Mac puede medir tiene su propia fila con la temperatura y una barra de color: verde si todo va bien, amarilla si está algo caliente y naranja si está caliente, según lo que es normal para ese componente.

¿Quieres tenerla siempre a la vista? Haz clic en el lápiz de la parte inferior del menú de pikapik y marca «Temperatura». El menú muestra entonces la misma palabra y la temperatura del procesador, y un clic en la fila abre la página.

Las temperaturas se actualizan cada dos segundos, pero solo mientras la página o el menú están abiertos, así que no se comprueba nada en segundo plano. pikapik solo lee las temperaturas: no necesita contraseña y no cambia nada.

**Corregido**

- Si elegiste qué filas muestra el menú de pikapik, la fila «Mantener el Dock en una sola pantalla» ya no aparece sola en él. Para mostrarla, haz clic en el lápiz y márcala.
- Cuando cierras Ajustes, pikapik ahora deja de revisar los ventiladores y la batería al instante, en vez de seguir haciéndolo en segundo plano.

---

## <a id="v1.41.1"></a>El control de ventiladores ya no te pide la contraseña

<sub>1.41.1 · 13 de octubre de 2026</sub>

El ayudante que ajusta la velocidad de los ventiladores ahora se actualiza junto con pikapik, así que las nuevas versiones ya no piden la contraseña de administrador.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Esta actualización la pide por última vez. Si usas el control de ventiladores, abre Ajustes › Permisos, haz clic en «Permitir» junto a «Control de ventiladores» e introduce la contraseña. A partir de ahí, pikapik actualiza el ayudante por sí solo y solo acepta un ayudante que de verdad venga de pikapik.

**Corregido**

- En Ajustes del Sistema › General › Ítems de inicio, el ayudante de los ventiladores ahora aparece como pikapik, con el icono de la app.

---

## <a id="v1.41.0"></a>Mira cómo está tu batería

<sub>1.41.0 · 13 de octubre de 2026</sub>

Una nueva página Batería en Ajustes muestra cuánto se ha desgastado la batería, con qué se carga y cómo hacer que dure más.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/battery-dark.png"><img src="../media/battery-light.png" width="340" alt=""></picture>

Abre Ajustes › Batería. Verás la carga y lo que le pasa a la batería ahora mismo, su estado, su capacidad máxima en comparación con cuando era nueva y el número de ciclos que lleva de los 1000 para los que está diseñada.

Cuando tu Mac está conectado, la página muestra el adaptador de corriente y su potencia y, mientras se carga, también la potencia de carga, es decir, lo que entra en la batería ahora mismo. Cuando tu Mac funciona con batería, la página muestra lo que consume en este momento.

Los consejos de abajo ayudan a que la batería dure más, y «Ajustes de la batería…» abre Batería en Ajustes del Sistema, donde eliges cómo la carga macOS. La página no cambia nada y no necesita ningún permiso, tampoco en la versión de la Mac App Store. Solo aparece en los Mac con batería.

**Corregido**

- Al eliminar pikapik con Homebrew, ahora también se desactiva «Abrir al iniciar sesión» y se restauran los ajustes del sistema que había cambiado, como las animaciones, la repetición de teclas y las esquinas activas. Si pikapik se ha estado actualizando solo, ejecuta una vez brew upgrade --cask pikapik antes de eliminarlo.

---

## <a id="v1.40.2"></a>Las actualizaciones con Homebrew ya no reinician el Dock

<sub>1.40.2 · 13 de octubre de 2026</sub>

Cuando actualizas pikapik con Homebrew, el Dock ya no desaparece un instante.

La actualización a esta versión todavía puede reiniciar el Dock una última vez, porque ese paso aún lo hace la versión que tenías antes. Las actualizaciones siguientes ya no lo tocan.

---

## <a id="v1.40.1"></a>Un clic en el Dock guarda las ventanas

<sub>1.40.1 · 13 de octubre de 2026</sub>

Haz clic en el icono del Dock de la app con la que trabajas, y todas sus ventanas se minimizan en el Dock. Haz clic otra vez, y vuelven todas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.40.1/dock-minimize-dark.png"><img src="../media/whats-new/1.40.1/dock-minimize-light.png" width="340" alt=""></picture>

Abre Ajustes › Dock y activa «Minimizar u ocultar con un clic en el Dock». Las ventanas vuelven en el mismo orden, con la que estabas usando encima. Un clic en otra app, mantener pulsado un icono para ver su menú y arrastrar iconos funcionan igual que antes.

¿Prefieres ocultar toda la app, como con ⌘H? Debajo del interruptor, cambia «Un clic en el icono» a «Oculta la app». Si ya ocultabas apps con un clic en el Dock, para ti no cambia nada. El interruptor necesita el permiso «Accesibilidad», no está en la versión de la Mac App Store y viene desactivado por omisión.

---

## <a id="v1.40.0"></a>El Dock se queda en una sola pantalla

<sub>1.40.0 · 13 de octubre de 2026</sub>

El Dock ya no salta a otra pantalla cuando el puntero empuja contra el borde de esa pantalla: se queda donde lo has puesto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-display-dark.png"><img src="../media/dock-display-light.png" width="340" alt=""></picture>

Abre Ajustes › Dock y activa «Mantener el Dock en una sola pantalla». Después el Dock se queda en su pantalla, abajo o en un lateral, y las esquinas activas siguen funcionando. No hace falta ningún permiso, tampoco en la versión de la Mac App Store.

Para mover el Dock a propósito, mantén pulsada ⌥ y empuja el puntero contra el borde de la otra pantalla. El Dock se pasa a esa pantalla y desde entonces se queda en ella.

Un segundo interruptor, «Devolver el Dock a su sitio», lleva el Dock de vuelta a su pantalla automáticamente tras el reposo o cuando cambian las pantallas. Necesita el permiso «Accesibilidad» y no está en la versión de la Mac App Store. Los dos interruptores están desactivados por omisión.

---

## <a id="v1.39.4"></a>El botón rojo ya no detiene los archivos comprimidos

<sub>1.39.4 · 13 de octubre de 2026</sub>

Antes, si cerrabas la ventana de la contraseña con el botón rojo, pikapik dejaba de abrir y crear archivos comprimidos hasta que lo reiniciabas. Ya está corregido.

Ahora el botón rojo de la ventana de la contraseña y de la de un archivo comprimido nuevo funciona igual que “Cancelar”, y el siguiente archivo se abre enseguida. VoiceOver ahora lee el botón de actualización de Ajustes › Acerca de por su propio nombre.

---

## <a id="v1.39.3"></a>Tu mascota sigue tu ritmo

<sub>1.39.3 · 13 de octubre de 2026</sub>

Mientras escribes, tu mascota se anima y trota con paso alegre. Si te alejas de tu Mac, le entra sueño, se sienta y se adormece.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.3/pet-rhythm-dark.png"><img src="../media/whats-new/1.39.3/pet-rhythm-light.png" width="340" alt=""></picture>

Tras unos 40 segundos sin tocar el teclado ni el ratón, le empiezan a pesar los párpados, y al minuto y medio ya duerme como un tronco, con pequeñas zetas que suben flotando. Pulsa una tecla o mueve el ratón y se despertará, se levantará y seguirá su camino. Mientras dormita, está callada y gasta menos energía.

pikapik nunca mira lo que escribes. Solo comprueba cuánto tiempo ha pasado desde la última vez que pulsaste una tecla o moviste el ratón, igual que hace macOS antes de atenuar la pantalla, así que no necesita ningún permiso. ¿Prefieres que tu mascota esté siempre animada? Desactiva «Sigue tu ritmo» en los ajustes de la mascota.

**Pruébalo:** Ajustes › Mascota › Sigue tu ritmo

---

## <a id="v1.39.2"></a>Los ajustes sincronizados ahora están en una carpeta pikapik

<sub>1.39.2 · 13 de octubre de 2026</sub>

Si sincronizas tus ajustes con iCloud, ahora están en iCloud Drive, en una carpeta llamada pikapik en lugar de pika-tools, y pikapik los mueve allí por sí solo.

<img src="../media/icon.png" width="128" height="128" alt="">

No tienes que hacer nada: tus ajustes siguen igual y la carpeta antigua desaparece cuando se han movido. Si guardaste en ella archivos tuyos, se queda donde está. Si sincronizas varios Mac, actualiza pikapik en cada uno para que sigan compartiendo los ajustes.

**Corregido**

- Eliminar pikapik por completo con Homebrew (brew uninstall --zap) ahora también borra la lista de apps eliminadas recientemente.
- Las publicaciones anteriores de esta página ahora llaman a la app pikapik.

---

## <a id="v1.39.1"></a>La barra de título de siempre en las ventanas de archivos comprimidos

<sub>1.39.1 · 13 de octubre de 2026</sub>

Las ventanas de archivos comprimidos vuelven a tener la barra de título de siempre de macOS, con tres botones redondos a la izquierda.

Puedes arrastrar una ventana por la parte de arriba, como en cualquier parte del Mac. En la ventana de un archivo comprimido nuevo y en la de la contraseña, el botón rojo cierra la ventana sin crear ni descomprimir nada. Los botones que no tienen nada que hacer en una ventana aparecen en gris. La ventana que muestra el progreso al crear una copia más ligera o convertir un archivo también tiene ahora estos botones. Ahora el interruptor «Abrir archivos comprimidos con esta app» recuerda qué app abría antes los archivos ZIP y 7Z, y se los devuelve al desactivarlo.

---

## <a id="v1.39.0"></a>Nuevas ventanas de archivos comprimidos y la contraseña dos veces

<sub>1.39.0 · 13 de octubre de 2026</sub>

Cuando pones contraseña a un nuevo archivo comprimido, ahora la escribes dos veces, para que una errata no te deje sin acceso a tus propios archivos.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Debajo de los campos aparece una línea verde cuando las contraseñas coinciden, o roja cuando no, y «Crear» espera hasta que coincidan.

Todas las ventanas de archivos comprimidos tienen un aspecto nuevo: un icono grande, un solo interruptor para la contraseña y una línea breve que te dice si los nombres de los archivos quedan a la vista, como en ZIP, o también se ocultan, como en 7Z. En macOS 26 los botones son de Liquid Glass.

Instalar también es más fácil: el comando al principio de la página de pikapik en GitHub no necesita nada más en tu Mac. Instala pikapik solo si la descarga está firmada por su desarrollador y ha pasado la revisión de malware de Apple.

---

## <a id="v1.38.2"></a>Actualizaciones más seguras junto a la versión de la App Store

<sub>1.38.2 · 12 de octubre de 2026</sub>

Si también tienes pikapik de la App Store en tu Mac, la versión de GitHub ahora se actualiza en su sitio y no toca la versión de la App Store.

Antes, si la versión de GitHub conservaba su nombre antiguo, pika-tools, y no estaba instalada con Homebrew, la actualización no se instalaba, en su lugar se abría la versión de la App Store y se desactivaba la apertura de pikapik al iniciar sesión.

---

## <a id="v1.38.1"></a>Un menú del Finder más fiable

<sub>1.38.1 · 12 de octubre de 2026</sub>

Las opciones que pikapik añade al Finder con un clic derecho ya no desaparecen al conectar un disco, abrir una imagen de disco, reactivar el Mac o cambiar al Finder.

En casos poco frecuentes, el asistente que las muestra se cerraba justo en ese momento.

---

## <a id="v1.38.0"></a>Abre y crea archivos comprimidos en el Finder

<sub>1.38.0 · 12 de octubre de 2026</sub>

Los nuevos «Archivos comprimidos en el Finder» abren RAR y otros archivos que macOS no entiende, y crean ZIP y 7Z con un clic derecho.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Abre Ajustes › Finder y activa «Archivos comprimidos en el Finder». Haz clic derecho en un archivo comprimido y elige «Extraer», y sus archivos aparecen a su lado. Haz clic derecho en cualquier otro archivo o carpeta y elige «Crear archivo comprimido…» para obtener un ZIP, 7Z, TAR.GZ o TAR.XZ. Un ZIP o un 7Z puede llevar contraseña, y cualquier archivo comprimido se puede dividir en partes, por ejemplo de 15 MB para el correo. Un ZIP creado así no lleva archivos ocultos de servicio y conserva legibles los nombres en cualquier idioma.

pikapik también abre lo que macOS no puede: RAR, incluso dividido en varios archivos, 7Z protegido con contraseña, ZIPX, CAB, LZH, ARJ, ZST, WIM y más. Un doble clic los abre en pikapik. Los nombres de archivo de ZIP antiguos, por ejemplo en cirílico, japonés o chino, ahora se leen bien. El interruptor «Abrir archivos comprimidos con esta app» también pasa los ZIP y 7Z a pikapik, mientras que los TAR y GZ se quedan con la app de archivos comprimidos integrada, que ya los maneja bien.

Una ventana pide la contraseña, «Detener» cancela cualquier tarea, y de un archivo comprimido dañado pikapik saca lo que aún se puede leer. Antes de extraer un archivo comprimido que se hincharía hasta un tamaño enorme, pikapik pregunta, y los que intentan escribir fuera de su propia carpeta quedan bloqueados. No está en la versión de la Mac App Store. Selecciona un archivo comprimido y pulsa Espacio para ver lo que contiene.

---

## <a id="v1.37.3"></a>La etiqueta de FPS pide el permiso en el lugar correcto

<sub>1.37.3 · 12 de octubre de 2026</sub>

La grabación de pantalla para la etiqueta de FPS ahora se permite en la página Permisos, junto con todos los demás permisos.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Para contar los fotogramas de un juego, «Mostrar FPS» puede necesitar la grabación de pantalla. Antes, pikapik la pedía en la propia página Juegos. Ahora está con todos los demás permisos: cuando «Mostrar FPS» la necesita, aparece una fila «Grabación de pantalla» en Ajustes › Permisos, y haces clic en «Permitir» ahí.

En la página Juegos ahora solo ves la línea de siempre bajo el interruptor: «Necesita un permiso. Haz clic para permitirlo.» Su botón «Permitir» te lleva directo a la fila «Grabación de pantalla». Activar «Mostrar FPS» ya no abre una pregunta por sí solo, y pikapik sigue sin pedir nada mientras juegas.

---

## <a id="v1.37.2"></a>Verificado por Apple

<sub>1.37.2 · 12 de octubre de 2026</sub>

pikapik ahora está firmado por un desarrollador verificado de Apple y comprobado por Apple. Por eso macOS ya no te avisa al abrirlo por primera vez.

Tras esta actualización, macOS puede volver a pedirte los permisos que diste a pikapik, como Accesibilidad, Monitorización de entrada o Acceso total al disco. Permítelos otra vez en Ajustes del Sistema › Privacidad y seguridad. Si usas el control de ventiladores, permítelo de nuevo en los ajustes de pikapik, y macOS te pedirá la contraseña una vez.

---

## <a id="v1.37.1"></a>La etiqueta de FPS sigue a tu juego sin retraso

<sub>1.37.1 · 12 de octubre de 2026</sub>

Mueve la ventana del juego y la etiqueta de FPS ahora se mueve con ella.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Antes, la etiqueta alcanzaba una ventana en movimiento solo una vez por segundo, más o menos, por lo que se quedaba atrás. Ahora revisa la ventana en cada fotograma de la pantalla y nunca va más de unas milésimas de segundo por detrás. Cuando la ventana está quieta, la revisa con menos frecuencia, así que apenas carga tu Mac mientras juegas. Además, ya no salta a otro sitio cuando parte de la ventana sale por el borde de la pantalla.

Si un juego tranquilo como el ajedrez muestra 0, no pasa nada: esos juegos solo dibujan una imagen nueva cuando algo se mueve. El número sube mientras una pieza se desliza y vuelve a 0 cuando el tablero se queda quieto.

---

## <a id="v1.37.0"></a>Mira lo fluido que va tu juego

<sub>1.37.0 · 12 de octubre de 2026</sub>

El nuevo «Mostrar FPS» pone un pequeño contador en una esquina de tu juego para que veas lo fluido que va.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Abre Ajustes › Juegos y activa «Mostrar FPS». Mientras el Modo de juego esté activado, aparece una pequeña etiqueta oscura con un número en una esquina de cualquier juego. FPS son los fotogramas por segundo: cuántas imágenes dibuja el juego cada segundo, y cuanto mayor es el número, más fluido va el juego. Haz clic en una esquina de la imagen que hay sobre el interruptor para elegir dónde se coloca.

Los clics atraviesan la etiqueta, que sigue a la ventana del juego. Un guion significa que aún no han llegado los primeros fotogramas, y un 0 atenuado, que el juego ha dejado de dibujar. «Mostrar FPS» está desactivado hasta que lo actives.

En macOS 27, macOS cuenta por sí mismo la mayoría de los juegos, así que no hace falta ningún permiso. Algunos juegos, sobre todo antiguos, solo se pueden contar mediante la grabación de pantalla, y entonces la cifra no puede superar la frecuencia de actualización de la pantalla. En macOS 14 a 26 y en la versión de la Mac App Store todos los juegos se cuentan así, por eso al activar «Mostrar FPS» pikapik pide «Grabación de pantalla». No se guarda ni se envía ninguna imagen.

---

## <a id="v1.36.0"></a>Elimina apps sin preocuparte

<sub>1.36.0 · 12 de octubre de 2026</sub>

El nuevo Eliminar apps quita una app con todos sus archivos y lo devuelve todo a su sitio si cambias de idea.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Abre Ajustes › Eliminar apps y elige una app, o suelta una sobre la imagen. pikapik muestra todo lo que la app guarda en tu Mac, con el motivo de cada archivo. Los archivos que claramente pertenecen a la app vienen marcados, y los que solo quizá estén relacionados, no. Haz clic en «Mover a la Papelera» y todo va a la Papelera, así que no se borra nada para siempre.

¿Has cambiado de idea? Haz clic en «Devolver a su sitio» y todo vuelve donde estaba. Las diez últimas eliminaciones esperan en «Eliminado recientemente» mientras sus archivos sigan en la Papelera. «Restablecer app» conserva la app y quita solo sus datos guardados, ajustes y archivos temporales, por si falla.

¿Moviste tú una app a la Papelera? La página muestra esas apps y los archivos que dejaron, y puedes activar un interruptor que ofrece limpiar cada vez que una app va a la Papelera. No se quita nada hasta que elijas. Para verlo todo, la página necesita Acceso total al disco.

---

## <a id="v1.35.0"></a>Viste a tu mascota

<sub>1.35.0 · 12 de octubre de 2026</sub>

Tu mascota ya tiene armario, y consigues prendas nuevas mientras jugáis juntos.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Abre Ajustes › Mascota y elige lo que lleva puesto tu mascota: gorros, gafas, bufandas, camisetas, zapatos, capas e incluso alas. Se lo pone al instante. Unas pocas prendas son gratis y el resto son premios que llegan mientras jugáis juntos: coge a tu mascota y lánzala, dale patadas a la pelota, mírala trepar por las ventanas y charlar, o simplemente hazle compañía día tras día. Cuando consigas un premio, tu mascota te lo dirá.

Los disfraces ya preparados la visten de pies a cabeza con un clic: mago, pirata, astronauta, superhéroe, rey y más. Un disfraz está listo cuando has conseguido todas sus piezas.

Solo se guardan números sencillos, como pasos, lanzamientos y días juntos. Se quedan en tu Mac, no se envía nada a ninguna parte y puedes borrarlos cuando quieras en Ajustes › Mascota.

---

## <a id="v1.34.0"></a>Ratón y trackpad en los juegos

<sub>1.34.0 · 12 de octubre de 2026</sub>

Los deslizamientos, los pellizcos y las esquinas activas ya no te sacan del juego, igual que los atajos de teclado.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

En Ajustes › Juegos › Más ajustes del juego hay un grupo llamado «Ratón y trackpad». Muestra solo lo que está activado en macOS en tu Mac, con los nombres de Apple y un pequeño dibujo para cada uno: atajos en un botón del ratón, deslizar entre escritorios y apps a pantalla completa, Mission Control y App Exposé, pellizcar para las apps y separar los dedos para el escritorio, deslizar desde el borde derecho para el Centro de notificaciones y cada esquina activa con su acción. Mientras un juego está al frente, quedan en pausa, así que un deslizamiento accidental o un roce con la esquina de la pantalla no te sacará del juego. Los gestos dentro del juego siguen funcionando. Cada uno se puede dejar funcionando como siempre.

---

## <a id="v1.33.2"></a>Los grupos de atajos se abren al instante

<sub>1.33.2 · 11 de octubre de 2026</sub>

Incluso el grupo más largo de atajos del sistema se abre enseguida, y cada fila tiene un nombre claro.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Antes, la ventana de ajustes se congelaba un momento al abrir un grupo de decenas de filas, porque todas las filas y sus vistas previas animadas se construían a la vez. Ahora solo se construyen las filas visibles y unas pocas cercanas. También desaparecieron las filas «Acción del sistema» con un número: Dictado, Siri y las teclas de brillo y zoom muestran su nombre real, y las acciones a las que macOS no pone nombre se ocultan, pero se siguen pausando en los juegos como antes.

---

## <a id="v1.33.1"></a>Los grupos de atajos se abren sin bloqueos

<sub>1.33.1 · 11 de octubre de 2026</sub>

La página Juegos sigue fluida al abrir una lista larga de vistas previas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Al abrir un grupo de atajos de teclado del sistema, la ventana de ajustes se congelaba hasta tres segundos, porque cada fila con su vista previa se calculaba varias veces. Ahora cada fila se calcula una sola vez, así que los grupos se abren casi al instante.

---

## <a id="v1.33.0"></a>Todos los permisos en un solo lugar

<sub>1.33.0 · 11 de octubre de 2026</sub>

Ajustes › Permisos ahora reúne todo lo que usa pikapik y te deja retirar cualquier permiso.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Ajustes › Permisos ahora muestra cada permiso que usa pikapik, desde Accesibilidad y Monitorización de entrada hasta Control de ventiladores, Extensiones de Finder, iCloud Drive y Acceso total al disco. Cada fila dice en una frase para qué sirve, con una marca verde cuando está activo y una cruz naranja cuando falta.

Cada fila tiene un solo botón: Permitir cuando falta, Apagar cuando está activo. Así puedes retirar cualquier permiso ahí mismo, sin buscar en Ajustes del Sistema. En Accesibilidad y Monitorización de entrada, pikapik te pregunta primero y después se reinicia sin ellos.

Una herramienta que necesita un permiso que no has dado aparece en gris. Haz clic en ella y se abre Permisos con la fila correcta resaltada, lista para un clic en Permitir.

**Pruébalo:** Abre Ajustes › Permisos y echa un vistazo a cada fila. Haz clic en una herramienta gris para ir directo al permiso que necesita.

---

## <a id="v1.32.2"></a>Instalación más segura y actualizaciones que nunca pierden la app

<sub>1.32.2 · 11 de octubre de 2026</sub>

Una tanda de arreglos para instalar, actualizar y desinstalar con más seguridad.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

El ayudante de ventiladores ahora se instala con más cuidado y se comprueba antes de arrancar. Si una actualización no se puede copiar, tu pikapik actual se queda donde está. Al desinstalar también se quita el ayudante de ventiladores y se restauran tu ajuste de repetición de teclas, las esquinas del Dock y los atajos del sistema.

Las teclas mantenidas ya no se quedan atascadas cuando una herramienta se reinicia, y al desactivar «Repetir una tecla mantenida» recuperas tu propio ajuste del menú de acentos. La mascota descansa mientras la pantalla está en reposo o bloqueada, y una copia de archive.tar.gz ahora se llama archive 2.tar.gz.

---

## <a id="v1.32.1"></a>La velocidad manual de los ventiladores se mantiene al primer intento

<sub>1.32.1 · 11 de octubre de 2026</sub>

Elegir Manual en Ventiladores ya no vuelve a Auto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

A veces, la primera pulsación en Manual devolvía los ventiladores a Auto con un aviso de seguridad, y solo funcionaba la segunda. Ahora Manual se mantiene desde el primer intento.

Si un ventilador sale del modo Manual por sí solo, pikapik lo devuelve a Auto de verdad, así que lo que ve siempre coincide con lo que hace su Mac.

No tiene que permitir nada de nuevo. Actualice y funciona.

**Pruébalo:** Abra Ajustes › Ventiladores y elija Manual.

---

## <a id="v1.32.0"></a>Mira a qué velocidad giran tus ventiladores

<sub>1.32.0 · 11 de octubre de 2026</sub>

Una nueva pestaña Ventiladores muestra cada ventilador en vivo y te deja elegir su velocidad.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Los ventiladores ahora tienen su propia pestaña en Ajustes y una fila en el menú. Ves en tiempo real a qué velocidad gira cada uno, junto a un pequeño ventilador que gira con él.

Déjalo en Auto y tu Mac decide, como siempre. O elige Manual y mueve un solo control deslizante para fijar la velocidad que quieras. La primera vez lo permites una sola vez con la contraseña de administrador, y ya está.

Está pensado para ser seguro. Los ventiladores vuelven a Auto cuando sales de pikapik, cuando tu Mac se suspende, si pikapik se cierra por un fallo o cuando tu Mac se calienta.

**Pruébalo:** Abre Ajustes › Ventiladores y mira la velocidad. Elige Manual para probar el control deslizante.

---

## <a id="v1.31.4"></a>Detalles cuando los necesitas

<sub>1.31.4 · 11 de octubre de 2026</sub>

Una página de juegos más tranquila y una sola búsqueda.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Cada modo explica su función dentro de la lista desplegable. Al cerrarla, solo queda el nombre elegido en la página.

Se han eliminado las descripciones que repiten el nombre de la acción. La información adicional útil se conserva.

La búsqueda global encuentra acciones del sistema por nombre, función y teclas. Un resultado abre y resalta el ajuste exacto.

**Pruébalo:** Busca una acción en la búsqueda global y abre su lista de modos.

---

## <a id="v1.31.3"></a>Un mismo estilo para los ajustes de juego

<sub>1.31.3 · 11 de octubre de 2026</sub>

Vistas previas uniformes y opciones más claras.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Cada atajo tiene ahora la misma vista previa amplia que las protecciones del juego y las demás páginas de ajustes. Debajo aparecen su descripción, controles y una explicación de la opción elegida.

«Seguir las reglas del modo Juego». Un atajo breve cambia el idioma sin menú. Las teclas de juego mantenidas evitan cambios accidentales.

«Desactivar en juegos». Esta acción de macOS se desactiva cuando el juego está en primer plano. Al salir, funciona como antes. «Permitir en juegos». macOS ejecuta la acción normalmente, aunque abra una ventana o quite el foco al juego.

**Pruébalo:** Abre Más ajustes de juego, despliega los controles del sistema y elige cómo se comporta una acción al jugar.

---

## <a id="v1.31.2"></a>Ajustes de juego más claros

<sub>1.31.2 · 11 de octubre de 2026</sub>

Ajusta la protección y explora los atajos de tu Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Ocho temas claros sustituyen las carpetas repetidas. Cada encabezado tiene nombre, explicación, icono y contador. Haz clic en cualquier parte de la fila para abrirlo.

Cada acción explica lo que hace junto a su vista previa animada. Las teclas actuales y el comportamiento en juegos tienen su propia fila. La búsqueda también encuentra descripciones.

Las teclas sin asignar tienen un enlace claro a Ajustes del Sistema. Las protecciones generales del juego están agrupadas aparte y tus opciones se conservan.

**Pruébalo:** Abre Más ajustes de juego, despliega un tema y compara la descripción de una acción con su vista previa.

---

## <a id="v1.31.1"></a>Gestos de idioma en juegos

<sub>1.31.1 · 11 de octubre de 2026</sub>

Simple por defecto, con el catálogo completo del sistema cuando lo necesitas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

El gesto de idioma de pikapik funciona en el juego aunque los atajos de idioma de macOS no estén asignados o estén desactivados.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automático pausa las acciones que abren ventanas o cambian el foco. Un atajo de idioma breve e intencionado cambia la fuente sin una ventana del sistema. Las teclas de movimiento mantenidas tienen prioridad para que correr y saltar no cambien el idioma por accidente.

Cada acción se ajusta en el catálogo con búsqueda. El idioma puede cambiar en segundo plano; otras acciones se pueden pausar o permitir normalmente. Las elecciones se sincronizan. Otras apps que observan el teclado aparecen aparte. Forzar salida sigue disponible.

**Pruébalo:** Mantén ⌥ y pulsa ⇧: idioma siguiente. Mantén ⇧ y pulsa ⌥: anterior

---

## <a id="v1.31.0"></a>El modo Juego conoce los atajos de tu Mac

<sub>1.31.0 · 11 de octubre de 2026</sub>

Simple por defecto, con el catálogo completo del sistema cuando lo necesitas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Activa el modo Juego y juega. Más ajustes del juego contiene el catálogo de tu Mac con las teclas actuales y una vista animada de cada acción.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automático pausa las acciones que abren ventanas o cambian el foco. Un atajo de idioma breve e intencionado cambia la fuente sin una ventana del sistema. Las teclas de movimiento mantenidas tienen prioridad para que correr y saltar no cambien el idioma por accidente.

Cada acción se ajusta en el catálogo con búsqueda. El idioma puede cambiar en segundo plano; otras acciones se pueden pausar o permitir normalmente. Las elecciones se sincronizan. Otras apps que observan el teclado aparecen aparte. Forzar salida sigue disponible.

**Pruébalo:** Abre los ajustes adicionales, busca un atajo de captura o idioma y compara la vista con y sin protección.

---

## <a id="v1.30.14"></a>Los enlaces de atajos se abren sin fallos

<sub>1.30.14 · 11 de octubre de 2026</sub>

Pulsar un atajo desactivado ya no cierra pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

En la página Juegos puedes pulsar un atajo aunque no tenga teclas asignadas. Ajustes del Sistema se abre de forma segura.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Antes pikapik podía leer dos veces la misma fila cambiante mientras se abría la ventana. Si el texto desaparecía entre las lecturas, la app fallaba.

Ahora cada fila se lee una vez. El texto ausente se omite. También se corrigen los enlaces de atajos en otras páginas.

**Pruébalo:** Pulsa un atajo desactivado en la página Juegos.

---

## <a id="v1.30.13"></a>Mantén Control y sigue jugando

<sub>1.30.13 · 10 de octubre de 2026</sub>

Control ya no deja que el cambio de idioma le quite Espacio al juego.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Mantén Control para correr y pulsa Espacio para saltar. En modo Juego se pausa el cambio de idioma con Control+Espacio y Control+Option+Espacio.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

También se pausan otros atajos de macOS con Control, o Mayús y Option sin Command, incluidos los que hayas asignado. Las pulsaciones, liberaciones y teclas mantenidas llegan juntas al juego.

El gesto de idioma de pikapik y los atajos de salida con modificadores de juego tampoco interfieren. Al salir del juego, los atajos del sistema vuelven exactamente como estaban.

**Pruébalo:** Mantén Control, muévete y pulsa Espacio varias veces. Después sal del juego y cambia de idioma como siempre.

---

## <a id="v1.30.12"></a>Arrastra tu juego desde Monitor de Actividad

<sub>1.30.12 · 10 de octubre de 2026</sub>

El modo Juego acepta procesos arrastrados desde Monitor de Actividad.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Busca el proceso del juego y arrastra su fila a Tus juegos en Ajustes → Juegos.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Los juegos Java también funcionan sin un icono normal en el Dock. Antes se ignoraban esas filas porque contienen un número y nombre de proceso en lugar de un archivo.

El juego queda guardado para próximos inicios. Minecraft aparece con su nombre. El número y nombre deben coincidir con un proceso abierto.

**Pruébalo:** Arrastra la fila java de Minecraft abierto a Tus juegos.

---

## <a id="v1.30.11"></a>Añade tu juego mientras está abierto

<sub>1.30.11 · 10 de octubre de 2026</sub>

Los juegos abiertos aparecen primero al añadir un juego.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Abre Ajustes → Juegos → Añadir un juego y haz clic en el juego abierto. También aparecen los juegos que usan Java u otros entornos, incluso sin archivo .app. Minecraft se muestra como Minecraft en lugar de java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Las apps del Dock tienen su propia lista desplegable para que encuentres enseguida el juego abierto.

Otro… y arrastrar y soltar también aceptan el archivo ejecutable del juego, además de las apps. Tras añadirlo, el modo Juego se activa cuando cambias al juego.

**Pruébalo:** Deja el juego abierto, elige Añadir un juego y pulsa su icono. No hace falta buscar carpetas.

---

## <a id="v1.30.10"></a>Tu mascota se deja ver cuando salta

<sub>1.30.10 · 10 de octubre de 2026</sub>

Tu mascota ya no desaparece detrás de las ventanas cuando salta en una pantalla sin Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, si el Dock estaba en otra pantalla u oculto, tu mascota saltaba detrás de tus ventanas y desaparecía hasta aterrizar. Ahora, en cuanto se despega del suelo, se ve delante de tus ventanas en cualquier pantalla, con Dock o sin él. La pelota también.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Una ventana que solo roza el borde de tu mascota ya no la esconde al saltar. Tu mascota se queda detrás de una ventana solo cuando esta la tapa de verdad, como un video que estás viendo.

En el suelo, tu mascota y su pelota pasean detrás de tus ventanas, como siempre.

**Pruébalo:** Haz que el Dock se oculte o llévalo a otra pantalla y pulsa Espacio junto a una ventana. Tu mascota salta delante de ella.

---

## <a id="v1.30.9"></a>La pantalla completa es tuya, y la pelota juega limpio

<sub>1.30.9 · 10 de octubre de 2026</sub>

Tu mascota ya no se cuela en un video a pantalla completa, y la pelota ya no choca con cosas que no están ahí.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, mientras veías un video a pantalla completa, tu mascota podía asomarse de vez en cuando. Ahora pikapik le pregunta directamente a macOS si una pantalla está a pantalla completa y vuelve a comprobarlo cuando termina el cambio. Tu mascota y su pelota se quedan escondidas hasta que salgas de la pantalla completa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

La pelota ya no rebota contra el aire. Pasa volando por encima del Dock en vez de chocar con una pared invisible. El ratón ahora golpea la pelota solo cuando el puntero de verdad la toca. Un toque suave la hace rodar, un movimiento rápido la manda a volar. Y si tu mascota o su pelota se esconden detrás de una ventana, el ratón sobre esa ventana las deja en paz.

Arrastrar un archivo por el escritorio ya no le construye un escalón a tu mascota. Solo lo hace un marco de selección.

**Pruébalo:** Mira un video a pantalla completa y páusalo varias veces con la barra espaciadora. Tu mascota no aparece. Luego lanza el ratón contra la pelota.

---

## <a id="v1.30.8"></a>Las esquinas de la pantalla se quedan quietas mientras juegas

<sub>1.30.8 · 10 de octubre de 2026</sub>

En el Modo de juego, el ratón en los bordes y esquinas de la pantalla ya no activa las esquinas activas ni saca el Dock oculto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Antes, en plena partida, llevar el ratón a una esquina o al borde de la pantalla podía activar una esquina activa o sacar el Dock oculto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Ahora el Modo de juego apaga las esquinas activas y el Dock oculto mientras juegas. Unos segundos después de salir del juego, o al cerrar pikapik, vuelven tal como estaban.

Y el puntero ya no da tirones en el borde de la pantalla del juego.

**Pruébalo:** Activa el Modo de juego, abre un juego y lleva el ratón a una esquina de la pantalla. No aparece nada.

---

## <a id="v1.30.7"></a>Tu mascota ya no se mete en tu vídeo

<sub>1.30.7 · 10 de octubre de 2026</sub>

Cuando tu mascota o su pelota están detrás de una ventana, se quedan ahí aunque salten o vuelen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, si tu mascota o su pelota se escondían detrás de un vídeo o un juego, un salto o un vuelo podía sacarlas justo encima de lo que estabas viendo. Pulsar Espacio para pausar un vídeo también hacía salir a tu mascota.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ahora se quedan detrás de la ventana que las tapa, hagan lo que hagan. Y un vídeo a pantalla completa en Firefox las esconde al instante.

Detrás de las ventanas normales siguen escondiéndose igual que antes.

**Pruébalo:** Pon un vídeo en una ventana grande que tape la parte de abajo de la pantalla y pulsa Espacio para pausarlo. Tu mascota se queda detrás del vídeo.

---

## <a id="v1.30.6"></a>Con pantalla completa, tu mascota descansa en todas partes

<sub>1.30.6 · 10 de octubre de 2026</sub>

Mientras cualquier app está a pantalla completa, tu mascota y su pelota ahora se esconden en todas las pantallas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, al poner un vídeo o un juego a pantalla completa, tu mascota y su pelota a veces se iban a otra pantalla y seguían jugando allí.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ahora, mientras cualquier app está a pantalla completa, se esconden en todas tus pantallas. Sal de la pantalla completa y vuelven al momento.

Detrás de las ventanas normales siguen escondiéndose igual que antes.

**Pruébalo:** Si tienes dos pantallas, pon un vídeo a pantalla completa en una de ellas. Tu mascota y su pelota desaparecen de ambas y vuelven cuando sales de la pantalla completa.

---

## <a id="v1.30.5"></a>Tu mascota se aparta mientras ves algo o juegas

<sub>1.30.5 · 10 de octubre de 2026</sub>

Tu mascota y su pelota ahora se esconden mientras una app está a pantalla completa, también en los Mac con notch.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, en un Mac con notch, tu mascota podía quedarse encima de un vídeo o un juego a pantalla completa, y la pelota a veces aparecía sobre una app a pantalla completa en otra pantalla.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ahora, mientras una app ocupa toda la pantalla, tu mascota y su pelota esperan fuera de la vista. Sal de la pantalla completa y vuelven al momento.

Detrás de las ventanas normales siguen escondiéndose igual que antes.

**Pruébalo:** Pon un vídeo a pantalla completa o abre un juego. Tu mascota y su pelota no molestan hasta que termines.

---

## <a id="v1.30.4"></a>Tu mascota sigue a la vista cuando salta o viaja en una selección

<sub>1.30.4 · 10 de octubre de 2026</sub>

Tu mascota y su pelota ya no desaparecen detrás de las ventanas mientras están en el aire.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, cuando tu mascota saltaba por encima del puntero o subía en un recuadro de selección, una ventana maximizada la tapaba y parecía que había desaparecido.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ahora, mientras tu mascota o su pelota están más arriba que el Dock, se ven delante de tus ventanas. Al volver al suelo, pasan otra vez detrás.

Y tu mascota puede volver a pasear detrás del Dock, como antes.

**Pruébalo:** Maximiza una ventana, empieza un recuadro de selección en el escritorio junto al Dock para que tu mascota se suba y arrástralo despacio hacia arriba. Tu mascota viaja en él delante de la ventana.

---

## <a id="v1.30.3"></a>Tu mascota y su pelota ya no se meten bajo el Dock

<sub>1.30.3 · 9 de octubre de 2026</sub>

Tu mascota ya no pasea ni duerme bajo el Dock, así que siempre puedes verla.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Antes, tu mascota y su pelota solían pasear y descansar justo debajo del Dock, donde nadie podía verlas. Con una ventana maximizada parecía que tu mascota había desaparecido para siempre.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Ahora el Dock es como una pared para ellas. Tu mascota se da la vuelta en su borde y la pelota rebota en él.

Así tu mascota siempre se ve junto al Dock, incluso cuando una ventana ocupa toda la pantalla.

**Pruébalo:** Maximiza una ventana y observa un par de minutos. Tu mascota siempre se ve a la izquierda o a la derecha del Dock.

---

## <a id="v1.30.2"></a>Tu mascota ya no desaparece detrás de las ventanas

<sub>1.30.2 · 9 de octubre de 2026</sub>

Aunque una ventana tape a tu mascota, sigue viva y cae al suelo cuando sueltas la selección.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Cuando las ventanas tapaban toda la franja donde vive tu mascota, pikapik la pausaba y podía quedarse congelada en el aire. Ahora tu mascota y su pelota siguen vivas detrás de la ventana: caminan, caen y juegan. Solo el dibujo se toma un descanso.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Si un recuadro de selección levanta a tu mascota detrás de una ventana, cae en cuanto lo sueltas y vuelves a verla junto al Dock.

Y un recuadro de selección ya no levanta a tu mascota más arriba de su franja.

**Pruébalo:** Maximiza una ventana, levanta a tu mascota con un recuadro de selección detrás de ella y suéltalo. Tu mascota cae y aparece junto al Dock.

---

## <a id="v1.30.1"></a>Las selecciones en el escritorio vuelven a funcionar

<sub>1.30.1 · 9 de octubre de 2026</sub>

Tu mascota y su pelota vuelven a saltar sobre los recuadros de selección, y las listas de apps solo se iluminan con apps.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Cuando el Dock o una app de escritorio remoto ocupaba toda la pantalla, pikapik no notaba el recuadro de selección que dibujas en el escritorio. Ahora vuelve a notarlo, y tu mascota y su pelota saltan sobre él como antes.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Las listas de apps en los ajustes solo se iluminan cuando arrastras una app encima. Los demás archivos se ignoran: no aparece ningún marco y no se añade nada de más. Si arrastras una app junto con otros archivos, solo se añade la app.

Y el marco se apaga en cuanto sueltas la app o alejas el puntero.

**Pruébalo:** Dibuja un recuadro de selección en el escritorio y mira cómo tu mascota salta encima.

---

## <a id="v1.30.0"></a>Salir ya no apaga pikapik

<sub>1.30.0 · 9 de octubre de 2026</sub>

¿Pulsaste Salir por costumbre? Tus atajos, «Mantener activo» y tu mascota siguen funcionando igual.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

Cuando eliges «Salir», pulsas ⌘Q o cierras pikapik desde el Dock, cierra sus ventanas y oculta su icono de la barra de menús, pero sigue trabajando en silencio en segundo plano: los atajos, «Mantener activo» y tu mascota siguen activos. Para recuperar el icono, simplemente abre pikapik otra vez.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

¿Quieres salir de verdad? Mantén pulsada Opción (⌥) y elige «Salir», o pulsa ⌥⌘Q. La primera vez que pikapik pasa a segundo plano, te explica qué ha pasado y te ofrece salir del todo ahí mismo.

¿Prefieres como antes? Desactiva «Seguir en segundo plano al salir» en Ajustes › General. Las actualizaciones, el cambio de idioma, cerrar sesión, reiniciar y apagar siempre cierran pikapik del todo, así que nunca tienen que esperarlo.

**Pruébalo:** Pulsa ⌘Q y luego abre pikapik otra vez para recuperar su icono.

---

## <a id="v1.29.1"></a>Tu mascota pasea por todas tus pantallas

<sub>1.29.1 · 9 de octubre de 2026</sub>

¿Tienes más de un monitor? Tu mascota y su pelota ya van a donde mires, y nunca se pierden.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Cuando tu mascota llega al borde de una pantalla, pasa sin más a la siguiente, y la pelota rueda detrás. También puedes coger la mascota o la pelota con el ratón y llevarlas a cualquier pantalla. Si una app pasa a pantalla completa, se van a otra pantalla para no molestar, y si desconectas un monitor, vuelven a la principal.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

La pelota ya no se queda atascada en una esquina. Tu mascota corre hacia ella, la lanza hacia atrás por encima de la cabeza y sigue jugando.

Y tu mascota ya no desaparece. Cada dos segundos comprueba que sigue en pantalla, y si algo salió mal, tras el reposo, al bloquear el Mac, al cambiar de escritorio o con la pantalla completa, vuelve sola enseguida.

**Pruébalo:** Lleva tu mascota a otra pantalla o haz rodar la pelota hasta una esquina.

**Corregido**

- Una mascota lanzada ya no aterriza en un recuadro de selección más alto de lo que puede saltar, y ya no desaparece por eso.

---

## <a id="v1.29.0"></a>Tu mascota tiene una pelota

<sub>1.29.0 · 9 de octubre de 2026</sub>

Ahora una pequeña pelota de fútbol rueda por la parte de abajo de la pantalla. Tu mascota juega con ella, y tú también puedes.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

La pelota rueda y rebota como una de verdad. Tu mascota corre tras ella, la patea y vuelve a perseguirla. Pasa el puntero rápido por la pelota para patearla tú, o agárrala, llévala y lánzala, igual que a la mascota.

Un pequeño truco: haz clic en un lugar vacío del escritorio y arrastra para dibujar un recuadro de selección, con o sin Mayúsculas. Mientras mantienes pulsado el botón, el recuadro se convierte en una repisa: tu mascota salta encima y la pelota también puede caer ahí. Suelta y la repisa desaparece.

¿Prefieres un escritorio tranquilo? Desactiva Pelota en los ajustes de la mascota y volverá a pasear a su aire.

**Pruébalo:** Ajustes › Mascota › Pelota

**Corregido**

- Junto al Dock, la mascota vuelve a saltar tan alto como quiere. Solo se queda abajo justo encima del Dock, así que nunca asoma por detrás.

---

## <a id="v1.28.0"></a>Añade apps con un clic o arrastrándolas

<sub>1.28.0 · 9 de octubre de 2026</sub>

Cada lista de apps en Ajustes muestra ahora lo que hay en tu Dock y lo que está abierto, y puedes arrastrar apps a ella desde el Finder.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Algunas funciones te dejan elegir apps donde se hacen a un lado, como el botón verde o Inicio y Fin. Antes, «Añadir app…» solo abría una carpeta larga con todo lo que tienes. Ahora aparece una estantería con las apps de tu Dock y las que están abiertas. Haz clic en una app para añadirla y otra vez para quitarla. Para todo lo demás está «Otro…».

También puedes arrastrar una app desde el Finder directamente a una lista. La lista se ilumina para mostrar dónde caerá la app. Tus juegos funcionan igual, con la misma estantería.

Y si algo falla, el formulario para informar de errores en GitHub ahora te deja elegir tu versión de pikapik y de macOS de una lista, así contárnoslo lleva menos tiempo.

**Pruébalo:** Ajustes › Ventanas, luego «Añadir app…»

**Corregido**

- El desplazamiento a través de AnyDesk u otra app de escritorio remoto ya no se invierte dos veces cuando usas la dirección clásica en los dos Mac. Ahora pikapik solo invierte el desplazamiento de un ratón o trackpad de verdad. Si una app hace su propio desplazamiento suave, como Mos, elige la dirección en esa app.
- La mascota se queda detrás del Dock cuando salta, igual que cuando camina, y vuelve sola cuando sales de una app a pantalla completa o de un juego.
- Los finos bordes alrededor de los pequeños dibujos de Ajustes ya no desaparecen en pantallas normales sin Retina.

---

## <a id="v1.27.3"></a>La mascota siempre a la vista, y las ventanas se abren listas

<sub>1.27.3 · 9 de octubre de 2026</sub>

La mascota ya no se esconde tras las ventanas a mitad de un salto, y las ventanas de pikapik se abren listas para usar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Cuando la mascota saltaba por encima del puntero o daba una voltereta, podía colarse detrás de las ventanas de otras apps y desaparecer en el aire. Ahora se queda delante durante todo el salto y vuelve detrás de tus ventanas al aterrizar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Cuando pikapik se abría en silencio en segundo plano, al iniciar sesión, tras una actualización o desde un enlace pikapik://, sus ventanas podían abrirse en gris y quedarse detrás de otras hasta que hicieras clic en ellas. Ahora Ajustes y la ventana Archivo nuevo pasan al frente, listas para escribir.

Lo mismo ocurre con el mensaje tras Crear copia más ligera y con la lista donde eliges una app para añadirla. No tienes que hacer nada.

**Pruébalo:** Ajustes › Mascota

---

## <a id="v1.27.2"></a>Archivo nuevo ha vuelto y los Ajustes son aún más ligeros

<sub>1.27.2 · 9 de octubre de 2026</sub>

Archivo nuevo vuelve a estar en el menú del clic derecho del Finder para todos, y los Ajustes piden todavía menos a tu Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Tras la última actualización, el Finder podía reiniciar Archivo nuevo en segundo plano y olvidar en qué carpetas trabaja, así que la opción desaparecía sin avisar del menú del clic derecho. Ahora Archivo nuevo le recuerda sus carpetas al Finder cada vez que arranca, y pikapik comprueba poco después de abrirse que el Finder lo ha recibido. No tienes que hacer nada.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Las imágenes animadas de los Ajustes ahora solo se mueven mientras se ve al menos la mitad de la imagen. En las imágenes de juegos, el pequeño héroe sigue moviéndose 30 veces por segundo, y las colinas y el suelo de detrás, 15. Así la página Juegos pide mucho menos a tu Mac. Todo se ve igual.

Después de una actualización, pikapik ya no vuelve a añadir sus opciones del Finder a menos que la app se haya movido de verdad, así que el Finder no tiene que recargarlas cada vez.

**Pruébalo:** Ajustes › Juegos

---

## <a id="v1.27.1"></a>Más silencioso, más ligero y el Finder listo al instante

<sub>1.27.1 · 9 de octubre de 2026</sub>

Ajustes apenas usa tu Mac, y las opciones del clic derecho en el Finder funcionan justo después del cambio a pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

Las pequeñas imágenes animadas de Ajustes redibujaban toda la página muchas veces por segundo, así que una ventana abierta mantenía ocupado tu Mac. Ahora cada imagen se redibuja solo a sí misma, como mucho 30 veces por segundo, y descansa cuando te desplazas más allá de ella o cuando ocultas la ventana. Se ven exactamente igual.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Tras el cambio de pika-tools a pikapik, el Finder podía seguir buscando la app antigua, y «Archivo nuevo», «Convertir a» y las demás opciones del clic derecho no hacían nada. Ahora pikapik lo nota en el primer arranque y reinicia el Finder por sí solo cuando no hay ventanas del Finder abiertas y no se está copiando nada. Si no, una línea breve en la página Finder ofrece el botón «Reiniciar Finder».

En Ajustes del Sistema, entre las apps que se abren al iniciar sesión, la app ahora aparece con su nuevo nombre, pikapik, y sigue activada.

**Pruébalo:** Ajustes › Finder

---

## <a id="v1.27.0"></a>Te presentamos a tu mascota de escritorio

<sub>1.27.0 · 9 de octubre de 2026</sub>

Ahora vive un amiguito en la parte de abajo de tu pantalla, y la app tiene un nombre nuevo: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Actívala en Ajustes › Mascota. Pasea detrás de tus ventanas y del Dock, salta por encima del puntero si se le cruza y brinca cuando pulsas Espacio. Puedes agarrarla, llevarla, lanzarla y atraparla en pleno salto.

De vez en cuando se sienta y dice algo cortito. Cuando de verdad sale una versión nueva, te lo cuenta una vez, y al hacer clic en ella se abren los Ajustes, donde te espera la actualización.

pika-tools ahora se llama pikapik. Tus permisos, ajustes y enlaces de Atajos siguen igual. Si la instalaste con Homebrew, ejecuta una vez `brew update && brew upgrade --cask pikapik`.

**Pruébalo:** Ajustes › Mascota

**Corregido**

- La búsqueda de actualizaciones avisaba de una versión nueva aunque ya tuvieras la última.
- La página Permisos mantenía ocupado tu Mac mientras estaba abierta.

---

## <a id="v1.26.2"></a>Novedades en tu idioma

<sub>1.26.2 · 8 de octubre de 2026</sub>

«Novedades» en los ajustes ahora abre esta página, en el mismo idioma que la app.

<img src="../media/icon.png" width="128" height="128" alt="">

Abre Ajustes › Acerca de y haz clic en «Novedades». Llegas justo aquí, a la página con una imagen para cada actualización, en el idioma que habla pikapik.

La lista completa de cambios también está más ordenada. Cada versión muestra el día en que salió, y cada número de versión abre su página de descarga.

Nada cambia en cómo funciona pikapik. Las actualizaciones llegan como antes, solas o con Homebrew.

**Pruébalo:** Ajustes › Acerca de › Novedades

**Corregido**

- «Novedades» abría una larga lista técnica en inglés en lugar de esta página.
- Los enlaces de la lista de cambios que no llevaban a ninguna parte ahora abren la página correcta.

---

## <a id="v1.26.1"></a>Las imágenes de juegos cobran vida

<sub>1.26.1 · 8 de octubre de 2026</sub>

Las imágenes de la página «Juegos» ahora se mueven, y ves qué detiene cada interruptor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Detrás de cada interruptor de la página «Juegos» ahora corre un pequeño juego. Aparecen unas teclas, se pulsan, y ves lo que saltaría encima de tu juego, como Spotlight o Mission Control, mientras el juego se detiene. Con el interruptor activado, las teclas solo brillan suavemente y el juego sigue. Cambia un interruptor y la imagen muestra la diferencia al instante.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

El pequeño juego sigue el aspecto de tu Mac: un día soleado en modo claro y una noche tranquila con luna y estrellas en modo oscuro.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

En todas las imágenes de la app, el puntero ahora se mueve como una mano: tarda un poco más en los trayectos largos, se detiene y solo entonces hace clic. Cuando una imagen vuelve a empezar, regresa suavemente al inicio en vez de saltar. Las imágenes descansan mientras la ventana está oculta, y con «Reducir movimiento» se quedan quietas.

**Pruébalo:** Ajustes › Juegos

---

## <a id="v1.26.0"></a>Un icono nuevo y borrón y cuenta nueva para los permisos viejos

<sub>1.26.0 · 8 de octubre de 2026</sub>

pikapik estrena cara y ahora quita los permisos que dejan las apps eliminadas.

<img src="../media/icon.png" width="128" height="128" alt="">

El icono nuevo es la marca de pikapik en azul, violeta y coral sobre un mosaico oscuro. La barra de menús muestra la misma forma, que se adapta a una barra clara u oscura. Cuando todas las herramientas están desactivadas, la forma se vuelve pálida.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Cuando eliminas una app, macOS guarda los permisos que le diste, y Ajustes del Sistema no tiene forma de quitarlos. Ahora la página «Permisos» tiene una lista llamada «Restos de apps eliminadas»: cada app con su icono, qué podía hacer y cuándo. «Eliminar» limpia una app, «Eliminar todo» las limpia todas, y una app que vuelvas a instalar simplemente volverá a preguntar. Para ver la lista, dale a pikapik acceso total al disco: solo mira y no cambia nada hasta que pulses «Eliminar».

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Las imágenes de las páginas «Animaciones» y «Juegos» están dibujadas de nuevo para su tamaño real, así que se ven nítidas. Una ventana se encoge hacia el Dock con las esquinas redondeadas, y el puntero hace clic primero y solo después se abre un menú. Y al final de «Acerca de» hay ahora una línea discreta: «Hecho con cariño · Invítame a un café». Nada aparece de golpe ni te lo recuerda nunca.

**Pruébalo:** Ajustes › Permisos, y luego «Restos de apps eliminadas»

**Corregido**

- Al hacer clic en un atajo del sistema se abre justo su sección en Ajustes del Sistema, como Mission Control, y no solo «Teclado».
- El consejo junto a las teclas ya no desaparece en cuanto se abre Ajustes del Sistema.

---

## <a id="v1.25.2"></a>Los atajos se abren donde se cambian

<sub>1.25.2 · 8 de octubre de 2026</sub>

Haz clic en un atajo en Ajustes y Ajustes del Sistema se abrirá en el lugar correcto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Antes, al hacer clic en un atajo, como el de Spotlight, siempre acababas en «Teclas de modificación». Ahora las teclas de Spotlight abren Spotlight directamente.

Para los demás atajos, Ajustes del Sistema se abre en «Teclado» y un consejo breve junto a las teclas te dice dónde hacer clic: «Atajos de teclado…» y luego «Mission Control» u otra sección.

Funciona igual en la página Juegos y en «Cortar archivos en el Finder». Para cortar archivos, el consejo te lleva a «Atajos de apps».

**Pruébalo:** Ajustes › Juegos, y luego haz clic en las teclas junto a «La búsqueda no aparece»

**Corregido**

- Hacer clic en un atajo ya no abre «Teclas de modificación».

---

## <a id="v1.25.1"></a>Imágenes grandes y juegos directo desde el Dock

<sub>1.25.1 · 8 de octubre de 2026</sub>

Cada interruptor tiene ahora una imagen grande, y «Añadir juego…» muestra lo que hay en tu Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

En las páginas Animaciones y Juegos, todas las imágenes son ahora grandes, como la de arriba de la página. Se ve enseguida qué hace cada interruptor, y las imágenes siguen moviéndose a la velocidad que elegiste.

Pulsa «Añadir juego…» y verás tu Dock: las apps que tienes ahí y las que están abiertas ahora, en el mismo orden. Un juego del Dock aparece aunque esté cerrado, también Minecraft. Un clic lo añade, y una marca muestra que ya está en la lista. Haz clic otra vez para quitarlo.

Todavía puedes arrastrar un juego aquí desde el Finder. Ya no hace falta sacarlo del Dock, así que el Dock no te ofrecerá eliminarlo.

**Pruébalo:** Ajustes › Juegos, y luego «Añadir juego…»

**Corregido**

- Un juego que está en el Dock pero cerrado ahora aparece en la lista para añadir.

---

## <a id="v1.25.0"></a>Añade un juego con un clic y elige tus propias teclas

<sub>1.25.0 · 8 de octubre de 2026</sub>

Elige un juego entre lo que tienes abierto y decide las teclas para salir y cerrar.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Pulsa «Añadir juego…» y las apps abiertas ahora aparecerán con iconos grandes, como en el Dock. Un clic añade un juego, o arrastra su icono a la lista. También puedes soltar un juego directamente desde el Finder o el Dock. Ahora cualquier app puede ser un juego, incluso Minecraft, que funciona con Java, y los juegos que añadiste antes se quedan.

Los interruptores del modo de juego ahora hablan claro, como «El juego no se cierra» o «La búsqueda no aparece», y cada uno tiene un pequeño dibujo de lo que detiene. El nombre del sistema, como Spotlight, aparece al lado en gris.

En Ajustes › Ventanas, haz clic en las teclas junto a «Salir de la app» o «Cerrar ventana» y pulsa otras nuevas. ⌫ recupera ⇧⌘Q y ⇧⌘W, y si las teclas ya están en uso, pikapik te pregunta primero. El modo de juego también usa tus teclas. Y cada atajo de Ajustes muestra ahora cómo está configurado de verdad en tu Mac: tus teclas, o Desactivado.

**Pruébalo:** Ajustes › Juegos, y luego «Añadir juego…»

**Corregido**

- Cortar archivos en el Finder sigue el atajo de Cortar que configuraste para el Finder en Ajustes del Sistema.
- Los nombres de las apps en las listas aparecen sin «.app».

---

## <a id="v1.24.1"></a>Una velocidad que se nota al instante

<sub>1.24.1 · 8 de octubre de 2026</sub>

La página Animaciones ahora te dice dónde se ve cada cambio y cuida tus propios valores.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

El Dock solo puede deslizarse más rápido si se oculta. Si el tuyo siempre está a la vista, el interruptor «Ocultar el Dock automáticamente» está ahora justo debajo del regulador de velocidad.

Después de un cambio, una línea al final de la página te avisa de que las apps lo aplican cuando las vuelves a abrir. Finder muestra la nueva velocidad de Vista Rápida y de las columnas solo tras reiniciarse, así que la línea trae un botón «Reiniciar Finder».

El regulador nunca hace más lento lo que ya habías acelerado, por ejemplo con comandos en Terminal. Y «Restaurar valores por omisión» o desinstalar pikapik devuelve los valores que tenías antes, en vez de borrarlos.

**Pruébalo:** Ajustes › Animaciones

**Corregido**

- El Dock ya no se reinicia sin motivo cuando no se oculta.

---

## <a id="v1.24.0"></a>Elige lo rápido que se mueve tu Mac

<sub>1.24.0 · 8 de octubre de 2026</sub>

La nueva página Animaciones decide lo rápido que todo se abre, se desliza y aparece en tu Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Basta con un regulador. Muévelo, y el Dock oculto, las ventanas nuevas, los diálogos de guardar, Vista Rápida y las columnas de Finder se aceleran a la vez, de «Como en macOS» a «Al instante».

¿Quieres ajustar solo una cosa? Cada efecto tiene su propio ajuste, igual que el efecto al minimizar, los iconos que rebotan en el Dock y las animaciones de Finder. Junto a cada ajuste, una pequeña imagen se mueve exactamente a la velocidad que elegiste.

«Restaurar valores por omisión» deshace solo lo que cambió pikapik, y desinstalarlo hace lo mismo. Si alguna vez pusiste tú uno de estos valores en Terminal, pikapik lo muestra tal cual.

**Pruébalo:** Ajustes › Animaciones

---

## <a id="v1.23.2"></a>Un interruptor para cada atajo en el modo de juego

<sub>1.23.2 · 8 de octubre de 2026</sub>

Ahora decides, atajo por atajo, qué silencia el modo de juego mientras juegas.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q y ⌘W tienen ahora interruptores separados, igual que Spotlight, Siri, ⌘Tab, Mission Control, los deslizamientos, el puntero, la pantalla y todo lo demás. Tus elecciones anteriores se mantienen.

Cada fila muestra exactamente las teclas que detiene, así que siempre sabes qué hace un interruptor.

El ajuste del idioma del teclado ha salido del modo de juego. ⌃Espacio y las demás formas de cambiar de idioma funcionan siempre, incluso en un juego.

**Pruébalo:** Ajustes › Juegos

**Corregido**

- Las teclas de un mismo atajo están más juntas, y hay un poco más de espacio entre atajos distintos, así que se ve fácilmente dónde termina uno y empieza el siguiente.

---

## <a id="v1.23.1"></a>La velocidad de tu internet, en palabras sencillas

<sub>1.23.1 · 8 de octubre de 2026</sub>

Velocidad de internet comprueba tu conexión y te dice, sin rodeos, para qué te alcanza.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Pulsa «Comprobar velocidad» y en medio minuto verás descarga, subida, ping y capacidad de respuesta. Bajo los números, unas palabras sencillas te dicen si basta para películas en 4K, videollamadas, juegos en línea y descargas grandes.

La prueba se hace en servidores de Apple, y el último resultado se queda hasta la siguiente. Velocidad de internet tiene su propia página en Ajustes, una fila en el panel de la barra de menús y un enlace para la app Atajos: `pikapik://speed-test`.

El modo de juego aprendió dos cosas. Bloquear los atajos con Control ahora forma parte de él: en un juego, ⌃-clic sigue siendo un clic y los atajos con ⌃ no se activan; en todo lo demás, ⌃ funciona como siempre. Y reconoce Minecraft: añade Minecraft Launcher o CurseForge a tus juegos, y el modo de juego se activa cuando Minecraft en sí está en primer plano.

**Pruébalo:** Ajustes › Velocidad de internet, y luego «Comprobar velocidad»

**Corregido**

- Las versiones de prueba de pikapik que cada uno compila guardan sus ajustes aparte en iCloud Drive y ya no tocan los tuyos.

---

## <a id="v1.23.0"></a>Modo de juego: juega sin interrupciones

<sub>1.23.0 · 7 de octubre de 2026</sub>

Añade tus juegos, y tu Mac deja de sacarte de ellos.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Mientras juegas, Spotlight, Siri, ⌘Tab, Mission Control y los deslizamientos entre escritorios no se abren encima del juego. ⌘Q y ⌘W no lo cierran por accidente, el puntero se queda en la pantalla del juego y la pantalla sigue encendida.

Para salir de un juego, pulsa ⇧⌘Q; para cerrar su ventana, ⇧⌘W. ⌥⌘Esc funciona siempre. pikapik te sugiere los juegos que encuentra en tu Mac. El modo de juego está desactivado hasta que lo activas.

Mantener activo te deja elegir qué hace la pantalla: seguir encendida, sin salvapantallas ni pantalla de bloqueo, o apagarse como siempre mientras tu Mac sigue trabajando. El nuevo botón «Apagar la pantalla ahora» la apaga al momento; mueve el ratón o pulsa una tecla para que vuelva.

**Pruébalo:** Ajustes › Juegos, y luego «Añadir juego…»

**Corregido**

- En los Mac sin tapa, Mantener activo ya no muestra las opciones de tapa cerrada.

---

<p align="center"><sub>Las versiones anteriores están en el <a href="../../CHANGELOG.md">registro de cambios</a> (en inglés).</sub></p>
