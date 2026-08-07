# Ephemeral PR Environments on AWS

> **Problem Solved:** Sharing staging environments leads to developer wait times and running permanent instances, which inflates costs. This project solves this by automatically triggering the creation of isolated, dynamic infrastructure whenever a PR is opened for reproducible testing, and destroys it upon merge or closure.

---

## 🏗️ Architecture & Workflow

This project establishes a fully automated, cost-optimized CI/CD pipeline using GitHub Actions, Terraform, and Ansible. It provisions an independent AWS environment for every Pull Request and ensures zero orphaned resources remain after testing.

1. **Provisioning (`pr-preview.yml`)**: Opening a PR triggers GitHub Actions to securely authenticate with AWS via **OIDC (OpenID Connect)**. Terraform provisions a temporary EC2 instance, tagging it strictly with `Environment: ephemeral`. 
2. **Configuration (`playbook.yml`)**: Once the infrastructure is up, Ansible connects to the instance, installs Docker, builds the image from the `Dockerfile`, and serves the `index.html` application via an Nginx container.
3. **Teardown (`destroy.yml`)**: Upon merging or closing the PR, a dedicated GitHub Action workflow executes a Terraform destroy command, completely removing the PR's specific AWS resources.
4. **Failsafe Cost Optimization (`core-infra/`)**: To guarantee no manual interventions or failed pipelines leave expensive EC2 instances running, a permanent AWS EventBridge cron rule triggers a Python Lambda function nightly to sweep and terminate any instances bearing the ephemeral tag.

---

## 🛠️ Tech Stack

* **CI/CD & Version Control:** GitHub Actions, Git
* **Infrastructure as Code (IaC):** Terraform
* **Configuration Management:** Ansible
* **Containerization:** Docker, Nginx
* **Cloud Provider & Security:** AWS (EC2, S3, IAM), OIDC
* **Serverless Automation:** Python (Boto3), AWS Lambda, EventBridge

---

## 🔒 Security & State Management

* **Zero Hardcoded Credentials:** The GitHub Actions pipeline relies entirely on OpenID Connect (OIDC) to assume temporary, short-lived IAM roles in AWS. No static access keys are stored in GitHub Secrets.
* **Isolated State Files:** Terraform state is managed remotely in an Amazon S3 backend. By utilizing distinct state keys based on the PR number, the infrastructure for each PR is completely isolated, preventing state locking or corruption.
* **Least Privilege:** The Python cleanup script operates under a strict IAM policy that only permits the termination of instances explicitly tagged with `Environment = ephemeral`.

---


## 📂 Repository Structure

The repository is logically divided into three distinct segments: the CI/CD pipeline, the permanent core infrastructure, and the ephemeral PR infrastructure.

```text
.
├── .github/
│   └── workflows/
│       ├── destroy.yml       # Action to tear down EC2 when PR is closed/merged
│       └── pr-preview.yml    # Action to provision EC2 and deploy Docker via Ansible
├── core-infra/               # Permanent infrastructure for cost-optimization
│   ├── cleanup.py            # Boto3 script executing the nightly EC2 termination logic
│   ├── lambda.tf             # Terraform config for the EventBridge rule and Lambda
│   └── providers.tf          # AWS provider configuration for the core infrastructure
├── Dockerfile                # Defines the Nginx container environment
├── index.html                # The web application source code served by Nginx
├── main.tf                   # Primary Terraform configuration for the ephemeral EC2 instance
├── outputs.tf                # Exports the dynamic IP address of the provisioned EC2 instance
├── playbook.yml              # Ansible playbook to install Docker and run the container
├── providers.tf              # AWS provider and remote S3 backend config for PR environments
├── terraform.tfvars          # Variable definitions for the ephemeral resources
└── variables.tf              # Variable declarations for Terraform configuration

