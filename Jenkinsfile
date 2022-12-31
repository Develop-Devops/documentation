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
                    curl -i -X GET "https://api.telegram.org/bot5930447612:AAF58r4BMMnnc0jWMLK7ZV4Od_3VoQyZwRI/sendMessage?chat_id=-1001625414484&text=✅✅✅The '"$JOB_NAME"' job execution was successful, for details go to: '"$RUN_DISPLAY_URL"' "
                '''
                }
            failure {
                sh '''
                    curl -i -X GET "https://api.telegram.org/bot5930447612:AAF58r4BMMnnc0jWMLK7ZV4Od_3VoQyZwRI/sendMessage?chat_id=-1001625414484&text=The '"$JOB_NAME"' job execution has failed, for details go to: '"$RUN_DISPLAY_URL"' "
                '''
                }
            aborted{
                sh '''
                    curl -i -X GET "https://api.telegram.org/bot5930447612:AAF58r4BMMnnc0jWMLK7ZV4Od_3VoQyZwRI/sendMessage?chat_id=-1001625414484&text=The '"$JOB_NAME"' job execution was aborted, for details go to: '"$RUN_DISPLAY_URL"' "
                '''
                }
        }

}
