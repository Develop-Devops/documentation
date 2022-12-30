## github apps

![qownnotes-media-rYAomz](../../media/qownnotes-media-rYAomz.png)

### developers settings

![qownnotes-media-cRyqKw](../../media/qownnotes-media-cRyqKw.png)

### new github App

![qownnotes-media-sAemVz](../../media/qownnotes-media-sAemVz.png)

![qownnotes-media-oBtVic](../../media/qownnotes-media-oBtVic.png)

![qownnotes-media-fcbOcp](../../media/qownnotes-media-fcbOcp.png)

![qownnotes-media-xsnyNn](../../media/qownnotes-media-xsnyNn.png)

### Copy your data

![qownnotes-media-SwRryz](../../media/qownnotes-media-SwRryz.png)

### Generate private key

![qownnotes-media-eTDyhO](../../media/qownnotes-media-eTDyhO.png)


### Converting the private key for Jenkins

After you have generated the private key authenticating to the GitHub App, you need to convert the key into a different format that Jenkins can use with the following command:

openssl pkcs8 -topk8 -inform PEM -outform PEM -in key-in-your-downloads-folder.pem -out converted-github-app.pem -nocrypt



https://docs.cloudbees.com/docs/cloudbees-ci/latest/cloud-admin-guide/github-app-auth





