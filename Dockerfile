FROM buildpack-deps:jessie-scm
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

# versions
ENV TERRAFORM_VERSION v0.6.3
ENV TERRAFORM_COREOS_VERSION v0.0.1
ENV TERRAFORM_EXECUTE_VERSION v0.0.2
ENV TERRAFORM_COREOSVER_VERSION v0.0.1
ENV KUBERNETES_VERSION v1.0.3

# get terraform
RUN wget https://github.com/Samsung-AG/homebrew-terraform/releases/download/${TERRAFORM_VERSION}/terraform-${TERRAFORM_VERSION}_linux64.tar.gz

# get custom providers
RUN wget https://github.com/Samsung-AG/homebrew-terraform-provider-coreos/releases/download/${TERRAFORM_COREOS_VERSION}/terraform-provider-coreos_linux_amd64.tar.gz
RUN wget https://github.com/Samsung-AG/terraform-provider-execute/releases/download/${TERRAFORM_EXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz
RUN wget https://github.com/Samsung-AG/terraform-provider-coreosver/releases/download/${TERRAFORM_COREOSVER_VERSION}/terraform-provider-coreosver_linux_amd64.tar.gz

# decompress everything
RUN tar -xvf terraform-${TERRAFORM_VERSION}_linux64.tar.gz \
    && tar -xvf terraform-provider-coreos_linux_amd64.tar.gz \
    && tar -xvf terraform-provider-coreosver_linux_amd64.tar.gz \
    && tar -xvf terraform-provider-execute_linux_amd64.tar.gz \
    && rm terraform*.tar.gz

# install all binaries
RUN cp terraform* /usr/local/bin

# cleanup
RUN rm terraform*

# python and ansible
RUN apt-get update \
    && apt-get install -y --force-yes \
      curl \
      jq \
      build-essential \
      python-yaml \
      python-jinja2 \
      python-httplib2 \
      python-keyczar \
      python-paramiko \
      python-setuptools \
      python-pkg-resources \
      python-pip \
      vim \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/ansible/
RUN pip install ansible
COPY ansible/ansible.cfg /etc/ansible/ansible.cfg

# install kubectl
RUN wget https://github.com/GoogleCloudPlatform/kubernetes/releases/download/${KUBERNETES_VERSION}/kubernetes.tar.gz
RUN tar -xvf kubernetes.tar.gz
RUN cp kubernetes/platforms/linux/amd64/kubectl /usr/bin && rm kubernetes.tar.gz

# install awscli
RUN pip install awscli

COPY ansible /opt/kraken/ansible/
COPY terraform /opt/kraken/terraform/