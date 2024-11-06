resource "aws_instance" "jenkins-agent" {
  ami                  = var.ami
  instance_type        = var.jenkins_agent_instance_type
  subnet_id            = aws_subnet.public_subnet[0].id
  key_name             = var.ssh_key
  security_groups      = ["${aws_security_group.jenkins-agent.id}"]
  iam_instance_profile = aws_iam_instance_profile.jenkins_admin_profile.name
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }
  /*  
#  user_data = file("jenkins-agent.sh")
  
  provisioner "file" {
    source      = "jenkins-agent.sh"
    destination = "/tmp/jenkins-agent.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/jenkins-agent.sh",
      "/tmp/jenkins-agent.sh",
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

*/
  tags = {
    Name = "Jenkins-Agent-Server"
  }
}

resource "null_resource" "jenkins-agent" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.jenkins-agent.public_ip
  }
  provisioner "file" {
    source      = "jenkins-agent.sh"
    destination = "/tmp/jenkins-agent.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/jenkins-agent.sh",
      "/tmp/jenkins-agent.sh",
    ]
  }
}