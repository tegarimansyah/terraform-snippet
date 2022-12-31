# How to use Terraform

## Preparation

For using remote state and state lock, please create:

- [S3 Bucket](https://s3.console.aws.amazon.com/s3/bucket/create?region=us-east-1) called `ecom-ai-tfstate`
- [Dynamo DB table](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#create-table) called `ecom-ai-tfstate-lock` with partition key `LockID`
- Change the value in [0_main.tf](0_main.tf) if needed

Prepare our docker repository in ECR

- [Create ECR](https://us-east-1.console.aws.amazon.com/ecr/create-repository?region=us-east-1)
- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [Configure it](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config)
- Docker login to your repo in terminal. If your aws account id is `49279044990` then:

```
$ export AWS_ACCOUNT_ID=49279044990
$ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
```

- Build your image as usual, then add tag with your repo name prefixed. This process usually add to CI/CD pipeline. For example if your image is `ecom-ai:0.0.1` and your repo name is `ecom-ai` with aws account id `49279044990` then

```
$ export AWS_ACCOUNT_ID=49279044990
$ export IMAGE_TAG=ecom-ai:0.0.1

$ docker build -t $IMAGE_TAG .
$ docker tag $IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$IMAGE_TAG
$ docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$IMAGE_TAG
```

> Notes:<br />
> If you build in ARM64 CPU Architecture (e.g. MacBook with M1 Chip) and you want to run it as LINUX 64 bit, then you need to build like this: `docker build --platform=linux/amd64 -t ${IMAGE} .`

## Change Terraform Configuration

This configuration is in [0_variables.tf](0_variables.tf) under `INPUT` section.

| Name                          | Description                                                                                                                                                |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project                       | Your project name                                                                                                                                          |
| region                        | Which AWS region you want to apply the project                                                                                                             |
| ecr_repo                      | Name of your ECR repo                                                                                                                                      |
| image_tag                     | Image tag that you already push to ECR and want to deploy                                                                                                  |
| container_port                | The app's listening port                                                                                                                                   |
| cpu                           | The cpu that will be allocated to container                                                                                                                |
| ram                           | The ram that will be allocated to container. Refer [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size) |
| ecs_autoscale_min_instance    | Minimum container that will run                                                                                                                            |
| ecs_autoscale_max_instances   | Maximum container that will run                                                                                                                            |
| ecs_as_cpu_low_threshold_per  | CPU threshold for reducing running container                                                                                                               |
| ecs_as_cpu_high_threshold_per | CPU threshold for incresing running container                                                                                                              |

For **environment variable** for container, we can add manually in [2_task_definition.tf](2_task_definition.tf) under `environment` array.

## Run Terraform

- Install [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- In your terminal, `cd` to this directory and run `terraform init`. This will install dependencies and config the remote state lock.
- Run `terraform plan` to see what will be add in your AWS. Then run `terraform apply` if everything is okay.
- Run `terraform deploy` if you want to clean up everything terraform make for you.
