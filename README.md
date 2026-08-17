# Parla

Parla es una aplicación para macOS que ayuda a hispanohablantes a practicar italiano con ejercicios breves de escucha, pronunciación y vocabulario.

![Pantalla principal de Parla](docs/viewport.png)

## Descargar e instalar

Parla requiere **macOS 14 o posterior** y un Mac con **Apple Silicon**.

1. Descarga `Parla.dmg` desde la [última versión publicada](https://github.com/marsillig/Parla/releases/latest).
2. Abre el archivo DMG y arrastra **Parla** a **Aplicaciones**.
3. La primera vez, haz clic derecho sobre Parla y selecciona **Abrir**.

La aplicación todavía no está notarizada por Apple. Si macOS vuelve a bloquearla, abre **Ajustes del Sistema → Privacidad y seguridad** y selecciona **Abrir igualmente**.

## Modos de práctica

- **Dettato:** escucha una frase en italiano y escribe lo que oyes.
- **Pronuncia:** graba tu voz y recibe una comparación palabra por palabra.
- **Abbina:** relaciona imágenes con 300 palabras de emociones, comida, viajes, lugares, objetos y animales.

Incluye 2.400 frases distribuidas entre los niveles A1, A2 y B1 y 16 temas cotidianos. El progreso se guarda localmente en el Mac.

## Atajos de teclado

### Dettato

| Acción | Atajo |
|---|---|
| Escuchar | `⌘A` |
| Escuchar lentamente | `⌘L` |
| Mostrar la respuesta | `⌘R` |
| Confirmar o continuar | `↩` |

### Pronuncia

| Acción | Atajo |
|---|---|
| Iniciar o detener la grabación | `Espacio` |
| Repetir el ejercicio | `⌘R` |
| Escuchar la frase | `⌘A` |
| Escuchar mi grabación | `⌘V` |
| Continuar | `↩` |

## Privacidad y conexión

El audio y el progreso se procesan y almacenan localmente. **Pronuncia** necesita acceso al micrófono y una conexión a internet durante el primer uso para descargar el modelo de reconocimiento de voz.

## Desarrollo

Requisitos: macOS 14, Swift 5.9 o posterior y Xcode Command Line Tools.

```bash
swift test
./build-app.sh
open Parla.app
```

También puedes ejecutar el proyecto directamente:

```bash
swift run Parla
```
