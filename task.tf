provider "aws" {
  region  = "ap-south-1"
  profile = "vibhav1"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "aws_db_instance" "wordpressDB" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.30"
  instance_class       = "db.t2.micro"
  name                 = "rdsDB"
  username             = "wordpressDB"
  password             = "redhat123"
  port                 = 3306
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = true
  skip_final_snapshot = true
}



resource "kubernetes_service" "service" {
  metadata {
    name = "wordpress"
  }
  spec {
    selector = {
      app = "frontend"
    }
    session_affinity = "ClientIP"
    port {
      port  = 80
      target_port = 80
      node_port = 31124
    }
    type = "NodePort"
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "wordpress"
    labels = {
      app = "frontend"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          name  = "wordpressapp"
          image = "wordpress"  
        }
      }
    }
  }
}