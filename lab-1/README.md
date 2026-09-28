## Команды
```
docker-compose up -d --build
docker exec -i db-lab-1 psql -U user -d db < ./shema.sql
docker exec -i db-lab-1 psql -U user -d db < ./data.sql
docker exec -i db-lab-1 psql -U user -d db < ./constraints_test.sql
docker-compose down -v
```