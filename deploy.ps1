# deploy.ps1
#
# Automatiza TODO el ciclo de publicación de MCLV MusicApp en un solo
# comando:
#   1. Commitea y sube (git push) cualquier cambio pendiente.
#   2. Crea un tag de Git con la versión (vincula el release al commit
#      exacto que lo generó).
#   3. Compila el APK (flutter build apk --release) y lo renombra con la
#      versión.
#   4. Compila la web (flutter build web), COPIA el APK dentro de
#      build/web/downloads/ (para que quede servido desde tu propio
#      dominio de Firebase Hosting), y despliega
#      (firebase deploy --only hosting).
#   5. Crea el Release en GitHub y sube el APK como asset (como respaldo /
#      historial de versiones).
#   6. Manda una notificación push (Firebase Cloud Messaging) al topic
#      "actualizaciones", con el link de descarga que apunta a TU PROPIO
#      DOMINIO (Firebase Hosting), no a GitHub.
#
# POR QUÉ SE SIRVE EL APK DESDE FIREBASE HOSTING EN VEZ DE SOLO GITHUB:
# Chrome en Android aplica una verificación extra de Google Safe Browsing
# a los .apk descargados desde dominios no reconocidos como tienda de
# apps. Con GitHub Releases, esto provocaba que la descarga se quedara
# congelada al 100% sin nunca ofrecer "Instalar" (confirmado: funcionaba
# en PC y en Samsung Internet, pero se colgaba específicamente en Chrome
# Android). Servir el mismo archivo desde el dominio propio de Firebase
# Hosting (mclv-musicapp.web.app) evita ese bloqueo. El Release de GitHub
# se sigue publicando igual, como respaldo/historial, pero el link que se
# comparte y el que manda la notificación push apuntan a Hosting.
#
# USO:
#   .\deploy.ps1 -Version "1.2.0"
#   .\deploy.ps1 -Version "1.2.0" -Notas "Corrige orden de canciones al compartir PDF"
#   .\deploy.ps1 -Version "1.2.0" -MensajeCommit "Arreglo de PDF en 2 columnas"
#
# Si por alguna razón NO quieres que este deploy mande la notificación
# push (ej. una versión de prueba silenciosa):
#   .\deploy.ps1 -Version "1.2.0" -SinNotificacion
#
# Si solo quieres publicar el APK (Hosting + GitHub Release) sin más:
#   .\deploy.ps1 -Version "1.2.0" -SinNotificacion
#
# REQUISITOS (una sola vez):
#   - Flutter instalado y en el PATH.
#   - Git instalado y este proyecto ya conectado a GitHub (git remote).
#   - GitHub CLI instalado y logueado: gh auth login
#   - Firebase CLI instalado y logueado, con firebase.json ya configurado
#     en la raíz del proyecto (firebase init hosting).
#   - Google Cloud CLI instalado (gcloud --version).
#   - El archivo JSON de la cuenta de servicio de Firebase Admin SDK,
#     guardado FUERA de este repositorio (ver $RutaCredencialesFirebase
#     más abajo). Este archivo es una credencial administrativa completa
#     sobre tu proyecto Firebase -- NUNCA debe subirse a Git.

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$Notas = "Nueva versión de MCLV MusicApp.",

    # Mensaje de commit a usar SI hay cambios pendientes por subir. Si no
    # se especifica, se usa uno genérico basado en la versión.
    [string]$MensajeCommit = "",

    # Si se pasa este switch, se saltan el build/deploy de Hosting web.
    # Útil si solo quieres publicar el APK sin tocar la página.
    [switch]$SinWeb,

    # Si se pasa este switch, no se manda la notificación push al final.
    [switch]$SinNotificacion
)

# =======================================================================
# CONFIGURACIÓN -- ajusta estas rutas/valores una sola vez si cambian
# =======================================================================

# Repositorio de GitHub donde se publican los releases.
$Repo = "jac2107/MCLV-MusicApp"

# Project ID de Firebase (el ID técnico, no el nombre bonito).
$FirebaseProjectId = "mclv-musicapp"

# Dominio de Firebase Hosting donde se sirve la web Y el APK. Se usa un
# dominio propio (no GitHub) para el link de descarga porque Chrome en
# Android se queda colgado al 100% al descargar .apk grandes desde
# dominios "no reconocidos" como GitHub Releases (ver nota arriba).
$DominioHosting = "https://mclv-musicapp.web.app"

# Ruta COMPLETA al archivo JSON de la cuenta de servicio de Firebase.
# IMPORTANTE: esta ruta está FUERA de la carpeta del repositorio a
# propósito -- nunca la muevas dentro de la carpeta del proyecto, o corres
# el riesgo de subirla por accidente a GitHub con un "git add -A".
$RutaCredencialesFirebase = "C:\Users\Jhoan\Desktop\Programas iglesia\MusicApp\mclv-musicapp-firebase-adminsdk-fbsvc-0c0c418f2d.json"

# Topic de FCM al que están suscritos los dispositivos con la app
# instalada (ver FirebaseMessaging.instance.subscribeToTopic en
# notification_bootstrap_io.dart).
$TopicNotificaciones = "actualizaciones"

# Nombre final que tendrá el APK en el Release (incluye la versión para
# que quede claro cuál es cuál en el historial de releases).
$NombreApk = "MCLV-MusicApp-v$Version.apk"

if ([string]::IsNullOrWhiteSpace($MensajeCommit)) {
    $MensajeCommit = "Release v$Version"
}

# Detiene el script si cualquier comando falla, en vez de seguir con pasos
# posteriores sobre un estado roto.
$ErrorActionPreference = "Stop"

function Fallar($mensaje) {
    Write-Host ""
    Write-Host "ERROR: $mensaje" -ForegroundColor Red
    exit 1
}

function Advertir($mensaje) {
    Write-Host ""
    Write-Host "ADVERTENCIA: $mensaje" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------
# 1. Verificaciones previas
# ---------------------------------------------------------------------
Write-Host "==> Verificando herramientas necesarias..." -ForegroundColor Cyan

if (-not (Test-Path "pubspec.yaml")) {
    Fallar "No se encontró pubspec.yaml en esta carpeta. Corre este script desde la raíz del proyecto Flutter."
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Fallar "No se encontró 'flutter' en el PATH. Verifica tu instalación de Flutter."
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fallar "No se encontró 'git' en el PATH. Instálalo desde https://git-scm.com/"
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Fallar "No se encontró 'gh' (GitHub CLI) en el PATH. Instálalo con: winget install --id GitHub.cli"
}

if (-not $SinWeb) {
    if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
        Fallar "No se encontró 'firebase' (Firebase CLI) en el PATH. Instálalo con: npm install -g firebase-tools"
    }
    if (-not (Test-Path "firebase.json")) {
        Fallar "No se encontró firebase.json en esta carpeta. Corre 'firebase init hosting' primero, o usa -SinWeb para saltar este paso."
    }
}

if (-not $SinNotificacion) {
    if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
        Fallar "No se encontró 'gcloud' en el PATH. Instálalo con: winget install --id Google.CloudSDK (o usa -SinNotificacion para saltar este paso)."
    }
    if (-not (Test-Path $RutaCredencialesFirebase)) {
        Write-Host ""
        Write-Host "ERROR: No se encontró el archivo de credenciales de Firebase en:" -ForegroundColor Red
        Write-Host "  $RutaCredencialesFirebase"
        Write-Host "Verifica la ruta en la sección CONFIGURACIÓN de este script, o usa -SinNotificacion para saltar este paso." -ForegroundColor Red
        exit 1
    }
}

gh auth status 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Fallar "No hay una sesión activa de GitHub CLI. Corre: gh auth login"
}

git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Fallar "Esta carpeta no es un repositorio Git. Verifica que estás en la raíz del proyecto."
}

# ---------------------------------------------------------------------
# 2. Commit + push de cambios pendientes (si los hay)
# ---------------------------------------------------------------------
Write-Host "==> Revisando cambios pendientes en Git..." -ForegroundColor Cyan

$cambiosPendientes = git status --porcelain

if ($cambiosPendientes) {
    Write-Host ""
    Write-Host "Hay cambios sin subir a Git:" -ForegroundColor Yellow
    git status --short
    Write-Host ""
    Write-Host "Mensaje de commit a usar: $MensajeCommit"
    $confirmacion = Read-Host "¿Confirmas hacer commit y push de estos cambios antes de compilar? (s/n)"

    if ($confirmacion -ne "s" -and $confirmacion -ne "S") {
        Fallar "Cancelado por el usuario. Revisa/commitea tus cambios manualmente y vuelve a correr el script."
    }

    git add -A
    git commit -m $MensajeCommit
    if ($LASTEXITCODE -ne 0) {
        Fallar "git commit falló. Revisa el error de arriba."
    }

    git push
    if ($LASTEXITCODE -ne 0) {
        Fallar "git push falló. Revisa tu conexión o permisos del repositorio."
    }

    Write-Host "==> Cambios subidos correctamente." -ForegroundColor Green
} else {
    Write-Host "==> No hay cambios pendientes; el árbol de trabajo ya está al día." -ForegroundColor Green
}

# ---------------------------------------------------------------------
# 3. Crear el tag de Git para esta versión
# ---------------------------------------------------------------------
$Tag = "v$Version"
Write-Host "==> Creando tag de Git $Tag..." -ForegroundColor Cyan

$tagExistente = git tag --list $Tag
if ($tagExistente) {
    Write-Host ""
    Write-Host "ERROR: El tag '$Tag' ya existe en Git." -ForegroundColor Red
    Write-Host "Usa una versión distinta, o borra el tag manualmente con estos dos comandos:" -ForegroundColor Red
    Write-Host "  git tag -d $Tag"
    Write-Host "  git push origin --delete $Tag"
    exit 1
}

git tag $Tag
if ($LASTEXITCODE -ne 0) {
    Fallar "git tag falló. Revisa el error de arriba."
}

git push origin $Tag
if ($LASTEXITCODE -ne 0) {
    Fallar "git push del tag falló. Revisa tu conexión o permisos del repositorio."
}

# ---------------------------------------------------------------------
# 4. Compilar el APK
# ---------------------------------------------------------------------
Write-Host "==> Compilando APK (flutter build apk --release)..." -ForegroundColor Cyan
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Fallar "flutter build apk falló. Revisa el error de arriba."
}

$RutaApkOriginal = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $RutaApkOriginal)) {
    Fallar "No se encontró el APK compilado en $RutaApkOriginal. ¿Cambió la ruta de salida de Flutter?"
}

# ---------------------------------------------------------------------
# 5. Renombrar el APK con la versión
# ---------------------------------------------------------------------
Write-Host "==> Preparando $NombreApk..." -ForegroundColor Cyan

$CarpetaTemporal = "build\release-temp"
New-Item -ItemType Directory -Force -Path $CarpetaTemporal | Out-Null
$RutaApkFinal = Join-Path $CarpetaTemporal $NombreApk
Copy-Item -Path $RutaApkOriginal -Destination $RutaApkFinal -Force

# ---------------------------------------------------------------------
# 6. Web: build, COPIAR el APK (renombrado, ver nota abajo) y generar
#    version.json dentro de build/web/, y deploy a Firebase Hosting.
#
# POR QUÉ EL APK SE RENOMBRA A .zip:
# El plan Spark (gratuito) de Firebase Hosting rechaza archivos detectados
# como ejecutables -- un .apk cae en esa categoría y el deploy falla con
# "Executable files are forbidden on the Spark billing plan". Firebase
# Storage sería la alternativa normal, pero también requiere el plan de
# pago (Blaze). La solución sin subir de plan: subir el mismo archivo con
# extensión .zip (Hosting no lo bloquea), y que la APP (no un link directo)
# lo descargue y lo guarde con el nombre .apk real usando el paquete
# `http` + `path_provider` -- ver el cambio correspondiente en
# splash_page.dart.
#
# POR QUÉ SE GENERA version.json:
# Es el archivo que la app consulta al abrir (en SplashScreen) para saber
# si hay una versión más nueva que la instalada. Contiene el número de
# versión y el nombre del archivo a descargar.
# ---------------------------------------------------------------------
if (-not $SinWeb) {
    Write-Host "==> Compilando web (flutter build web)..." -ForegroundColor Cyan
    flutter build web
    if ($LASTEXITCODE -ne 0) {
        Fallar "flutter build web falló. Revisa el error de arriba."
    }

    Write-Host "==> Preparando descarga del APK (renombrado a .zip)..." -ForegroundColor Cyan
    $CarpetaDescargasWeb = "build\web\downloads"
    New-Item -ItemType Directory -Force -Path $CarpetaDescargasWeb | Out-Null

    # Nombre con el que el archivo queda SERVIDO en Hosting (no ejecutable,
    # así Firebase no lo bloquea). El nombre final que verá el usuario al
    # instalar (MCLV-MusicApp-vX.X.X.apk) se restaura dentro de la app al
    # guardarlo en el teléfono -- ver splash_page.dart.
    $NombreApkServido = "$NombreApk.zip"
    Copy-Item -Path $RutaApkFinal -Destination (Join-Path $CarpetaDescargasWeb $NombreApkServido) -Force

    Write-Host "==> Generando version.json..." -ForegroundColor Cyan
    $VersionJson = @{
        version     = $Version
        apkFileName = $NombreApk
        downloadUrl = "$DominioHosting/downloads/$NombreApkServido"
        notas       = $Notas
    } | ConvertTo-Json
    Set-Content -Path "build\web\version.json" -Value $VersionJson -Encoding utf8

    Write-Host "==> Desplegando a Firebase Hosting..." -ForegroundColor Cyan
    firebase deploy --only hosting
    if ($LASTEXITCODE -ne 0) {
        Fallar "firebase deploy falló. Revisa el error de arriba."
    }

    Write-Host "==> Hosting actualizado correctamente (incluye el APK y version.json)." -ForegroundColor Green
} else {
    Write-Host "==> Saltando build/deploy de web (-SinWeb)." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------
# 7. Crear el Release en GitHub y subir el APK (respaldo / historial de
#    versiones; el link que se comparte y la notificación push usan el
#    de Hosting, no este).
# ---------------------------------------------------------------------
Write-Host "==> Creando release $Tag en $Repo..." -ForegroundColor Cyan

gh release create $Tag $RutaApkFinal `
    --repo $Repo `
    --title "MCLV MusicApp $Tag" `
    --notes $Notas

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: gh release create falló." -ForegroundColor Red
    Write-Host "El tag '$Tag' ya se creó en Git. Si necesitas reintentar el release, corre:" -ForegroundColor Red
    Write-Host '  gh release create' $Tag $RutaApkFinal '--repo' $Repo '--title' "MCLV MusicApp $Tag" '--notes' $Notas
    exit 1
}

$LinkPaginaRelease = "https://github.com/$Repo/releases/tag/$Tag"
$LinkDescargaGitHub = "https://github.com/$Repo/releases/download/$Tag/$NombreApk"

# Este es el link RECOMENDADO para compartir: descarga el APK desde tu
# propio dominio de Firebase Hosting, evitando el bloqueo de Chrome
# Android que se queda colgado al 100% con descargas de .apk grandes
# desde GitHub Releases (ver nota al inicio del script). Solo existe si
# no se usó -SinWeb.
$LinkDescargaHosting = "$DominioHosting/downloads/$NombreApk"

# ---------------------------------------------------------------------
# 8. Notificación push por FCM al topic de actualizaciones
# ---------------------------------------------------------------------
if (-not $SinNotificacion) {
    Write-Host "==> Enviando notificación push (FCM) al topic '$TopicNotificaciones'..." -ForegroundColor Cyan

    # El link que se manda en la notificación es el de Hosting (evita el
    # problema de Chrome Android). Si se usó -SinWeb, no hay APK en
    # Hosting, así que se cae al link de GitHub como respaldo.
    $linkParaNotificacion = if ($SinWeb) { $LinkDescargaGitHub } else { $LinkDescargaHosting }

    try {
        # Genera un token de acceso OAuth2 a partir del JSON de la cuenta
        # de servicio. Este token es temporal (dura ~1 hora) y solo se usa
        # para esta llamada puntual a la API de FCM -- no deja ninguna
        # sesión de tu cuenta de Google abierta en la máquina.
        $env:GOOGLE_APPLICATION_CREDENTIALS = $RutaCredencialesFirebase
        $accessToken = gcloud auth application-default print-access-token 2>$null

        if ([string]::IsNullOrWhiteSpace($accessToken)) {
            throw "gcloud no devolvió un token de acceso válido."
        }

        # Cuerpo del mensaje FCM (API V1). "topic" hace que le llegue a
        # TODOS los dispositivos suscritos a "actualizaciones" con una
        # sola llamada, sin necesitar la lista de tokens individuales.
        # El campo data.url es el mismo que ya maneja
        # notification_bootstrap_io.dart (message.data['url']) para abrir
        # un link externo al tocar la notificación.
        $cuerpoMensaje = @{
            message = @{
                topic = $TopicNotificaciones
                notification = @{
                    title = "Nueva versión disponible: $Tag"
                    body  = $Notas
                }
                data = @{
                    url = $linkParaNotificacion
                }
            }
        } | ConvertTo-Json -Depth 10

        $urlFcm = "https://fcm.googleapis.com/v1/projects/$FirebaseProjectId/messages:send"

        $respuesta = Invoke-RestMethod -Uri $urlFcm -Method Post `
            -Headers @{
                "Authorization" = "Bearer $accessToken"
                "Content-Type"  = "application/json; UTF-8"
            } `
            -Body $cuerpoMensaje

        Write-Host "==> Notificación enviada correctamente." -ForegroundColor Green
    } catch {
        # Si la notificación falla, NO se revierte nada de lo ya publicado
        # (Git, Hosting, APK, Release) -- solo se avisa, porque el release
        # ya es válido y descargable aunque el aviso push no haya llegado.
        $mensajeError = $_.Exception.Message
        Write-Host ""
        Write-Host "ADVERTENCIA: No se pudo enviar la notificación push: $mensajeError" -ForegroundColor Yellow
        Write-Host "El release y el hosting SÍ se publicaron correctamente; solo falló el aviso automático." -ForegroundColor Yellow
    } finally {
        Remove-Item Env:\GOOGLE_APPLICATION_CREDENTIALS -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "==> Saltando notificación push (-SinNotificacion)." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------
# 9. Resumen final
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "==> ¡Listo! Deploy completo." -ForegroundColor Green
Write-Host ""

if (-not $SinWeb) {
    Write-Host "Link RECOMENDADO para compartir (descarga desde tu propio" -ForegroundColor Green
    Write-Host "dominio -- evita el problema de Chrome Android con GitHub):" -ForegroundColor Green
    Write-Host "  $LinkDescargaHosting"
    Write-Host ""
}

Write-Host "Página del release en GitHub ($Tag) -- respaldo/historial:"
Write-Host "  $LinkPaginaRelease"
Write-Host ""
Write-Host "Descarga directa desde GitHub ($Tag) -- puede colgarse en Chrome Android:"
Write-Host "  $LinkDescargaGitHub"
Write-Host ""