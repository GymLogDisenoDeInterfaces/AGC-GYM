# verificar.ps1 - Comprueba el proyecto completo de principio a fin.
# USO: abre PowerShell en la carpeta del proyecto (donde esta pubspec.yaml) y ejecuta:
#   powershell -ExecutionPolicy Bypass -File .\scripts\verificar.ps1
# Para en el primer fallo y te dice en que paso ha sido. Pega aqui el error y se arregla.

$ErrorActionPreference = 'Continue'

function Paso([string]$titulo, [scriptblock]$orden, [switch]$Opcional) {
    Write-Host ''
    Write-Host "== $titulo ==" -ForegroundColor Cyan
    & $orden
    if ($LASTEXITCODE -ne 0) {
        if ($Opcional) {
            Write-Host "AVISO: '$titulo' ha fallado (no es bloqueante)." -ForegroundColor Yellow
            return
        }
        Write-Host "FALLO en: $titulo" -ForegroundColor Red
        exit 1
    }
}

if (-not (Test-Path 'pubspec.yaml')) {
    Write-Host 'No encuentro pubspec.yaml: entra en la carpeta del proyecto.' -ForegroundColor Red
    exit 1
}
if ($PWD.Path -match '[^\x00-\x7F]' -or $PWD.Path -match ' ') {
    Write-Host 'AVISO: la ruta tiene espacios o tildes. Mueve el proyecto a C:\dev\AGC_GYM.' -ForegroundColor Yellow
}

Paso '1/7 Dependencias (flutter pub get)' { flutter pub get }
Paso '2/7 Textos ES/EN (flutter gen-l10n)' { flutter gen-l10n }
Paso '3/7 Analisis estatico (flutter analyze)' { flutter analyze }
Paso '4/7 Tests de la app' { flutter test }
Paso '5/7 Tests del paquete gym_components' {
    Push-Location packages/gym_components
    flutter pub get
    flutter test --coverage
    $codigo = $LASTEXITCODE
    Pop-Location
    exit $codigo
}
Paso '6/7 Cobertura de la app' { flutter test --coverage } -Opcional
Paso '7/7 APK de depuracion' { flutter build apk --debug } -Opcional

Write-Host ''
Write-Host 'TODO CORRECTO. Ahora prueba la app: flutter run -d windows  (o un emulador Android).' -ForegroundColor Green
Write-Host 'Voz, camara y pose solo funcionan en un movil/emulador Android con camara.' -ForegroundColor Green
