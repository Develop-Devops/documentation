
Crear directorio .github/workflows/ y dentro escribir un .yml por ejemplo

`.github/workflows/deploy.yml`

name: Deploy to ECR

on:
 push:
    branches:
     - dev
     - 'feature/**'
     - 'bugfix/**'
     - 'hotfix/**'
jobs:
  build:    
    name: Build Image
    runs-on: ubuntu-latest

    steps:
    - name: Check out code
      uses: actions/checkout@v2
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Build, tag, and push image to Amazon ECR
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: calorify-portal
        IMAGE_TAG: dev
      run: |
        rm -rf .env*
        echo "$ENV_NAME" > .env.production
        cat .env.production      
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
    - name: Force deployment
      run: |
        aws ecs update-service --cluster calorify --service calorify-staging-portal --force-new-deployment