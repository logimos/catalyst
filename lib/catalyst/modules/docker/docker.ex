defmodule Catalyst.Modules.Docker do
  @moduledoc """
  Configures Docker support for the Phoenix application with Dockerfile and docker-compose.yml.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    create_documentation: 3
  ]

  def setup(project_path) do
    try do
      create_dockerfile(project_path)
      create_docker_compose(project_path)
      create_dockerignore(project_path)
      create_docker_documentation(project_path)
      :ok
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  defp create_dockerfile(project_path) do
    app_name = Path.basename(project_path)

    dockerfile_content = """
# Use the official Elixir image as base
FROM elixir:1.16-alpine

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm

# Set working directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \\
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy config files
COPY config/config.exs config/runtime.exs config/
COPY config/$MIX_ENV.exs config/$MIX_ENV.exs

# Compile the release
COPY lib lib
COPY priv priv
COPY assets assets

# Compile assets
RUN mix assets.deploy

# Compile the release
RUN mix do compile, release

# Start a new build stage
FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

# Copy the release from the build stage
COPY --from=0 /app/_build/prod/rel/#{app_name} ./

# Set run ENV
ENV PHX_HOST=localhost

# Run the Phoenix app
CMD ["bin/#{app_name}", "start"]
"""

    create_file_from_template(project_path, "Dockerfile", dockerfile_content)
  end

  defp create_docker_compose(project_path) do
    app_name = Path.basename(project_path)

    compose_content = """
version: '3.8'

services:
  app:
    build: .
    ports:
      - "4000:4000"
    environment:
      - DATABASE_URL=postgres://postgres:postgres@db:5432/#{app_name}_prod
      - SECRET_KEY_BASE=your_secret_key_base_here
      - PHX_HOST=localhost
    depends_on:
      - db
    volumes:
      - ./priv/static:/app/priv/static

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=#{app_name}_prod
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
"""

    create_file_from_template(project_path, "docker-compose.yml", compose_content)
  end

  defp create_dockerignore(project_path) do
    dockerignore_content = """
_build/
deps/
.git/
.gitignore
README.md
test/
priv/static/assets/
assets/node_modules/
"""

    create_file_from_template(project_path, ".dockerignore", dockerignore_content)
  end

  defp create_docker_documentation(project_path) do
    content = """
# Docker Setup

Catalyst has added Docker support to your Phoenix project for containerized deployment.

## What was added:
- `Dockerfile` - Multi-stage build for production
- `docker-compose.yml` - Development environment with database
- `.dockerignore` - Excludes unnecessary files from build

## Development with Docker

### Start the development environment:
```bash
docker-compose up --build
```

This will:
- Build your Phoenix application
- Start a PostgreSQL database
- Make your app available at http://localhost:4000

### Stop the environment:
```bash
docker-compose down
```

### View logs:
```bash
docker-compose logs -f app
```

## Production Deployment

### Build the production image:
```bash
docker build -t #{Path.basename(project_path)} .
```

### Run the production container:
```bash
docker run -p 4000:4000 \\
  -e DATABASE_URL=your_database_url \\
  -e SECRET_KEY_BASE=your_secret_key_base \\
  #{Path.basename(project_path)}
```

## Environment Variables

Set these environment variables for production:

- `DATABASE_URL` - Your database connection string
- `SECRET_KEY_BASE` - Phoenix secret key base
- `PHX_HOST` - Your application hostname

## Database Setup

The docker-compose setup includes PostgreSQL. For production:

1. Use a managed database service
2. Set the `DATABASE_URL` environment variable
3. Run migrations: `docker run --rm your-app eval "YourApp.Release.migrate"`

## Customization

### Development Database
Edit `docker-compose.yml` to change:
- Database type (MySQL, etc.)
- Port mappings
- Environment variables

### Production Build
Edit `Dockerfile` to:
- Change base image
- Add additional dependencies
- Modify build process

## Best Practices

1. **Security**: Never commit secrets to version control
2. **Performance**: Use multi-stage builds to reduce image size
3. **Monitoring**: Add health checks to your containers
4. **Logging**: Configure proper logging for production
5. **Backup**: Set up database backups for production data

## Troubleshooting

### Common Issues:

1. **Port conflicts**: Change ports in docker-compose.yml
2. **Database connection**: Check DATABASE_URL format
3. **Build failures**: Ensure all dependencies are in Dockerfile
4. **Asset compilation**: Verify Node.js is available in build

### Useful Commands:
```bash
# Rebuild without cache
docker-compose build --no-cache

# Enter running container
docker-compose exec app sh

# View database logs
docker-compose logs db

# Reset database
docker-compose down -v && docker-compose up
```
"""

    create_documentation(project_path, "docker", content)
  end
end
