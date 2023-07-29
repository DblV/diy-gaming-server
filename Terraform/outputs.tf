output "spot_request_id" {
  description = "ID of the spot request"
  value       = aws_spot_instance_request.gaming_server_request.id
}

output "spot_price" {
  description = "Spot instance cost per hour"
  value       = aws_spot_instance_request.gaming_server_request.spot_price
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = data.aws_instance.gaming_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = data.aws_instance.gaming_server.public_ip
}
