def buildWar() {
    echo "building the java application..."
    sh 'mvn package'
} 

def buildImage() {
    echo "building the docker image and push it on public ECR repository..."
    sh 'docker build -t public.ecr.aws/f0y2n1c4/aws-devops:latest .'
    sh 'docker push public.ecr.aws/f0y2n1c4/aws-devops:latest'
    
} 

def deployApp() {
    echo 'deploying the application...'
} 

return this
