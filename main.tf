resource "cherryservers_project" "projektas" {
  team_id = "${var.team_id}"
  name = "${var.project_name}"
}
resource "cherryservers_ssh" "mykey" {
  name = "terraformkey"
  public_key = "${file("${var.private_key}.pub")}"
}

resource "cherryservers_ip" "floating-ip-main" {
  project_id = "${cherryservers_project.projektas.id}"
  region = "${var.region}"
}

resource "cherryservers_ip" "floating-ip-worker1" {
  project_id = "${cherryservers_project.projektas.id}"
  region = "${var.region}"
}

resource "cherryservers_ip" "floating-ip-worker2" {
  project_id = "${cherryservers_project.projektas.id}"
  region = "${var.region}"
}

data "template_file" "haproxycfg" {
  template = "${file("./templates/haproxy.cfg")}"
  vars = {
    worker1 = "${cherryservers_ip.floating-ip-worker1.address}"
    worker2 = "${cherryservers_ip.floating-ip-worker2.address}"
    mainip = "${cherryservers_ip.floating-ip-main.address}"

  }
}

resource "cherryservers_server" "HA" {
  project_id = "${cherryservers_project.projektas.id}"
  region = "EU-East-1"
  hostname = "HAproxy"
  image = "${var.image}"
  plan_id = "${var.plan_id}"
  ssh_keys_ids = [
    "${cherryservers_ssh.mykey.id}"]
  ip_addresses_ids = [
    "${cherryservers_ip.floating-ip-main.id}"]

  provisioner "remote-exec" {
    inline = [
      "apt-get update -y",
      "apt-get install haproxy -y",
      "cat > /etc/haproxy/haproxy.cfg <<EOL",
      "${data.template_file.haproxycfg.rendered}",
      "EOL",
      "service haproxy restart"
    ]

    connection {
      type = "ssh"
      user = "root"
      host = "${cherryservers_server.HA.primary_ip}"
      private_key = "${file(var.private_key)}"
      timeout = "20m"
    }
}
}

data "template_file" "fwsh" {
  template = "${file("./templates/fw.sh")}"
  vars = {
    floating = "${cherryservers_ip.floating-ip-main.address}"
    main = "${cherryservers_server.HA.primary_ip}"
  }
}

resource "cherryservers_server" "web1" {
  project_id = "${cherryservers_project.projektas.id}"
  region = "${var.region}"
  hostname = "Web1"
  image = "${var.image}"
  plan_id = "${var.plan_id}"
  ssh_keys_ids = [
    "${cherryservers_ssh.mykey.id}"]
  ip_addresses_ids = [
    "${cherryservers_ip.floating-ip-worker1.id}"]

  provisioner "remote-exec" {
    inline = [
      "apt-get update -y",
      "apt-get install apache2 -y",
      "service apache2 start",
      "cat > /var/www/html/index.html <<EOL",
      "${cherryservers_ip.floating-ip-worker1.address}",
      "EOL"
    ]

    connection {
      type = "ssh"
      user = "root"
      host = "${cherryservers_server.web1.primary_ip}"
      private_key = "${file(var.private_key)}"
      timeout = "20m"
    }
}

  provisioner "remote-exec" {
    inline = [
      "until ping -c1 ${cherryservers_ip.floating-ip-worker1.address} >/dev/null 2>&1; do :; done",
      "cat > /etc/fw.sh <<EOL",
      "${data.template_file.fwsh.rendered}",
      "EOL",
      "chmod +x /etc/fw.sh",
      "/etc/fw.sh"
    ]

    connection {
      type = "ssh"
      user = "root"
      host = "${cherryservers_server.web1.primary_ip}"
      private_key = "${file(var.private_key)}"
      timeout = "20m"
    }
}

}

resource "cherryservers_server" "web2" {
  project_id = "${cherryservers_project.projektas.id}"
  region = "${var.region}"
  hostname = "Web2"
  image = "${var.image}"
  plan_id = "${var.plan_id}"
  ssh_keys_ids = [
    "${cherryservers_ssh.mykey.id}"]
  ip_addresses_ids = [
    "${cherryservers_ip.floating-ip-worker2.id}"]

  provisioner "remote-exec" {
    inline = [
      "apt-get update -y",
      "apt-get install apache2 -y",
      "service apache2 start",
      "cat > /var/www/html/index.html <<EOL",
      "${cherryservers_ip.floating-ip-worker2.address}",
      "EOL"
    ]

    connection {
      type = "ssh"
      user = "root"
      host = "${cherryservers_server.web2.primary_ip}"
      private_key = "${file(var.private_key)}"
      timeout = "20m"
    }
}
  provisioner "remote-exec" {
    inline = [
      "until ping -c1 ${cherryservers_ip.floating-ip-worker2.address} >/dev/null 2>&1; do :; done",
      "cat > /etc/fw.sh <<EOL",
      "${data.template_file.fwsh.rendered}",
      "EOL",
      "chmod +x /etc/fw.sh",
      "/etc/fw.sh"
    ]

    connection {
      type = "ssh"
      user = "root"
      host = "${cherryservers_server.web2.primary_ip}"
      private_key = "${file(var.private_key)}"
      timeout = "20m"
    }
}
}
