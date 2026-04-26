# provision.ps1
$REGION = "us-east-1"
$REPO_NAME = "simple-web-app"
$SERVICE_NAME = "simple-web-app-service"
$ROLE_NAME = "AppRunnerECRAccessRole"

Write-Host "--- Provisioning AWS Resources ---" -ForegroundColor Cyan

# 1. Create ECR Repository
Write-Host "Checking ECR Repository..."
$repo = aws ecr describe-repositories --repository-names $REPO_NAME --region $REGION 2>$null
if (-not $repo) {
    Write-Host "Creating ECR Repository: $REPO_NAME"
    aws ecr create-repository --repository-name $REPO_NAME --region $REGION
} else {
    Write-Host "ECR Repository already exists."
}

# 2. Create IAM Role for App Runner (to pull from ECR)
Write-Host "Checking IAM Role: $ROLE_NAME"
$role = aws iam get-role --role-name $ROLE_NAME 2>$null
if (-not $role) {
    Write-Host "Creating IAM Role: $ROLE_NAME"
    $trustPolicy = '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "build.apprunner.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'
    $trustPolicy | Out-File -FilePath trust-policy.json -Encoding ascii
    aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://trust-policy.json
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess
    Remove-Item trust-policy.json
} else {
    Write-Host "IAM Role already exists."
}

# 3. Get Account ID
$accountId = (aws sts get-caller-identity --query "Account" --output text)
$imageUri = "$accountId.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest"
$roleArn = "arn:aws:iam::$accountId:role/$ROLE_NAME"

# 4. Check if service exists
Write-Host "Checking App Runner Service..."
$service = aws apprunner list-services --query "ServiceSummaryList[?ServiceName=='$SERVICE_NAME'].ServiceArn" --output text --region $REGION

if ($service -eq "None" -or -not $service) {
    Write-Host "Creating App Runner Service: $SERVICE_NAME"
    # Note: This might fail if the image hasn't been pushed yet. 
    # Usually, we push the first image manually or via pipeline before creating the service.
    # But we can create it with a placeholder if we want.
    # Better: We'll wait for the first push.
    Write-Host "Please push the first image to ECR before creating the service, or run this script again after the first pipeline run." -ForegroundColor Yellow
} else {
    Write-Host "App Runner Service already exists: $service"
}

Write-Host "--- Provisioning Complete ---" -ForegroundColor Green
