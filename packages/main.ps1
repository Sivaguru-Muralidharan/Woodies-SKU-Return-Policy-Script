Import-Module ImportExcel
Import-Module .\packages\controller.ps1
[XML]$config = Get-Content .\config\config.xml

InitModule

try {
    $data = Import-Excel -Path $config.settings.inputFilePath
}
catch {
    Write-Log -Message $_.Exception.Message -Terminate $true
}
$outputData = @()

foreach ($row in $data) {
    # Loop through each property (column) of the row object
    $ReturnPolicyHTML = ''
    $columnNum = 1
    $SpecificRuleExist = $false
    foreach ($property in $row.PSObject.Properties) {
        if ($columnNum -eq 1)
        {
            $itemNo = $property.Value
            $columnNum++
            continue
        }
        $columnValue = $property.Value
        if ($null -eq $columnValue)
        {
            $columnNum++
            continue
        }
        if ($columnNum -eq 5 -and $SpecificRuleExist -eq $true)
        {
            break
        }
        $SpecificRuleExist = $true
        $columnNum++
        $ReturnPolicyHTML += "<h$($config.settings.heading)>$($property.Name)</h$($config.settings.heading)>"
        $ReturnPolicyHTML += "<p>"
        $lines = $columnValue.Split([Environment]::NewLine)
        foreach($line in $lines)
        {
            $ReturnPolicyHTML = $ReturnPolicyHTML + $line+"<br>"  
        }
        $ReturnPolicyHTML = $ReturnPolicyHTML + "<hr>"
        $ReturnPolicyHTML += "</p>"
    }
    $outputRow = [PSCustomObject]@{
        "ItemNo" = $itemNo
        "ReturnPolicy" = $ReturnPolicyHTML
    }
    $outputData += $outputRow
}
$outputData | Export-Excel -Path $config.settings.outputFilePath -WorksheetName "Sheet1" -AutoSize -ClearSheet
Write-Log('Execution Complete')