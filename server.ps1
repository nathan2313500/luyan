Add-Type -AssemblyName System.Web
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8000/')
$listener.Start()
Write-Host 'Server running at http://localhost:8000/'

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $localPath = $request.Url.LocalPath
    if ($localPath -eq '/') {
        $localPath = '/index.html'
    }
    
    $filePath = Join-Path (Get-Location) $localPath.TrimStart('/')
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    } else {
        $response.StatusCode = 404
        $errorContent = 'File not found'
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorContent)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    $response.OutputStream.Close()
}