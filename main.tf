# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.

variable "project_id" {
  type    = string
  default = "cloud-1-439021"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-c"
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "node_count" {
  type    = number
  default = 1
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "cloud-1" {
  count        = var.node_count
  name         = "cloud-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    auto_delete = true
    device_name = "cloud-${count.index + 1}"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240830"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }

    stack_type = "IPV4_ONLY"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    # It's better to use a dedicated service account, but for now we'll keep the one provided
    email  = "496846340842-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server", "https-server", "allow-8080"]

  metadata = {
    startup-script = file("${path.module}/startup.sh")
  }
}

resource "google_compute_firewall" "allow-8080" {
  name    = "allow-8080"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-8080"]
}

output "instance_ips" {
  value = google_compute_instance.cloud-1[*].network_interface[0].access_config[0].nat_ip
}
