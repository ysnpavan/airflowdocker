FROM python:3.8-slim-buster
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}
ENV PYTHONPATH=${AIRFLOW_USER_HOME}
# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN apt-get update -y && \
    apt-get install -y gcc && \
    apt-get install vim -y && \
    useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
libglib2.0-0 libxext6 libsm6 libxrender1   

RUN apt-cache policy lsb-release
RUN apt-get -y install lsb-release
RUN wget https://packages.couchbase.com/clients/c/libcouchbase-3.0.0_debian10_buster_amd64.tar && \
    tar xf libcouchbase-3.0.0_debian10_buster_amd64.tar && \
    cd libcouchbase-3.0.0_debian10_buster_amd64 && \
    apt install libevent-core-2.1
RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -y wget \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        libsasl2-dev \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY requirements.txt ${AIRFLOW_USER_HOME}/requirements.txt
COPY dags ${AIRFLOW_USER_HOME}/dags/
COPY operators ${AIRFLOW_USER_HOME}/operators/
COPY hooks ${AIRFLOW_USER_HOME}/hooks/
COPY transformers ${AIRFLOW_USER_HOME}/transformers/
COPY utils ${AIRFLOW_USER_HOME}/utils/
COPY sensors ${AIRFLOW_USER_HOME}/sensors/
COPY entrypoint.sh ${AIRFLOW_USER_HOME}/entrypoint.sh
RUN chmod -R a+rx ${AIRFLOW_USER_HOME}/entrypoint.sh


USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
RUN pip install --user -r requirements.txt