variable "kubeconfig" {
  description = "the path to kubeconfig"
  default     = "~/.kube/config-digit"
  type        = string
}

variable "kube_context" {
  description = "the kubeconfig context to use"
  default     = "homelab"
  type        = string
}