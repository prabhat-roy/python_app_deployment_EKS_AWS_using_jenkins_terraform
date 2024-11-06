resource "aws_eks_cluster" "cluster1" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-iam-role.arn
  vpc_config {
    subnet_ids = local.public_subnet_ids
    #    subnet_ids         = concat(local.public_subnet_ids, local.private_subnet_ids)
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
  depends_on = [aws_iam_role.eks-iam-role]
}

locals {
  public_subnet_ids = aws_subnet.public_subnet.*.id
  #  private_subnet_ids = aws_subnet.private_subnet.*.id
}