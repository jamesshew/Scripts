<#
.SYNOPSIS 

.DESCRIPTION
This script will allow you to automatically add one or more content packs to Log Insight
The content packs must be unzipped and placed into a folder which is then specified in
the ContentPackLocation variable.

Once all content packs in the chosen folder have been uploaded, this script will restart
the LogInsight service to recognize all of the newly added Content packs.

.NOTES

   Author: Brian Graf
   Role: Technical Marketing Engineer - Automation
   Company: VMware
   Created: 07-29-2014
   E-mail: grafb@vmware.com
   Twitter: @vTagion
   Website: www.vTagion.com
#>

### Variable Configuration ###
$vmname = "<Log Insight VM>"
$LIPassword = "<Log Insight Root Password>"
$ContentPackLocation = "<directory of content packs>"
##############################

# Add Content Packs if applicable
		if (Test-Path $ContentPackLocation)
		{
			if (Get-ChildItem $ContentPackLocation -Filter "*.vlcp")
			{
				$CPs = get-childitem $contentPackLocation -Filter "*.vlcp"
				$i = 1
				foreach ($CP in $CPs)
				{	Write-Host "[INFO] $($CP.name) found, importing into Log Insight"
					Copy-VMGuestFile -VM $vmname -Source ($CP.Fullname) -Destination /usr/lib/loginsight/application/etc/
					content-packs/CP$i/content.json -LocalToGuest -GuestUser root -GuestPassword "$LIPassword" -force
					$i++
					Write-Host "[INFO] $($CP.name) has be imported into Log Insight" -ForegroundColor Green 
				}
				Write-Host "[INFO] Restarting Log Insight service to refresh content packs in UI"
				$script = "/etc/init.d/loginsight restart"
				Invoke-VMScript -VM $vmname -GU root -GP "$LIPassword" -ScriptText $script -ScriptType bash
				Write-Host"[INFO] Log Insight service has been restarted"
			}
		}
		
