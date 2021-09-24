data "aws_route53_zone" "root" {
  name = var.domain
}

resource "aws_route53_record" "master" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${aws_instance.master.tags.dns_name}.${var.namespace}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.master.public_dns]
}

resource "aws_route53_record" "worker" {
  count   = length(aws_instance.worker)
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${aws_instance.worker[count.index].tags.dns_name}.${var.namespace}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.worker[count.index].public_dns]
}

resource "aws_route53_record" "cluster" {
  count   = length(aws_instance.worker)
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "cluster.${var.namespace}"
  type    = "CNAME"
  ttl     = "60"
  weighted_routing_policy {
    weight = 10
  }
  set_identifier = aws_instance.worker[count.index].id
  records        = [aws_instance.worker[count.index].public_dns]
}
