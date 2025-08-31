$ErrorActionPreference = "Stop"
Push-Location (Split-Path $script:MyInvocation.MyCommand.Path)

function main {
   MSBuild ..\sandcastle-md.sln -t:Restore -p:RestorePackagesConfig=true
}

try {
   main
} finally {
   Pop-Location
}
