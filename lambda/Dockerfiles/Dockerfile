FROM amazon/aws-lambda-provided:al2

RUN yum install curl unzip openssl tar gzip -y jq && \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install && \
curl -LO https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl && \
chmod +x kubectl && mv kubectl /usr/local/bin/ && \
curl -LO https://get.helm.sh/helm-v3.10.3-linux-amd64.tar.gz && \
tar -xzf helm-v3.10.3-linux-amd64.tar.gz && chmod +x linux-amd64/helm && \
mv linux-amd64/helm /usr/local/bin/ && rm -rf linux-amd64/ helm-v3.10.3-linux-amd64.tar.gz awscliv2.zip && \
yum clean all && rm -rf /var/cache/yum

WORKDIR /var/runtime/
COPY bootstrap bootstrap
RUN chmod 755 bootstrap

WORKDIR /var/task/
COPY trigger-script.sh function.sh
RUN chmod 755 function.sh

CMD [ "function.sh.handler" ]