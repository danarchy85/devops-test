terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.11.0"
    }
  }
}

provider "vault" {}

provider "docker" {}

resource "docker_image" "devops-test" {
  name = "devops-test:testing"
  build {
    path = "../"
    dockerfile = "Dockerfile"
    no_cache = true
  }
}

data "vault_generic_secret" "devops-test" {
  path = "secret/devops-test"
}

resource "docker_container" "devops-test" {
  name = "devops-test"
  hostname = "devops-test"
  image = docker_image.devops-test.latest
  network_mode = "host"
  logs = true

  env = [
    "MONGODB_URL=${data.vault_generic_secret.devops-test.data["mongodb_url"]}",
    "REDIS_URL=${data.vault_generic_secret.devops-test.data["redis_url"]}"
  ]
}
