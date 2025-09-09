# azure-container-hosting

## Build Docker images

### Build image for backend

```bash
docker build \
    --file src/Demo.BeerVoting.Backend/Dockerfile \
    --tag beer-rating-backend:9.0.0 \
    --tag daniellindemann/beer-rating-backend:9.0.0 \
    .
```

Run image with in-memory database:

```bash
docker run -it --rm \
    -p 5178:5178 \
    -e Database__UseInMemoryDatabase=true \
    --name beer-rating-backend \
     beer-rating-backend:9.0.0
```

### Build image for backend

```bash
docker build \
    --file src/Demo.BeerVoting.Frontend/Dockerfile \
    --tag beer-rating-frontend:9.0.0 \
    --tag daniellindemann/beer-rating-frontend:9.0.0 \
    .
```

Run image with in-memory database:

```bash
docker run -it --rm \
    -p 5179:5179 \
    -e Backend__HostUrl='http://beer-rating-backend:5178' \
    --name beer-rating-frontend \
     beer-rating-frontend:9.0.0
```
