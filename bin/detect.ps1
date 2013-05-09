# vim: set ft=ps1

$build_dir=$args[0]

# ASP.NET
if (Test-Path(Join-Path $build_dir 'web.config'))
{
  Write-Host "ASP.NET"
  exit 0
}

# Standalone
# TODO: should standalone have a config?
$exe_files = Get-ChildItem $build_dir -Filter '*.exe'
foreach ($exe_file in $exe_files)
{
  if (Test-Path($exe_file + '.config'))
  {
    echo "Standalone"
    exit 0
  }
}

Write-Host "no"
exit 1
