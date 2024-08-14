# Pull an official Elixir image
FROM elixir:1.14.0-alpine

# Install dependencies
RUN apk add --no-cache build-base git

# Set working directory
WORKDIR /app

# Install Hex + Rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy the project files
COPY . .

# Install Elixir dependencies
RUN mix deps.get && mix deps.compile

# Set the environment to prod
ENV MIX_ENV=prod

# Compile the app
RUN mix compile

# Migrate the database
CMD ["mix", "ecto.migrate"]

# Start the Phoenix server
CMD ["mix", "phx.server"]
