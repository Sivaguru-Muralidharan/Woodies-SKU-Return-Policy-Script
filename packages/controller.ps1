$Global:config

function Test-HeadingProperty {
    $Heading = $config.settings.heading
    $Err1 = "Error: <heading> property must have an integer value between 1 and 6 in the config file"
    try {
        $Heading = [int16]$Heading
    }
    catch {
        Write-Log -Message $Err1 -Terminate $true
    }
    if ($Heading -gt 6 -or $Heading -lt 1)
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
function InitModule {
    [XML]$config = Get-Content .\config\config.xml
    $logfileTimestamp = Get-Date -Format "ddMMyyy_HHmms"
    $Global:logFilePath = "$($config.settings.logsPath)\Log_$($logfileTimestamp).log"
    New-Item -path $logFilePath

    Test-HeadingProperty
    Test-InputFile
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