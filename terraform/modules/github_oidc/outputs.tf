output "gha_role_arn" {
  value       = try(aws_iam_role.gha_ci[0].arn, null)
  description = "GitHub Actions CI role ARN"
}
