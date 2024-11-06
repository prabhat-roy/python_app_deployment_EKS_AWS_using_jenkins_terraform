output "jenkins_url" {
  value = join("", ["http://", aws_instance.jenkins.public_ip, ":", "8080"])
}

output "jenkins-agent" {
  value = aws_instance.jenkins-agent.public_ip
}

output "sonar-ip" {
  value = join("", ["http://", aws_instance.sonarqube.public_ip, ":", "9000"])
}