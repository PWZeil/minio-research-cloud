# MinIO Nginx Reverse Proxy Setup (SURF Research Cloud Component)

This setup is designed as a **SURF Research Cloud component** to simplify deploying and accessing a MinIO instance with Nginx reverse proxy integration.

## What this setup does

* Runs a Python script (`minio_install.py`) to generate MinIO credentials:

  * Creates a fixed MinIO username `admin`
  * Generates a secure random password
  * Saves these credentials in a `.env` file for your reference

* Configures Nginx to proxy requests:

  * `/console` routes to the MinIO admin console running on port `9090`
  * `/api` routes to the MinIO api running on port `9000`

* Restarts Nginx to apply the new configuration

## Accessing MinIO

* **MinIO Admin console:**
  Access via your server’s base URL (e.g., `https://yourdomain.com/`)

* **MinIO API:**
  Access via `https://yourdomain.com/api/`


## Finding your MinIO credentials

1. Use `sudo docker compose ls` to list your Docker Compose projects.
   This shows where your components (like MinIO) were created.

2. Navigate to the project directory listed by the command.

3. Inside, find the `.env` file — it contains your MinIO username and password:

   ```bash
   MINIO_ROOT_USER=admin
   MINIO_ROOT_PASSWORD=your_generated_password
   ```

Use these credentials to log into the MinIO UI and admin console.
