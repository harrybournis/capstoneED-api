Documentation: https://harrybournis.github.io/capstoned-api-documentation/

Trello: https://trello.com/b/ahb8alLZ/capstoneed-api

# Installation
1. Install ruby 2.7.7
2. Run `gem install bundler`
3. Run `bundle update`
4. Run `bundle install`

# Environment Variables
The application uses multiple environment variables to allow for configuration.
These variables can be applied through a `.env` file if running locally, or
through docker compose, when running in docker. Below is a list of all the
additional variables:

| Variable                   | Default Value                     | Description                                                                                                   |
|----------------------------|-----------------------------------|---------------------------------------------------------------------------------------------------------------|
| PG_HOST                    | -                                 | Host where Postgres is running                                                                                |
| PG_USER                    | -                                 | Postgres user to log in as                                                                                    |
| PG_PASS                    | -                                 | Password for postgres user                                                                                    |
| PG_NAME                    | -                                 | Name of the database. Will be also used to generate `PG_NAME_development` and `PG_NAME_test` databases        |
| SECRET_KEY_BASE            | -                                 | Generate using `bundler exec rake secret`.  You *MUST* provide this.                                          |
| CAPSTONEED_API_URL         | 'http://capstoneed-api.org:21992' | The URL used to access the API. Will be used  to generate links (i.e. forgot your password)                   |
| CAPSTONEED_API_PORT        | 21992                             | Port the rails server will listen on. This is ON the container, does not affect the exposed port on the host. |
| CAPSTONEED_ALLOWED_ORIGINS | '*'                               | Origins allowed to access the API. Seperte using `;`                                                          |

In addition you can define multiple "built-in" variables, such as the ones below:

```env
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
