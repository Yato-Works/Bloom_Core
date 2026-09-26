Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 1. Kill old instances
Get-Process BloomCore -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 600

# 2. Launch BloomCore with --preview
$env:PATH = "C:\Qt\6.11.1\mingw_64\bin;C:\Qt\Tools\mingw1310_64\bin;" + $env:PATH
$env:BLOOM_NO_SINGLE_INSTANCE = "1"
$env:BLOOM_PREVIEW = "1"

$proc = Start-Process -FilePath "c:\Users\smily\Bloom_Core\build-mingw\BloomCore.exe" -ArgumentList "--preview" -PassThru
Write-Host "Started BloomCore with PID: $($proc.Id)"

# 3. Wait for UI animation to settle
Start-Sleep -Seconds 4

# 4. Capture Primary Screen
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)

# 5. Save Preview Images
$assetsDir = "c:\Users\smily\Bloom_Core\assets"
if (!(Test-Path $assetsDir)) { New-Item -ItemType Directory -Path $assetsDir -Force }

$target1 = Join-Path $assetsDir "bloom_core_preview.png"
$target2 = Join-Path $assetsDir "bloom_core_hero.png"
$bmp.Save($target1, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Save($target2, [System.Drawing.Imaging.ImageFormat]::Png)

$artifactDir = "C:\Users\smily\.gemini\antigravity-ide\brain\cb9aaa05-af42-4193-9c9b-9b910d1e071f"
if (Test-Path $artifactDir) {
    $target3 = Join-Path $artifactDir "bloom_core_preview.png"
    $bmp.Save($target3, [System.Drawing.Imaging.ImageFormat]::Png)
}

$gfx.Dispose()
$bmp.Dispose()

Write-Host "Screenshot successfully saved to $target1 and $target2"
