<#
.SYNOPSIS
Get-UsnJrnlInfo

.DESCRIPTION
Get-UsnJrnlInfo.ps1 is a simple PowerShell script utilized to parse $UsnJrnl information from extracted $Max file.

[root]\$Extend\$UsnJrnl:$Max

.PARAMETER PathToMaxFile
Specifies the path to the extracted $Max file.

.EXAMPLE
PS C:\> .\Get-UsnJrnlInfo.ps1 -PathToMaxFile "G:\C\$Extend\`$Max"

.NOTES
Author - Martin Willing

.LINK
https://evild3ad.com/

#>

Param([string]$PathToMaxFile)

if (!($PathToMaxFile))
{
    Write-Output "You have to specify the path to the extracted `$Max file:"
    Write-Output ".\Get-UsnJrnlInfo.ps1 [[-PathToMaxFile] <string>]"
    Exit
}

Function Get-UsnJrnlInfo
{
    # Check if File exists
    if (Test-Path "$PathToMaxFile")
    {
        # Check if it is a File
        if ((Get-Item $PathToMaxFile) -is [System.IO.FileInfo])
        {
            # Check for fixed size of 32 Bytes (Logical Size)
            $Bytes = (Get-Item -Path "$PathToMaxFile").Length
            if ($Bytes -eq "32")
            {
                # Reading The Bytes Of A File Into A Byte Array
                $ByteArray = [System.IO.File]::ReadAllBytes("$PathToMaxFile")

                # Convert Byte Array To Hex
                $ByteContentOfMax = [System.BitConverter]::ToString($ByteArray).Replace("-", " ")
                Write-Output "[Info]  Content: $ByteContentOfMax"

                Function Get-FileSize() {
                Param ([long]$Length)
                If ($Length -gt 1TB) {[string]::Format("{0:0.00} TB", $Length / 1TB)}
                ElseIf ($Length -gt 1GB) {[string]::Format("{0:0.00} GB", $Length / 1GB)}
                ElseIf ($Length -gt 1MB) {[string]::Format("{0:0.00} MB", $Length / 1MB)}
                ElseIf ($Length -gt 1KB) {[string]::Format("{0:0.00} KB", $Length / 1KB)}
                ElseIf ($Length -gt 0) {[string]::Format("{0:0.00} Bytes", $Length)}
                Else {""}
                }

                # MaximumSize (Converts Byte Array Into A 64-Bit Unsigned Integer)
                $ByteSize = [Bitconverter]::ToUInt64($ByteArray[0 .. 8], 0)
                $MaximumSize = Get-FileSize($ByteSize)
                Write-Output "[Info]  Maximum USN Size: $MaximumSize ( $ByteSize Bytes )"

                # Allocation Delta (Converts Byte Array Into A 64-Bit Unsigned Integer)
                $ByteSize = [Bitconverter]::ToUInt64($ByteArray[8 .. 16], 0)
                $AllocationDelta = Get-FileSize($ByteSize)
                Write-Output "[Info]  Allocation Size: $AllocationDelta ( $ByteSize Bytes )"

                # USN ID (Converts Byte Array Into A 64-Bit Unsigned Integer)
                $UsnIdDec = [Bitconverter]::ToUInt64($ByteArray[16 .. 24], 0)
                $UsnIdHex = "0x{0:x}" -f 132634203089494385
                Write-Output "[Info]  USN ID (Decimal): $UsnIdDec"
                Write-Output "[Info]  USN ID (Hex): $UsnIdHex"

                # Lowest Valid USN (Converts Byte Array Into 64-Bit Integer)
                $LowestUsn = [Bitconverter]::ToInt64($ByteArray[24 .. 32], 0)
                Write-Output "[Info]  Lowest Valid USN: $LowestUsn"
            }
            else
            {
                Write-Output "[Error] The size of the provided file does not match the fixed size of the `$Max file."
            }
        }
    }
    else
    {
        Write-Output "[Error] The provided file does not exist."
    }
}

Get-UsnJrnlInfo