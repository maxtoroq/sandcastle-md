
$ErrorActionPreference = "Stop"
Push-Location (Split-Path $script:MyInvocation.MyCommand.Path)

$nuget = "..\.nuget\nuget.exe"

function ensure-nuget {
   if (-not (Test-Path $nuget -PathType Leaf)) {
      
      $nuget_dir = Split-Path -Parent $nuget

      if (-not (Test-Path $nuget_dir -PathType Container)) {
         md $nuget_dir | Out-Null
      }

      write "Downloading NuGet..."
      Invoke-WebRequest https://www.nuget.org/nuget.exe -OutFile $nuget
   }
}

function main {
   ensure-nuget
   &$nuget restore ..\sandcastle-md.sln
}

try {
   main
} finally {
   Pop-Location
}