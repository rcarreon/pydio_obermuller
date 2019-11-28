### Instances ###
resource "aws_instance" "obermuller_instance" {
                ami                             =       "${var.ami}"
                associate_public_ip_address     =       "true"
                ebs_optimized                   =       "false"
                instance_type                   =       "${var.type}"
                key_name                        =       "${var.key}"
                monitoring                      =       "false"
		count				=	1
                root_block_device {
                        delete_on_termination   =       "true"
                        iops                    =       100
                        volume_size             =       30
                        volume_type             =       "gp2"
                }
                #source_dest_check               =       "true"
                tags {
                        Tier                    =       "${var.tier_app}"
                        Name                    =       "${var.org}_${var.project}_${var.tier_app}"
                        inspector               =       "false"
                }
                user_data  		        =       "${data.template_cloudinit_config.this.rendered}"

		vpc_security_group_ids		=	["${aws_security_group.iac_obermuller.id}"]
}
