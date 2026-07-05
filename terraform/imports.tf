# One-time bootstrap imports — the OIDC provider and TFC role were created
# manually (chicken-and-egg: TFC needs them to authenticate). Safe to delete
# this file after the first successful apply.
import {
  to = aws_iam_openid_connect_provider.tfc
  id = "arn:aws:iam::048319616750:oidc-provider/app.terraform.io"
}

import {
  to = aws_iam_role.tfc
  id = "tfc-FifaApp-infra-role"
}

import {
  to = aws_iam_role_policy_attachment.tfc_admin
  id = "tfc-FifaApp-infra-role/arn:aws:iam::aws:policy/AdministratorAccess"
}

import {
  to = aws_iam_openid_connect_provider.github
  id = "arn:aws:iam::048319616750:oidc-provider/token.actions.githubusercontent.com"
}
