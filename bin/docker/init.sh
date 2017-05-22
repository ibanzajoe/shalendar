#!/bin/bash
bundle

if [ ! -f /app/tmp/initialized ]
then
padrino rake db:reset
padrino rake db:seed
padrino rake db:migrate
touch /app/tmp/initialized
else    
padrino rake db:migrate
fi

bundle exec rackup  -p 3000
#passenger start -d --pool-idle-time=0
#tail -f /app/log/passenger.3000.log
