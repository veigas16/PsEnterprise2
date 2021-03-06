#[reflection.assembly]::LoadWithPartialName('CrystalDecisions.Enterprise.Framework') | Out-Null
#[reflection.assembly]::LoadWithPartialName('CrystalDecisions.Enterprise.InfoStore') | Out-Null
#[reflection.assembly]::LoadWithPartialName('CrystalDecisions.CrystalReports.Engine') | Out-Null

function Get-Session {

	[cmdletbinding()]
	param (	
		[parameter(Mandatory = $true)][Alias("svr")][string]$server,		
        [parameter(Mandatory = $true)][Alias("acct")][string]$account,
        [parameter()][Alias("pwd")][string]$password,
		[parameter()][Alias("auth")][ValidateSet("secEnterprise","secWinAD","secLDAP")]
        [string]$authentication="secEnterprise"
    )

	begin {Write-Verbose "$($MyInvocation.MyCommand.Name)::Begin"}
	
	process {
	
		try {

			$sessionMgr = New-Object CrystalDecisions.Enterprise.SessionMgr
		    $Global:enterpriseSession = $sessionMgr.Logon($account, $password, $server, $authentication)
		    
			Write-Verbose $global:enterpriseSession.LogonTokenMgr.DefaultToken
			
		    return $Global:enterpriseSession
		}
        catch {
            write-host $_.Exception
        }

    }
	
	end {Write-Verbose "$($MyInvocation.MyCommand.Name)::End"}

	<#
    .SYNOPSIS
        Authenticate; create session object
        
    .DESCRIPTION
    .NOTES
    .LINK
    .EXAMPLE
		Get-Session -svr "CMShost:6400" -acct "account" -pwd "password" | Out-Null

	.EXAMPLE
		Get-Session -svr "CMShost:6400" -acct "account" -pwd "password" -auth "secLDAP" | Out-Null

    .INPUTTYPE
    .RETURNVALUE
    .COMPONENT
    .ROLE
    .FUNCTIONALITY
    .PARAMETER
    #>

}

function Get-LogonToken {

	[cmdletbinding()]
    param ()
	
	begin {Write-Verbose "$($MyInvocation.MyCommand.Name)::Begin"}
	
    process {
		return $global:session.LogonTokenMgr.DefaultToken
    }
	
    end {Write-Verbose "$($MyInvocation.MyCommand.Name)::End"}
}

<#
function publish {

    param (
        [Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)][CrystalDecisions.Enterprise.EnterpriseSession]$enterpriseSession,
        [string]$src,
        [string]$dest
    )
    process {
            
        # get the plugin mgr and get the report plugin
		$pluginMgr = $infoStore.getPluginMgr
		$reportPlugin = $pluginMgr.getPluginInfo("CrystalEnterprise.Report")
              
        $infoObjects = $infoStore.NewInfoObjectCollection
        $infoObjects.add($reportPlugin)
        
        $reportObject = (IInfoObject)$reportPlugin
        
        # get parent folder

	    # refresh the properties
		boReport = (IReport)boReportObject;
	       boReport.refreshProperties();
                    
        # commit the new report
	   $infoStore.commit($infoObjects)
       
    }
    
}
#>
<#
function get-folder {

    param (
        #[Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)][CrystalDecisions.Enterprise.EnterpriseSession]$enterpriseSession,
        [Parameter(Mandatory=$true)][int]$id
    )
    process {
    
        $cmd = prepare-cmd -cmd "SELECT SI_ID, SI_CUID, SI_NAME, SI_PATH, SI_PARENTID, SI_PARENT_FOLDER, SI_PARENT_FOLDER_CUID FROM CI_INFOOBJECTS" -where ('SI_ID=' + $id) -sort ('SI_NAME ASC')
        
        return $cmd
    }

}
#>
<#
function prepare-cmd {
    param (
        [string]$cmd,
        [string[]]$where,
        [string[]]$sort
    )
    process {

        if ($where) { $cmd += " WHERE " + ($where -join ' AND ') }
        if ($sort) { $cmd += " ORDER BY " + ($sort -join ', ') }        
        return $cmd
    }
}
#>

function Get-InfoObjects {

    param (
        #[Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)][CrystalDecisions.Enterprise.EnterpriseSession]$enterpriseSession,
        [string]$cmd
    )
	begin {Write-Verbose "$($MyInvocation.MyCommand.Name)::Begin"}
    process {
        Write-Verbose $cmd
		
        $infoStore = [CrystalDecisions.Enterprise.InfoStore]$Global:enterpriseSession.GetService("","InfoStore")  
        $infoObjects = $infoStore.Query($cmd)
                
        Return $infoObjects 
    }
	end {Write-Verbose "$($MyInvocation.MyCommand.Name)::End"}

    <#
    .SYNOPSIS
        Query the repository
        
    .DESCRIPTION
    .NOTES
    .LINK
    .EXAMPLE
    .INPUTTYPE
    .RETURNVALUE
    .COMPONENT
    .ROLE
    .FUNCTIONALITY
    .PARAMETER
    #>
}

Export-ModuleMember Get-Session
Set-Alias bo-gs Get-Session
Export-ModuleMember -Alias bo-gs

Export-ModuleMember Get-InfoObjects
Set-Alias bo-gii Get-InfoObjects
Export-ModuleMember -Alias bo-gii

Export-ModuleMember Get-LogonToken
Set-Alias bo-glt Get-LogonToken
Export-ModuleMember -Alias bo-glt
