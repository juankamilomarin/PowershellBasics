<#
################################################################################################
Constants
################################################################################################
#>

#Special characters
$nl = "`n"    #New Line
$tab = "`t"   #Tabulation

#Current script directory
$currentFilePath = (((Get-Variable MyInvocation).Value).MyCommand.Path)
$currentDirectorypath = Split-Path $currentFilePath