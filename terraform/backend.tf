terraform {
  cloud {
    organization = "TonyVerin"
    workspaces {
      name = "FifaApp-infra"
    }
  }
}