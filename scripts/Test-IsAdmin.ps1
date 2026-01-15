function Test-IsAdmin {
	([Security.Principal.WindowsPrincipal]::new(
        [Security.Principal.WindowsIdentity]::GetCurrent())
	).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}
function Restart-RunAs {
	Start-Process `
		-FilePath "powershell.exe" `
		-ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script:PSCommandPath`"" `
		-WorkingDirectory "$PSScriptRoot" `
		-Verb RunAs
	exit
}
function Elevate-Privileges {
	Write-Host "Elevating privileges..." -ForegroundColor Yellow
	if (-not (Test-IsAdmin)) {
		Restart-RunAs
	}
}