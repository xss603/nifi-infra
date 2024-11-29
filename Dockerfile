FROM alpine

COPY requirements.txt /

# Install needed packages
RUN apk add --no-cache python3 ca-certificates openssl && \
    apk add openjdk8 && \
    apk add py3-pip

# Install requirements
RUN apk --update-cache add --virtual build-dependencies curl libffi-dev openssl-dev python3-dev build-base && \
    pip3 install -r /requirements.txt && \
    apk del build-dependencies \
    curl https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_arm.zip  -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform
WORKDIR /appli