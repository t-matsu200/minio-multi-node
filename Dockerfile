FROM docker.io/amazon/aws-cli:2.22.25

ENV AWS_DEFAULT_REGION ap-northeast-1
ENV AWS_DEFAULT_OUTPUT json

ENV TF_CLI_ARGS_plan  "--parallelism=30"
ENV TF_CLI_ARGS_apply "--parallelism=100"

RUN yum -y update \
  && amazon-linux-extras install epel -y \
  && yum install git tar gzip unzip curl wget tree jq sshpass -y

# Install Helm
ARG HELM_VERSION=3.16.4
RUN curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz \
  && tar -zxf helm.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && rm -rf linux-amd64 \
  && rm helm.tar.gz

# Install Session Manager Plugin
# https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-linux.html
RUN yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm \
  && yum clean all \
  && rm -r /var/cache/yum

# Install Terraform
ARG TERRAFORM_VERSION=1.10.3
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin/ \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

WORKDIR /work

ENTRYPOINT bash
CMD ["-c", "sleep", "infinity"]
