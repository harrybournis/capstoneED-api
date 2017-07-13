Documentation: https://harrybournis.github.io/capstoned-api-documentation/

Trello: https://trello.com/b/ahb8alLZ/capstoneed-api

# Installation
1. Install ruby 2.4.1
2. Run `gem install bundler`
3. Run `bundle update`
4. Run `bundle install`

# DotEnv File
```
DEVELOPMENT_SECRET_KEY_BASE=<development key>
TEST_SECRET_KEY_BASE=<test key>
RAILS_MIN_THREADS=3
RAILS_MAX_THREADS=16
WEB_CONCURRENCY=3
APP_PRELOAD=true
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
