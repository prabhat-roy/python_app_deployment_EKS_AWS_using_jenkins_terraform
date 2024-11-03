resource "aws_iam_policy" "AmazonEKSAdminPolicy" {
  name   = "AmazonEKSAdminPolicy"
  policy = file("AmazonEKSAdminPolicy.json")
}

resource "aws_iam_role" "eks_admin" {
  name               = "eks-admin"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::873330726955:root"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_admin_attachment" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.AmazonEKSAdminPolicy.arn
}

resource "aws_iam_policy" "AmazonEKSAssumeEKSAdminPolicy" {
  name   = "AmazonEKSAssumeEKSAdminPolicy"
  policy = file("AmazonEKSAssumeEKSAdminPolicy.json")
}

resource "aws_iam_policy" "ecrimage" {
  name   = "ECR_image_upload_policy"
  policy = file("ecr_image_upload.json")
}

resource "aws_iam_user" "jenkins-eks" {
  name = "eks-jenkins"
}

resource "aws_iam_user_policy_attachment" "eks-jenkins-policy" {
  user       = aws_iam_user.jenkins-eks.name
  policy_arn = aws_iam_policy.AmazonEKSAssumeEKSAdminPolicy.arn
}

resource "aws_iam_user_policy_attachment" "ecr-jenkins-policy" {
  user       = aws_iam_user.jenkins-eks.name
  policy_arn = aws_iam_policy.ecrimage.arn
}

resource "aws_iam_role" "jenkins_admin_role" {
  name               = "jenkins_admin_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jenkins_attachment" {
  role       = aws_iam_role.jenkins_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins_admin_profile" {
  name = "jenkins_admin_profile"
  role = aws_iam_role.jenkins_admin_role.name
}

resource "aws_iam_role" "eks-iam-role" {
  name = "eks-iam-role"

  path = "/"

  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-iam-role.name
}

resource "aws_iam_role" "workernodes" {
  name = "eks-worker-node-role"

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

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workernodes.name
}