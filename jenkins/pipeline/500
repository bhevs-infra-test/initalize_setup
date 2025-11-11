@Library('bhevs-shared-library') _

pipeline {
    agent { label 'windows-server-agent' }

    environment {
        GIT_CREDENTIALS_ID = 'teamforge-choiseu'
        BUILD_OUTPUT_PATH = 'renault_gen3_appl/Renault_Gen3/Appl/MakeBin'
        GIT_BASE_URL = 'https://teamforge.bhevs.co.kr/gerrit'
        NEXUS_HOST_PORT = "192.168.37.239:32511"
        NEXUS_REPO_ID = "Renault"
        NEXUS_CREDENTIALS_ID = "nexus-id"
    }

    stages {
        stage('1. Source Checkout') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        echo "Cloning 1. renault_gen3_appl..."
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: 'renault_gen3_SWEET500_release']],
                            userRemoteConfigs: [[
                                credentialsId: env.GIT_CREDENTIALS_ID,
                                url: "${env.GIT_BASE_URL}/renault_gen3_release_appl_test"
                            ]],
                            extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'renault_gen3_appl']]
                        ])
                    }
                }
            }
        }

        stage('2. Build Execution') {
            steps {
                script {
                    echo '--- Starting B.Bat Build ---'
                    dir('renault_gen3_appl/Renault_Gen3/Appl') {
                        bat script: 'b -j16', returnStatus: true
                    }

                    echo 'Running [OneBin_Step_1]RN_SW_Image_Maker.bat and Signing Process...'

                    def hashValue
                    def bearerToken
                    def binFileToDelete = "Renault_Gen3_Appl_Pre_Signed.bin"

                    dir('renault_gen3_appl/Renault_Gen3/Appl/MakeBin') {
                        bat '[OneBin_Step_1]RN_SW_Image_Maker.bat'
                        try {
                            hashValue = bat(
                                script: '@python bin_sha256_hasher.py',
                                returnStdout: true
                            ).trim()

                            echo "Successfully captured hash from Python: ${hashValue}"
                            bat "del ${binFileToDelete}"
                        } catch (e) {
                            error "Failed to execute Python hasher: ${e.message}"
                        }
                    }

                    echo '--- Starting Signing Process ---'
                    dir("${env.BUILD_OUTPUT_PATH}") {
                        def rawTokenOutput = powershell(
                            script: "powershell -File \".\\run_signing.ps1\" -hashValue \"${hashValue}\" -Verbose",
                            returnStdout: true
                        )

                        echo "Raw output from signing script: [${rawTokenOutput}]"

                        def lines = rawTokenOutput.split('\n')
                        if (lines.size() > 0) {
                            bearerToken = lines[-1].trim().replace("\uFEFF", "")
                        }
                        if (!bearerToken || bearerToken.length() < 50) {
                           error "Sanitized token seems invalid or empty. Value: [${bearerToken}]"
                        }

                        echo "Captured Token: ${bearerToken}"
                    }

                    echo '--- Starting [OneBin_Step_2]RN_SW_Image_Maker.bat Build ---'
                    dir("${env.BUILD_OUTPUT_PATH}") {
                        bat '[OneBin_Step_2]RN_SW_Image_Maker.bat'
                    }

                    echo '--- Starting Encryption Process ---'
                    dir("${env.BUILD_OUTPUT_PATH}") {
                        powershell(
                            script: "powershell -File \".\\run_encryption.ps1\" -bearerToken \"${bearerToken}\""
                        )
                    }

                    echo '--- Starting 5_Make_encrypted_Pdx.bat Build ---'
                    dir('renault_gen3_appl/Renault_Gen3/Appl/MakeBin') {
                        bat '5_Make_encrypted_Pdx.bat'XUS
                    }
                }
            }
        }

//        stage('3. Deploy to Nexus') {
//            steps {
//                script {
//                    def VERSION = currentBuild.displayName.replace('#', '-')
//                    echo "VERSION: ${VERSION}"
//
//                    def deployFiles = [
//                        'Renault_Gen3.pdx'                   : "release/${VERSION}/Renault_Gen3.pdx",
//                        'Renault_Gen3_OneBin.hex'            : "release/${VERSION}/Renault_Gen3_OneBin.hex",
//                        'Renault_Gen3_Appl_Encrypted.bin'    : "release/${VERSION}/Renault_Gen3_Appl_Encrypted.bin"
//                    ]
//
//                    withCredentials([usernamePassword(credentialsId: env.NEXUS_CREDENTIALS_ID, passwordVariable: 'NE_PWD', usernameVariable: 'NEXUS_USER')]) {
//                        deployFiles.each { fileName, targetPath ->
//                            def sourceFile = "${env.BUILD_OUTPUT_PATH}/${fileName}"
//                            def nexusUrl = "http://${env.NEXUS_HOST_PORT}/repository/${env.NEXUS_REPO_ID}/${targetPath}"
//                            echo "Deploying ${fileName} to: ${nexusUrl}"
//                            powershell """
//                                \$securePassword = ConvertTo-SecureString -String "\$env:NEXUS_PWD" -AsPlainText -Force
//                                \$credential = New-Object System.Management.Automation.PSCredential ("\$env:NEXUS_USER", \$securePassword)
//                                Invoke-RestMethod -Uri "${nexusUrl}" `
//                                    -Method PUT `
//                                    -InFile "${sourceFile}" `
//                                    -Credential \$credential
//                            """
//                        }
//                    }
//                }
//            }
//        }
//    }

    post {
        always {
            script {
                def filesToAttach = [
                    'Renault_Gen3.pdx',
                    'Renault_Gen3_OneBin.hex',
                    'Renault_Gen3_Appl_Encrypted.bin'
                ]

                sendCiNotification(
                    buildStatus: currentBuild.currentResult,
                    payload: env,
                    attachments: filesToAttach
                )
            }
        }
    }
}