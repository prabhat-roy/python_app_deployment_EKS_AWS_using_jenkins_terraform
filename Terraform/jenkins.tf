resource "aws_instance" "jenkins" {
  ami                  = var.ami
  instance_type        = var.jenkins_instance_type
  subnet_id            = aws_subnet.public_subnet[0].id
  key_name             = var.ssh_key
  security_groups      = ["${aws_security_group.jenkins.id}"]
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
#  user_data = file("jenkins.sh")
  
  provisioner "file" {
    source      = "jenkins.sh"
    destination = "/tmp/jenkins.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/jenkins.sh",
      "/tmp/jenkins.sh",
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
    Name = "Jenkins-Server"
  }
}

resource "null_resource" "jenkins" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.jenkins.public_ip
  }
  provisioner "file" {
    source      = "jenkins.sh"
    destination = "/tmp/jenkins.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/jenkins.sh",
      "/tmp/jenkins.sh",
    ]
  }
}