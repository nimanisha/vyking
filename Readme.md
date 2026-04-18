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
```


Step 1: Configure Local Domain Resolution
Add the frontend domain to your /etc/hosts file so it resolves locally.


127.0.0.1 frontend.k3d.localhost
This allows access to the frontend application via a friendly domain name.

Step 2: Clone the Vyking Repository
Clone the project repository from GitHub and move into the project directory.

```bash
git clone https://github.com/nimanisha/vyking.git
cd vyking
Step 4: Install Terraform (v1.14.3)
Install the required Terraform version.
```

Example (Linux)
```bash
wget https://releases.hashicorp.com/terraform/1.14.3/terraform_1.14.3_linux_amd64.zip
unzip terraform_1.14.3_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```
Verify:

```bash
terraform version
Expected output includes:
```

Terraform v1.14.3
Step 5: Initialize Terraform
Navigate to the Terraform directory and initialize the working directory.

```bash
cd terraform
terraform init
```
This downloads required providers and prepares Terraform for execution.

Step 6: Provide Required Terraform Variables
Terraform will prompt for three on-demand variables:

1. Cluster Name
Value must match the k3d cluster name created earlier.

Example:
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

## Prerequisites:

Variable values

Terraform resources : use should provide variables into tfvars files we need these variables :

variable "deploy_phase2" 
description= if you 're supposed to use false and true in deploy you can use this variable or you can ignore it.

variable "dockerconfigjson" 
description = "GitHub token for my account because I provided images under my private repo for realstic.

  
variable "postgres_password" 
description = "DB Password"
  

variable "cluster_name" 
description = this is k3d cluster name we use to use config file in provider


Step 7: Terraform Plan (Phase 1)

Run Terraform plan with phase 2 disabled.

In this step create a Local Kubernetes Cluster with k3d

Create a Kubernetes cluster named mycluster with one server and two agents, and expose HTTP/HTTPS ports via a load balancer.


#### Notes
The cluster name must be remembered, as it will be required later in Terraform variables.

If you already have multiple clusters, this name helps Terraform select the correct Kubernetes context.
```bash
terraform plan --target=module.phase0
```
This step validates:

Kubernetes connectivity


Step 8: Terraform Apply (Phase 1)
If the plan succeeds, apply the configuration: 

```bash
terraform apply --var=module.phase0
```
(Optional, non-interactive):
In this step terraform will install sequntialy k3d application and will create 2 worker and 1 master node.


```bash
terraform apply --var=module.phase1
```
(Optional, non-interactive):
In this step terraform will install sequntialy these manifests :

1- Namespace

2- Secrets for database , secret for pulling images and make ssl file then creating secret for ssl

3- Then try to install ArgoCD via helm release

4- In this step try to install Istio ingress and Istiod to perform mtls between frontend and backend

5- In next step install Victoria Metrics db vi Helm release

6- In this final step try to install prometheus Adapter to read a custom metric - latency 95.

7- Open telemetry install and configuration to grab the source-label 

8- Kiali install and configured to connect to VM database to grab the mtls configurations.

```bash
terraform apply --var=deploy_phase2=true --auto-approve
```
What Terraform Does in This Phase


Installs Argo CD using a Helm chart
### 1- Frontend
### 2- Backend
### 3- Infrastructure

Step 9: Retrieve Argo CD Initial Admin Password
After Argo CD is installed, Terraform outputs the initial admin password.

Retrieve it with:

```bash
terraform output argocd_initial_password
```
Use:

Username: admin

Password: output from the command above

This password is required to log in to the Argo CD web interface.

Step 10: Argo CD Applications Deployment
Terraform installs Argo CD Applications as Kubernetes resources.
Three applications are managed by Argo CD:

## 1. Frontend Application
Deployed using a Helm chart

Supports continuous deployment

Uses versioned Helm releases

Exposed via the load balancer and mapped domain:


frontend.k3d.localhost
## 2. Backend Application
Deployed using a Helm chart

Version-controlled deployments

Pulls container images from GitHub Packages

Uses Kubernetes secrets for database credentials

## 3. Infrastructure Application
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



Cleanup (Optional)
To remove all resources:

```bash
terraform destroy --auto-approve
Delete the k3d cluster:

```
```bash
k3d cluster delete mycluster
```

# Data Flow:
## How Prometheus Adapter Translates Custom Metrics for HPA:

In my Terraform file, I configured a rules block that defines the exact logic for metric translation. Since Kubernetes (HPA) doesn't understand PromQL or the concept of histogram buckets—it just expects a simple numerical value (e.g., 4 milliseconds)—I set up the Prometheus Adapter to handle this translation in three specific steps:

## 1. Finding the Raw Data (seriesQuery)
```bash
YAML seriesQuery:
'istio_request_duration_milliseconds_bucket'
```

First, I configured the adapter to query VictoriaMetrics to locate all the raw metrics named istio_request_duration_milliseconds_bucket. This represents the raw telemetry data currently being collected by the OTel pipeline.

## 2. Renaming and Reshaping (The name section)
```bash
YAMLname:
  matches: "istio_request_duration_milliseconds_bucket"
  as: "istio_requests_latency_p95"
  ```
This is where I mapped the metric renaming:

matches: Tells the adapter to look for the raw metric name in the database.

as: Instructs the adapter to expose this metric to the Kubernetes API (custom.metrics.k8s.io) under a custom name: istio_requests_latency_p95.

By doing this, when I reference istio_requests_latency_p95 in my HPA configuration, the adapter automatically links it back to the underlying Istio metric in the database.

## 3. Real-time Mathematical Calculation (metricsQuery)
```bash
YAMLmetricsQuery: "(histogram_quantile(0.95, sum(rate(<<.Series>>{<<.LabelMatchers>>}[2m])) by (le, <<.GroupBy>>)) >= 0) ... "
```
Since raw bucket data consists of simple counters, it doesn't hold any direct scaling value on its own. I set up the metricsQuery so that when the HPA asks, "What is the value of istio_requests_latency_p95?", the adapter dynamically constructs this PromQL formula and sends it to VictoriaMetrics.

It uses dynamic variables (templates) like <<.Series>>. In real-time, the adapter replaces <<.Series>> with istio_request_duration_milliseconds_bucket, calculates the 95th percentile (p95), and ultimately hands over a single, pure number to the HPA.

## 🗺️ Workflow Summary
To summarize the complete metric naming and scaling flow I built:

### Envoy / OTel / VictoriaMetrics: 
These components generate, collect, and store the data using the actual raw name: istio_request_duration_milliseconds_bucket.

### Prometheus Adapter:
 Reads this raw data, applies my mathematical formula (histogram_quantile 0.95), and packages the resulting value under the new label: istio_requests_latency_p95.

### HPA:
 Only interacts with the translated name istio_requests_latency_p95. It makes Scale Up or Scale In decisions based purely on the calculated number provided by the adapter.




# Final Result:




After completing all steps:

A local Kubernetes cluster is running via k3d

Argo CD is installed and accessible

Frontend, backend, and infrastructure are deployed

## Architecture Diagram

![Vyking Architecture](images/2.png)
<p align="center">
  <img src="images/2.png" alt="Vyking Architecture" width="800"/>
</p>

Continuous deployment is active via Argo CD

