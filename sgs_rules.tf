resource "aws_security_group_rule" "iac_obermuller_ingress" {
        cidr_blocks             =       ["${var.cidr_all}"]
        from_port               =       22
        protocol                =       "tcp"
        to_port                 =       22
        type                    =       "ingress"
        security_group_id       =       "${aws_security_group.iac_obermuller.id}"
}
resource "aws_security_group_rule" "iac_obermuller_ingress-2" {
        cidr_blocks             =       ["${var.cidr_all}" ]
        from_port               =       80
        protocol                =       "tcp"
        to_port                 =       80
        type                    =       "ingress"
        security_group_id       =       "${aws_security_group.iac_obermuller.id}"
}
resource "aws_security_group_rule" "iac_obermuller_egress" {
        cidr_blocks             =       ["${var.cidr_all}"]
        from_port               =       0
        protocol                =       "-1"
        to_port                 =       0
        type                    =       "egress"
        security_group_id       =       "${aws_security_group.iac_obermuller.id}"
}

