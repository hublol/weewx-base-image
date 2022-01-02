# Use an official Python runtime as a parent image
FROM python:slim-bullseye

# Modify those variable if needed
ENV TZ=Europe/Paris
ENV WEEWX_VERSION=4.5.1
# But it is recommended to keep those as is
ENV WEEWX_HOME=/home/weewx
ENV SOURCE_DIR=/home/sources
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Set the working directory to /share
WORKDIR ${WEEWX_HOME}

# Install some useful packages
# NOTE: the python packages are installed using pip rather than apt-get to avoid issues with multiple python versions
# build-essential, libmariadb-dev, default-mysql-client (and python mysqlclient) are used for MySQL/MariaDB,
# and could be removed if not used (resulting in a smaller image).
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils locales && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/default/locale && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common && \
    DEBIAN_FRONTEND=noninteractive add-apt-repository contrib && \
    DEBIAN_FRONTEND=noninteractive add-apt-repository non-free && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y procps unzip p7zip-full vim usbutils curl rsync wget \
        sqlite3 default-mysql-client xtide xtide-data\
        build-essential libmariadb-dev zlib1g-dev libjpeg-dev libfreetype6-dev && \
    apt-get clean && \
    mkdir -p ${SOURCE_DIR}

# Install the python requirements
COPY requirements.txt ${SOURCE_DIR}
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r ${SOURCE_DIR}/requirements.txt && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the weewx scripts
COPY scripts ${SOURCE_DIR}/scripts
RUN chmod +x ${SOURCE_DIR}/scripts/*.sh

