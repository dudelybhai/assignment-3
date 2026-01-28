package main
import rego.v1

# Helper to get all resources from the plan
resources := input.planned_values.root_module.resources

# 1. Mandatory Tags (S3 Buckets)
deny contains msg if {
    resource := resources[_]
    resource.type == "aws_s3_bucket"
    
    # Get tags safely
    tags := object.get(resource.values, "tags", {})
    
    # Check for owner
    not tags.owner
    msg := sprintf("Resource '%v' is missing mandatory tag: owner", [resource.address])
}

deny contains msg if {
    resource := resources[_]
    resource.type == "aws_s3_bucket"
    
    # Get tags safely
    tags := object.get(resource.values, "tags", {})
    
    # Check for environment
    not tags.environment
    msg := sprintf("Resource '%v' is missing mandatory tag: environment", [resource.address])
}

# 2. S3 Public Access
deny contains msg if {
    resource := resources[_]
    resource.type == "aws_s3_bucket"
    
    acl := object.get(resource.values, "acl", "private")
    acl == "public-read"
    msg := sprintf("S3 Bucket '%v' has unsafe ACL: public-read", [resource.address])
}

deny contains msg if {
    resource := resources[_]
    resource.type == "aws_s3_bucket"
    
    acl := object.get(resource.values, "acl", "private")
    acl == "public-read-write"
    msg := sprintf("S3 Bucket '%v' has unsafe ACL: public-read-write", [resource.address])
}

# 3. Security Groups - Admin Ports open to 0.0.0.0/0
deny contains msg if {
    resource := resources[_]
    resource.type == "aws_security_group"
    
    ingress := resource.values.ingress[_]
    
    # Check if CIDR includes 0.0.0.0/0
    "0.0.0.0/0" == ingress.cidr_blocks[_]
    
    # Check ports
    is_admin_port(ingress.from_port, ingress.to_port)
    
    msg := sprintf("Security Group '%v' allows 0.0.0.0/0 on admin port (SSH/RDP)", [resource.address])
}

is_admin_port(from, to) if {
    from <= 22
    to >= 22
}
is_admin_port(from, to) if {
    from <= 3389
    to >= 3389
}

# 4. IAM Policies - Full Admin Access
deny contains msg if {
    resource := resources[_]
    resource.type == "aws_iam_policy"
    
    # Parse policy JSON
    policy_json := resource.values.policy
    policy_doc := json.unmarshal(policy_json)
    
    # Handle single statement vs list
    statements := as_array(policy_doc.Statement)
    statement := statements[_]
    
    statement.Effect == "Allow"
    statement.Action == "*"
    statement.Resource == "*"
    
    msg := sprintf("IAM Policy '%v' grants full Admin Access (*:*)", [resource.address])
}

# 5. Logs not enabled (S3 Bucket Logging)
deny contains msg if {
    resource := resources[_]
    resource.type == "aws_s3_bucket"
    
    # Check for logging block
    not resource.values.logging
    
    msg := sprintf("Resource '%v' does not have Access Logging enabled", [resource.address])
}

# Helper to normalize statement to array
as_array(x) = x if is_array(x)
as_array(x) = [x] if not is_array(x)
