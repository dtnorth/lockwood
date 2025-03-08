Setup Instructions
Store AWS Credentials in GitHub Secrets

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
Ensure the ECR Repository Exists

sh
Copy
Edit
aws ecr create-repository --repository-name flask-app --region us-east-1
Push Changes to main Branch

GitHub Actions will automatically build, push, and deploy.

