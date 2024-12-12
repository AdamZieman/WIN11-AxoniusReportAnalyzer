@echo off
setlocal enabledelayedexpansion

REM Initializes variables to define the path to Axonius reports and checks for the existence of relevant directories and files.
REM Prompt the user to input the report date, constructs the path for the specific report, and verifies its existence.
REM Constructs the path to the "WIN11 Incompatible Apps and Hardware" CSV file and checks if the file exists.
REM If any path or file is missing, the script prints an error message and either jumps to an error handling label or prompts the user again for input.

set "axoniusReportsParentDirectory=C:\Users\d18284\LocalDocuments\Projects\WIN11\AxoniusReports\"
set workingPath=%axoniusReportsParentDirectory%

if not exist "%workingPath%" (
    echo Error: Parent directory for Axonius reports does not exist.
    echo %workingPath%
    goto :ExitOnError
)

:GetReportDate

set /p reportDate="Enter the date of the Axonius report in YYYY_MM_DD format: "
set "axoniusReportTargetedDirectory=Axonius Report !reportDate!\"
set workingPath=%workingPath%!axoniusReportTargetedDirectory!

if not exist !workingPath! (
	echo Error: Directory for specified Axonius report does not exist.
	echo !workingPath!
	echo.
	goto :GetReportDate
)

set "incompatibleAppsHardwareCSV=Windows 11 Not Compatible Apps and Hardware*"
set workingPath=!workingPath!%incompatibleAppsHardwareCSV%

if not exist "!workingPath!" (
    echo Error: WIN11 Incompatible Apps and Hardware CSV file does not exist.
	echo !workingPath!
    goto :ExitOnError
)

set "targetedCsvField=Sccm: Collections"=

echo !workingPath!



REM Initializes temporary files to store SCCM collections, incompatible hardware, and incompatible software data.
REM Extracts data from a specified CSV file using PowerShell, removes duplicate entries, and classifies the entries into either incompatible hardware or software based on the content.
REM The script checks for entries related to "Dell" or "HP" and appends them to the respective temporary file.
REM After processing, the temporary SCCM collections file is deleted.

set tempSccmCollectionsFile=%axoniusReportsParentDirectory%temp_sccmCollections.txt
> %tempSccmCollectionsFile% echo.
set tempIncompatibleHardwareFile=%axoniusReportsParentDirectory%temp_incompatibleHardware.txt
> %tempIncompatibleHardwareFile% echo.
set tempIncompatibleSoftwareFile=%axoniusReportsParentDirectory%temp_incompatibleSoftware.txt
> %tempIncompatibleSoftwareFile% echo.

echo ... Extracting data

powershell -Command "Import-Csv -Path '!workingPath!' | Select-Object -Unique -ExpandProperty '%targetedCsvField%' | Out-File -FilePath '%tempSccmCollectionsFile%' -Encoding utf8"

echo ... Removing duplicate entries

for /f "usebackq delims=" %%A in (%tempSccmCollectionsFile%) do (
    set line=%%A

    for /f "tokens=* delims=" %%B in ("!line!") do set "line=%%B"
		echo !line! | findstr /b /i "Dell HP" >nul
		
		if !errorlevel! equ 0 (
			findstr /x /c:"!line!" %tempIncompatibleHardwareFile% >nul
			
			if !errorlevel! neq 0 (
				>> %tempIncompatibleHardwareFile% echo(!line!
			)
		) else (
			findstr /x /c:"!line!" %tempIncompatibleSoftwareFile% >nul
			
			if !errorlevel! neq 0 (
				>> %tempIncompatibleSoftwareFile% echo(!line!
			)
    )
)

del %tempSccmCollectionsFile%



REM Sorts the entries in the temporary incompatible hardware and software files alphanumerically and saves the sorted results to a output files.
REM Deletes the temporary files and outputs the paths to the sorted hardware and software files, indicating the process is complete.

echo ... Sorting alphanumerically

set incompatibleHardwareFile=%axoniusReportsParentDirectory%incompatibleHardware.txt
> %incompatibleHardwareFile% echo.
set incompatibleSoftwareFile=%axoniusReportsParentDirectory%incompatibleSoftware.txt
> %incompatibleSoftwareFile% echo.

sort %tempIncompatibleHardwareFile% /o %incompatibleHardwareFile%
sort %tempIncompatibleSoftwareFile% /o %IncompatibleSoftwareFile%

del %tempIncompatibleSoftwareFile%
del %tempIncompatibleHardwareFile%

echo ... Completed
echo %axoniusReportsParentDirectory%%incompatibleHardwareFile%
echo %axoniusReportsParentDirectory%%incompatibleSoftwareFile%



REM Prompts the user to decide whether they want to compare a file.
REM If the user chooses to compare, it checks for the existence of the required previous reports based on the provided date.
REM If the files exist, it compares the current and previous reports, appending the differences to a file and opening it in Notepad.
REM If the user chooses not to compare or provides invalid input, the script exits or prompts again.

set /p isCompareFile="Would you like to compare a file? (y/n)? "

:CompareFile

echo.

set "previousAxoniusReportOutputs=%axoniusReportsParentDirectory%PreviousOutputs\"

if /i "!isCompareFile!"=="y" (
    if not exist "%previousAxoniusReportOutputs%" (
		echo Error: Directory for previous Axonius report outputs does not exist.
		echo "%axoniusReportsParentDirectory%"
        echo "%previousAxoniusReportOutputs%"
        goto :ExitOnError
    )
    
    set /p compareDate="Enter the date of the file you would like to compare in YYYY_MM_DD format: "

    if not exist "%previousAxoniusReportOutputs%\incompatibleSoftware!compareDate!.txt" (
		echo Error: Previous incompatible software file does not exist.
        echo "%previousAxoniusReportOutputs%\incompatibleSoftware!compareDate!.txt"
        goto :CompareFile
    )
    
    if not exist "%previousAxoniusReportOutputs%\incompatibleHardware!compareDate!.txt" (
		echo Error: Previous incompatible hardware file does not exist.
        echo "%previousAxoniusReportOutputs%\incompatibleHardware!compareDate!.txt"
        goto :CompareFile
    )
    
    set "differencesFile=%axoniusReportsParentDirectory%\differences.txt"
	> %incompatibleSoftwareFile% echo.
	
    echo ... Comparing reports
	
    fc "%incompatibleSoftwareFile%" "%previousAxoniusReportOutputs%\incompatibleSoftware!compareDate!.txt" >> "!differencesFile!" 2>&1
    fc "%incompatibleHardwareFile%" "%previousAxoniusReportOutputs%\incompatibleHardware!compareDate!.txt" >> "!differencesFile!" 2>&1
	
    start notepad "!differencesFile!"
	
	goto :ExitOnSuccess
) else if /i "!isCompareFile!"=="n" (
    goto :ExitOnSuccess
) else (
    echo Error: Invalid input.
    goto :CompareFile
)



REM This section handles the exit points for the script.
REM If the script successfully completes, it opens the incompatible hardware and software files in Notepad and then ends the local environment.
REM If an error occurs, it simply ends the local environment.

:ExitOnSuccess
start notepad %incompatibleHardwareFile%
start notepad %incompatibleSoftwareFile%
endlocal

:ExitOnError
endlocal
