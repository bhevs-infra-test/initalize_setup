@Library('bhevs-shared-library') _

pipeline {
    agent { label 'windows-server-agent' }

    environment {
        GIT_CREDENTIALS_ID = 'teamforge-choiseu'
        BUILD_OUTPUT_PATH = 'renault_gen3_odc_appl/Renault_Gen3/Appl/MakeBin'
        GIT_BASE_URL = 'https://teamforge.bhevs.co.kr/gerrit'
    }

    stages {
        stage('1. Source Checkout') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        echo "Cloning 1. renault_gen3_fbl..."
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: 'renault_gen3_SWEET100_release']],
                            userRemoteConfigs: [[
                                credentialsId: env.GIT_CREDENTIALS_ID,
                                url: "${env.GIT_BASE_URL}/renault_gen3_fbl"
                            ]],
                            extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'renault_gen3_fbl']]
                        ])

                        echo "Cloning 2. renault_gen3_odc_appl..."
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: 'renault_gen3_SWEET100_release']],
                            userRemoteConfigs: [[
                                credentialsId: env.GIT_CREDENTIALS_ID,
                                url: "${env.GIT_BASE_URL}/renault_gen3_odc_appl"
                            ]],
                            extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'renault_gen3_odc_appl']]
                        ])

                        echo "Cloning 3. renault_gen3_platform_common..."
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: 'renault_gen3_SWEET100_release']],
                            userRemoteConfigs: [[
                                credentialsId: env.GIT_CREDENTIALS_ID,
                                url: "${env.GIT_BASE_URL}/renault_gen3_platform_common"
                            ]],
                            extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'renault_gen3_platform_common']]
                        ])

                        echo "Cloning 4. renault_gen3_platform_wlc..."
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: 'renault_gen3_SWEET400_release']],
                            userRemoteConfigs: [[
                                credentialsId: env.GIT_CREDENTIALS_ID,
                                url: "${env.GIT_BASE_URL}/renault_gen3_platform_wlc"
                            ]],
                            extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'renault_gen3_platform_wlc']]
                        ])

                        echo "Cloning 5. renault_gen3_platform_wlc_inc..."
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: 'renault_gen3_SWEET400_release']],
                            userRemoteConfigs: [[
                                credentialsId: env.GIT_CREDENTIALS_ID,
                                url: "${env.GIT_BASE_URL}/renault_gen3_platform_wlc_inc"
                            ]],
                            extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'renault_gen3_platform_wlc_inc']]
                        ])
                    }
                }
            }
        }

        stage('2. Build Execution') {
            steps {
                script {
                    def BM_HEX_FILE = 'Renault_Bm.hex'
                    def FBL_HEX_FILE = 'Renault_Fbl.hex'

                    def TARGET_PATH = "${env.WORKSPACE}\\${env.BUILD_OUTPUT_PATH.replace('/', '\\')}"

                    def BM_SOURCE_PATH = "${env.WORKSPACE}\\renault_gen3_fbl\\Renault_Gen3\\Bm\\Appl\\${BM_HEX_FILE}"
                    def FBL_SOURCE_PATH = "${env.WORKSPACE}\\renault_gen3_fbl\\Renault_Gen3\\Fbl\\Appl\\${FBL_HEX_FILE}" // 수정된 변수 사용

                    echo "Ensuring target directory exists: ${TARGET_PATH}"
                    bat "IF NOT EXIST \"${TARGET_PATH}\" MKDIR \"${TARGET_PATH}\""

                    echo '--- Starting BM Build ---'
                    dir('renault_gen3_fbl/Renault_Gen3/Bm/Appl') {
                        bat script: 'b -j16', returnStatus: true
                    }
                    echo "Copying ${BM_SOURCE_PATH} to ${TARGET_PATH}"
                    bat "COPY /Y \"${BM_SOURCE_PATH}\" \"${TARGET_PATH}\""

                    echo '--- Starting FBL Build ---'
                    dir('renault_gen3_fbl/Renault_Gen3/Fbl/Appl') {
                        bat script: 'b -j16', returnStatus: true
                    }

                    echo "Copying ${FBL_SOURCE_PATH} to ${TARGET_PATH}"
                    bat "COPY /Y \"${FBL_SOURCE_PATH}\" \"${TARGET_PATH}\""

                    echo '--- Starting build_Appl.bat ---'
                    dir('renault_gen3_odc_appl/Renault_Gen3/Appl') {
                        bat 'build_Appl.bat'
                    }

                    echo '--- Starting RN_SW_Image_Maker.bat ---'
                    dir("${TARGET_PATH}") {
                        bat '"[OneBin]RN_SW_Image_Maker.bat"'
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                def filesToAttach = [
                    'Renault_Gen3.pdx',
                    'Renault_Gen3_OneBin.hex'
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
