## This covers creating Helm template package and uploading to ECR

### Create ECR Repo

```
aws ecr create-repository --repository-name open5gs-charts --region $AWS_REGION
```

### Package charts

```
helm package .
```

### Push to ECR Repo

```
aws ecr get-login-password \
     --region $AWS_REGION | helm registry login \
     --username AWS \
     --password-stdin $AWS_ACCOUNT_NUMBER.dkr.ecr.$AWS_REGION.amazonaws.com

helm push open5gs-charts-0.0.4.tgz oci://$AWS_ACCOUNT_NUMBER.dkr.ecr.$AWS_REGION.amazonaws.com/ 
```