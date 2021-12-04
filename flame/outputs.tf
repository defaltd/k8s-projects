output "admin_password" {
  description = "the admin password"
  sensitive = true
  value = random_password.admin_password.result
}