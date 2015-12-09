#Allow this script to be executed
Set-ExecutionPolicy Unrestricted CurrentUser

#Define directory where to generate png
$workingDir = "C:\Users\unrz198\Documents\GitHub\rrze-icon-set\"

#Force to overwrite existing files
$ForceWrite = $false

#Where is inkscape installed
$Inkscape = "C:\Program Files\Inkscape\inkscape.exe"

#Count the svg files in the defined $workingDir
$svgCount = ((Get-ChildItem $workingDir -recurse -filter "*.svg").Count *6)

#make sure that counter is always zero
$i = 0

#Core function that writes the exported png-files
function Export-PNG ($file, $fileOut, $dimension) {
    try {
        #call inkscape and wait export to finish otherwise a lot of processes are spawned and computer running this script has a heavy load
        & $Inkscape --export-png $fileOut --export-width $dimension --export-height $dimension --export-area-drawing $file  | Out-Null
    }
    catch {
        Write-Warning "Error occured: $_"
    }
}

#Function to test the correct configuration of Inkscape
function Test-inkscape {
    if (-not (Test-Path $Inkscape)) {
        Write-Error -Message "ERROR: Inkscape not found! Please correct configuration." -Category ObjectNotFound -TargetObject $inkscape
        exit
    }
    Else {
        return
    }
}

#Test if a file is existing and continue only if $ForceWrite is TRUE
function Test-ExistingOrForce ($fileOut) {
    If ((-not (Test-Path $fileOut)) -or ($ForceWrite)) {
        return
    }
    Else {
        Write-Warning -Message "ERROR: $fileOut already existing! Please set force to overwrite."
        break
    }
}

#cALCULATE AND SHOW PROGRESS
function Progress-Made ($fileOut) {
    #Increment counter for progress calculation
    $global:i++ 
    
    #Calculate progress in percent and round it for beautifying reasons
    $progress = [System.Math]::Round(($global:i / $svgCount) * 100)
    
    #Show progress
    Write-Progress -activity "Generating $fileOut" -status "$global:i / $svgCount = $progress %" -PercentComplete ($progress)
}





#Files total to be written
#Write-Host "svg-files in ${workingDir}: " $svgCount

#MAIN
#search for all svg files
function Main {

#Inkscape configured right? If not terminate with Error message.
Test-inkscape

Get-ChildItem $workingDir -recurse -filter "*.svg"| ForEach-Object{
    #define fileOout based on source filename 
    $file = $_.FullName
    
    $svgFileDirectory = (Get-Item $file).Directory.parent.BaseName
    #Write-Host $svgFileDirectory
               
    switch ($svgFileDirectory)
    {
        "16x16" { 
            $dimension = 16
            $fileOut = [System.IO.Path]::ChangeExtension($file, "2.png")
            Test-ExistingOrForce $fileOut
            Write-Host $fileOut
            #Export-PNG $file $fileOut $dimension
            Progress-Made $fileOut
        }
        
        "22x22" {
            $dimension = 22
            $fileOut = [System.IO.Path]::ChangeExtension($file, "2.png")
            Test-ExistingOrForce $fileOut
            Write-Host $fileOut 
            #Export-PNG $file $fileOut $dimension
            Progress-Made $fileOut
        }
               
        
        "scalable" {
             
            foreach ($dimension in (32, 48, 72, 150, 720)) {
                $fileOut = (Get-Item $file).Directory.parent.parent.Fullname+"\"+$dimension+"x"+$dimension+"\"+(Get-Item $file).Directory.Basename+"\"+(Get-Item $file).BaseName+".2.png"
                Test-ExistingOrForce $fileOut
                Write-Host $fileOut
                #Export-PNG $file $fileOut $dimension
                Progress-Made $fileOut
                }
         }
    }
            
    
       
    }
 
invoke-item $workingDir
#Summary and quit
Write-Host "$i png files generated. Good bye."
}

Main


#compare Count in scalable with count in dimension directories - indicator for missing icons



#Reset ExecutionPolicy to be safe again
# Set-ExecutionPolicy Restricted CurrentUser

#delete test files
#(Get-ChildItem $workingDir -recurse -filter "*.2.png")|ForEach-Object {del $_.FullName}