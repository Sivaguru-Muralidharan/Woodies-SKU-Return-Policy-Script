$Global:config
function Initialize-HTMLConfig {
    [XML]$config = Get-Content .\config\config.xml
}
function Add-BreakTag {
    $BreakTag = "<br>"
    return $BreakTag
}
function Add-PreContentTags {
    $preContentTags = "
    <div class='section'>
    <h$($config.settings.heading.headingSize)>
    $($property.Name)
    </h$($config.settings.heading.headingSize)>
    <p>
    "
    return $preContentTags
}
function Add-PostContentTags {
    $PostContentTags = "
    </p>
    </div>
    "
    return $PostContentTags
}
function Get-FinalHTML {
    param (
        [string]$ReturnPolicy,
        [char]$compress
    )
    $finaHTML = "
<html>
<head>
<style>
body {
font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
line-height: 1.6;
max-width: 90%;
margin: 0 auto;
padding: 20px;
background-color: #f7f7f7;
border-radius: 10px;
box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
color: #333;
}
.section {
margin-bottom: 20px;
padding: 20px;
background-color: #fff;
border-radius: 8px;
box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.1);
}
h$($config.settings.heading.headingSize) {
font-family:$($config.settings.heading.headingFontFamily)
font-size: 1.8em;
margin-bottom: 15px;
color: #333;
border-bottom: 1px solid #ddd;
padding-bottom: 10px;
}
p {
margin-bottom: 20px;
color: #555;
}
</style>
</head>
<body>
$($ReturnPolicy)
</body>
</html>
    "
    if ($compress -eq '1')
    {
        $compressedFinalHTML =  $finaHTML -replace '\r?\n',''
        return $compressedFinalHTML
    }
    else {
        return $finaHTML
    }
}