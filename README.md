# Docker-based setup for The Art of PostgreSQL

This repository provides a Docker-based setup for working through [The Art of PostgreSQL](https://theartofpostgresql.com/) by Dimitri Fontaine.

The provided Docker image includes:
- PostgreSQL 18
- Both databases mentioned in the book (`f1db` and `chinook`)
- Pre-configured `.psqlrc` file from Chapter 6

## Quick Start

```bash
# Build and start the container
make start

# Connect to PostgreSQL
make psql
```

PostgreSQL will be available at `localhost:5432`.

## Configuration

Available Config options are listed in `.env.example`. You need to create a `.env` based on the provided example.

A simple config might look like this:

```bash
POSTGRES_USER=youruser
POSTGRES_PASSWORD=yourpassword
```

## Available Commands

| Command | Description |
|---------|-------------|
| `make start` | Build the image and start the container |
| `make start-build` | Force rebuild the image and start |
| `make attach` | Start an interactive shell session |
| `make psql` | Start a psql session |
| `make stop` | Stop the container |
| `make purge` | Stop container and delete data volume |

## Credit

This setup was inspired by [Docker for TAOP](https://github.com/mikebranski/the-art-of-postgresql-docker).

