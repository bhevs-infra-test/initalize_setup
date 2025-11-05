// vars/sendCiNotification.groovy

/**
 * CI/CD 빌드 결과를 파싱하여 HTML 이메일로 전송합니다.
 * @param config Map: 'buildStatus' (빌드 상태), 'payload' (env 객체), 'attachments' (파일명 리스트)
 */
def call(Map config) {
    def payload = config.payload
    def buildStatus = config.buildStatus
    def attachments = config.attachments ?: []
    def attachmentNameString = attachments.join(',')

    if (!payload.change_obj_branch) {
        echo "[Notification] Webhook variables not found (change_obj_branch is null). Skipping notification."
        return
    }

    withCredentials([usernamePassword(credentialsId: 'smtp-credentials', usernameVariable: 'EMAIL_USER', passwordVariable: 'EMAIL_PASS')]) {

        powershell """
            \$OutputEncoding = [System.Text.Encoding]::UTF8
            \$BuildStatus = "${buildStatus}"
            \$ProjectName = "${payload.change_obj_project}"
            \$BranchName = "${payload.change_obj_branch}"
            \$Subject = "${payload.change_obj_subject}"
            \$SubmitterName = "${payload.submitter_obj_name}"
            \$SubmitterEmail = "${payload.submitter_obj_email}"
            \$Status = "${payload.change_obj_status}"
            \$ChangeUrl = "${payload.change_obj_url}"
            \$ChangeNumber = "${payload.change_obj_number}"
            \$NewRev = "${payload.newRev}"
            \$Insertions = "${payload.patchSet_obj_sizeInsertions}"
            \$Deletions = "${payload.patchSet_obj_sizeDeletions}"
            
            \$BuildUrl = "${payload.BUILD_URL}"
            \$JobName = "${payload.JOB_NAME}"
            \$BuildNumber = "${payload.BUILD_NUMBER}"
            
            \$Workspace = "${payload.WORKSPACE}"
            \$BuildOutputPath = "${payload.BUILD_OUTPUT_PATH}"
            \$BuildOutputPathWin = \$BuildOutputPath.Replace('/', '\\') 
            \$AttachmentDir = Join-Path -Path \$Workspace -ChildPath \$BuildOutputPathWin
            
            \$AttachmentNameString = "${attachmentNameString}"
            \$ExistingAttachments = @()

            if (\$AttachmentNameString -ne "") {
                \$AttachmentNames = \$AttachmentNameString.Split(',')
                
                Write-Host "[Notification] Checking for attachments in \$AttachmentDir..."

                foreach (\$name in \$AttachmentNames) {
                    \$fileName = \$name.Trim()
                    \$filePath = Join-Path -Path \$AttachmentDir -ChildPath \$fileName
                    
                    if (Test-Path \$filePath) {
                        \$ExistingAttachments += \$filePath
                        Write-Host "[Notification] Found attachment: \$filePath"
                    } else {
                        Write-Host "[Notification] [Warning] Attachment file not found, skipping: \$filePath"
                    }
                }
            } else {
                Write-Host "[Notification] No attachments specified."
            }

            # --- 이메일 제목 및 본문 생성 ---
            \$EmailSubject = "[Jenkins - \${BuildStatus}] \${ProjectName}(\${BranchName}) - \${Subject}"
            \$EmailBody = @"
            <h2>Jenkins Build 알림: \${BuildStatus}</h2>
            <p>
                <b>\${ProjectName}</b> 프로젝트의 <b>\${BranchName}</b> 브랜치에 변경 사항이 병합되어 빌드가 실행되었습니다.
            </p>
            <hr>
            <h3>📋 핵심 변경 사항</h3>
            <table border="1" cellpadding="5" cellspacing="0" style="border-collapse:collapse;">
                <tr style="background-color:#f0f0f0;">
                    <td><b>항목</b></td>
                    <td><b>내용</b></td>
                </tr>
                <tr>
                    <td><b>프로젝트</b></td>
                    <td>\${ProjectName}</td>
                </tr>
                <tr>
                    <td><b>브랜치</b></td>
                    <td>\${BranchName}</td>
                </tr>
                <tr>
                    <td><b>변경 제목</b></td>
                    <td>\${Subject}</td>
                </tr>
                <tr>
                    <td><b>제출자 (Submitter)</b></td>
                    <td>\${SubmitterName} (\${SubmitterEmail})</td>
                </tr>
                <tr>
                    <td><b>상태</b></td>
                    <td><b>\${Status} (MERGED)</b></td>
                </tr>
            </table>
            <br>
            <h3>🔗 관련 링크</h3>
            <ul>
                <li><b>Gerrit 변경 사항:</b> <a href="\${ChangeUrl}">[#\${ChangeNumber}] \${Subject}</a></li>
                <li><b>Jenkins 빌드 로그:</b> <a href="\${BuildUrl}console">\${JobName} #\${BuildNumber} (Console)</a></li>
            </ul>
            <br>
            <h3>📝 상세 정보</h3>
            <ul>
                <li><b>병합된 커밋(Hash):</b> \${NewRev}</li>
                <li><b>변경 내용:</b> +\${Insertions} 줄, -\${Deletions} 줄</li>
            </ul>
"@
            
            # --- SMTP 인증 정보 생성 ---
            \$SmtpUser = \$env:EMAIL_USER
            \$SmtpPass = \$env:EMAIL_PASS
            \$SmtpCreds = New-Object System.Management.Automation.PSCredential(\$SmtpUser, (ConvertTo-SecureString \$SmtpPass -AsPlainText -Force))
            
            # --- 이메일 발송 ---
            \$MailParams = @{
                From = \$SmtpUser
                To = \$SubmitterEmail
                Subject = \$EmailSubject
                Body = \$EmailBody
                BodyAsHtml = \$true
                SmtpServer = "gw.bhevs.co.kr"
                Credential = \$SmtpCreds
                Encoding = ([System.Text.Encoding]::UTF8)
            }

            if (\$ExistingAttachments.Count -gt 0) {
                \$MailParams.Add('Attachments', \$ExistingAttachments)
                Write-Host "[Notification] Sending email to \${SubmitterEmail} with \${ExistingAttachments.Count} attachments."
            } else {
                Write-Host "[Notification] Sending email to \${SubmitterEmail} without attachments."
            }

            # Splatting을 사용하여 명령어 실행
            Send-MailMessage @MailParams
        """
    }
}