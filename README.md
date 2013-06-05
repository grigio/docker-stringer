Stringer Feed RSS Reader on a Docker Sandbox
--

A real world webapp inside a docker image, see `Dockerfile` and `deploy.sh` if you are interested to build a similar base image.

What is bundled in that big tar.gz?
---

- App:     Stringer
- Runtime: Ruby 1.9.3 Debian/Ubuntu stock
- db:      Postgresql 9.1

Why Docker is cool? A simple workflow
---

```
  git clone git@github.com:grigio/docker-stringer.git               # Download
  zcat stringer-app.tar.gz | docker import - yourname/stringer-app  # Import (the base image)
  
  # The app#1 instance, the changes won't affect the base image
  APP_ID=$(docker run -d -i -p 5000 grigio/impo deploy.sh app_run) 
  APP_PORT=$(docker port $APP_ID 5000)
  echo "Your app is ready on => http://localhost:"$APP_ID           # Launch
  
  docker attach $APP_ID  # Inspect app#1 live
  docker stop $APP_ID    # Stop app#1
```

