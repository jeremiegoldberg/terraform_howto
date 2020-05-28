resource "scaleway_instance_ip" "public_ip" {}

resource "scaleway_instance_security_group" "my_security_group" {
  external_rules = true
}

resource "scaleway_instance_security_group_rules" "security-rule" {
  security_group_id = "${scaleway_instance_security_group.my_security_group.id}"

  inbound_rule {
    action = "accept"
    port   = "22"
  }

  inbound_rule {
     action = "accept"
     port   = "80"
  }

  inbound_rule { 
     action = "accept"
     port   = "443"
  }

  inbound_rule {
     action = "drop"
  }
}

data "scaleway_image" "docker" {
  architecture = "x86_64"
  name         = "Docker"
}

resource "scaleway_instance_server" "instance" {
  name  = "monserveur"
  type  = "DEV1-S"

  image = "${data.scaleway_image.docker.id}"
  tags = [ "tag1", "tag2" ]
  ip_id = scaleway_instance_ip.public_ip.id
  security_group_id = "${scaleway_instance_security_group.my_security_group.id}"

  connection {
    type     = "ssh"
    user     = "root"
    host     = "${scaleway_instance_ip.public_ip.address}"
  }

  provisioner "file" {
    source      = "files/docker-compose.yml"
    destination = "/root/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose up -d"
    ]
  }
}


output "lien_de_wordpress" {
  value = ["http://${scaleway_instance_ip.public_ip.address}"]
}
