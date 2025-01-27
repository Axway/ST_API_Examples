#! /bin/bash

echo "Loading variables into our context..."
source "../set_variables.sh"

#
# Once you are ready with all your tasks, you can logout using the DELETE method.
#
REFERER_HEADER="Referer: THIS_IS_A_RANDOM_TEXT"
curl -k --cookie-jar cookie.jar -u "${USER}:${PWD}" -X POST "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"

curl -k --cookie cookie.jar -X GET "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"

curl -k -L --cookie cookie.jar -X DELETE "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"

curl -k --cookie cookie.jar -X GET "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"