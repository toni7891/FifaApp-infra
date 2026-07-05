variable "github_org" {
  description = "GitHub organization/user that owns FifaApp-backend and FifaApp-frontend"
  type        = string
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid     = "AllowMainBranchWorkflows"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/FifaApp-backend:ref:refs/heads/main",
        "repo:${var.github_org}/FifaApp-frontend:ref:refs/heads/main",
      ]
    }
  }

  statement {
    sid     = "DenyPullRequestBuilds"
    effect  = "Deny"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/FifaApp-backend:pull_request*",
        "repo:${var.github_org}/FifaApp-frontend:pull_request*",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  tags               = { Project = "FifaApp" }
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

output "gha_role_arn" {
  description = "Set this as AWS_ROLE_ARN secret in FifaApp-backend and FifaApp-frontend"
  value       = aws_iam_role.github_actions.arn
}
