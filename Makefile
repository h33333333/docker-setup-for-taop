start:
	docker compose up -d

start-build:
	docker compose up -d --build

stop:
	docker compose down

purge:
	docker compose down -v

attach:
	docker exec -it the_art_of_postgres bash
	
psql:
	docker exec -it the_art_of_postgres psql

