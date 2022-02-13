az feature register --name EnablePodIdentityPreview --namespace Microsoft.ContainerService


$resourceGroup = "crgar-aks-msi-rg"
$identityName = "crgar-aks-msi-aks-pod-identity"
$aksName = "crgar-aks-msi-aks"

az identity create --resource-group $resourceGroup --name $identityName
$IdentityClientId="$(az identity show -g $resourceGroup -n $identityName --query clientId -otsv)"
$IdentityResourceId="$(az identity show -g ${resourceGroup} -n ${identityName} --query id -otsv)"

# DROP USER IF EXISTS "crgar-aks-msi-aks-pod-identity"
# GO
# CREATE USER "crgar-aks-msi-aks-pod-identity" FROM EXTERNAL PROVIDER;
# GO
# ALTER ROLE db_datareader ADD MEMBER "crgar-aks-msi-aks-pod-identity";
# ALTER ROLE db_datawriter ADD MEMBER "crgar-aks-msi-aks-pod-identity";
# GRANT EXECUTE TO "crgar-aks-msi-aks-pod-identity"
# GO

az aks update -g $resourceGroup -n $aksName --enable-pod-identity --enable-pod-identity-with-kubenet

kubectl apply -f my-app-namespace.yaml

$podIdentityName="crgar-aks-msi-aks-pod-identity"
$podIdentityNamespace="my-app"
az aks pod-identity add --resource-group $resourceGroup --cluster-name $aksName --namespace $podIdentityNamespace  --name $podIdentityName --identity-resource-id $IdentityResourceId

kubectl get azureidentity -n $podIdentityNamespace
kubectl get azureidentitybinding -n $podIdentityNamespace

kubectl apply -f my-app.yaml --namespace $podIdentityNamespace
kubectl delete pod my-app --namespace $podIdentityNamespace
kubectl logs my-app --namespace $podIdentityNamespace
kubectl describe pod my-app --namespace $podIdentityNamespace
kubectl get pod --namespace $podIdentityNamespace

kubectl exec my-app -c my-app -it --namespace $podIdentityNamespace -- bash

apt-get update
apt-get upgrade
apt-get install curl
apt-get install software-properties-common
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc
apt-add-repository https://packages.microsoft.com/ubuntu/20.04/prod
apt-get update
apt-get upgrade
ACCEPT_EULA=Y apt-get install -y msodbcsql17
# optional: for bcp and sqlcmd
ACCEPT_EULA=Y apt-get install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
# optional: for unixODBC development headers
apt-get install -y unixodbc-dev
apt install pip
pip install pyodbc