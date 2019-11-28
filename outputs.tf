output "instance_id" {
        value = "${aws_instance.obermuller_instance.id}"
}

output "instance_private_ip" {
        value = "${aws_instance.obermuller_instance.private_ip}"
}
output "instance_public_ip" {
        value = "${aws_instance.obermuller_instance.public_ip}"
}
output "epam_iac_workshop-sg" {
        value = "${aws_security_group.iac_obermuller.id}"
}

output "s3_bucket_name" {
	value = "${aws_s3_bucket.obermuller.bucket}"
}
