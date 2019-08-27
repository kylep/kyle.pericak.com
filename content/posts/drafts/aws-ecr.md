title: Using AWS Elestic Container Registry
slug: aws-ecr
category: guides
date: 2019-08-26
modified: 2019-06-26
Status: draft



# Environment
This was done using a Ubuntu Xenial VM. Docker is already installed.


# Create an AWS ECR Repository
Nagivate to the
[AWS ECR Repositories page](https://ca-central-1.console.aws.amazon.com/ecr/repositories)
and click Create a repository.

Fill in the form to name your repository.

# Create an AWS IAM User For the Registry
Its a good idea to have user accounts with write access, and others with
read-only access. This way you can push to the registry with your privileged
user but you never need to expose those credentials outside your development
or CICD environment.

## Create Groups for ECR Access
First, review the AWS Group access levels [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ecr_managed_policies.html).

### Make a group with write access
Users in this group can push to existing registries but they can't use the cli
to make new ones.

1. Go to the [AWS IAM page](https://console.aws.amazon.com/iam)
2. Click Groups on the sidebar
3. Name the group, ex: `ecr-write`
4. Attach Policy: `AmazonEC2ContainerRegistryPowerUser`, next
5. click Create Group

### Make a read-only group
Its the same procedure as above, but use the read-only policy instead:
`AmazonEC2ContainerRegistryReadOnly`.

Consider also making an admin group with the
`mazonEC2ContainerRegistryFullAccess` permission.

## Create Users for ECR Access
Make two users, one for pushing and one for pulling. To make a user:
1. Go to the [AWS IAM page](https://console.aws.amazon.com/iam)
2. Click Users on the sidebar
3. Add User
4. Enter user name, check Programatic Access, next
5. Choose from the groups you just created to grant read/write access, next
6. Skip the tags, next
7. Create User. Be sure to save the secret access key in your password manager.



# Connect Docker to the Elastic Container Registry
## Install the AWS CLI
The one from apt is really old and doesn't work. Use pip.
```bash
apt-get install -y python python-pip
pip install aws awscli
```

Test it out
```bash
python -m awscli help
```

## Configure the AWS CLI USER
When prompted, enter your key, secret key, region (ca-central-1), and output
format (none):
```bash
aws configure
```

## Get the docker login command
Use the AWS cli to create the docker login command. Save it in a file for
future reference:
```bash
aws ecr get-login --no-include-email --region ca-central-1 > docker_login.sh
chmod +x docker_login.sh
```

## Log In to ECR
Run the docker login command you saved to docker\_login.sh:
```bash
bash docker_login.sh
```

# Push Images to the ECR Registry
If you click on the Push Commands button in the ECR registry page you'll get
examples programatically generated for your registry.

Pushing is kind of unintuitive. Unlike a normal `registry:2` docker registry,
ECR won't automatically create your repositories for you. You have to manually
create each one. You can use the web UI, or log in as an admin user and run the
following:

```bash
aws ecr create-repository --repository-name kolla/ubuntu-source-base
```

Then you can push.
```bash
docker push $myId.dkr.ecr.ca-central-1.amazonaws.com/$repo:$tag
```

If you first create the repository, you get an error like this: `name unknown:
The repository with name 'kolla/ubuntu-source-base' does not exist in the
registry with id '...'`
