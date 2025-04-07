data "aws_route53_zone" "root" {
  name = var.domain
}

resource "aws_route53_record" "controller" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${aws_instance.controller.tags.dns_name}.${var.subdomain}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.controller.public_dns]
}

resource "aws_route53_record" "worker" {
  count   = length(aws_instance.worker)
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${aws_instance.worker[count.index].tags.dns_name}.${var.subdomain}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.worker[count.index].public_dns]
}

resource "aws_route53_record" "proxy" {
  count   = strcontains(var.features, "proxy") ? 1 : 0
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${aws_instance.proxy[count.index].tags.dns_name}.${var.subdomain}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.proxy[count.index].public_dns]
}

resource "aws_route53_record" "kali" {
  count   = strcontains(var.features, "kali") ? 1 : 0
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${aws_instance.kali[count.index].tags.dns_name}.${var.subdomain}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.kali[count.index].public_dns]
}

resource "aws_route53_record" "cluster" {
  count   = length(aws_instance.worker)
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "*.${var.subdomain}"
  type    = "CNAME"
  ttl     = "60"
  weighted_routing_policy {
    weight = 10
  }
  set_identifier = aws_instance.worker[count.index].id
  records        = [aws_instance.worker[count.index].public_dns]
}
