provider "github" {
  token = var.token
}

resource "github_repository" "create-repo1" {
  name       = "test-tf-1"
  visibility = "public"
  auto_init  = true
}

resource "github_repository" "create-repo-2" {
  name       = "test-tf-2"
  visibility = "public"
  auto_init  = true
}

output "repo-url" {
  depends_on = [github_repository.create-repo1]
  value      = github_repository.create-repo1.git_clone_url
}