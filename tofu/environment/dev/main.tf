terraform {
  backend "s3" {
    bucket = "devops-pipelines-dev-tfstate"
    key = "devops-pipelines.tfstate"
    region = "us-east-1"
  }
}

module "backend" {
  source = "github.com/codeforamerica/tofu-modules/aws/backend"

  project = "devops-pipelines"
  environment = "dev"
}
