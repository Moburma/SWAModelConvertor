#Syndicate Wars Pre-Alpha Model Covertor by Moburma

#VERSION 0.1
#LAST MODIFIED: 17/02/2023

<#
.SYNOPSIS
   This script can read Bullfrog Standard 3D Object Format models as found in the Syndicate Wars pre-alpha and convert them to standard Wavefront .obj format 

.DESCRIPTION    
    The pre-alpha demo of Syndicate Wars contained unused models in a simplistic custom format used internally by Bullfrog. They have the file extension .Bxx
    where x is a number. There are only a handful of these, but I thought it would be interesting (and fairly easy) to see what they were.


.PARAMETER Filename
   
   The model file to open. E.g. OBJ46.B01


.RELATED LINKS
    
    Hi-Octane Tools - https://github.com/movAX13h/HiOctaneTools

    
#>

Param ($filename)

$outputfile = [io.path]::GetFileName("$filename")

if ($filename -eq $null){
write-host "Error - No argument provided. Please supply a model file to read!"
write-host ""
write-host "Example: SWLevelReader.ps1 C006L001.DAT"
}
Else{

if ((Test-Path -Path $filename -PathType Leaf) -eq 0){
write-host "Error - No file with that name found. Please supply a target level file to read!"
write-host ""
write-host "Example: SWLevelReader.ps1 C006L001.DAT"
exit
}
}
$modfile = Get-Content $filename 

if ($modfile[0] -like "Bullfrog Standard 3D Object Format"){

write-host "No Bullfrog model header found - are you sure this is a model file?"
exit
}



$outheader = "o $outputfile"

$output = @()

$output += $outheader

$linelength = $modfile.count
$linelength = $linelength -3
$linecount = 5
$vertexend = 0

foreach ($line in $modfile[5..$linelength]){   #Find end of vertex data and start of face data

    if ($vertexend -eq 0){
        if ($line -like "Vertex*"){
        #$line
        }
        Else{
        $vertexend = $linecount
        $vertend = $vertexend - 3
         $line
         write-host "Vertex data ends at line $vertexend"
        }
    }
$linecount = $linecount +1
}

foreach ($line in $modfile[5..$vertexend]){ #Find vertice information

   $findxstring = $line -match "X: (-?\b\d+)"
   $xstring = $matches[1]
   $findystring = $line -match "Y: (-?\b\d+)"
   $ystring = $matches[1]
   $findzstring = $line -match "Z: (-?\b\d+)"
   $zstring = $matches[1]

   $vlineoutput = "v $xstring $ystring $zstring"
   $vlineoutput
   $output += $vlineoutput
    }

$vertexend = $vertexend + 2 #skip blank lines

foreach ($line in $modfile[$vertexend..$linelength]){ #Find Face information

   $findastring = $line -match "A: (-?\b\d+)"
   $astring = $matches[1]
   $findbstring = $line -match "A: (-?\b\d+)  B: (-?\b\d+)" #Already another B:, so need more specifc criteria
   $bstring = $matches[2]
   $findcstring = $line -match "C: (-?\b\d+)"
   $cstring = $matches[1]

   $astring = [int]$astring+1  #Bullfrog format has an index starting at zero so need bumping up
   $bstring = [int]$bstring+1
   $cstring = [int]$cstring+1

   $flineoutput = "f $astring $bstring $cstring"
   $flineoutput
   $output += $flineoutput
    }



Set-Content "$outputfile.obj" -Value $output