resource "aws_launch_template" "eks_node_group" {
  name_prefix = "${var.cluster_name}-eks-node-group"
  description = "Launch template for ${var.cluster_name} EKS node group"

  vpc_security_group_ids = [aws_security_group.eks_nodes_sg.id]

  key_name = var.ssh_key

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "EKS-Worker-Node"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda" # Adjusted to the common root device name for Linux AMIs

    ebs {
      volume_size           = 20    # Disk size specified here
      volume_type           = "gp3" # Example volume type, adjust as necessary
      delete_on_termination = true
    }
  }

  tags = {
    "Name"                                      = "${var.cluster_name}-eks-node-group"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
  }
}
