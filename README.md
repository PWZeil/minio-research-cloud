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

# How to Create and Configure Buckets for Student Groups

This guide explains how to set up **per-group S3 buckets in MinIO** for your students to use with **DVC**.

 MinIO Admin Console: [https://url/console](https://url/console)
 See `.env` for admin login credentials

---

## 1. Create a Bucket for Each Student Group

1. Log in to the **MinIO admin console**: [https://url/console](https://url/console)
2. Go to the **Buckets** section.
3. Click **"Create Bucket"**, and name it clearly (e.g., `group1-dvc`, `team-rocket`, etc.)
4. Keep access set to **Private**.

---

## 2. Create a Policy to Restrict Access to That Bucket

Create a new **custom policy** for each group that only allows access to their bucket.

Use the following template and replace `BUCKET_HERE` with the actual bucket name:

```json
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Action": [
    "s3:DeleteObject",
    "s3:GetObject",
    "s3:PutObject"
   ],
   "Resource": [
    "arn:aws:s3:::BUCKET_HERE/*"
   ]
  },
  {
   "Effect": "Allow",
   "Action": [
    "s3:ListBucket"
   ],
   "Resource": [
    "arn:aws:s3:::BUCKET_HERE"
   ]
  }
 ]
}
```

 This ensures each group **can only access their own bucket** — not others.

---

## 3. Create a User or Group for the Students

1. Go to **Users** (or **Groups**) in the MinIO console.
2. Click **"Create User"** or **"Create Group"**.
3. Set:

   * Username = group name (e.g., `group1`)
   * Password = secure password
   * Attach the policy you created above (e.g., `policy-group1-dvc`)
4. Share the **access key** and **secret key** with the students in that group.

 Once logged in, students can generate their own **additional access keys** and manage files via the MinIO UI.

---

##  4. How Can Students Use This?

### **Browse and Manage Files via Web UI**

Students can log into the MinIO browser at:

> [https://url/console](https://url/console)

With their access key (username) and secret key (password), they can:

* Browse their bucket
* Upload/download files
* Create folders
* Generate new keys

---

###  **Use MinIO Bucket with DVC**

Students should first install DVC with S3 support:

```bash
pip install 'dvc[s3]'
```

Then configure their DVC project:

```bash
dvc remote add -d minio s3://BUCKET_HERE
dvc remote modify minio endpointurl https://url/api
dvc remote modify minio access_key_id KEY_NAME_HERE
dvc remote modify minio secret_access_key KEY_PASSWORD_HERE
```

Replace the placeholders:

* `BUCKET_HERE` → the name of their assigned bucket
* `KEY_NAME_HERE` → their access key (username)
* `KEY_PASSWORD_HERE` → their secret key (password)

---

## Example Workflow for Students

```bash
dvc init
dvc add data/
git add data.dvc .gitignore
git commit -m "Add dataset"
dvc push
```

The data will be stored in their assigned MinIO bucket, separate from others.
