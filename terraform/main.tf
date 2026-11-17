terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Región obligatoria en Learner Lab
}

# --- 1. SECURITY GROUP ÚNICO ---
resource "aws_security_group" "reto4_cluster_sg" {
  name        = "reto4-cloud-cluster-${var.grupo}"
  description = "Security group para manager y workers del reto F1"

  # Puertos de entrada desde Internet / Aula
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # (O acotado a tu IP o red de aula)
  }

  ingress {
    description = "Web HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Web Alternativa 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- Puertos internos obligatorios para Docker Swarm ---
  ingress {
    description = "Swarm Management"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    self        = true # Permite tráfico entre nodos del mismo SG
  }

  ingress {
    description = "Container Network Discovery TCP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Container Network Discovery UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Overlay Network Traffic"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "ICMP Ping entre nodos"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    self        = true
  }

  # Tráfico de salida libre hacia Internet (necesario para descargar paquetes)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "reto4-cloud-${var.grupo}"
  }

  # Evitar bloqueos al cambiar de nombre
  lifecycle {
    create_before_destroy = true
  }
}

# --- CLAVES DE ACCESO SSH ---
resource "aws_key_pair" "clave_aitor" {
  key_name   ="key-aitor-g2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCMFzHpLkZsSfi3KpfJ2+iGWaEUfKiQivC0tR/6gibtfgz/TENRvh5OjUV27PShZXEcRngJubTh9GAONCe0mFxw9VTPgFqLvykVuYeDLCaKSJOGsCw5058H4E7Uq3n3JMxbebzrY6novDQlb7yf0KYsgnCplCukaJvpxRACURS/4M7sREyQEIkmrudOtNGVlpF5euuJl1UckQVVZmk/lLo2yF7KkvCLDZ+zoTHmh9rJvgRGYFw8N77dWi0fGyAjMBzwLTlBSfph30hd8YVciJD15aOX4KAHXAxh6+rtEAVYMnAC+mKO+vpj2fzLUeGiOnoGNv+Qrx2Y7aDA/bzERixoN80LKVuKl5i5sMU2KqvlGjFTjuTY2Di12vmzOkJ4WKqNIlRD5mGia9SBIPSs97iTf9Xl/4m08WEfdGFowvvUG4YQJrcjvBx0U2bjvyABIZRh9YJrPVHH01ly3/ABmpvGRVbMwdXYCX+QFUYuzE4jdAdkmj389dOK2+TnDD5pwBPx1eg00yey7Pv1Bmv3B3KM8nK02Z/1xu/Oy4R2h0xDFIyMdEyLLzeVBo4623Jwfln3UthkUDfQmcha6H8iXdxlyz8ij985RVdcEDHUynQFKvM1lIcdl9cw/U8PgSy+l+EELJOJLEiXYuqw8jfaRLMHqWWhaTl1qIEPSeq7z5ccLw== vscode@codespaces-b296ce"
}

resource "aws_key_pair" "clave_antonio" {
  key_name   ="key-antonio-g2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCtGI74WvcfahILV78XtFRkQDiC9zUKJ/gN6efPY+T2z02boJh23fUjSCt2OUxSmHXbh1vMLLTx+e5A8CsbQVD6+ZDVwTFDIASd4bAvqQw9XGwXfwT7GQXJA72bqU7JeC1B+2s4pFKneEXJdaT41XF+u3OF95zDdn7Triy1vsNho9xbDzwsKPJkhOXOXFArKjch8B5fmE8rGQgJb8axJtUGZjyviNiGTQxdTG7U1cpHcqWuHb5YYPFxu5ZNs92di94TXf5q76oR7UEXlRTWVlHH1D2aTcOsIDivC6wWVDU8iXmDt/4uLE0izESXlBI6ABScfjAeKInT/PiflxRUZN6jATMMxGUcF5hGFpjgy9IWYWkUai1UUaNQFel2VG9K2T9JsTneO+krSkKUclechrc9BtC0/PVLf+9/7aJUagT3IoybcA4enyGvQZK3jLQTLd51R4Mj+jpYT+UiYKa2caJrGXws5bQS8EU3tvY+U+Y2OYRZCgka5vaK1RbzGK90x+yFwL+r6a6eymRednQgYClY8BMptgWm9URSBUCiJxGfw83RdO+M/1D+cx+ni9JsK93BWXD+oAD0KH9KRJtpPfJoQ/+UFs9M+lcVKmMbJY/tDIdDPfUOP+iRglftnQfnawiTTP+yB8dlNkKSfkU1vsImiJycgAS8dfE7DrdxmZEZUw== vscode@codespaces-b296ce"
}

resource "aws_key_pair" "clave_gari" {
  key_name   ="key-gari-g2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcXLLbQk096NZ3ODYZwvGiX7NUTkvQkYSpQ4YXA7yQRa7oXOHb/lMe0EaxGt8CbbbunHQd2laMqCgR8lzndDIzY4grXcnphDr+Xw/yRAYEKtdBjc0z+fbwbUPX3wvxq2OFOh2L0xDdKVzhkZZ9sth51QIA/aG0E7ZcTcaeabzDuGz4SjfiOjz8Xvlmdfx7JTluhVPa+bsp6sPcpE/IkDu0RjbKJxWZZuM2Wx2seqQPyKeOdHmcZ02PIx10A9zJgdxK+wZWN8anS0nHJjfLLbrItXZFxyV7MyIlcdO9izzMc4OJNkL7RZkweXv9et5pAdlcLqWacK0zCBMH09nglhoJFmh9sgYDrhC7YHGLlcv/7kSm+fL2r4VwsrFC1Y145xCvEDV6hn42CItXiIUFVwuu4yXu1ebkWLGaCjT/+pj9s4KYbIajXUXToHJTNbjleFOEIo1HIS7iskD7qAEOjp9Nb/mJMtqnrTw6sxGQvV6olzNn/pG74U8GjTEhsv8t4SrsoMVZ0noKoNlPq7injELo8PpQhPCKulxtHWQgb/82QZTOlHJEcpx/WhXwy9nwB2P4SC44NBYkgNyFriG+vKfBsJ1gZjSqkKKTZQ8TVeVFamwOqmL7Mz2JXlaNJ2sLuk/x197NJ+IUGsyF2PMEb07xptQjt7gN1xDA3AYjY7EW+Q== vscode@codespaces-b296ce"
}

resource "aws_key_pair" "clave_endika" {
  key_name   ="key-endika-g2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6p8gDlf6kFQBlRA5rXlwWOE7sXV3QfKnyd5oyznraeOzHnDKMOb3CWtbe3HkE20qdm3y/jzr/qoHgUhVmaPJzvM0k4FfMukV41Teyb4nyRPLhV5PqRdzChIeHDQ9LLHl48sRX6jUqFINcfo44EQ5/sQy72PjB6RaV6G0ZXO2hVxQeHFkB+5Q3SVUHPG9b8QwmbiJisphbqt2Q6BZ8Dlesy1Cnm+NH9c05Yv8sQxSaaDwl01oNYMbUrF4GIbSFd8YQZs41tl7cyq0PSFckSmQOAGo2dmG9yHE38tFKEUn0wKIhsObXJp6uLn4bKVUX5re/JZBo46TRhKXzP/dNBq1DAk33p1q/TqqzXeYSFYEF6BBG6f9pprLRg+RUF2UsViuaQfK4rdNNCnSCIdHzHwZbN+tlDEwdBnykYR8W+Me8suvQ2Rcm47hrSEvS5kTzWCtQ9Lu06CmG64VBM7K+JWcE1iwtQ1g8IG4P2Co4jNnYSYv33eTBuR+kf8slHLdZkLbaUo9FhkYBFF3MgVZ/mCXM+Ci9qH7L5ue3kNyVyUqX7o2zuqfRrTsqQVFdHRTM473dRdTE1E7GMLKT42kVY3FSW8o8sBaEdHgmYGf6++1KqcJ6riD8l2F+FEboLybB6X4G9KmEggVtIa7jRshyewsCjhiGVsvOjbJBOtzd65oZPQ== vscode@codespaces-b296ce"
}

resource "aws_key_pair" "clave_serrato" {
  key_name   ="key-serrato-g2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCUN3OjD1cjzfBxRGYegIEh2CCeULDI4Oans2vSNKZasH3CHZvTe7hjvsL+YHxpMNiBVFHAAMH5D2UBH2NN7f04ry+cYtOngx9hdWKuIpBtXu/JQ5bSduEK+aklQC/eA3ZZmIZTcTUJORCBPKhsMXLM33tDWD3XVj3/e0rgjbA2r/k/yThETDbpkj+Qbfnbqa02ppSrx4cTYoUBybU/rNH8hJYz6DIjmWts6HjJ2VtnPjVHPsBS3RSakVIaEPVcw9gaxCR6/0hBnE6le8yEoISNOt4Ndax6WHMZxo+w3Vk2JlBYScr2t2q4Pn+tJnYvrkEXD7JFjUHjGxAgbNgwpvT2JGFDMUTGGK3J46AeVhAJ6BUuMo1jlSnLYbGh0pKK+cDipPMAF5mktoQiaEay+kbOf9lVdfLvWYVDI8eiZaEiy7Vc0MZlGs5OikRcOm47X/fhGBsSJsgoAJvTHE8wpbsFdI7q7tBSvna5oI9ywqvO32DH2n/Nqmssvt/WHj6MVkAJ6lwQ//YN4IRV6smJ9ILmBpUxv8DFRirxUbJljWG5lu8qfw3b5e9LxNwGF6XI5qtxbSsQiKiKkGbzkI6nlhnb4O//u0ck/rLBAlMU/6h2QAd4V9wxyaeSdqD1CIqeh9bxNgUS7PlEBHTkLsSy7jNGwtB4SyAP5Uxpcb+AZ5Hm0w== vscode@codespaces-b296ce"
}

# --- 2. NODO MANAGER ---
resource "aws_instance" "manager" {
  ami           = var.ami_id
  instance_type = var.tipo_manager
  key_name      = "vockey" # Clave por defecto de AWS Academy Learner Lab
  vpc_security_group_ids = [aws_security_group.reto4_cluster_sg.id]

  root_block_device {
    volume_size = 20 # 20 GB exigidos para el manager[cite: 1]
    volume_type = "gp2"
  }

  # Pasa el nombre de host al script de arranque
  user_data = templatefile("${path.module}/user_data.sh", {
    hostname = "manager-${var.grupo}"
  })

  tags = {
    Name = "manager-${var.grupo}"
    Rol  = "Manager"
  }
}

# --- NODOS WORKERS (Usando count = 3 para asignar su nombre exacto) ---
resource "aws_instance" "worker" {
  count         = 3 
  ami           = var.ami_id
  instance_type = var.tipo_worker
  key_name      = "vockey"
  vpc_security_group_ids = [aws_security_group.reto4_cluster_sg.id]

  root_block_device {
    volume_size = 10 
    volume_type = "gp2"
  }

  # Asigna el hostname exacto: worker1-gX, worker2-gX, worker3-gX (sustituyendo gX por tu variable de grupo)
  user_data = templatefile("${path.module}/user_data.sh", {
    hostname = "worker${count.index + 1}-${var.grupo}"
  })

  tags = {
    Name = "worker${count.index + 1}-${var.grupo}"
    Rol  = "Worker"
  }
}