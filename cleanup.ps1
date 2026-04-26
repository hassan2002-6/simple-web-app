# cleanup.ps1
$REGION = "us-east-1"
$REPO_NAME = "simple-web-app"
$SERVICE_NAME = "simple-web-app-service"
$ROLE_NAME = "AppRunnerECRAccessRole"

Write-Host "--- Destroying AWS Resources ---" -ForegroundColor Red

# 1. Delete App Runner Service
Write-Host "Deleting App Runner Service..."
$serviceArn = aws apprunner list-services --query "ServiceSummaryList[?ServiceName=='$SERVICE_NAME'].ServiceArn" --output text --region $REGION
if ($serviceArn -and $serviceArn -ne "None") {
    aws apprunner delete-service --service-arn $serviceArn --region $REGION
    Write-Host "Deletion initiated for $serviceArn"
}

# 2. Delete ECR Repository
Write-Host "Deleting ECR Repository..."
aws ecr delete-repository --repository-name $REPO_NAME --force --region $REGION

# 3. Delete IAM Role
Write-Host "Deleting IAM Role..."
aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess
aws iam delete-role --role-name $ROLE_NAME

Write-Host "--- Cleanup Complete ---" -ForegroundColor Green
