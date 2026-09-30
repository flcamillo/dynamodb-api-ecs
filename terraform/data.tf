# identifica a conta atual
data "aws_caller_identity" "current" {}

# identifica a org da conta
data "aws_organizations_organization" "current" {}

# região atual dos recursos
data "aws_region" "current" {}
