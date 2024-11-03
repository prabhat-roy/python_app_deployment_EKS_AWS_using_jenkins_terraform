resource "aws_security_group" "jenkins" {
  vpc_id      = aws_vpc.aws_vpc.id
  description = "Jenkins Security Group"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.icanhazip.response_body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Jenkins Security Group"
  }
}

resource "aws_security_group" "jenkins-agent" {
  vpc_id      = aws_vpc.aws_vpc.id
  description = "Jenkins-Agent Security Group"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.aws_vpc_cidr]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.icanhazip.response_body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Jenkins-Agent Security Group"
  }
}

resource "aws_security_group" "sonarqube" {
  vpc_id      = aws_vpc.aws_vpc.id
  description = "Sonarqube Security Group"
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.icanhazip.response_body)}/32"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.aws_vpc_cidr]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.icanhazip.response_body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Soarqube Security Group"
  }
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane communication with worker nodes"
  vpc_id      = aws_vpc.aws_vpc.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.cluster_name}-eks-cluster-sg"
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow inbound traffic from the worker nodes on the Kubernetes API endpoint port"
}

resource "aws_security_group_rule" "eks_cluster_egress_kublet" {
  type                     = "egress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow control plane to node egress for kubelet"
}

resource "aws_security_group_rule" "eks_cluster_egress_nginx" {
  type                     = "egress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow control plane to node egress for nginx"
}

# Node Security group
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-eks-nodes-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.aws_vpc.id

  tags = {
    Name                                        = "${var.cluster_name}-eks-nodes-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Unneccessary because all outbound traffic from worker nodes is allowed by worker_node_egress_internet rule
# resource "aws_security_group_rule" "worker_node_to_control_plane_egress_https" {
#   type                     = "egress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_nodes_sg.id
#   source_security_group_id = aws_security_group.eks_cluster_sg.id
#   description              = "Allow worked node to control plane/Kubernetes API egress for HTTPS"
# }

resource "aws_security_group_rule" "worker_node_ingress_nginx" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "Allow control plane to node ingress for nginx"
}

resource "aws_security_group_rule" "worker_node_to_worker_node_ingress_coredns_tcp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_nodes_sg.id
  self              = true
  description       = "Allow workers nodes to communicate with each other for coredns TCP"
}

resource "aws_security_group_rule" "worker_node_to_worker_node_ingress_coredns_udp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.eks_nodes_sg.id
  self              = true
  description       = "Allow workers nodes to communicate with each other for coredns UDP"
}

resource "aws_security_group_rule" "worker_node_ingress_kublet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "Allow control plane to node ingress for kubelet"
}

resource "aws_security_group_rule" "worker_node_to_worker_node_ingress_ephemeral" {
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Allow workers nodes to communicate with each other on ephemeral ports"
}

resource "aws_security_group_rule" "ssh_access" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_nodes_sg.id

  #cidr_blocks = ["${format(jsondecode(data.http.ipinfo.body).ip)}/32"]
  cidr_blocks = ["${chomp(data.http.icanhazip.response_body)}/32"]
}

resource "aws_security_group_rule" "worker_node_egress_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Allow outbound internet access"
}