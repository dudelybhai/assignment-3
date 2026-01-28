# SHIP-HAT Compliance Scan

In the Government Commercial Cloud (GCC) context, **SHIP-HAT** (Secure Hybrid Integrated Pipeline - Hive Agile Testing) is the mandated CI/CD platform that enforces security baselines.

## Pipeline Integration

This repository assumes a stage in the CI/CD pipeline (e.g., GitLab CI or Jenkins) dedicated to SHIP-HAT integration.

### Scanners Validated
1.  **Static Application Security Testing (SAST)**:
    - Scans source code (`/app`) for vulnerabilities.
    - **Tool**: SonarQube / Fortify.
    - **Gate**: Critical/High vulnerabilities = Build Fail.

2.  **Software Composition Analysis (SCA)**:
    - Scans dependencies (`package.json`, `requirements.txt`) for CVEs.
    - **Tool**: Nexus IQ / Black Duck.
    - **Gate**: CVSS > 7.0 = Build Fail.

3.  **Container Security**:
    - Scans the built Docker image.
    - **Tool**: Trivy / Clair.
    - **Gate**: Fixable Critical vulnerabilities = Build Fail.

4.  **Interactive/Dynamic Analysis (DAST)**:
    - Scans the running application for runtime issues.
    - **Tool**: WebInspect / OWASP ZAP.

## Emulation (Assignment 3)

Since we cannot connect to the actual SHIP-HAT platform, this assignment mimics the compliance gate using:
- **`scripts/policy_check.py`**: Custom Policy-as-Code gate enforcing Infrastructure security (S3, IAM, SG).
- **`trivy fs .`**: Local container/fs scan simulation (from Assignment 1).
- **Audit Bundle**: Generating a zip file containing all scan outputs for audit trail.
