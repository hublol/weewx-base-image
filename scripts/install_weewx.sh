#!/bin/sh

echo "Installing (or updating) weewx version ${WEEWX_VERSION}."

wget -O ${SOURCE_DIR}/weewx-${WEEWX_VERSION}.tar.gz http://weewx.com/downloads/weewx-${WEEWX_VERSION}.tar.gz
tar xvfz ${SOURCE_DIR}/weewx-${WEEWX_VERSION}.tar.gz -C ${SOURCE_DIR}

cd ${SOURCE_DIR}/weewx-${WEEWX_VERSION} && python3 ./setup.py build
echo "default\n0, meter\n0.00\n0.00\nn\nmetric\n3\n" | python3 ./setup.py install

# Fix for logging in container
sed -i 's/handlers = syslog/handlers = console/g' ${WEEWX_HOME}/bin/weeutil/logger.py

echo Done.