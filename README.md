# 🚀 Automated Transaction Processing System
### Enterprise-Grade Event-Driven Architecture (AWS)

This repository contains the complete Infrastructure as Code (IaC) and orchestration logic for a robust, event-driven transaction processing system. Engineered for **ABC Startup**, the platform leverages a serverless-first approach to ensure scalability, auditability, and strict cost control.

---

## 🏛️ System Architecture Overview

The system transitions from an idle state to active execution only upon data ingress. It utilizes a **synchronized state machine** to gate processing based on infrastructure availability.

```text
[ GitHub ] --(OIDC Authentication)--> [ GitHub Actions ] --(Terraform)--> [ AWS Environment ]
                                                                                |
                                                                                |
      +-------------------------------------------------------------------------+
      | AWS VPC (Virtual Private Cloud)                                         |
      |                                                                         |
      |  [ S3 Bucket ] ---> [ EventBridge ] ---> [ Step Functions (Orchestrator) ]
      |      (Input)        (Event Bus)                 |                       |
      |                                                 |                       |
      |                                       (Step 1: Status Check)   (Step 2: Execution)
      |                                                 v                       v
      |                                         [ EC2 Instance ]        [ ECS Fargate Task ]
      |                                          (Dependency)             (Batch Logic)
      +-------------------------------------------------------------------------+
```

---

## 🔧 Technical Component Deep-Dive

### 1. Orchestration Layer (`stepfunctions.tf`)
The **AWS Step Functions** state machine acts as the distributed orchestrator. It uses the AWS SDK integration to perform out-of-band checks without requiring custom Lambda glue code.

* **Service Integration:** Uses `arn:aws:states:::aws-sdk:ec2:describeInstanceStatus` for native API interaction.
* **Logical Gating:** A `Choice` state evaluates the JSON path `$.ec2.InstanceStatuses[0].InstanceState.Name`. 
* **Synchronous Execution:** The ECS task is invoked using the `.sync` pattern (`runTask.sync`), meaning the workflow waits for the container exit code before finalizing the status.

### 2. Compute Strategy (`ecs.tf` & `ec2.tf`)
The architecture separates **Persistent Dependency** from **Ephemeral Processing**:

* **Pre-processing Dependency (EC2):** A `t3.micro` instance serves as a required environment gate. It is managed as a static resource within the Terraform state.
* **Batch Processor (ECS Fargate):** * **Serverless Execution:** Utilizes Fargate to eliminate the overhead of managing underlying EC2 clusters for the processing logic.
    * **Resource Efficiency:** Configured at 256 CPU units and 512MB RAM, optimizing for the lowest possible AWS Fargate pricing tier.
    * **Task Definition:** Decouples the runtime environment from the application code, allowing for immutable container deployments.

### 3. Event-Driven Trigger (`s3.tf`)
The system eliminates polling. It utilizes **S3 Event Notifications** integrated directly with **Amazon EventBridge**.
* **Pattern Matching:** EventBridge rules filter specifically for `Object Created` events within the designated transaction bucket.
* **Zero-Latency:** The workflow initiates milliseconds after the S3 `PutObject` operation is completed.

### 4. Networking & Security Matrix (`network.tf` & `iam.tf`)
The security posture follows the principle of least privilege (PoLP):
* **Identity:** A unified IAM role is assumed via **OIDC (OpenID Connect)** from GitHub Actions, removing the need for long-lived AWS Access Keys.
* **Isolation:** All compute resources reside in a VPC with DNS Support and Hostnames enabled. 
* **Traffic Control:** The Security Group (`aws_security_group.main`) allows internal VPC communication while restricting outbound traffic to legitimate AWS API endpoints.

---

## 🛠️ DevOps & Deployment Pipeline

### Infrastructure as Code (Terraform)
* **State Management:** Remote state is persisted in S3 with **native state locking** enabled to prevent concurrent execution conflicts during multi-engineer deployments.
* **Modular Variables:** Configurable via `variables.tf`, allowing the system to be replicated across `ap-south-1` or other regions by simply changing the `aws_region` input.

### Continuous Deployment (GitHub Actions)
The repository includes two highly controlled workflows:
1.  **🚀 Deploy:** Performs `terraform init` and `terraform apply --auto-approve`. It ensures the live environment matches the version-controlled configuration.
2.  **💣 Destroy:** A fail-safe workflow to decommission the entire stack, ensuring zero "zombie" resources or unexpected costs.

---

## 📊 Operational Visibility

| Metric | Monitoring Source |
| :--- | :--- |
| **Workflow State** | Step Functions Execution History (Visual Graph) |
| **Infrastructure Changes** | GitHub Commit History & Terraform Plan Output |
| **Compute Health** | ECS Task Exit Codes (0 = Success, 1+ = Failure) |
| **Data Ingress** | S3 CloudWatch Metrics |

---

## 📖 Quick Start for Engineers

1.  **Modify Logic:** Update the `command` array in `ecs.tf` to point to your specific processing script.
2.  **Toggle Dependency:** Stop the EC2 instance in the console to test the workflow's "Fail-Fast" logic.
3.  **Deploy:** Navigate to **GitHub Actions** > **Deploy ABC Startup Infrastructure** > **Run Workflow**.
4.  **Execute:** Upload any file to the bucket named in `s3_bucket_name`.

---

## 📝 Conclusion
This system is a high-availability solution that balances **strict operational control** with **automated agility**. By moving infrastructure management to GitHub and execution logic to Step Functions, ABC Startup achieves a professional-grade processing pipeline with minimal maintenance overhead.
