locals {
  IMAGE         = "pawelmalak/flame:2.1.0"
  NAMESPACE     = data.kubernetes_namespace.flame.metadata[0].name
  NODE_AFFINITY = "nexus1"
  VOLUME_SIZE   = "5Gi"
}

data "kubernetes_namespace" "flame" {
  metadata {
    name = "flame"
  }
}

resource "kubernetes_persistent_volume" "app" {
  metadata {
    name = "flame-app-volume"
  }

  spec {
    access_modes = [ "ReadWriteOnce" ]
    volume_mode = "Filesystem"
    storage_class_name = "local-path"
    persistent_volume_reclaim_policy = "Retain"

    capacity = {
      "storage" = local.VOLUME_SIZE
    }

    persistent_volume_source {
      host_path {
        path = "/var/lib/rancher/k3s/storage/pvc-flame-app"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "app" {
  metadata {
    namespace = local.NAMESPACE
    name = "flame-app-pvc-claim"
  }

  spec {
    access_modes = [ "ReadWriteOnce" ]
    volume_name = kubernetes_persistent_volume.app.metadata[0].name

    resources {
      requests = {
        storage = local.VOLUME_SIZE
      }

      limits = {
        storage = local.VOLUME_SIZE
      }
    }
  }

  wait_until_bound = true
}

resource "kubernetes_service_account" "app" {
  metadata {
    namespace = local.NAMESPACE
    name = "flame-svc-account"
  }
}

resource "kubernetes_service" "flame-svc" {
  metadata {
    namespace = local.NAMESPACE
    name = "flame-svc"
  }

  spec {
    selector = {
      "app" = "flame"
    }

    type = "LoadBalancer"

    port {
      name = "app"
      port = 8001
      target_port = 5005
    }
  }

  wait_for_load_balancer = true
}

resource "kubernetes_ingress_v1" "flame_ingress" {
  metadata {
    namespace = local.NAMESPACE
    name = "flame-ingress"

    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-gcp-homelab"
    }
  }

  wait_for_load_balancer = true

  spec {
    tls {
      hosts = [ "strodrig.dev" ]
      secret_name = "flame-ingress-cert-secret"
    }

    default_backend {
      service {
        name = kubernetes_service.flame-svc.metadata[0].name
        port {
          number = 8001
        }
      }
    }

    rule {
      host = "strodrig.dev"
      http {
        path {
          path = "/"

          backend {
            service {
              name = kubernetes_service.flame-svc.metadata[0].name
              port {
                number = 8001
              }
            }
          }
        }
      }
    }
  }
}

resource "random_password" "admin_password" {
  length = 56
  special = false
}

resource "kubernetes_secret" "app" {
  metadata {
    namespace = local.NAMESPACE
    name = "flame-secrets"
  }

  data = {
    "PASSWORD" = random_password.admin_password.result
  }
}

resource "kubernetes_stateful_set" "flame" {
  metadata {
    namespace = local.NAMESPACE
    name = "flame"
  }

  wait_for_rollout = true

  spec {
    pod_management_policy = "OrderedReady"
    replicas = 1
    revision_history_limit = 5
    service_name = "flame-svc"

    selector {
      match_labels = {
        "app" = "flame"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "flame"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.app.metadata[0].name

        container {
          name = "flame"
          image = local.IMAGE
          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              cpu = "0.2"
              memory = "128Mi"
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.app.metadata[0].name
            }
          }

          port {
            name = "app"
            protocol = "TCP"
            container_port = 5005
          }

          volume_mount {
            name = "app-data"
            mount_path = "/app/data"
          }
        }

        volume {
          name = "app-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.app.metadata[0].name
          }
        }
      }
    }
  }
}
