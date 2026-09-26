Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$code = @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;

public class Win32Capture {
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    public static extern bool PrintWindow(IntPtr hWnd, IntPtr hdcBlt, uint nFlags);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    public static Bitmap CaptureWindow(IntPtr hWnd) {
        RECT r;
        GetWindowRect(hWnd, out r);
        int w = r.Right - r.Left;
        int h = r.Bottom - r.Top;
        if (w <= 0 || h <= 0) return null;

        Bitmap bmp = new Bitmap(w, h);
        using (Graphics g = Graphics.FromImage(bmp)) {
            IntPtr hdc = g.GetHdc();
            PrintWindow(hWnd, hdc, 2); // PW_RENDERFULLCONTENT
            g.ReleaseHdc(hdc);
        }
        return bmp;
    }
}
"@

Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

$hwnd = [Win32Capture]::FindWindow($null, "Bloom Core")
Write-Host "HWND: $hwnd"

if ($hwnd -ne [IntPtr]::Zero) {
    $bmp = [Win32Capture]::CaptureWindow($hwnd)
    if ($bmp -ne $null) {
        $p1 = "c:\Users\smily\Bloom_Core\assets\bloom_core_preview.png"
        $p2 = "c:\Users\smily\Bloom_Core\assets\bloom_core_hero.png"
        $bmp.Save($p1, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Save($p2, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "Successfully captured window to $p1 ($($bmp.Width)x$($bmp.Height))"
        $bmp.Dispose()
    } else {
        Write-Host "Failed to capture window bitmap"
    }
} else {
    Write-Host "Window not found!"
}
