"""
    -- MINIO installation script --
"""

import random
import string
import os
import argparse


def build(folder_installation="./", redirect_url=None):
    """
    Create MinIO admin user and generate password, optionally include redirect URL.
    """

    # Fixed username
    minio_user = "admin"
    minio_pass = generate_random_password()

    # Write .env file with MinIO user and password
    env_path = os.path.join(folder_installation, ".env")
    print(f"Writing MinIO configuration to {env_path}")
    with open(env_path, "w") as fw:
        fw.write(f'MINIO_ROOT_USER="{minio_user}"\n')
        fw.write(f'MINIO_ROOT_PASSWORD="{minio_pass}"\n')
        if redirect_url:
            fw.write(f'MINIO_BROWSER_REDIRECT_URL="{redirect_url}"\n')
        fw.flush()

    print("Done")


def generate_random_password(length=20):
    characters = list(string.ascii_letters + string.digits + "%&")
    random.shuffle(characters)
    password = [random.choice(characters) for _ in range(length)]
    random.shuffle(password)
    return "".join(password)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="MinIO installation environment generator")
    parser.add_argument("--MINIO_BROWSER_REDIRECT_URL", type=str, help="URL to use for the MinIO console", default=None)
    args = parser.parse_args()

    build(redirect_url=args.MINIO_BROWSER_REDIRECT_URL)
