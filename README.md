# Assignment 3: Compliance-as-Code & Integration

This assignment implements a "Compliance-as-Code" framework suitable for regulated environments like the Government Commercial Cloud (GCC).

## Structure
- **`policies/policy.rego`**: OPA Policy definitions (Rego v1).
- **`pipelines/SHIP_HAT.md`**: Documentation for the SHIP-HAT compliance stage.
- **`scripts/generate_evidence.sh`**: Automation to run checks (OPA + Jira) and bundle evidence.
- **`scripts/validate_jira.py`**: Jira integration script.

## Write-up: Supporting Regulated Environments (GCC)
In a regulated environment like GCC, "Defense in Depth" and "Auditability" are paramount. This solution supports these by:

1.  **Policy Gates (Preventative Control)**:
    - **Open Policy Agent (OPA)** acts as a hard gate in the CI/CD pipeline. It prevents non-compliant resources (e.g., S3 Public Access, Open Security Groups) from ever being deployed. This aligns with **IM8** and **GCC Design Principles**.

2.  **Traceability (Jira Integration)**:
    - Enforcing Jira Ticket IDs in commits links every infrastructure change to an approved change request (CR). This provides the "Why" and "Who" for audit trails.

3.  **Audit Evidence (Immutable Artifacts)**:
    - The `generate_evidence.sh` script produces a timestamped zip bundle containing *actual* validation outputs (Terraform Plan, Policy Reports, Test Results).
    - Uploading this to a WORM (Write Once Read Many) S3 bucket ensures non-repudiation for auditors.

4.  **SHIP-HAT Alignment**:
    - The architecture acknowledges the mandatory SHIP-HAT pipeline (SAST/DAST/SCA) required for government workloads, with the `pipelines/SHIP_HAT.md` document serving as the integration contract.

## Usage

### Run Evidence Generation
```bash
cd scripts
./generate_evidence.sh
```
This produces a `evidence_bundle_<timestamp>.zip` in the `evidence/` directory.

### Run Policy Check Manually
```bash
opa eval --data policies/policy.rego --input scripts/mock_tfplan_fail.json "data.main.deny"
```
