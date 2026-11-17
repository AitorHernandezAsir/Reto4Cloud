output "manager_info" {
  description = "Datos de conexion del nodo Manager"
  value = {
    id         = aws_instance.manager.id
    ip_publica = aws_instance.manager.public_ip
    ip_privada = aws_instance.manager.private_ip
  }
}

output "workers_info" {
  description = "Datos de conexion de los nodos Workers"
  value = [
    for w in aws_instance.worker : {
      id         = w.id
      ip_publica = w.public_ip
      ip_privada = w.private_ip
      tag_name   = w.tags["Name"]
    }
  ]
}