"""
    -- MINIO installation script --
"""

import random
import string
import os


def build(folder_installation="./", global_env={}):
    """
        Create MinIO admin user and generate password only
    """

    # Fixed username
    minio_user = "admin"

    # Generate MinIO password if not provided
    minio_pass = global_env.get("IECON_INTELLIGENCE_MINIO_PASSWORD", "")
    if not minio_pass:
        print("INFO: Generate minio_pass password")
        minio_pass = generate_random_password()

    # Write .env file with MinIO user and password
    env_path = os.path.join(folder_installation, ".env")
    print(f"Writing MinIO credentials to {env_path}")
    with open(env_path, "w") as fw:
        fw.write(f'IECON_INTELLIGENCE_MINIO_USER="{minio_user}"\n')
        fw.write(f'IECON_INTELLIGENCE_MINIO_PASSWORD="{minio_pass}"\n')
        fw.flush()

    print("Done")


def generate_random_password(length=20):
    characters = list(string.ascii_letters + string.digits + "%&")
    random.shuffle(characters)
    password = [random.choice(characters) for _ in range(length)]
    random.shuffle(password)
    return "".join(password)


if __name__ == "__main__":
    build()
