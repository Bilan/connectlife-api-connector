#!/usr/bin/with-contenv bashio

if ! [[ -v CONNECTLIFE_LOGIN ]]; then
    export CONNECTLIFE_LOGIN=$(bashio::config 'connectlife_login')
fi

if ! [[ -v CONNECTLIFE_PASSWORD ]]; then
    export CONNECTLIFE_PASSWORD=$(bashio::config 'connectlife_password')
fi

if ! [[ -v TEMPERATURE_UNIT ]]; then
    export TEMPERATURE_UNIT=$(bashio::config 'temperature_unit')
fi

if ! [[ -v LOG_LEVEL ]]; then
    export LOG_LEVEL=$(bashio::config 'log_level')
fi

if ! [[ -v DISABLE_HTTP_API ]]; then
    export DISABLE_HTTP_API=$(bashio::config 'disable_http_api')
else
    export DISABLE_HTTP_API=false
fi

[[ -v BEEPING ]] || export BEEPING=$(bashio::config "beeping")
[[ -v DEVICES_CONFIG ]] || export DEVICES_CONFIG=$(bashio::config "devices_config")

# mqtt config

if ! [[ -v MQTT_HOST ]]; then
    export MQTT_HOST=$(bashio::config "mqtt_host")
fi

if ! [[ -v MQTT_USER ]]; then
    export MQTT_USER=$(bashio::config "mqtt_user")
fi

if ! [[ -v MQTT_PASSWORD ]]; then
    export MQTT_PASSWORD=$(bashio::config "mqtt_password")
fi

if ! [[ -v MQTT_PORT ]]; then
    export MQTT_PORT=$(bashio::config "mqtt_port")
fi

if ! [[ -v MQTT_SSL ]]; then
    export MQTT_SSL=$(bashio::config "mqtt_ssl")
fi

# Try to get mqtt config from ha if config empty
if [ -z "$MQTT_HOST" ]; then
    export MQTT_HOST=$(bashio::services mqtt "host")
    export MQTT_USER=$(bashio::services mqtt "username")
    export MQTT_PASSWORD=$(bashio::services mqtt "password")
    export MQTT_PORT=$(bashio::services mqtt "port")
    export MQTT_SSL=$(bashio::services mqtt "ssl")
fi

php artisan app:check-config

if [ -z "$MQTT_HOST" ]; then
    echo "MQTT configuration not found, running HTTP API only."
    /usr/bin/supervisord -c /home/app/docker-files/supervisord/webapi.conf
elif [ "$DISABLE_HTTP_API" = "true" ]; then
    echo "HTTP API disabled, running MQTT client only."
    /usr/bin/supervisord -c /home/app/docker-files/supervisord/mqtt.conf
else
    /usr/bin/supervisord -c /home/app/docker-files/supervisord/all.conf
fi
