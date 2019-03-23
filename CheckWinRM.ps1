# ################################################################################################ #
# Copyright (c) 2019 MetaStack Solutions Ltd. See distribution terms at the end of this file.      #
# David Allsopp. 3-Feb-2019                                                                        #
# ################################################################################################ #

param([string]$Hostname = [System.Net.Dns]::GetHostName())

$server_authentication = '1.3.6.1.5.5.7.3.1'
$winrm = 'winrm/config/listener'

$thumb = (Get-ChildItem Cert:\LocalMachine\My).where({-Not $_.Archived -And $_.DnsNameList -Like $Hostname -And $_.EnhancedKeyUsageList.Where{$_.ObjectId -Eq $server_authentication} -And $_.Subject -Ne $_.Issuer}) | Sort NotAfter -Descending | Select-Object -ExpandProperty Thumbprint -First 1

Write-Host "It should be $thumb"
$changed = $false
Get-WSManInstance -ResourceURI $winrm -Enumerate | Where-Object {$_.Transport -Eq 'HTTPS' -And $_.Hostname -Eq $Hostname -And $_.CertificateThumbprint -Ne $thumb} | ForEach-Object {Write-Host "Updated thumbprint for HTTP connector $($_.Address) from $($_.CertificateThumbprint) to $thumb"; $changed = $true; Set-WSManInstance -ResourceURI $winrm -SelectorSet @{Address=$_.Address; Transport='HTTPS'} -ValueSet @{CertificateThumbprint=$thumb} | Out-Null}

if ($changed) {
  Restart-Service WinRM -Force -ErrorAction Stop
  Write-Host "Restarted WinRM"
}

# ################################################################################################ #
# Redistribution and use in source and binary forms, with or without modification, are permitted   #
# provided that the following conditions are met:                                                  #
#     1. Redistributions of source code must retain the above copyright notice, this list of       #
#        conditions and the following disclaimer.                                                  #
#     2. Redistributions in binary form must reproduce the above copyright notice, this list of    #
#        conditions and the following disclaimer in the documentation and/or other materials       #
#        provided with the distribution.                                                           #
#     3. Neither the name of MetaStack Solutions Ltd. nor the names of its contributors may be     #
#        used to endorse or promote products derived from this software without specific prior     #
#        written permission.                                                                       #
#                                                                                                  #
# This software is provided by the Copyright Holder 'as is' and any express or implied warranties, #
# including, but not limited to, the implied warranties of merchantability and fitness for a       #
# particular purpose are disclaimed. In no event shall the Copyright Holder be liable for any      #
# direct, indirect, incidental, special, exemplary, or consequential damages (including, but not   #
# limited to, procurement of substitute goods or services; loss of use, data, or profits; or       #
# business interruption) however caused and on any theory of liability, whether in contract,       #
# strict liability, or tort (including negligence or otherwise) arising in any way out of the use  #
# of this software, even if advised of the possibility of such damage.                             #
# ################################################################################################ #