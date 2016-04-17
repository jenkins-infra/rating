# Backend for community rating
It's a very simple PHP app used from [https://jenkins.io/changelog/], which stores data to PostgreSQL backend.


# Developing
Edit files, then `make run` to launch a dockerized version of the app with a temporary test database.
Run `make run-test` to make sure the program is functional.

Run `docker-compose down` to wipe out the test database content. 
