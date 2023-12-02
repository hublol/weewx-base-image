# Use an official Python runtime as a parent image
# weewx 4.10 doesn't support bookworm yet...
FROM python:3-bookworm

# Modify those variable if needed
ENV TZ=Europe/Paris
ENV WEEWX_VERSION=4.10.2
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

# NOTE: add-apt-repository currently not working in with Debian 12 bookworm (not support for DEB822-STYLE format)
# Replaced with sed commands for now
#    DEBIAN_FRONTEND=noninteractive add-apt-repository -y contrib && \
#    DEBIAN_FRONTEND=noninteractive add-apt-repository -y non-free && \

# TODO: xtide currently not available on bookworm - should be manually installed.
# xtide xtide-data xtide-data-nonfree

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils locales && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/default/locale && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common python3-launchpadlib && \
    sed -i "s/Components: main/Components: main contrib non-free/" /etc/apt/sources.list.d/debian.sources && \
    DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y procps unzip p7zip-full vim usbutils curl rsync wget \
        sqlite3 default-mysql-client \
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

