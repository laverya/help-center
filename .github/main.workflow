workflow "Hugo Link Check" {
  resolves = "linkcheck"
  on = "pull_request"
}

action "filter-to-pr-open-synced" {
  uses = "actions/bin/filter@master"
  args = "action 'opened|synchronize'"
}

action "linkcheck" {
  uses = "marccampbell/hugo-linkcheck-action@v0.1.2"
  needs = "filter-to-pr-open-synced"
  secrets = ["GITHUB_TOKEN"]
  env = {
    HUGO_FINAL_URL = "https://help.replicated.com"
  }
}

workflow "null workflow" {
  on = "push"
  resolves = ["HTTP client"]
}

action "Filters for GitHub Actions" {
  uses = "actions/bin/filter@3c98a2679187369a2116d4f311568596d3725740"
}

action "HTTP client" {
  uses = "swinton/httpie.action@8ab0a0e926d091e0444fcacd5eb679d2e2d4ab3d"
  needs = ["Filters for GitHub Actions"]
}
