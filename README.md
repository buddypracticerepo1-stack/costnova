# costnova

Demo infrastructure repository for CostGuard cost validation.

## CostGuard Integration

This repo uses [CostGuard CLI](https://pypi.org/project/costguard-cli/) to validate Terraform plans before deployment.

### What It Does

Every pull request and push to `main` automatically:
1. Reads `terraform/plan.json`
2. Sends it to the CostGuard API
3. Validates against budget `CS-FY2026-M01`
4. Posts a cost breakdown comment on the PR
5. Exits with `ALLOW`, `WARN`, or `BLOCK`

### Current Cost Estimate

| Resource | Type | Monthly Cost |
|---|---|---|
| `aws_instance.web` | t3.medium | $32.77 |
| `aws_db_instance.main` | db.t3.medium | $64.06 |
| `aws_s3_bucket.storage` | S3 | $2.10 |
| **Total** | | **$98.93/month** |

### Run Locally

```bash
pip install costguard-cli
export COSTGUARD_API_URL=https://4tm9xj5nv0.execute-api.us-east-1.amazonaws.com/rnd
export COSTGUARD_API_KEY=<your-key>
costguard-validate --plan terraform/plan.json --format terminal --budget-code CS-FY2026-M01
```
