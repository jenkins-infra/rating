# Backend for community rating
It's a very simple PHP app used for Jenkins versions rating on https://jenkins.io/changelog, and which stores its data in a PostgreSQL backend.

## Helm Chart
https://github.com/jenkins-infra/helm-charts/tree/main/charts/rating

# Developing
Edit files, then `make run` to launch a dockerized version of the app with a temporary test database.

Run `make test` to make sure the program is functional before opening a pull request.

Run `docker-compose down` to wipe out the test database content. 
