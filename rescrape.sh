#!/bin/sh

for i in {1..4}; do
  echo ${i}
  RAILS_ENV=production bundle exec rake scrape:otherentry_hachi[${i}]
done
