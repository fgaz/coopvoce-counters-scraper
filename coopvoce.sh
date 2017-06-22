#!/bin/bash

# Questo script permette di ottienere i contatori coopvoce
# (C) 2017 Francesco Gazzetta
# Rilasciato sotto licenza MIT

# imposta questi prima:
username=iltuousername
password=latuapassword

cookie_jar=$(mktemp --suffix=".coopvoce_cookie_jar")

# get the csrf tokens
tokens_page=$(\
  curl -s --compressed 'https://private.coopvoce.it/cas/login' \
  -H 'Accept-Encoding: gzip,deflate' \
  -b "${cookie_jar}" \
  -c "${cookie_jar}"
)
lt_token=$(\
  echo "${tokens_page}" \
  | grep 'name="lt"' \
  | sed -e 's/.*value="\(.*\)".*/\1/'
)
execution_token=$(\
  echo "${tokens_page}" \
  | grep 'name="execution"' \
  | sed -e 's/.*value="\(.*\)".*/\1/'
)

# authenticate
curl -s --compressed 'https://private.coopvoce.it/cas/login' \
  -H 'Accept-Encoding: gzip,deflate' \
  --data "username=${username}" \
  --data "password=${password}" \
  --data "_eventId=submit" \
  --data "submit=LOGIN" \
  --data-urlencode "lt=${lt_token}" \
  --data-urlencode "execution=${execution_token}" \
  -b "${cookie_jar}" \
  -c "${cookie_jar}" \
  > /dev/null

# get the stats page (~10 redirects!)
home_page=$(\
  curl -sL --compressed 'https://private.coopvoce.it/' \
    -H 'Accept-Encoding: gzip,deflate' \
    -b "${cookie_jar}" \
    -c "${cookie_jar}"
)
amounts=$(\
  echo "${home_page}" \
  | grep -Eo 'Residui: [0-9]* di [0-9]* [a-zA-Z]*'
)

rm "${cookie_jar}"

echo "${amounts}"

