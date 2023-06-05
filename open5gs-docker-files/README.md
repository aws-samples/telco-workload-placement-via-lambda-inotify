## This Covers Building Of Container Images For Open5gs

A single container image is used for all the Open5gs CNF, hence we will call the container image ***open5gs-aio*** and a separate container image for the Open5gs web-ui which will be named as ***open5gs-web-ui***

To build the images please follow the steps below:

```
## Create ECR repos

aws ecr create-repository --repository-name open5gs-aio

aws ecr create-repository --repository-name open5gs-web-ui

## Login To ECR

aws ecr get-login-password --region AWS_REGION | sudo docker login --username AWS --password-stdin AWS_ACCOUNT_NUMBER.dkr.ecr.AWS_REGION.amazonaws.com
```

**Build AIO  open5gs NF image:**

```
sudo docker build -t AWS_ACCOUNT_NUMBER.dkr.ecr.AWS_REGION.amazonaws.com/open5gs-aio:v2.5.6-inotify -f open5gs-aio-dockerfile .
```

**Push image to your ECR:**

```
sudo docker push AWS_ACCOUNT_NUMBER.dkr.ecr.AWS_REGION.amazonaws.com/open5gs-aio:v2.5.6-inotify
```

**To build the web-ui image please follow the steps below:**

```
## Login To ECR

aws ecr get-login-password --region AWS_REGION | sudo docker login --username AWS --password-stdin AWS_ACCOUNT_NUMBER.dkr.ecr.AWS_REGION.amazonaws.com

## Build and tag image
sudo docker build -t AWS_ACCOUNT_NUMBER.dkr.ecr.AWS_REGION.amazonaws.com/open5gs-web-ui:v2.5.6 -f open5gs-web-dockerfile .
```

**Push image to your ECR:**

```
sudo docker push AWS_ACCOUNT_NUMBER.dkr.ecr.AWS_REGION.amazonaws.com/open5gs-web-ui:v2.5.6
```

You can now use the repos in your respective helm values file.