terraform {
  backend "gcs" {
    bucket = "capstonepj_bucket"
    prefix = "minikube"
    credentials = "admin-project-284718-d558eaed25f4.json"
  }
}

provider "google" {
  credentials = file("gcp_capstone_project.json")
  project = "rock-nebula-260922"
  region  = "us-central1"
  zone    = "us-central1-a"
}

// A variable for extracting the external ip of the instance
output "ip" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}
output "hostname" {
  value = google_compute_instance.vm_instance.hostname
}

variable gce_ssh_user0 { default = "capstone" }
variable gce_ssh_pub_key_file0 { default = "id_rsa.pub" }

resource "google_compute_instance" "vm_instance" {
  name         = "minikube-vm"
  machine_type = "n1-standard-4"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20200317"
      size = 100
    }
  }
  network_interface {
    network       = google_compute_network.vpc_network.self_link
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  hostname = "minikubevm.capstone.com"
  metadata = {
    ssh-keys = "${var.gce_ssh_user0}:${file(var.gce_ssh_pub_key_file0)}"
    startup-script = "sudo apt-get update -y; sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"; sudo apt-get update -y; sudo apt-get install docker-ce docker-ce-cli containerd.io -y; curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x ./minikube && sudo mkdir -p /usr/local/bin/ && sudo mv ./minikube /usr/local/bin/minikube; curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl; sudo apt-get install conntrack; curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sudo bash; sudo apt-get install git -y; git clone https://github.com/poojamariam/capstoneproject.git"
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_firewall" "fw_all_in" {
  name    = "tf-fw-in"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  direction = "INGRESS"
}

resource "google_compute_firewall" "fw_all_out" {
  name    = "tf-fw-out"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  direction = "EGRESS"
}

resource "google_dns_managed_zone" "capstone" {
  name     = "capstone-zone"
  dns_name = "capstone.com."
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.id
    }
  }
}

resource "google_dns_record_set" "minikubevm" {
  name = "minikubevm.${google_dns_managed_zone.capstone.dns_name}"
  type = "A"
  ttl  = 60
  managed_zone = google_dns_managed_zone.capstone.name
  rrdatas = [google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip]
}

resource "google_dns_record_set" "dashboard" {
  name = "dashboard.${google_dns_managed_zone.capstone.dns_name}"
  type = "A"
  ttl  = 60
  managed_zone = google_dns_managed_zone.capstone.name
  rrdatas = [google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip]
}

resource "google_dns_record_set" "jenkins" {
  name = "jenkins.${google_dns_managed_zone.capstone.dns_name}"
  type = "A"
  ttl  = 60
  managed_zone = google_dns_managed_zone.capstone.name
  rrdatas = [google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip]
}

resource "google_dns_record_set" "gitlab" {
  name = "gitlab.${google_dns_managed_zone.capstone.dns_name}"
  type = "A"
  ttl  = 60
  managed_zone = google_dns_managed_zone.capstone.name
  rrdatas = [google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip]
}

resource "google_dns_record_set" "registry" {
  name = "registry.${google_dns_managed_zone.capstone.dns_name}"
  type = "A"
  ttl  = 60
  managed_zone = google_dns_managed_zone.capstone.name
  rrdatas = [google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip]
}
