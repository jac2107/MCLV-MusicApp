# deploy.ps1
#
# Automatiza el ciclo completo "código -> APK -> GitHub Release" para
# MCLV MusicApp:
#   1. Commitea y sube (git push) cualquier cambio pendiente.
#   2. Crea un tag de Git con la versión, para que el release quede
#      vinculado exactamente al commit que lo generó.
#   3. Compila el APK.
#   4. Crea el Release en GitHub y sube el APK como asset.
#
# En vez de: hacer commit a mano, compilar a mano, buscar el .apk en
# build/app/outputs, renombrarlo, y subirlo manualmente como asset de un
# Release en GitHub -- todo eso ahora es un solo comando:
#
#   .\deploy.ps1 -Version "1.2.0"
#
# Al terminar, imprime los links para compartir. El link fijo que NUNCA
# cambia (recomendado para compartir con tu equipo) es:
#   https://github.com/jac2107/MCLV-MusicApp/releases/latest
#
# REQUISITOS (una sola vez):
#   - Flutter instalado y en el PATH.
#   - Git instalado y este proyecto ya conectado a GitHub (git remote).
#   - GitHub CLI instalado y logueado: gh auth login
#   - Este script debe correrse desde la raíz del proyecto Flutter
#     (donde está pubspec.yaml).
#
# USO:
#   .\deploy.ps1 -Version "1.2.0"
#   .\deploy.ps1 -Version "1.2.0" -Notas "Corrige orden de canciones al compartir PDF"
#   .\deploy.ps1 -Version "1.2.0" -MensajeCommit "Arreglo de PDF en 2 columnas"

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$Notas = "Nueva versión de MCLV MusicApp.",

    # Mensaje de commit a usar SI hay cambios pendientes por subir. Si no
    # se especifica, se usa uno genérico basado en la versión.
    [string]$MensajeCommit = ""
)

# Repositorio de GitHub donde se publican los releases.
$Repo = "jac2107/MCLV-MusicApp"

# Nombre final que tendrá el APK en el Release (incluye la versión para
# que quede claro cuál es cuál en el historial de releases).
$NombreApk = "MCLV-MusicApp-v$Version.apk"

if ([string]::IsNullOrWhiteSpace($MensajeCommit)) {
    $MensajeCommit = "Release v$Version"
}

# Detiene el script si cualquier comando falla, en vez de seguir con pasos
# posteriores sobre un estado roto (ej. intentar subir un APK que no se
# llegó a compilar porque falló el build).
$ErrorActionPreference = "Stop"

function Fallar($mensaje) {
    Write-Host ""
    Write-Host "ERROR: $mensaje" -ForegroundColor Red
    exit 1
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

# Verifica que la sesión de gh esté activa antes de compilar nada -- así
# si falta autenticarse, el usuario se entera ANTES de esperar varios
# minutos a que termine el build, no después.
gh auth status 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Fallar "No hay una sesión activa de GitHub CLI. Corre: gh auth login"
}

# Verifica que esta carpeta sea de verdad un repo Git (si el usuario
# corre el script desde un lugar sin inicializar, mejor fallar temprano
# con un mensaje claro que con un error críptico de git más abajo).
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Fallar "Esta carpeta no es un repositorio Git. Verifica que estás en la raíz del proyecto."
}

# ---------------------------------------------------------------------
# 2. Commit + push de cambios pendientes (si los hay)
# ---------------------------------------------------------------------
Write-Host "==> Revisando cambios pendientes en Git..." -ForegroundColor Cyan

# `git status --porcelain` devuelve texto SOLO si hay algo sin commitear
# (archivos modificados, nuevos, o eliminados). Si no devuelve nada, el
# árbol de trabajo está limpio y no hay nada que commitear.
$cambiosPendientes = git status --porcelain

if ($cambiosPendientes) {
    Write-Host ""
    Write-Host "Hay cambios sin subir a Git:" -ForegroundColor Yellow
    git status --short
    Write-Host ""
    Write-Host "Mensaje de commit a usar: `"$MensajeCommit`""
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
# 3. Crear el tag de Git para esta versión (vincula el release al commit
#    exacto que lo generó, para poder rastrear después qué código produjo
#    cada APK publicado).
# ---------------------------------------------------------------------
$Tag = "v$Version"
Write-Host "==> Creando tag de Git $Tag..." -ForegroundColor Cyan

$tagExistente = git tag --list $Tag
if ($tagExistente) {
    Fallar "El tag '$Tag' ya existe en Git. Usa una versión distinta, o borra el tag manualmente si necesitas rehacerlo (git tag -d $Tag && git push origin :refs/tags/$Tag)."
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
# 6. Crear el Release en GitHub (usando el tag ya creado) y subir el APK
# ---------------------------------------------------------------------
Write-Host "==> Creando release $Tag en $Repo..." -ForegroundColor Cyan

gh release create $Tag $RutaApkFinal `
    --repo $Repo `
    --title "MCLV MusicApp $Tag" `
    --notes $Notas

if ($LASTEXITCODE -ne 0) {
    Fallar "gh release create falló. El tag '$Tag' ya se creó en Git -- si necesitas reintentar el release, no vuelvas a correr el script con la misma versión (fallaría en el paso del tag); crea el release manualmente con: gh release create $Tag $RutaApkFinal --repo $Repo --title `"MCLV MusicApp $Tag`" --notes `"$Notas`""
}

# ---------------------------------------------------------------------
# 7. Mostrar los links para compartir
# ---------------------------------------------------------------------
$LinkPaginaRelease = "https://github.com/$Repo/releases/tag/$Tag"
$LinkDescargaDirecta = "https://github.com/$Repo/releases/download/$Tag/$NombreApk"
$LinkUltimaVersionPagina = "https://github.com/$Repo/releases/latest"

Write-Host ""
Write-Host "==> ¡Listo! Release publicado." -ForegroundColor Green
Write-Host ""
Write-Host "Link FIJO para compartir con tu equipo (nunca cambia, siempre" -ForegroundColor Green
Write-Host "muestra la versión más reciente):" -ForegroundColor Green
Write-Host "  $LinkUltimaVersionPagina"
Write-Host ""
Write-Host "Página de este release en particular ($Tag):"
Write-Host "  $LinkPaginaRelease"
Write-Host ""
Write-Host "Descarga directa de ESTA versión ($Tag):"
Write-Host "  $LinkDescargaDirecta"
Write-Host ""