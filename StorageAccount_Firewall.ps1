$azure_ip_ranges_file_download = "https://www.microsoft.com/en-us/download/details.aspx?id=56519"
$serviceTags = Get-AzNetworkServiceTag -Location "eastasia"

#Get all public range IP of serviceTage named AzureFrontDoor.Backend which used as Azure CDN backend
$CDN_backend_service = $serviceTags.Values | Where-Object { $_.Name -eq "AzureFrontDoor.Backend" }
$CDN_backend_service_iprange=$CDN_backend_service.Properties.AddressPrefixes

#Get ll range IP current settings on firewall of storage account
$current_firewall=(Get-AzStorageAccountNetworkRuleSet -ResourceGroupName "mylab" -AccountName "storageacc996").IPRules
$value = "Allow"
$current_rule = @()
foreach ($a_rule in $current_firewall)
{
	 $current_rule += $a_rule.IPAddressOrRange
}

$checked_rules = @()
foreach ($a_rangeip in $CDN_backend_service_iprange)
{
	if ($a_rangeip.Contains(":"))
		{ 
  
		}
	else
		{
			$checked_rules += $a_rangeip
		}
}


# Compare and filtering to create new list of range IP of backend CDN used need update to storage account
$new_add_rules = @()
$checked_rules| ForEach-Object {
    if ($_ -in $current_rule) {
       
    }
	else{
		$new_add_rules += $_
	}
}

Write-Output $new_add_rules

#Add new range IP to firewall setting of storage account

foreach ($a_newrule in $new_add_rules)
{
		Add-AzStorageAccountNetworkRule -ResourceGroupName "mylab" -AccountName "storageacc996 " -IPAddressOrRange $a_newrule
}