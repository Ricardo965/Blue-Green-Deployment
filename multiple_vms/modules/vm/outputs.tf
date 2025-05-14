output "ip_servers" {
  description = "Lista de nombres e IPs públicas de las máquinas creadas"
  value = [
    for key, vm in azurerm_linux_virtual_machine.vm_devops :
    {
      name = vm.name
      ip   = azurerm_public_ip.devops_ip[key].ip_address
    }
  ]
}
