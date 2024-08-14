# iOS-DuoFetch
 A project to sync Core Data with Elixir PostgreSQL server

## iOS Swift and Elixir Dual Sync Application

## Overview

This project demonstrates a complete application setup with a cloud backend using Elixir and a local iOS client using Swift. The system includes:

- **Elixir Backend**: Provides a REST API with JWT authentication and interacts with a PostgreSQL database.
- **iOS Client**: Contains a local Hummingbird server, CoreData for local caching, and synchronizes with the cloud backend.

## Project Structure

### Elixir Backend

- **Elixir Application**: Implements a REST API that connects to a PostgreSQL database.
- **JWT Authentication**: Secures the API with JWT tokens.
- **Dockerfile**: Configures the Elixir application to run in a Docker container.

### iOS Client

- **SynchronizationDaemon.swift**: Manages synchronization between local CoreData and the Elixir backend, including JWT authentication and token refresh.
- **CoreDataStack.swift**: Handles CoreData operations, including fetching and saving data.
- **APITestView.swift**: A basic frontend for testing API endpoints, similar to a simplified Swagger UI.

## Elixir Backend

### Setup and Run

1. **Clone the Repository**

   ```bash
   git clone https://github.com/arpitg94/ios-duofetch/elixir-server.git
   cd elixir-server
   ```

2. **Build and Run with Docker**

   Ensure Docker is installed and running. Build and run the Docker container:

   ```bash
   docker build -t elixir-server .
   docker run -p 4000:4000 elixir-server
   ```

3. **API Endpoints**

   - **GET** `/users` - Retrieve users.
   - **POST** `/users` - Create or update users.
   - **GET** `/posts` - Retrieve posts.
   - **POST** `/posts` - Create or update posts.
   - **POST** `/refresh-token` - Refresh JWT token.

4. **Configuration**

   Update `config/config.exs` with PostgreSQL and JWT settings.

### Dockerfile

```Dockerfile
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
```

## iOS Client

### Setup and Run

1. **Clone the Repository**

   ```bash
   git clone https://github.com/arpitg94/ios-duofetch/iosApp.git
   cd iosApp
   ```

2. **Open and Build in Xcode**

   Open the project in Xcode and build the application.

3. **API Testing**

   Use `APITestView.swift` to test API endpoints. This view provides a basic interface to interact with the Elixir backend.

4. **Synchronize Data**

   The `SynchronizationDaemon.swift` class manages synchronization between CoreData and the cloud backend, including token management.

### Key Files

- **SynchronizationDaemon.swift**: Handles data synchronization, JWT authentication, and token refresh.
- **CoreDataStack.swift**: Manages CoreData operations.
- **APITestView.swift**: Basic user interface for API testing.

## Security Considerations

- **Token Storage**: The `SynchronizationDaemon` uses `UserDefaults` for token storage in this example. For production, consider using Keychain for secure token storage.
- **Secure API Endpoints**: Ensure your Elixir backend's `/refresh-token` endpoint is properly secured and validates the current token.

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.

## Contributing

Feel free to open issues and pull requests. Contributions are welcome!

---