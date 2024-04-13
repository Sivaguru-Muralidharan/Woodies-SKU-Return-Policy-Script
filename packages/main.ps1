Import-Module ImportExcel
Import-Module .\packages\controller.ps1
Import-Module .\packages\html.ps1
[XML]$config = Get-Content .\config\config.xml

Initialize-Controller
Initialize-HTMLConfig

try {
    $data = Import-Excel -Path $config.settings.inputFilePath
}
catch {
    Write-Log -Message $_.Exception.Message -Terminate $true
}
$outputData = @()

foreach ($row in $data) {
    $ReturnPolicy = ''
    $columnNum = 1
    $SpecificRuleExist = $false
    foreach ($property in $row.PSObject.Properties) {
        if ($columnNum -eq 1)
        {
            $itemNo = $property.Value
            $columnNum++
            if ($config.settings.logs.showOnlyErrors -eq 0)
            {
                Write-Log -Message "Processing Item No.: $($itemNo)"
            }
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
        $ReturnPolicy += Add-PreContentTags
        $lines = $columnValue.Split([Environment]::NewLine)
        foreach($line in $lines)
        {
            $ReturnPolicy += $line+"$(Add-BreakTag)" 
        }
        $ReturnPolicy += Add-PostContentTags
    }
    $finaHTML = Get-FinalHTML -ReturnPolicy $ReturnPolicy -compress $config.settings.output.compress
    $outputRow = [PSCustomObject]@{
        "$($config.settings.output.Field1Name)" = $itemNo
        "$($config.settings.output.Field2Name)" = $finaHTML
    }
    $outputData += $outputRow
    if ($config.settings.logs.showOnlyErrors -eq 0)
    {
        Write-Log -Message "Successfully Processed Item"
    }
}
$outputData | Export-Excel -Path $config.settings.outputFilePath -WorksheetName "$($($config.settings.output.sheetName))" -AutoSize -ClearSheet
Write-Log('Execution Complete')