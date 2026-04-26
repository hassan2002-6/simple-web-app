# Simple Web App - AWS Containerization Assignment

This repository contains a fully containerized static web application deployed to AWS using GitHub Actions.

## Architecture
- **Frontend**: HTML/CSS served by Nginx.
- **Container**: Docker (nginx:alpine).
- **Registry**: Amazon ECR.
- **Hosting**: AWS App Runner.
- **CI/CD**: GitHub Actions.

## CI/CD Workflow
1. Push to `main`.
2. Build Docker image.
3. Push to Amazon ECR.
4. Deploy to AWS App Runner.

## Local Development
Build and run the container locally:
```bash
docker build -t simple-web-app .
docker run -p 8080:80 simple-web-app
```

## Live Link
[https://xwixyhus4m.us-east-1.awsapprunner.com](https://xwixyhus4m.us-east-1.awsapprunner.com)
