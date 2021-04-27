Authors: David Wright (dwright@hashicorp.com) and Tony Vattahil (tonynv@amazon.com)

**Deploying the Terraform AWS Transit Gateway module**

1. Install Terraform. For instructions and a video tutorial, see [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli). 
2. Configure the AWS Command Line Interface (CLI). For more information, see [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
3. If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). 
4. Clone this **aws-quickstart/terraform-aws-transit-gateway** repository using the following command:

   `git clone https://github.com/aws-quickstart/terraform-aws-transit-gateway`

5. Change directory to the root repository directory.

   `cd terraform-aws-transit-gateway/`

6. Change to the deploy directory.

   - For a new virtual private cloud (VPC), use `cd deploy/new_vpc`. 

   - For an existing VPC, use `cd deploy/existing_vpc`.

7. To perform operations locally, do the following: 
   
   a. Initialize the deploy directory. Run `terraform init`.

   b. Start a Terraform run using the configuration files in your deploy directory. Run `terraform apply`.
   
8. To perform remotely using Terraform Cloud, see [Terraform Runs and Remote Operations](https://www.terraform.io/docs/cloud/run/index.html).

9. For more information about configuring a transit gateway as multiple isolated routers that use a shared service, see [Example: Isolated VPCs with shared services](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-isolated-shared.html).

