$Global:config
$Global:developerConfig
function Test-HeadingProperty {
    $HeadingSize = $config.settings.heading.headingSize
    $Err1 = "Error: <heading> property must have an integer value between 1 and 6 in the config file"
    try {
        $HeadingSize = [int16]$HeadingSize
    }
    catch {
        Write-Log -Message $Err1 -Terminate $true
    }
    if ($HeadingSize -gt 6 -or $HeadingSize -lt 1)
    {
        Write-Log -Message $Err1 -Terminate $true
    }
}
function Test-InputFile {
    $InputPath = $config.settings.inputFilePath
    if(!(Test-Path $InputPath))
    {
        Write-Log -Message "Input File not Found at path $($InputPath)" -Terminate $true
    }
}
function Test-OutputSheetName {
    $SheetName = $config.settings.output.sheetName
    $maxLength = [int16]$developerConfig.settings.output.sheetNameMaxLength
    if($SheetName -gt $maxLength)
    {
        Write-Log -Message "Output Sheet Name Cannot be greater than $($maxLength)" -Terminate $true
    }
}
function Initialize-Controller {
    [XML]$config = Get-Content .\config\config.xml
    [XML]$developerConfig = Get-Content .\config\developerConfig.xml
    $logfileTimestamp = Get-Date -Format "ddMMyyy_HHmms"
    $Global:logFilePath = "$($config.settings.logsPath)\Log_$($logfileTimestamp).log"
    New-Item -path $logFilePath

    Test-HeadingProperty
    Test-InputFile
    Test-OutputSheetName
}

function Write-Log {
    param (
        [string]$Message,
        [boolean]$Terminate
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp:: $Message"
    Add-Content -Path $logFilePath -Value $logEntry
    if($Terminate)
    {
        $ErrMessage = 'Terminating Program'
        $logEntry = "$timestamp:: $ErrMessage"
        Add-Content -Path $logFilePath -Value $logEntry
        exit
    }
}