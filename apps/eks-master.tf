resource "aws_eks_cluster" "eks-master" {
  name     = "eks-master"
  role_arn = aws_iam_role.eks-master.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.eks-master.id]
    subnet_ids = concat(
      data.terraform_remote_state.network.outputs.private_subnets.*,
      data.terraform_remote_state.network.outputs.public_subnets.*
    )
    endpoint_private_access = true
    endpoint_public_access = false
}

  depends_on = [
    aws_iam_role_policy_attachment.eks-master-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-master-AmazonEKSServicePolicy,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks-master.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-master.certificate_authority.0.data
}

resource "aws_iam_role" "eks-master" {
  name = "eks-cluster-eks-master"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-master-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-master.name
}

resource "aws_iam_role_policy_attachment" "eks-master-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-master.name
}
