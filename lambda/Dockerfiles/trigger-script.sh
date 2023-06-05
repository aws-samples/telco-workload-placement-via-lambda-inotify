function handler () {
  set -xe
  EVENT_DATA=$1
  REGION=$(echo "$EVENT_DATA" | jq -r .location)
  HELM_CHART_REPO=$(echo "$EVENT_DATA" | jq -r .chart_repository)
  HELM_CHART_VALUES=$(echo "$EVENT_DATA" | jq -r .values_yaml_file)
  HELM_CHART_VERSION=$(echo "$EVENT_DATA" | jq -r .chart_version)
  HELM_DEPLOY_NAME=$(echo "$EVENT_DATA" | jq -r .function_name)
  INSTALL_NAMESPACE=$(echo "$EVENT_DATA" | jq -r .run_namespace)
  EKS_CLUSTER_NAME=$(echo "$EVENT_DATA" | jq -r .eks_cluster_name)
  AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity | jq -r '.Account')

  # Generate kubeconfig #
  aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${REGION} --kubeconfig /tmp/config
  export KUBECONFIG=/tmp/config
  mkdir -p /tmp/helm-cache/
  mkdir -p /tmp/helm-config/
  export HELM_CACHE_HOME=/tmp/helm-cache/
  export HELM_CONFIG_HOME=/tmp/helm-config/

  aws ecr get-login-password \
     --region  ${REGION} | helm registry login \
     --username AWS \
     --password-stdin ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${REGION}.amazonaws.com

  if [ -z ${HELM_CHART_VALUES} ] || [ ${HELM_CHART_VALUES} == 'null' ]
  then
      echo "Values file in S3 not provided, proceeding to use the default"
      helm -n ${INSTALL_NAMESPACE} upgrade --install ${HELM_DEPLOY_NAME} ${HELM_CHART_REPO} --version ${HELM_CHART_VERSION} --create-namespace
      kubectl -n ${INSTALL_NAMESPACE} get pods
  else
      echo "Values file in S3 (${HELM_CHART_VALUES}) provided, proceeding to use it to deploy the helm chart"
      aws --region ${REGION} s3 cp ${HELM_CHART_VALUES} /tmp/values.yaml
      helm -n ${INSTALL_NAMESPACE} upgrade --install ${HELM_DEPLOY_NAME} ${HELM_CHART_REPO} --version ${HELM_CHART_VERSION} --create-namespace -f /tmp/values.yaml
      kubectl -n ${INSTALL_NAMESPACE} get pods
  fi      
  RESPONSE="Echoing request: '$EVENT_DATA'"

  echo $RESPONSE
}