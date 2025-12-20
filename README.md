Documentation: https://harrybournis.github.io/capstoned-api-documentation/

Trello: https://trello.com/b/ahb8alLZ/capstoneed-api

# Installation
1. Install ruby 3.4.7
2. Run `gem install bundler`
3. Run `bundle install`

# ENV vars
```
DB_URL=postgresql://dev:dev@127.0.0.1:5432
SECRET_KEY_BASE=<development key>
RAILS_MAX_THREADS=16
WEB_CONCURRENCY=3
PORT=3000
APP_PRELOAD=true
API_DOMAIN=
```

# Set up Cron Jobs
Execute this in the project root to write to
the crontab file the contents of the /config/schedule.rb file.
See [whenever gem](https://github.com/javan/whenever).

```
whenever --update-crontab
```

# Generate Documentation
Install the YARD gem.

```
gem install yard
```

Run `yard` in the parent directory.

# Generate coverage report
To generate coverage report with SimpleCov, run

`COVERAGE=true rspec`

in the parent directory.

# Generate examples for API documentation.
Run in the parent directory:

```
rspec  --require ./spec/formatters/test_result_formatter.rb --format TestResultFormatter
```

Take the generated `doc_examples` folder and copy it in the `/data` folder of in the documentation project.
