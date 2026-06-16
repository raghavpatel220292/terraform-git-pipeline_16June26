resource "azurerm_resource_group" "rgs" {
  name     = "test-rg88"
  location = "centralindia"
}


resource "azurerm_storage_account" "stg" {
  name                     = "storageaccount8800"
  resource_group_name      = azurerm_resource_group.rgs.name
  location                 = azurerm_resource_group.rgs.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "vnets" {

  name                = "vnet99"
  location            = azurerm_resource_group.rgs.location
  resource_group_name = azurerm_resource_group.rgs.name
  address_space       = ["10.111.0.0/16"]
}

resource "azurerm_subnet" "subnets" {

  name                 = "subnet99"
  resource_group_name  = azurerm_resource_group.rgs.name
  virtual_network_name = azurerm_virtual_network.vnets.name
  address_prefixes     = ["10.111.1.0/25"]

}

resource "azurerm_public_ip" "pip" {
  name                = "pip999"
  location            = azurerm_resource_group.rgs.location
  resource_group_name = azurerm_resource_group.rgs.name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "nics" {

  name                = "nic999"
  location            = azurerm_resource_group.rgs.location
  resource_group_name = azurerm_resource_group.rgs.name

  ip_configuration {
    name                          = "nicconfig"
    subnet_id                     = azurerm_subnet.subnets.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg99"
  location            = azurerm_resource_group.rgs.location
  resource_group_name = azurerm_resource_group.rgs.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "nsg_attach" {
 
  network_interface_id      = azurerm_network_interface.nics.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_windows_virtual_machine" "VM" {
  name                = "Windows-VM"
  resource_group_name = azurerm_resource_group.rgs.name
  location            = azurerm_resource_group.rgs.location
  size                = "Standard_B2as_v2"
  admin_username      = "adminuser"
  admin_password      = "Password@1234"
  network_interface_ids = [azurerm_network_interface.nics.id]   //this argument take values in the form list/set of ids that why it in [] brackets, we also pass only 1 nic id but in [] bracket only 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}