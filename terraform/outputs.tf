output "server_public_ip" {
  value = aws_instance.taskflow_server.public_ip
}

output "app_url" {
  value = "http://${aws_instance.taskflow_server.public_ip}:8090"
}

output "grafana_url" {
  value = "http://${aws_instance.taskflow_server.public_ip}:3000"
}

output "prometheus_url" {
  value = "http://${aws_instance.taskflow_server.public_ip}:9090"
}
