# Vyking Project – Local Installation Guide  
*k3d · Terraform · Argo CD · Helm*

This document describes step by step how to install and deploy the **Vyking project** on a local Kubernetes cluster using **k3d**, **Terraform**, and **Argo CD**.  
The setup follows a GitOps approach where Argo CD continuously syncs infrastructure and applications from GitHub.

---

## Prerequisites

Make sure the following tools are installed on your machine:

- Docker
- kubectl
- k3d
- Terraform **v1.14.3**
- Helm (used internally by Terraform)
- Git

Verify tools:

```bash
docker --version
kubectl version --client
k3d version
terraform version
Step 1: Create a Local Kubernetes Cluster with k3d
Create a Kubernetes cluster named mycluster with one server and two agents, and expose HTTP/HTTPS ports via a load balancer.

bash
Copy code
k3d cluster create mycluster \
  --api-port 6550 \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  --agents 2
Notes
The cluster name must be remembered, as it will be required later in Terraform variables.

If you already have multiple clusters, this name helps Terraform select the correct Kubernetes context.

Step 2: Configure Local Domain Resolution
Add the frontend domain to your /etc/hosts file so it resolves locally.

text
Copy code
127.0.0.1 frontend.k3d.localhost
This allows access to the frontend application via a friendly domain name.

Step 3: Clone the Vyking Repository
Clone the project repository from GitHub and move into the project directory.

bash
Copy code
git clone https://github.com/nimanisha/vyking.git
cd vyking
Step 4: Install Terraform (v1.14.3)
Install the required Terraform version.

Example (Linux)
bash
Copy code
wget https://releases.hashicorp.com/terraform/1.14.3/terraform_1.14.3_linux_amd64.zip
unzip terraform_1.14.3_linux_amd64.zip
sudo mv terraform /usr/local/bin/
Verify:

bash
Copy code
terraform version
Expected output includes:

text
Copy code
Terraform v1.14.3
Step 5: Initialize Terraform
Navigate to the Terraform directory and initialize the working directory.

bash
Copy code
cd terraform
terraform init
This downloads required providers and prepares Terraform for execution.

Step 6: Provide Required Terraform Variables
Terraform will prompt for three on-demand variables:

1. Cluster Name
Value must match the k3d cluster name created earlier.

Example:

text
Copy code
mycluster
Used by Terraform to select the correct Kubernetes context.

2. GitHub Token
A GitHub Personal Access Token (PAT).

Must have permission to pull images from GitHub Packages (private container registry).

Required for backend and frontend image pulls.

3. Database Password
Arbitrary password of your choice.

Used to configure the PostgreSQL database.

Should be kept secret and not committed to Git.

Step 7: Terraform Plan (Phase 1)
Run Terraform plan with phase 2 disabled.

bash
Copy code
terraform plan --var=deploy_phase2=false
This step validates:

Kubernetes connectivity

Variable values

Terraform resources

No changes are applied yet.

Step 8: Terraform Apply (Phase 1)
If the plan succeeds, apply the configuration:

bash
Copy code
terraform apply --var=deploy_phase2=false
(Optional, non-interactive):

bash
Copy code
terraform apply --var=deploy_phase2=false --auto-approve
What Terraform Does in This Phase
Creates required Kubernetes namespaces

Creates Kubernetes secrets

Installs Argo CD using a Helm chart

Step 9: Retrieve Argo CD Initial Admin Password
After Argo CD is installed, Terraform outputs the initial admin password.

Retrieve it with:

bash
Copy code
terraform output argocd_initial_password
Use:

Username: admin

Password: output from the command above

This password is required to log in to the Argo CD web interface.

Step 10: Argo CD Applications Deployment
Terraform installs Argo CD Applications as Kubernetes resources.
Three applications are managed by Argo CD:

1. Frontend Application
Deployed using a Helm chart

Supports continuous deployment

Uses versioned Helm releases

Exposed via the load balancer and mapped domain:

text
Copy code
frontend.k3d.localhost
2. Backend Application
Deployed using a Helm chart

Version-controlled deployments

Pulls container images from GitHub Packages

Uses Kubernetes secrets for database credentials

3. Infrastructure Application
Deployed using GitHub sync (not Helm)

Responsible for shared and stateful components:

PostgreSQL database

PersistentVolumeClaim (PVC)

CronJob (e.g., scheduled jobs or backups)

Supporting infrastructure resources

This application ensures infrastructure resources remain consistent with the Git repository.

GitOps Flow Summary
Terraform installs Argo CD and initial resources

Argo CD continuously watches the GitHub repository

Any changes committed to Git are automatically synced to the cluster

Infrastructure and applications remain declarative and versioned

Security Notes
Secrets are provided dynamically and should never be committed to Git

For production environments, consider:

Sealed Secrets

Mozilla SOPS

HashiCorp Vault

External Secrets Operator

Cleanup (Optional)
To remove all resources:

bash
Copy code
terraform destroy --auto-approve
Delete the k3d cluster:

bash
Copy code
k3d cluster delete mycluster
Final Result
After completing all steps:

A local Kubernetes cluster is running via k3d

Argo CD is installed and accessible

Frontend, backend, and infrastructure are deployed

Continuous deployment is active via Argo CD

Support
If you need help with:

Terraform variables

Argo CD access

Application synchronization

Helm chart customization

Please refer to the repository documentation or contact the maintainers.

markdown
Copy code

If you want, I can also:
- Add **architecture diagrams**
- Convert this into **enterprise-style documentation**
- Add **Windows/macOS specific instructions**
- Include **Argo CD UI access steps**

Just say the word 👌






You said:
but only first part is MD format other one is html could you pls include whole steps into md format or give me a file , so far is good but it's not in MD format so what should I do , Are you able to generate a md file and put those context in the file or not ?



2/2

ChatGPT said:
You’re right to be frustrated — thanks for calling it out clearly.
Let me be very explicit and remove any ambiguity:

✅ Yes, I am able to generate a proper Markdown file
✅ No HTML is required
✅ Everything below is 100% valid Markdown
✅ What you should do: copy this into a file called INSTALL.md or README.md

There is no HTML in this version at all (no <br>, no <p>, no inline HTML).

👉 What to do now
Create a file:

bash
Copy code
touch INSTALL.md
Open it in an editor.

Paste everything below exactly as-is.

Save the file.

✅ FULL VALID MARKDOWN FILE (READY TO USE)
md
Copy code
# Vyking Project – Installation Guide

This document explains step by step how to install and deploy the **Vyking project**
on a local Kubernetes cluster using **k3d**, **Terraform**, **Argo CD**, and **Helm**.
The deployment follows a GitOps approach using Argo CD.

---

## Prerequisites

Ensure the following tools are installed:

- Docker
- kubectl
- k3d
- Terraform v1.14.3
- Helm
- Git

Verify installations:

```bash
docker --version
kubectl version --client
k3d version
terraform version
Step 1: Create Kubernetes Cluster Using k3d
Create a local Kubernetes cluster named mycluster.

bash
Copy code
k3d cluster create mycluster \
  --api-port 6550 \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  --agents 2
Notes
The cluster name will be required later in Terraform variables.

If you use a different name, make sure to update it when prompted by Terraform.

Step 2: Configure Local Domain
Edit /etc/hosts and add the following entry:

text
Copy code
127.0.0.1 frontend.k3d.localhost
This allows access to the frontend application locally.

Step 3: Clone the Vyking Repository
Clone the project repository and move into the directory:

bash
Copy code
git clone https://github.com/nimanisha/vyking.git
cd vyking
Step 4: Install Terraform v1.14.3
Example installation for Linux:

bash
Copy code
wget https://releases.hashicorp.com/terraform/1.14.3/terraform_1.14.3_linux_amd64.zip
unzip terraform_1.14.3_linux_amd64.zip
sudo mv terraform /usr/local/bin/
Verify the version:

bash
Copy code
terraform version
Step 5: Initialize Terraform
Navigate to the Terraform directory and initialize it:

bash
Copy code
cd terraform
terraform init
Step 6: Provide Terraform Variables
Terraform will ask for three variables:

1. Cluster Name
text
Copy code
mycluster
Used to select the correct Kubernetes context.

2. GitHub Token
A GitHub Personal Access Token that has permission to pull images
from GitHub Packages (private repositories).

3. Database Password
An arbitrary password of your choice.
Used for the PostgreSQL database.

Step 7: Terraform Plan (Phase 1)
Run Terraform plan with phase 2 disabled:

bash
Copy code
terraform plan --var=deploy_phase2=false
This validates the configuration without applying changes.

Step 8: Terraform Apply (Phase 1)
Apply the configuration:

bash
Copy code
terraform apply --var=deploy_phase2=false
Optional non-interactive mode:

bash
Copy code
terraform apply --var=deploy_phase2=false --auto-approve
What This Step Does
Creates Kubernetes namespaces

Creates Kubernetes secrets

Installs Argo CD via Helm

Step 9: Retrieve Argo CD Admin Password
Terraform outputs the initial Argo CD admin password.

Retrieve it using:

bash
Copy code
terraform output argocd_initial_password
Login credentials:

Username: admin

Password: value from command output

Step 10: Argo CD Applications
Terraform creates three Argo CD Applications.

Frontend Application
Deployed via Helm chart

Supports continuous deployment

Exposed via frontend.k3d.localhost

Backend Application
Deployed via Helm chart

Uses GitHub Packages container images

Reads database credentials from Kubernetes secrets

Infrastructure Application
Deployed using GitHub repository sync (not Helm)

Responsible for:

PostgreSQL database

PersistentVolumeClaim (PVC)

CronJob

Infrastructure resources

GitOps Workflow
Terraform installs Argo CD

Argo CD monitors the GitHub repository

Any Git changes are automatically applied to the cluster

Infrastructure and applications stay in sync

Security Notes
Secrets should never be committed to Git

Recommended for production:

Sealed Secrets

SOPS

HashiCorp Vault

External Secrets Operator

Cleanup
To remove all resources:

bash
Copy code
terraform destroy --auto-approve
Delete the cluster:

bash
Copy code
k3d cluster delete mycluster