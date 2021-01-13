#!/bin/bash

seafile_ini="$HOME/.ccnet/seafile.ini"
if [ ! -f "$seafile_ini" ]; then
    echo "Initializing Seafile client..."
    seaf-cli init -d ~/.seafile
    while [ ! -f "$seafile_ini" ]; do sleep 1; done
fi

# Start the Seafile daemon.
echo "Starting Seafile client..."
seaf-cli start
while [ ! -S "$HOME/.seafile/seafile-data/seafile.sock" ]; do sleep 1; done

# Synchronize the library, if not already synchronized.
if [ -z "$(seaf-cli status | grep -v ^\#)" ]; then
    echo "Synchronizing Seafile library..."
    # Set the disable_verify_certificate key to true only if the environment variable exists.
    [[ "$SEAF_SKIP_SSL_CERT" ]] && seaf-cli config -k disable_verify_certificate -v true

    # Set the upload/download limits
    [[ "$SEAF_UPLOAD_LIMIT" ]] && seaf-cli config -k upload_limit -v $SEAF_UPLOAD_LIMIT
    [[ "$SEAF_DOWNLOAD_LIMIT" ]] && seaf-cli config -k download_limit -v $SEAF_DOWNLOAD_LIMIT

    # Build the seaf-cli sync command.
    cmd="seaf-cli sync -u $SEAF_USERNAME -p $SEAF_PASSWORD -s $SEAF_SERVER_URL -l $SEAF_LIBRARY_UUID -d /library"
    [[ "$SEAF_2FA_SECRET" ]] && cmd+=" -a $(oathtool --base32 --totp $SEAF_2FA_SECRET)"
    [[ "$SEAF_LIBRARY_PASSWORD" ]] && cmd+=" -e $SEAF_LIBRARY_PASSWORD"

    # Run it.
    if ! eval $cmd; then echo "Failed to synchronize."; exit 1; fi
fi

# Continously print the log, infinitely.
while true; do
    tail -v -f ~/.ccnet/logs/seafile.log
    echo $?
done
