# AWS CodePipeline and CodeBuild Setup for S3 Deployment

This guide outlines the steps to configure AWS CodePipeline and CodeBuild to deploy an `index.html` file to an S3 bucket successfully.

## 1. IAM Role Permissions
Ensure the IAM roles for CodeBuild and CodePipeline have the necessary permissions.

### CodeBuild Role Permissions
The CodeBuild role (`codebuild-auto-deployment-project-service-role`) requires permissions to:
- Upload objects to the S3 bucket (`auto-deployment-01`).
- Use AWS KMS for server-side encryption.
- Access the artifact bucket (`codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b`).

**Example IAM Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b",
        "arn:aws:s3:::codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::auto-deployment-01/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": [
        "arn:aws:kms:us-east-1:956126608641:key/*"
      ]
    }
  ]
}
```

### CodePipeline Role Permissions
The CodePipeline role (`AWSCodePipelineServiceRole-us-east-1-auto-deployment-pipeline`) needs permissions to access the artifact bucket.

**Example IAM Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b",
        "arn:aws:s3:::codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b/*"
      ]
    }
  ]
}
```

## 2. S3 Bucket Policies
The artifact bucket (`codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b`) requires server-side encryption with AWS KMS and secure connections (HTTPS). Update the bucket policy to allow access for the CodeBuild and CodePipeline roles.

**Example Bucket Policy:**
```json
{
  "Version": "2012-10-17",
  "Id": "SSEAndSSLPolicy",
  "Statement": [
    {
      "Sid": "AllowCodeBuildAndCodePipeline",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::956126608641:role/codebuild-auto-deployment-project-service-role",
          "arn:aws:iam::956126608641:role/AWSCodePipelineServiceRole-us-east-1-auto-deployment-pipeline"
        ]
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b",
        "arn:aws:s3:::codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b/*"
      ]
    },
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
    {
      "Sid": "DenyInsecureConnections",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

## 3. Buildspec Configuration
Configure the `buildspec.yml` file to:
- Use the `--sse aws:kms` option with the `aws s3 cp` command for encryption.
- Define the `artifacts` section to upload `index.html`.

**Example `buildspec.yml`:**
```yaml
version: 0.2
phases:
  install:
    commands:
      - echo "[INSTALL] nothing to install"
  pre_build:
    commands:
      - echo "[PRE_BUILD] start"
      - ls -l  # Check if index.html exists
  build:
    commands:
      - echo "[BUILD] nothing to build"
  post_build:
    commands:
      - echo "[POST_BUILD] deploying index.html to S3://auto-deployment-01/"
      - aws s3 cp index.html s3://auto-deployment-01/ --sse aws:kms
artifacts:
  files:
    - index.html
  discard-paths: yes
```

## 4. KMS Key Permissions
If using a specific KMS key, ensure the CodeBuild and CodePipeline roles have permissions to use it (see the `kms` actions in the IAM policies above).

## 5. Pipeline Configuration
- Confirm that CodePipeline uses the correct artifact bucket (`codepipeline-us-east-1-90bdd01c2f03-493c-984b-82fdc5115e6b`).
- Ensure artifact names match between CodeBuild output and CodePipeline input.

## 6. Debugging
- Add `ls -l` in the `PRE_BUILD` phase to verify `index.html` exists.
- Review CodeBuild logs for errors, especially during the `aws s3 cp` command.

## Additional Notes
- **Static Website Hosting**: Configure the S3 bucket (`auto-deployment-01`) for static website hosting with a public read policy if needed.
- **Region Consistency**: Use the same region (`us-east-1`) for CodePipeline, CodeBuild, and S3 buckets.
- **KMS Key**: Replace the wildcard (`*`) in the KMS policy with the specific key ARN if applicable.

By following these steps, your pipeline should successfully deploy `index.html` to the S3 bucket.