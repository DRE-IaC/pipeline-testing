##########################################################################
##########################################################################
############################### Please Read ##############################
# When adding credentials we started a bad habit of using the same       #
# secret id. The ID should be something that is relevant to the secret   #
# being stored. For all future additions the ID must be relevant to the  #
# the secret being added. PRs should be rejected if they do not provide  #
# an ID that is relevant to the secret.                                  #
##########################################################################
##########################################################################

resource "aws_secretsmanager_secret" "argocd_github_credentials" {
  count = length(var.aws_secret_name)
  # Needs to be updated for sandbox, but where this is being replaced by controlplane going with simpliest solution. 
  name                    = "/use2/iac/controlplane/${var.aws_secret_name[count.index]}"
  recovery_window_in_days = 0

  tags = local.tags
}
