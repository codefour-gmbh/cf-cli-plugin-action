#!/bin/bash -l

set -e

cf api "$INPUT_CF_API"

AUTH_WAIT_TIME=0
until [ $AUTH_WAIT_TIME -eq 5 ] || cf auth "$INPUT_CF_USERNAME" "$INPUT_CF_PASSWORD"; do
    sleep $(( AUTH_WAIT_TIME++ ))
done
[ $AUTH_WAIT_TIME -lt 5 ]

if [ -n "$INPUT_CF_ORG" ] && [ -n "$INPUT_CF_SPACE" ]; then
  cf target -o "$INPUT_CF_ORG" -s "$INPUT_CF_SPACE"
fi

if [ -n "$INPUT_CF_PLUGIN" ]; then
	cf plugins

	# cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org
	# cf install-plugin -f -r CF-Community "$INPUT_CF_PLUGIN"

	# testing pre-release version 1.2.1
	cf install-plugin -f /cf-puppeteer-linux

	cf plugins
fi

if [ -n "$INPUT_COMMAND" ] && [[ "$INPUT_COMMAND" == "zero-downtime-push" ]]; then
	# THIS SHOULD WORK, but it currenty doesn't ...
	# sh -c "cf $INPUT_COMMAND $* --no-route"
	# sh -c "cf $INPUT_COMMAND $* --route-only"
	# INSTEAD WE WILL TRY TO FIX THIS MANUALLY AT THE END :/
	sh -c "cf $INPUT_COMMAND $*"
	if [ -n "$INPUT_CF_APP" ] && [ -n "$INPUT_CF_ROUTES" ]; then
		export IFS=","
		REQ_ROUTES=($(echo "${INPUT_CF_ROUTES}"))
		ALL_ROUTES=($(cf app "$INPUT_CF_APP" | grep 'routes: ' | sed "s#routes: ##g" | sed "s# ##g"))
		for REQ_ROUTE in ${REQ_ROUTES[@]}; do
			if [[ ${ALL_ROUTES} != *"${REQ_ROUTE}"* ]]; then
				echo "Could not find route: '${REQ_ROUTE}' in app '${INPUT_CF_APP}'"
				cf map-route "$INPUT_CF_APP" "$REQ_ROUTE" || echo "Warning: Failed route mapping '${REQ_ROUTE}' (ignore FAILURE)"
			fi
		done
	fi
else
	sh -c "cf $INPUT_COMMAND $*"
fi
