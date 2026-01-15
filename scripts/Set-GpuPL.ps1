param (
    [Parameter(Position = 0)]
    [Alias('v', 'val')]
    [string]$Value
)

function Set-GpuPL {
	param($w)
	nvidia-smi -pl $w
}
function Get-GpuDefaultPL {
	return nvidia-smi --query-gpu=power.default_limit --format=csv,noheader,nounits
}
function Get-GpuMinPL {
	return nvidia-smi --query-gpu=power.min_limit --format=csv,noheader,nounits
}
function Get-GpuMaxPL {
	return nvidia-smi --query-gpu=power.max_limit --format=csv,noheader,nounits
}
function Maximize-GpuPL {
	Set-GpuPL (Get-GpuMaxPL)
}
function Minimaze-GpuPL {
	Set-GpuPL (Get-GpuMinPL)
}
function Default-GpuPL {
	Set-GpuPL (Get-GpuDefaultPL)
}

if($PSBoundParameters.ContainsKey('Value')){
	switch ($Value.ToLower()) {
		{ $_ -in "max", "m", "maximum" } {
			Maximize-GpuPL
			exit
		}
		{ $_ -in "min", "n", "minimum" } {
			Minimaze-GpuPL
			exit
		}
		{ $_ -in "def", "d", "default" } {
			Default-GpuPL
			exit
		}
		default {
			if ($doubleValue = $Value -as [double]) {
				Set-GpuPL $Value $doubleValue
				exit
			}
		}
	}
}
Write-Error "Invalid value. Expected number (e.g. 215.5), max, min, or default."