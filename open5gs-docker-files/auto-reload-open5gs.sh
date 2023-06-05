#!/usr/bin/bash
open5gs-${CNF_NAME}d -D -c /open5gs/config-map/${CNF_NAME}.yaml
oldcksum=$(cksum /open5gs/config-map/${CNF_NAME}.yaml)

inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M' --format '%T' \
/open5gs/config-map/ | while read date time; do

    newcksum=$(cksum /open5gs/config-map/${CNF_NAME}.yaml)
    if [ "$newcksum" != "$oldcksum" ]; then
        echo "At ${time} on ${date}, config file update detected."
        oldcksum=$newcksum
        pkill open5gs-${CNF_NAME}d
        open5gs-${CNF_NAME}d -D -c /open5gs/config-map/${CNF_NAME}.yaml
    fi
done    