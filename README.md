# ☁️ **cloud-1** ☁️

This project automates the deployment of a full-stack infrastructure on **Google Cloud Platform (GCP)** using **Terraform** and **Docker**. It specifically provisions a Virtual Machine (VM) and automatically deploys the **Inception** project (a LEMP stack in Docker) upon startup.

### 🛠️ **Workflow Overview**

1.  🚀 **Terraform** provisions a GCP Compute Engine instance.
2.  🔑 **Metadata** is used to securely pass the `.env` configuration to the instance.
3.  ⚙️ **Startup Script** (`startup-instance.sh`) runs automatically on the VM to:
    - Install Docker and Docker Compose.
    - Clone the [Inception](https://github.com/MiguelTolino/inception.git) repository.
    - Retrieve the `.env` from metadata and place it in the correct location.
    - Build and launch the Docker containers using `make`.

### 🔑 **Key Components**

- **`main.tf`**: Terraform configuration defining the VM instances, networking, and firewall rules. Supports scaling via `node_count`.
- **`launch-vm.sh`**: A wrapper script that initializes Terraform, applies the configuration, and monitors the startup of all instances in parallel.
- **`startup-instance.sh`**: The script that runs inside each VM to bootstrap the environment and deploy the application.
- **`setup_ubuntu.sh`**: A local helper script to install Terraform and the Google Cloud CLI on your Ubuntu machine.

### 📋 **Prerequisites**

- 🛠️ **Virtualized Environment (Optional)**: [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) if using the automated setup.
- 🧩 **Terraform** (if running locally).
- 🔧 **Google Cloud SDK (gcloud)** (if running locally).
- 🌐 A **GCP project** with a service account key (`cloud-1-key.json`).

### 🚀 **Setup Options**

Choose the setup that best fits your environment:

#### Option A: Local Setup (Ubuntu)
If you are on an Ubuntu machine and have permissions to install dependencies locally:
1.  Run the setup script:
    ```sh
    ./setup_ubuntu.sh
    ```
2.  Authenticate with GCP:
    ```sh
    gcloud init
    ```

#### Option B: Virtualized Environment (Vagrant) – **Recommended for Submissions**
If you cannot install dependencies on your host machine or want a clean, isolated environment for evaluation:
1.  Spin up the pre-configured Ubuntu VM:
    ```sh
    vagrant up
    ```
2.  SSH into the VM:
    ```sh
    vagrant ssh
    ```
3.  Inside the VM, initialize GCP:
    ```sh
    gcloud init
    ```
    *All necessary tools (Terraform, gcloud CLI) are pre-installed via the Vagrant provisioning script.*

### ▶️ **Usage**

Regardless of your setup (Local or Vagrant), follow these steps to deploy:

#### 1. Configuration
- **GCP Key**: Place your Google Cloud service account key as `cloud-1-key.json` in the project root.
- **Environment Variables**: Create a `.env` file in the root with your Inception project secrets. This file is automatically passed to the VM via metadata.

#### 2. Launch
Run the automated deployment script:
```sh
./launch-vm.sh
```

### 🌐 **Accessing the Application**

Once the deployment is complete, the `launch-vm.sh` script will provide the list of external IPs for all created nodes. You can also find them via:
```sh
terraform output instance_ips
```

- **Wordpress**: `http://<IP_NODE_X>`
- **phpMyAdmin**: `http://<IP_NODE_X>:8080`

### 🏗️ **Parallel Deployment & Scaling**

This project supports deploying multiple independent servers simultaneously. 

To change the number of servers:
1. Open [`main.tf`](file:///Users/migueltolino/42Cursus/cloud-1/main.tf).
2. Update the `node_count` variable:
   ```hcl
   variable "node_count" {
     type    = number
     default = 3 # Change this as needed
   }
   ```
3. Run `./launch-vm.sh` again. Terraform will provision the additional instances in parallel.

### 🔍 **Troubleshooting**

If an application instance is not accessible, you can check its startup script logs by SSHing into the specific VM:
```sh
# The launch script provides these commands at the end
gcloud compute ssh cloud-1 --zone=europe-west1-b --command="tail -f /var/log/startup-script.log"
gcloud compute ssh cloud-2 --zone=europe-west1-b --command="tail -f /var/log/startup-script.log"
```

> [!NOTE]
> The default zone is `europe-west1-b`. You can modify this and other variables in `main.tf`.
