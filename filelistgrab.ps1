Get-ChildItem -Path "C:\" -Recurse | Out-File -FilePath "C:\path\to\output.txt" -Append
$senderEmail = "sender@example.com"
$recipientEmail = "recipient@example.com"
$subject = "File List"
$body = "Please find attached the file list."
$attachmentPath = "C:\path\to\output.txt"
$smtpServer = "smtp.example.com"
$username = "your_username"
$password = "your_password"

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

$maxRetries = 5
$retryIntervalMinutes = 10
$retryCount = 0
$success = $false

while (-not $success -and $retryCount -lt $maxRetries) {
    try {
        $result = Send-MailMessage -From $senderEmail -To $recipientEmail -Subject $subject -Body $body -Attachments $attachmentPath -SmtpServer $smtpServer -Credential $credentials
        $success = $true
        Write-Output "Email sent successfully."
    } catch {
        $retryCount++
        Write-Output "Failed to send email: $($_.Exception.Message)"
        Write-Output "Retry attempt: $retryCount"
        if ($retryCount -lt $maxRetries) {
            Write-Output "Retrying in $retryIntervalMinutes minutes..."
            Start-Sleep -Seconds ($retryIntervalMinutes * 60)
        }
    }
}

if (-not $success) {
    Write-Output "Maximum retries reached. Failed to send the email."
}
