output "dns" {
  value = ["${aws_instance.cli.*.public_dns}"]
}

output "public_ip" {
  value = ["${aws_instance.cli.*.public_ip}"]
}
