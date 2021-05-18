# Heal devops-test Deployment
The included Dockerfile describes a Docker image with Ruby 2.7, copying this repository's contents, and running `foreman start` upon container startup. The Terraform deployment will use 'kruezwerker/docker' to generate the Dockerfile's image, then acquires Vault secrets and creates the Docker container with environment variables from the Vault provided secrets.

# Pre-requisites
This deployment assumes Vault environment variables have been set locally:

```
$ export VAULT_ADDR='http://VAULT_ADDRESS:8200'
$ export VAULT_TOKEN='YOUR_VAULT_TOKEN'
```

And a secret is stored within Vault at secret/devops-test containing the following JSON:

```
{
  "mongodb_url": "mongodb://YOUR_MONGODB_HOST:27017",
  "redis_url": "redis://YOUR_REDIS_HOST:6379"
}
```

# Deployment
Clone this repository and `cd` into the terraform/ directory.

```
git clone https://github.com/getheal/devops-test.git
cd ./terraform/

```

Then run terraform to initialize main.tf, plan, and apply the defined infrastructure:

```
$ terraform init
$ terraform plan
$ terraform apply

```

This should yield a docker container running on localhost:5000 with the Vault secrets defined as environemnt variables successfully connected to Redis. This can be verified by running an exec /bin/bash on the container and viewing the running processes and assigned environment variables.

```
$ docker exec -it devops-test /bin/bash
root@devops-test:/opt/devops-test# env | grep URL
REDIS_URL=redis://127.0.0.1:6379
MONGODB_URL=mongodb://127.0.0.1:27017
root@devops-test:/opt/devops-test# ps auxf
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root        40  0.0  0.0   5752  3408 pts/0    Ss   18:46   0:00 /bin/bash
root        46  0.0  0.0   9392  3020 pts/0    R+   18:51   0:00  \_ ps auxf
root         1  0.0  0.0 162716 26864 ?        Ssl  18:28   0:00 foreman: master
root         6  0.1  0.3 166656 99728 ?        S    18:28   0:02 puma 5.2.2 (tcp://0.0.0.0:5000) [devops-test]
root        16  0.0  0.2 910224 94528 ?        Sl   18:28   0:00  \_ puma: cluster worker 0: 6 [devops-test]
root        23  0.0  0.2 910244 95568 ?        Sl   18:28   0:00  \_ puma: cluster worker 1: 6 [devops-test]
root         7  0.3  0.3 637448 116720 ?       Sl   18:28   0:05 sidekiq 6.2.1  [0 of 5 busy]
```
