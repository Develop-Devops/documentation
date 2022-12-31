pipeline {
    agent {label 'master'}
	stages {
       stage('Deploy Prod') {
           when {expression { env.BRANCH_NAME == 'main' }}
           agent { node {label 'master' }}
           steps {
                sh '''
                echo Deploying ....
                '''
           }
       }
    }
	post
	    {
            success {
                sh '''
                    curl -i -X GET "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage?chat_id=${TELEGRAM_GROUP}&text=✅✅✅The '"$JOB_NAME"' job execution was successful, for details go to: '"$RUN_DISPLAY_URL"' "
                '''
                }
            failure {
                sh '''
                    curl -i -X GET "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage?chat_id=${TELEGRAM_GROUP}&text=🚨🚨🚨The '"$JOB_NAME"' job execution has failed, for details go to: '"$RUN_DISPLAY_URL"' "
                '''
                }
            aborted{
                sh '''
                    curl -i -X GET "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage?chat_id=${TELEGRAM_GROUP}&text=The '"$JOB_NAME"' job execution was aborted, for details go to: '"$RUN_DISPLAY_URL"' "
                '''
                }
        }

}