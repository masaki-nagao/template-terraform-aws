resource "aws_eks_node_group" "eks-nodes" {
  cluster_name    = aws_eks_cluster.eks-master.name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.eks-nodes.arn
  subnet_ids      = data.terraform_remote_state.network.outputs.private_subnets.*

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}

resource "aws_iam_role" "eks-nodes" {
  name = "eks-node-group-eks-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-nodes.name
}
