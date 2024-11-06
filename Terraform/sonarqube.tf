resource "aws_instance" "sonarqube" {
  ami             = var.ami
  instance_type   = var.sonarqube_instance_type
  subnet_id       = aws_subnet.public_subnet[0].id
  key_name        = var.ssh_key
  security_groups = ["${aws_security_group.sonarqube.id}"]
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
#  user_data = file("sonarqube.sh")
  
  provisioner "file" {
    source      = "sonarqube.sh"
    destination = "/tmp/sonarqube.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/sonarqube.sh",
      "/tmp/sonarqube.sh",
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
    Name = "sonarqube-Server"
  }
}

resource "null_resource" "sonarqube" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.sonarqube.public_ip
  }
  provisioner "file" {
    source      = "sonarqube.sh"
    destination = "/tmp/sonarqube.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/sonarqube.sh",
      "/tmp/sonarqube.sh",
    ]
  }
}