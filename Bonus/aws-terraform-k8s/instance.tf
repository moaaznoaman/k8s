resource "aws_instance" "k8s_master" {
  ami           = var.AMIS-K8S-MASTER[var.AWS_REGION]
  instance_type = "t2.medium"
  # count = 1
  # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-connection.id]

  # the public SSH key
  key_name = aws_key_pair.mykey.key_name
  # associate public ip address
  associate_public_ip_address = true
  # temporay change ssh port number
//  user_data = "${file("scripts/changessh.sh")}"

  provisioner "local-exec" {
    command = "echo ${aws_instance.k8s_master.private_ip} kmaster.example.com kmaster > files/hosts"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_dns} > files/dns.txt"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_dns} > files/masternode_hostname.txt"
  }

  tags = {
    #  Name = "k8s_master${count.index}"
    Name = "k8s_master"
  }
}

resource "aws_instance" "k8s_worker_zoneA" {
  depends_on = ["aws_instance.k8s_master"]
  ami           = var.AMIS-K8S-WORKER[var.AWS_REGION]
  instance_type = "t2.micro"
  count = var.k8s_worker_count

  # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-connection.id]

  # the public SSH key
  key_name = aws_key_pair.mykey.key_name

  associate_public_ip_address = true
  # temporay change ssh port number
//  user_data = "${file("scripts/changessh.sh")}"

  provisioner "local-exec" {
        command = "echo ${self.private_ip} kworker-a-${count.index + 1 }.example.com kworker-a-${count.index + 1 } >> files/hosts"
    //    command = "echo ${aws_instance.k8s_worker.private_ip} kworker${count.index}.example.com kworker${count.index} >> files/hosts"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_dns} >> files/dns.txt"
  }

  tags = {
//    Name = "k8s_worker"
      Name = "k8s_worker_a_${count.index + 1 }"
  }
}


resource "aws_instance" "k8s_worker_zoneB" {
  depends_on = ["aws_instance.k8s_master"]
  ami           = var.AMIS-K8S-WORKER[var.AWS_REGION]
  instance_type = "t2.micro"
  count = var.k8s_worker_count

  # the VPC subnet
  subnet_id = aws_subnet.main-public-2.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-connection.id]

  # the public SSH key
  key_name = aws_key_pair.mykey.key_name

  associate_public_ip_address = true
  # temporay change ssh port number
//  user_data = "${file("scripts/changessh.sh")}"

  provisioner "local-exec" {
        command = "echo ${self.private_ip} kworker-b-${count.index + 1 }.example.com kworker-b-${count.index + 1 } >> files/hosts"
    //    command = "echo ${aws_instance.k8s_worker.private_ip} kworker${count.index}.example.com kworker${count.index} >> files/hosts"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_dns} >> files/dns.txt"
  }

  tags = {
//    Name = "k8s_worker"
      Name = "k8s_worker_b_${count.index + 1 }"
  }
}

resource "null_resource" "executer_master" {
  triggers = {
    public_ip = aws_instance.k8s_master.public_ip
  }

  connection {
    type = "ssh"
    host = aws_instance.k8s_master.public_ip
    user = var.ssh_user
    port = var.ssh_port
 #   agent = true
    private_key = "${file("mykey")}"
  }

  provisioner "file" {
    source = "files/hosts"
    destination = "/tmp/hosts"
  }

  // copy our example script to the server
  provisioner "file" {
    source = "scripts/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  // copy our example script to the server
  provisioner "file" {
    source = "scripts/bootstrap_kmaster.sh"
    destination = "/tmp/bootstrap_kmaster.sh"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh /tmp/bootstrap_kmaster.sh",
      "sudo sh /tmp/bootstrap.sh master",
      "sudo sh /tmp/bootstrap_kmaster.sh ${aws_instance.k8s_master.private_ip} ${aws_subnet.main-public-1.cidr_block}",
    ]
  }

  //  provisioner "local-exec" {
  //    # copy the public-ip file back to CWD, which will be tested
  //    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${aws_instance.example_public.public_ip}:/tmp/public-ip public-ip"
  //  }

}

resource "null_resource" "executer_workerA" {
  depends_on = ["null_resource.executer_master"]
  count = "${length(aws_instance.k8s_worker_zoneA.*.id)}"
//  triggers = {
//    public_ip = "${element(aws_instance.k8s_worker.*.public_ip, count.index)}"
//  }

  connection {
    type = "ssh"
    host = "${element(aws_instance.k8s_worker_zoneA.*.public_ip, count.index)}"
    user = var.ssh_user
    port = var.ssh_port
  #  agent = true
    private_key = "${file("mykey")}"
  }

  provisioner "file" {
    source = "files/hosts"
    destination = "/tmp/hosts"
  }

  // copy our example script to the server
  provisioner "file" {
    source = "scripts/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  // copy our example script to the server
  provisioner "file" {
    source = "scripts/bootstrap_kworker.sh"
    destination = "/tmp/bootstrap_kworker.sh"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh /tmp/bootstrap_kworker.sh",
      "sudo sh /tmp/bootstrap.sh worker a ${count.index + 1 }",
      "sudo sh /tmp/bootstrap_kworker.sh",
    ]
  }

  //  provisioner "local-exec" {
  //    # copy the public-ip file back to CWD, which will be tested
  //    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${aws_instance.example_public.public_ip}:/tmp/public-ip public-ip"
  //  }

}

resource "null_resource" "executer_workerB" {
  depends_on = ["null_resource.executer_master"]
  count = "${length(aws_instance.k8s_worker_zoneB.*.id)}"
//  triggers = {
//    public_ip = "${element(aws_instance.k8s_worker.*.public_ip, count.index)}"
//  }

  connection {
    type = "ssh"
    host = "${element(aws_instance.k8s_worker_zoneB.*.public_ip, count.index)}"
    user = var.ssh_user
    port = var.ssh_port
  #  agent = true
    private_key = "${file("mykey")}"
  }

  provisioner "file" {
    source = "files/hosts"
    destination = "/tmp/hosts"
  }

  // copy our example script to the server
  provisioner "file" {
    source = "scripts/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  // copy our example script to the server
  provisioner "file" {
    source = "scripts/bootstrap_kworker.sh"
    destination = "/tmp/bootstrap_kworker.sh"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh /tmp/bootstrap_kworker.sh",
      "sudo sh /tmp/bootstrap.sh worker b ${count.index + 1 }",
      "sudo sh /tmp/bootstrap_kworker.sh",
    ]
  }

  //  provisioner "local-exec" {
  //    # copy the public-ip file back to CWD, which will be tested
  //    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${aws_instance.example_public.public_ip}:/tmp/public-ip public-ip"
  //  }

}