# Telco Workload Placement and Configuration Updates via Lambda and iNotify



## Getting started

N.B - You are required to build the container Open5gs container images yourself and push to your ECR. Details on how to do this can be found in the open5gs-docker-files/ folder.

## Export Environment Variables (Use appropriate values with respect to your environment)

```
export AWS_REGION="us-east-2"
export AWS_ACCOUNT_NUMBER=""
```

# EKS and NG Creation

```
eksctl create cluster -n ohio-az-a --region ${AWS_REGION} --zones ${AWS_REGION}a,${AWS_REGION}b --node-zones ${AWS_REGION}a
eksctl create cluster -n ohio-az-b --region ${AWS_REGION} --zones ${AWS_REGION}a,${AWS_REGION}b --node-zones ${AWS_REGION}b
```

# Add Lambda Role to the EKS Clusters

```
eksctl create iamidentitymapping --region ${AWS_REGION} --cluster ohio-az-a --arn arn:aws:iam::${AWS_ACCOUNT_NUMBER}:role/lamda-orchestration-role --group system:masters --username admin
eksctl create iamidentitymapping --region ${AWS_REGION} --cluster ohio-az-b --arn arn:aws:iam::${AWS_ACCOUNT_NUMBER}:role/lamda-orchestration-role --group system:masters --username admin
```

# Command Lambda will be using to generate kubeconfig

```
aws eks update-kubeconfig --name ohio-az-a --region ${AWS_REGION} --kubeconfig /tmp/config
aws eks update-kubeconfig --name ohio-az-b --region ${AWS_REGION} --kubeconfig /tmp/config
```

# Lambda ECR

```
ECR repo for the helm trigger function:
${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-2.amazonaws.com/helm-trigger-function:v0.0.7

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-2.amazonaws.com

docker build -t ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com/helm-trigger-function:v0.0.7 .

docker push ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com/helm-trigger-function:v0.0.7
```

Open5gs Helm Chart ECR

```
### Helm comands to package the charts and push to ECR (as an oci repo)

helm package .\5gcore-helm-inotify-charts\

### Create Private ECR Repo

aws ecr create-repository --repository-name open5gs-charts --region ${AWS_REGION}

### Login To ECR

aws ecr get-login-password \
     --region ${AWS_REGION} | helm registry login \
     --username AWS \
     --password-stdin ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com

### Push Chart To ECR Repo

helm push open5gs-charts-0.0.4.tgz oci://${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com/
```



# Sample JSON payload to test th API GW

```
{
  "location": "us-east-2",
  "chart_repository": "oci://public.ecr.aws/e4d9p0p1/open5gs-charts",
  "chart_version": "0.0.3",
  "function_name": "core5g-1",
  "run_namespace": "open5gs-1",
  "eks_cluster_name": "ohio-az-a"
}

{
  "location": "us-east-2",
  "chart_repository": "oci://public.ecr.aws/e4d9p0p1/open5gs-charts",
  "chart_version": "0.0.4",
  "function_name": "core5g-2",
  "run_namespace": "open5gs-2",
  "eks_cluster_name": "ohio-az-b"
}

With S3 values:

{
  "location": "us-east-2",
  "chart_repository": "oci://public.ecr.aws/e4d9p0p1/open5gs-charts",
  "values_yaml_file": "s3://orchestration-nfv-values/values.yaml",
  "chart_version": "0.0.4",
  "function_name": "core5g-1",
  "run_namespace": "open5gs-1",
  "eks_cluster_name": "ohio-az-a"
}

{
  "location": "us-east-2",
  "chart_repository": "oci://public.ecr.aws/e4d9p0p1/open5gs-charts",
  "values_yaml_file": "s3://orchestration-nfv-values/values.yaml",
  "chart_version": "0.0.4",
  "function_name": "core5g-2",
  "run_namespace": "open5gs-2",
  "eks_cluster_name": "ohio-az-b"
}

{
  "location": "us-east-2",
  "chart_repository": "oci://public.ecr.aws/e4d9p0p1/open5gs-charts",
  "values_yaml_file": "s3://orchestration-nfv-values/values-test.yaml",
  "chart_version": "0.0.4",
  "function_name": "core5g-2",
  "run_namespace": "open5gs-2",
  "eks_cluster_name": "ohio-az-b"
}

```
