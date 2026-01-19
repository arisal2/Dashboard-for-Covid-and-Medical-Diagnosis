# Fluffy Octo System

[![CodeFactor](https://www.codefactor.io/repository/github/arisal2/dashboard-for-covid-and-medical-diagnosis/badge)](https://www.codefactor.io/repository/github/arisal2/dashboard-for-covid-and-medical-diagnosis)
[![Fluffy-Octo-System](https://github.com/arisal2/fluffy-octo-system/actions/workflows/fluffy_octo_system.yml/badge.svg)](https://github.com/arisal2/fluffy-octo-system/actions/workflows/fluffy_octo_system.yml)

## Features
- Live Covid-19 dashboard
- Live vaccination records
- World map and various reports
- Diagnosis checker based on symptoms
- Load and save potential user list and send emails

## Tech

- [Next.js](https://nextjs.org/) (Frontend)
- [Tailwind CSS](https://tailwindcss.com/)
- [Ruby](https://www.ruby-lang.org/en/)
- [Rails](https://rubyonrails.org/) (API Backend)
- [Bootstrap](https://getbootstrap.com/) (Backend UI)
- [Postgres](https://www.postgresql.org/)
- [Docker](https://www.docker.com/)
- [Redis](https://redis.io/)
- [Sidekiq](https://sidekiq.org/)
- [Datatable](https://datatables.net/)

## Requirements

You must have Docker & Docker Compose installed.

# Setup and local development

## Environment File

This application depends on `.env.dev` file. An example of the environment file (`env_example.txt`) is also included. Please read the message inside the file which contains API information and credentials, and generate it first so that it loads properly when you setup docker.

Create an `.env.dev` file in the root directory and copy all the requried fields from `env_example.txt`

## Docker
After cloning the repository, run the command:
```
./build.dev.sh
```
This will build the docker containers, setup the database, and start the container.
Also, you can use individual commands if you wish:

```
docker-compose build
docker-compose run web bundle exec rake db:create
docker-compose run web bundle exec rake db:migrate
docker-compose run web bundle exec rake db:seed
```

Command to start the container: 
```
docker-compose up
```
Command to stop the container: 
```
docker-compose stop
```
Command to remove the container: 
```
docker-compose down
```

There is also a script included to clear everything docker related called `nuke-everything.sh`. Please be careful while using this script!

To access the rails console:
```
docker-compose run web rails c
```

To run Rspec:
```
docker-compose run web rake spec
```

## Application

The application is split into two parts:

- **Frontend (Next.js)**: `http://localhost:3001` - This is the main modern dashboard.
- **Backend API (Rails)**: `http://localhost:3000` - Serves JSON API and legacy admin views.

## Local CI / GitHub Actions

You can run GitHub Actions locally using [act](https://github.com/nektos/act).
Prerequisite: `brew install act` (if not already installed).

Run all workflows:
```bash
act -l  # List available jobs
act     # Run the default workflow
```
You can find the default user credentials inside the `db/seeds.rb` file

## Sidekiq and CronJob
- In the application you will find a file called `schedule.yml` where you can setup cron. For now it is setup for `01:00 every Sunday`. This cronjob will send an email at the time specified to a list of potential users.  This can be setup to whatever you want for development puropse.
- Sidekiq UI - http://localhost:3000/sidekiq
- Sidekiq Cron UI - http://localhost:3000/sidekiq/cron
- This application includes a feature to upload an email list, example provided with repo (email_list.csv).
- After logging into the system, visit  `http://localhost:3000/potential_users` and upload the CSV file.
- The Sidekiq is responsible for running a job that will send email to the list provided via the CSV file. All logs for the email valid and invalid will be logged in `email.log` inside the log folder.
- If you are using your gmail account, you will have to enable less secure apps for sending an email.

## API and References
- [disease.sh - Open Disease Data API](https://disease.sh)
- [OWID](https://ourworldindata.org)
- [Corona API](https://corona-api.com)
- [API Medic](https://apimedic.com)

## Other

- Please find the login module architecture in the login_module_diagrams folder
