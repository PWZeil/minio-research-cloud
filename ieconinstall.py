"""
    -- IECON Module installation script --

"""
import random
import string
import os
from ruamel.yaml import YAML
import uuid
from cryptography.fernet import Fernet



def build(folder_installation="./", global_env={}):
    """
        Module custom installation steps
    """

    # Update config.yml files with IECON specific parameters ------------------------------------------------

    # CONFIG - Update Configuration file with MQTT information
    print("Loading config")
    with open(os.path.join(folder_installation, "config.yml"), "r") as fr:
        config = YAML().load(fr)

    # Generate Environment file-----------------------------------------------------------------------------------
    print("Generating .env")
    config["IECON_INFLUXDB2_PORT"] = global_env.get("IECON_INFLUXDB2_PORT", 8086)
    config["IECON_INFLUXDB2_ORG"] = global_env.get("IECON_INFLUXDB2_ORG", "")
    config["IECON_INTELLIGENCE_AIRFLOW_UID"] = global_env.get("IECON_INTELLIGENCE_AIRFLOW_UID", 0)

    # Generate passwords
    airflow_pass = global_env.get("IECON_INTELLIGENCE_WEBSERVER_KEY", "")
    if not airflow_pass:
        print("INFO: Generate airflow_pass password")
        airflow_pass = generate_random_password()
        config['IECON_INTELLIGENCE_WEBSERVER_KEY'] = airflow_pass  # Save pass

    fernet_pass = global_env.get("IECON_INTELLIGENCE_FERNET_KEY", "")
    if not fernet_pass:
        print("INFO: Generate fernet_pass password")
        fernet_pass = Fernet.generate_key()
        config['IECON_INTELLIGENCE_FERNET_KEY'] = fernet_pass.decode()  # Save pass

    minio_pass = global_env.get("IECON_INTELLIGENCE_MINIO_PASSWORD", "")
    if not minio_pass:
        print("INFO: Generate minio_pass password")
        minio_pass = generate_random_password()
        config['IECON_INTELLIGENCE_MINIO_PASSWORD'] = minio_pass  # Save pass

    postgress_pass = global_env.get("IECON_INTELLIGENCE_POSTGRES_KEY", "")
    if not postgress_pass:
        print("INFO: Generate postgress_pass password")
        postgress_pass = generate_random_password()
        config['IECON_INTELLIGENCE_POSTGRES_KEY'] = postgress_pass  # Save pass

    # .ENV - Generate .env Environment file
    with open(os.path.join(folder_installation, ".env"), "w") as fw:
        print("Generating .env")
        fw.write('IECON_INTELLIGENCE_WEBSERVER_KEY="%s"\n' % config.get("IECON_INTELLIGENCE_WEBSERVER_KEY", ""))
        fw.write('IECON_INTELLIGENCE_WEBSERVER_KEY="%s"\n' % config.get("IECON_INTELLIGENCE_WEBSERVER_KEY", ""))
        fw.write('FOLDER_IECON_APP_INTELLIGENCE="%s"\n' % folder_installation)
        fw.write('IECON_INTELLIGENCE_WEBSERVER_KEY="%s"\n' % config.get("IECON_INTELLIGENCE_WEBSERVER_KEY", ""))
        fw.write('IECON_INTELLIGENCE_FERNET_KEY="%s"\n' % config.get("IECON_INTELLIGENCE_FERNET_KEY", ""))
        fw.write('IECON_INTELLIGENCE_MINIO_PASSWORD="%s"\n' % config.get("IECON_INTELLIGENCE_MINIO_PASSWORD", ""))
        fw.write('IECON_INTELLIGENCE_AIRFLOW_UID="%s"\n' % config.get("IECON_INTELLIGENCE_AIRFLOW_UID", 0)) # I don't use this right now as i set it to 0
        fw.write('IECON_INTELLIGENCE_POSTGRES_KEY="%s"\n' % config.get("IECON_INTELLIGENCE_POSTGRES_KEY", ""))
        fw.flush()

    # Save config file
    print("Saving config")
    with open(os.path.join(folder_installation, "config.yml"), "w") as fw:
        YAML().dump(config, fw)
    print("Done")

def generate_random_password(length=20):

    characters = list(string.ascii_letters + string.digits + "%&")

    # shuffling the characters
    random.shuffle(characters)

    # picking random characters from the list
    password = []
    for i in range(length):
        password.append(random.choice(characters))

    # shuffling the resultant password
    random.shuffle(password)

    # converting the list to string
    # printing the list
    return "".join(password)




if __name__ == "__main__":

    build()

