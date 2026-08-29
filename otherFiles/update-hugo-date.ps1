param(
    [string]$File
)

$date = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"

$content = Get-Content $File -Raw -Encoding UTF8
$content = $content -replace '(?m)^date\s*=.*$', "date = '$date'"

Set-Content $File $content -Encoding UTF8