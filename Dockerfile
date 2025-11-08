FROM postgres:18 AS setup

ARG POSTGRES_USER
ARG POSTGRES_PASSWORD

RUN apt-get update && apt-get install -y wget mariadb-client mariadb-server pgloader

# Setup Postgres
RUN su - postgres -c "/usr/lib/postgresql/18/bin/initdb -D /tmp/pgdata --auth-host=scram-sha-256 --auth-local=trust" &&\
    su - postgres -c "/usr/lib/postgresql/18/bin/pg_ctl -D /tmp/pgdata -l /tmp/log start" &&\
    su - postgres -c "psql -c \"CREATE USER ${POSTGRES_USER};\" 2>/dev/null || true" &&\
    su - postgres -c "psql -c \"ALTER USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';\"" &&\
    su - postgres -c "psql -c \"ALTER USER ${POSTGRES_USER} WITH SUPERUSER;\"" &&\
    echo "host all all all scram-sha-256" >> /tmp/pgdata/pg_hba.conf &&\
    su - postgres -c "/usr/lib/postgresql/18/bin/pg_ctl -D /tmp/pgdata stop";

# Chinook
RUN su - postgres -c "/usr/lib/postgresql/18/bin/pg_ctl -D /tmp/pgdata -l /tmp/log start" &&\
    su - postgres -c "/usr/lib/postgresql/18/bin/createdb chinook" &&\
    pgloader https://raw.githubusercontent.com/lerocha/chinook-database/7f67772503d71ba90f19283c38e93923addb43fa/ChinookDatabase/DataSources/Chinook_Sqlite_AutoIncrementPKs.sqlite pgsql://postgres@/chinook &&\
    su - postgres -c "/usr/lib/postgresql/18/bin/pg_ctl -D /tmp/pgdata stop";

# F1DB
RUN wget "https://web.archive.org/web/20231012172625/http://ergast.com/downloads/f1db.sql.gz" -N
RUN gunzip f1db.sql.gz
RUN service mariadb start &&\
    mysql -e "CREATE USER IF NOT EXISTS 'migrator'@'localhost';" &&\
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'migrator'@'localhost';" &&\
    mysql -e "CREATE DATABASE f1db" &&\
    mysql f1db < f1db.sql &&\
    su - postgres -c "/usr/lib/postgresql/18/bin/pg_ctl -D /tmp/pgdata -l /tmp/log start" &&\
    su - postgres -c "/usr/lib/postgresql/18/bin/createdb f1db" &&\
    pgloader mysql://migrator@localhost/f1db pgsql://postgres@/f1db &&\
    service mariadb stop &&\
    su - postgres -c "/usr/lib/postgresql/18/bin/pg_ctl -D /tmp/pgdata stop";


FROM postgres:18

RUN apt-get update && apt-get install -y vim emacs nano && apt-get clean

WORKDIR /var/lib/postgresql
COPY --from=setup /tmp/pgdata ./18/docker
COPY ./.psqlrc .
RUN chown -R postgres:postgres ./
USER postgres

EXPOSE 5432
