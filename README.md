# Observer
[![Build Status](https://travis-ci.org/zxftr45/observer.svg?branch=master)](https://travis-ci.org/ololyay/observer)
[![Code Climate](https://codeclimate.com/github/zxftr45/observer/badges/gpa.svg)](https://codeclimate.com/github/zxftr45/observer)
[![Dependency Status](https://gemnasium.com/badges/github.com/zxftr45/observer.svg)](https://gemnasium.com/github.com/zxftr45/observer)

### Setup
#### Requirements
- install ruby 2.3
- install node
- install other packages
```
apt-get install mongodb redis-server dnsutils
```

- install dependencies

```
npm install gulp-cli -g
npm install bower -g
npm install
bundle install
```

### Set up configs
Create `mongoid.yml` like:
```yml
development:
  clients:
    default:
      database: observer_dev
      hosts:
        - localhost:27017
      options:
        max_pool_size: 100

test:
  clients:
    default:
      database: observer_test
      hosts:
        - localhost:27017
      options:
        max_pool_size: 100
```
Create `config/config.yml` like:
```yml
mailgun_domain: sandboxXXXXXXXXXXXXXXXX.mailgun.org
mailgun_key: key-XXXXXXXXXXXXXXXXXXX
host: 127.0.0.1:9292
email_from: 'bot@observer'
default_emails: # default emails for notifications
  - 'some@example.com'
```

Set up crontab
```
whenever --update-cronatb
```

### Run
Compile frontend
```
gulp dev
```

Run server
```
bundle exec puma -C puma.rb
```

Run sidekiq processing
```
bundle exec sidekiq -r ./main.rb
```
