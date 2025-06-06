# MinIO Nginx Reverse Proxy Setup (SURF Research Cloud Component)

This setup is designed as a **SURF Research Cloud component** to simplify deploying and accessing a MinIO instance with Nginx reverse proxy integration.

## What this setup does

* Runs a Python script (`minio_install.py`) to generate MinIO credentials:

  * Creates a fixed MinIO username `admin`
  * Generates a secure random password
  * Saves these credentials in a `.env` file for your reference

* Configures Nginx to proxy requests:

  * `/` routes to the MinIO API running on port `8080`
  * `/API/` routes to the MinIO admin console running on port `8081`

* Restarts Nginx to apply the new configuration

## Accessing MinIO

* **MinIO UI (API):**
  Access via your server’s base URL (e.g., `http://yourdomain.com/`)

* **MinIO Admin Console:**
  Access via `http://yourdomain.com/API/`


## Finding your MinIO credentials

1. Use `sudo docker compose ls` to list your Docker Compose projects.
   This shows where your components (like MinIO) were created.

2. Navigate to the project directory listed by the command.

3. Inside, find the `.env` file — it contains your MinIO username and password:

   ```bash
   IECON_INTELLIGENCE_MINIO_USER=admin
   IECON_INTELLIGENCE_MINIO_PASSWORD=your_generated_password
   ```

Use these credentials to log into the MinIO UI and admin console.
