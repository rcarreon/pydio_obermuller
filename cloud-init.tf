data "template_file" "init" {
  template  = "${file("${path.module}/user_data/app_server_pydio.sh")}"
  vars {
        ROOT_PASS  	=  "${var.root_pass}"
        PYDIO_PASS  	=  "${var.pydio_pass}"
  }
}
data "template_file" "s3fs" {
  template  = "${file("${path.module}/user_data/app_server_s3fs.sh")}"
  vars {
        ACCESS_KEY  = "${var.access_key}"
        SECRET_KEY  = "${var.secret_key}"
	BUCKET      = "${var.bucket}"
  }
}

data "template_cloudinit_config" "this" {
  gzip     = false
  base64_encode  = false
  
  part {
    filename      = "init.sh"
    content_type  = "text/x-shellscript"
    content       = "${data.template_file.init.rendered}" 
  }   
  part {
    filename      = "s3fs.sh"
    content_type  = "text/x-shellscript"
    content       = "${data.template_file.s3fs.rendered}" 
  }   
}

