## K8S in docker container

The project create a K8S cluster (k3s version) environment with Prometheus, K8S Dashboard and Grafana using docker and docker compose.

This project is built on docker using docker compose. It has a one container:

- k8s: K3S version v1.29.4-rc1-k3s1

### Content

- [Prerequisites](#prerequisites)
- [How to build and run?](#how-to-build-and-run)

## Prerequisites

- Docker (>= 26.0.0)
- Docker Compose (>= v2.25.0)

## How to build and run?

To build and run the application using Docker compose command:

```bash
$ docker compose up -d
$ docker exec -it k8s sh
$ cd data && ./init.sh
```

The enviroments variables are located in the .env file

## Relevants info

The Static token to acess the dashboard is: admin123. Your value can be changed in the file data/token.csv.

The Grafana username/password is admin/admin.

## Mapped ports

 - The K8S Dashboard: ([https://localhost:32000](https://localhost:32000))
 - The Prometheus Dashboard: ([http://localhost:32001](http://localhost:32001))
 - The Grafana Dashboard: ([http://localhost:32002](http://localhost:32002))