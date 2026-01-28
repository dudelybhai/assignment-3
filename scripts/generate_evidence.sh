#!/bin/bash
set -e

EVIDENCE_DIR="./evidence"
BUNDLE_NAME="evidence_bundle_$(date +%s).zip"
mkdir -p $EVIDENCE_DIR/temp

echo "Gathering Evidence for Assignment 3..."

# 1. Terraform Plan Compliance (Policy Gate - OPA)
echo "---------------------------------------------------"
echo "Running OPA Policy Check on PASSING plan..."
# OPA Eval returns a JSON result. We want to check if 'deny' is empty.
opa eval --format pretty --data policies/policy.rego --input scripts/mock_tfplan_pass.json "data.main.deny" > $EVIDENCE_DIR/temp/policy_pass.json
cat $EVIDENCE_DIR/temp/policy_pass.json

echo "Running OPA Policy Check on FAILING plan..."
opa eval --format pretty --data policies/policy.rego --input scripts/mock_tfplan_fail.json "data.main.deny" > $EVIDENCE_DIR/temp/policy_fail.json
cat $EVIDENCE_DIR/temp/policy_fail.json
echo "---------------------------------------------------"

# 2. Jira Integration
echo "Validating Jira Ticket..."
python3 scripts/validate_jira.py --title "GCC-1234: Feat - New S3 bucket" --comment "Deployment started" > $EVIDENCE_DIR/temp/jira_validation.log 2>&1
echo "Jira Validation Log:"
cat $EVIDENCE_DIR/temp/jira_validation.log

# 3. SHIP-HAT / Gov Compliance
cp pipelines/SHIP_HAT.md $EVIDENCE_DIR/temp/SHIP_HAT_COMPLIANCE.md

# Zip it up
echo "Creating Artifact Bundle: $BUNDLE_NAME"
# Zip it up
echo "Creating Artifact Bundle: $BUNDLE_NAME"
cd $EVIDENCE_DIR/temp
zip -r ../$BUNDLE_NAME .
cd - > /dev/null # Return to project root (since we gathered evidence/temp/..)

echo "Mock Uploading to S3..."
echo "Uploaded $BUNDLE_NAME to s3://gcc-audit-bucket/evidence/$BUNDLE_NAME"
ls -l $EVIDENCE_DIR/$BUNDLE_NAME
