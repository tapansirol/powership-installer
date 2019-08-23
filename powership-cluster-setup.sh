# CHECK INPUT
if [ -z "$1" ] ||  [ -z "$2" ]
  then
    echo "ERROR: This script requires your Artifactory credentials:"
    echo "    powership-cluster-setup.sh <username> <password> [namespace]"
    exit 1
fi

# POWERSHIP REPOS
HELM_REPO=https://hclproducts.jfrog.io/hclproducts/powership-helm
DOCKER_REPO=https://hclproducts-powership-docker.jfrog.io
NAMESPACE="${3:-default}"
                    
# CREATE THE NAMESPACE AND DOCKER-REGISTRY SECRET THAT WILL ALLOW KUBERNETES TO PULL IMAGES
kubectl create namespace ${NAMESPACE} 2>/dev/null
kubectl delete secret powership-docker --namespace ${NAMESPACE} 2>/dev/null
kubectl create secret docker-registry powership-docker --namespace ${NAMESPACE} --docker-server=${DOCKER_REPO} --docker-username=${1} --docker-password=${2} --docker-email=${1}
kubectl patch serviceaccount default --namespace ${NAMESPACE} -p '{"imagePullSecrets": [{"name": "powership-docker"}]}'

# ADD THE POWERSHIP HELM REPO WITH AUTHENTICATION
helm repo add powership-repo ${HELM_REPO} --username ${1} --password ${2} 
helm repo update
