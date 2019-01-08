#!/bin/sh

for i in {1..2}; do
  echo ${i}
#  RAILS_ENV=production bundle exec rake scrape:otherentry[${i}]
done
