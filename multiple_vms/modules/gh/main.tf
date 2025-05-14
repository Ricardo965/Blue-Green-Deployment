resource "github_repository_webhook" "webhook" {
  repository = var.repo_name

  configuration {
    url          = var.webhook_url
    content_type = var.content_type
    insecure_ssl = true
  }

  active = true
  events = ["push", "pull_request"]
}
