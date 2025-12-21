# ☁️ **cloud-1** ☁️

This project automates the setup and management of cloud infrastructure on **Google Cloud Platform (GCP)** using Terraform and shell scripts. Here's a detailed explanation of what it does:

### 🛠️ **Overview**
The project contains **Terraform configurations** and scripts to:

- 🚀 Provision a **Virtual Machine (VM)** on GCP.
- 🛠️ Install necessary software on the VM.
- 🐳 Deploy a **Docker-based application** on the VM.

### 🔑 **Key Components**

#### 1. **Terraform Configuration (`main.tf`)**
Defines the **infrastructure resources**, such as the VM, that will be created on GCP.

#### 2. **Shell Scripts (`launch-vm.sh` & `startup.sh`)**

- **`launch-vm.sh`**: Automates the Terraform commands to provision the VM and sets up the VM with a startup script.
- **`startup.sh`**: Runs on the VM to install **Docker**, **Docker Compose**, and other necessary software, and then deploys the application using Docker.

### 📋 **Prerequisites**

- 🧩 [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- 🔧 **Google Cloud SDK** installed and configured.
- 🌐 A **GCP project** with the necessary permissions.

### 🚀 **Setup**

There are two ways to set up your environment:

#### Option A: Automated Setup (Vagrant)
If you want to spin up a pre-configured Ubuntu VM with Terraform and Google Cloud CLI already installed:
1.  Run `vagrant up`.
2.  SSH into the VM: `vagrant ssh`.
3.  Continue with the steps in the **Usage** section from inside the VM.

#### Option B: Manual Setup (Local Ubuntu)
If you are already on an Ubuntu machine and want to install the tools locally:
1.  Run the setup script:
    ```sh
    ./setup_ubuntu.sh
    ```

#### Configuration
1. Clone the repository:
   ```sh
   git clone https://github.com/MiguelTolino/cloud-1.git
   cd cloud-1
   ```

2. Create a `.env` file with the necessary environment variables.

3. Place the `cloud-1-key.json` file in the root directory.

### ▶️ **Usage**

Once your environment is ready (either locally or via Vagrant), launch the GCP infrastructure:

```sh
./launch-vm.sh
```

> ⚠️ **Note**:
> - You can change the number of instances deployed by modifying the Terraform configuration file (`main.tf`).
> - Adjust the `count` parameter in the resource block to the desired number of instances.

### 🌐 **Accessing the Application**

1. **Discover the IP Address**:
   Use the following command to get the external IP address of your instance:
   ```sh
   gcloud compute instances describe cloud-1 --zone=us-central1-c --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
   ```

2. **Access Wordpress**: Navigate to the discovered IP address. For example: `34.123.45.67`

3. **Access phpMyAdmin**: Navigate to the discovered IP address on port 8080 to access **phpMyAdmin**. For example, if the IP address is `34.123.45.67:8080`.
