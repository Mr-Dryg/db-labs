## Команды
```
docker-compose up -d --build
docker exec -i db-lab-1 psql -U user -d db < lab-1/shema.sql
docker exec -i db-lab-1 psql -U user -d db < lab-1/migration.sql
docker exec -i db-lab-1 psql -U user -d db < lab-2/data.sql
docker-compose down -v
```