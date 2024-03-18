#!/bin/bash
touch .env
echo "REMOTE_DATABASE_URL=$REMOTE_DATABASE_URL" > .env
echo "SECRET_KEY_BASE=$SECRET_KEY_BASE" >> .env
echo "RAILS_ENV=production" >> .env