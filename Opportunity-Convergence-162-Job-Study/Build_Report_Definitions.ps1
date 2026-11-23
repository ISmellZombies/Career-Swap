$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$report = Join-Path $root 'Opportunity_Convergence.Report'
$pagesDir = Join-Path $report 'definition\pages'
$denebType = 'deneb7E15AEF80B9E4D4F8E12924291ECE89A'
function Get-Projection([string]$entity,[string]$field) { @{ field = @{ Column = @{ Expression = @{ SourceRef = @{ Entity = $entity } }; Property = $field } }; queryRef = "$entity.$field"; nativeQueryRef = $field; active = $true; displayName = $field } }
function Write-Json($object,[string]$path) { $object | ConvertTo-Json -Depth 80 | Set-Content -LiteralPath $path -Encoding utf8 }
function Add-Deneb([string]$page,[string]$id,[string]$specFile,[string[]]$fields,[int]$x,[int]$y,[int]$w,[int]$h) {
  $spec = Get-Content -Raw (Join-Path $root $specFile); $literal = "'" + $spec.Replace("'","''") + "'"; $projections = @($fields | ForEach-Object { Get-Projection 'Jobs' $_ })
  $visual = @{'$schema'='https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.14.0/schema.json';name=$id;position=@{x=$x;y=$y;z=1000;height=$h;width=$w;tabOrder=0};visual=@{visualType=$denebType;query=@{queryState=@{dataset=@{projections=$projections}}};objects=@{vega=@(@{properties=@{jsonSpec=@{expr=@{Literal=@{Value=$literal}}};jsonConfig=@{expr=@{Literal=@{Value="'{}'"}}};provider=@{expr=@{Literal=@{Value="'vegaLite'"}}};renderMode=@{expr=@{Literal=@{Value="'svg'"}}};enableTooltips=@{expr=@{Literal=@{Value='true'}}}}})};drillFilterOtherVisuals=$true}}
  $path=Join-Path $pagesDir "$page\visuals\$id\visual.json";New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path)|Out-Null;Write-Json $visual $path
}
function Add-Textbox([string]$page,[string]$id,[string]$title,[string]$eyebrow,[int]$x,[int]$y,[int]$w,[int]$h) {
  $paragraphs = @(
    @{ textRuns = @(@{ value=$eyebrow; textStyle=@{ fontFamily='Segoe UI'; fontSize='12px'; color='#FF0056'; bold=$true } }); horizontalTextAlignment='left' },
    @{ textRuns = @(@{ value=$title; textStyle=@{ fontFamily='Segoe UI'; fontSize='32px'; color='#1D3329'; bold=$true } }); horizontalTextAlignment='left' }
  )
  $visual = @{
    '$schema'='https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.14.0/schema.json'
    name=$id
    position=@{ x=$x; y=$y; z=1010; height=$h; width=$w; tabOrder=0 }
    visual=@{
      visualType='textbox'
      query=@{ queryState=@{} }
      objects=@{ general=@(@{ properties=@{ paragraphs=$paragraphs } }) }
    }
  }
  $path=Join-Path $pagesDir "$page\visuals\$id\visual.json";New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path)|Out-Null;Write-Json $visual $path
}
function Add-Slicer([string]$page,[string]$id,[string]$field,[int]$x,[int]$y,[int]$w,[int]$h) {
  $visual=@{'$schema'='https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.14.0/schema.json';name=$id;position=@{x=$x;y=$y;z=1000;height=$h;width=$w;tabOrder=0};visual=@{visualType='slicer';query=@{queryState=@{Values=@{projections=@((Get-Projection 'Jobs' $field))}}}}}
  $path=Join-Path $pagesDir "$page\visuals\$id\visual.json";New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path)|Out-Null;Write-Json $visual $path
}
function Add-Table([string]$page,[string]$id,[string[]]$fields,[int]$x,[int]$y,[int]$w,[int]$h) {
  $projections=@($fields|ForEach-Object {Get-Projection 'Jobs' $_});$filters=@($fields|ForEach-Object {@{name=([guid]::NewGuid().ToString('N').Substring(0,20));field=@{Column=@{Expression=@{SourceRef=@{Entity='Jobs'}};Property=$_}};type='Categorical'}})
  $visual=@{'$schema'='https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.14.0/schema.json';name=$id;position=@{x=$x;y=$y;z=1000;height=$h;width=$w;tabOrder=0};visual=@{visualType='tableEx';query=@{queryState=@{Values=@{projections=$projections}}}};filterConfig=@{filters=$filters}}
  $path=Join-Path $pagesDir "$page\visuals\$id\visual.json";New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path)|Out-Null;Write-Json $visual $path
}
$baseFields=@('JobID','StudyID','JobNo','EmployerLabel','JobTitle','RowLabel','LocationRaw','WorkArrangement','JobSource','EmploymentType','FitScore','Eligible','Applied','FitBand','DecisionQuadrant','JobFamily','DutiesRaw','SearchTermRaw','SalaryStatus','SalaryEntryRaw','SalaryMidRaw','SalarySeniorRaw','ReceivedRaw','SuccessRaw')
$pages=@('01_Opportunity_Landscape','02_Skills_Convergence','03_Salary_Spectrum')
foreach($p in $pages){Get-ChildItem -LiteralPath (Join-Path $pagesDir "$p\visuals") -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force}
Add-Textbox '01_Opportunity_Landscape' 'HeaderOpportunity' 'Opportunity Landscape' 'RESEARCH / OPPORTUNITY INTELLIGENCE' 48 18 1120 78
Add-Slicer '01_Opportunity_Landscape' 'StudySelector' 'StudyID' 1200 26 352 62
Add-Deneb '01_Opportunity_Landscape' 'LandscapeCanvas' 'visual_specs\opportunity_landscape.vl.json' $baseFields 48 112 1504 738
$filterFields=@('StudyID','JobSource','WorkArrangement','Applied','FitBand')
Add-Textbox '02_Skills_Convergence' 'HeaderSkills' 'Skills Convergence' 'FIT-001 / 75% APPLICATION MINIMUM' 48 8 1120 60
for($i=0;$i -lt $filterFields.Count;$i++){Add-Slicer '02_Skills_Convergence' ('Filter'+$i) $filterFields[$i] (48+($i*300)) 70 286 52}
Add-Deneb '02_Skills_Convergence' 'FitRanking' 'visual_specs\skills_convergence.vl.json' $baseFields 48 130 1504 580
Add-Table '02_Skills_Convergence' 'AllOpportunities' @('JobID','RowLabel','FitScore','FitBand','Eligible','Applied','StudyID','WorkArrangement','JobSource','SearchTermRaw','JobFamily') 48 724 1504 158
Add-Textbox '03_Salary_Spectrum' 'HeaderSalary' 'Salary Spectrum' 'RECORDED COMPENSATION ESTIMATES / QUALITY-AWARE' 48 8 1120 60
$salaryFilters=@('StudyID','JobSource','WorkArrangement','Eligible','SalaryStatus')
for($i=0;$i -lt $salaryFilters.Count;$i++){Add-Slicer '03_Salary_Spectrum' ('SalaryFilter'+$i) $salaryFilters[$i] (48+($i*300)) 70 286 52}
Add-Deneb '03_Salary_Spectrum' 'SalaryRanges' 'visual_specs\salary_spectrum.vl.json' $baseFields 48 130 1504 580
Add-Table '03_Salary_Spectrum' 'SalaryQualityReview' @('JobID','RowLabel','SalaryStatus','SalaryTextRaw','SalaryEntryRaw','SalaryMidRaw','SalarySeniorRaw','NotesRaw','ExtraNotesRaw','StudyID') 48 724 1504 158
