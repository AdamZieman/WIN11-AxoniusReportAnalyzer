@echo off
setlocal enabledelayedexpansion


REM Instatiate a working absolute Path
set workingAbsolutePath=''


REM Instantiate the path to the parent directory for the Axonius reports
set "axoniusReportsPath=C:\Users\d18284\LocalDocuments\Projects\WIN11\AxoniusReports\"
set workingAbsolutePath=!axoniusReportsPath!
if not exist "%workingAbsolutePath%" (
    echo Error: Path does not exist.
    echo %axoniusReportsPath%
	
    goto :EndError
)


REM Function to get the date for the Axonius report
:GetAxoniusReportDate


REM Get the date of the Axonius report from the user
set /p axoniusReportDate="Enter the date of the Axonius report in YYYY_MM_DD format: "


REM Instantiate the Axonius report directory
set "targetedReportDirectory=Axonius Report !axoniusReportDate!\"
set set workingAbsolutePath=!axoniusReportsPath!!targetedReportDirectory!


REM Check if the required files exist
if not exist !workingAbsolutePath! (
	echo Error: Directory does not exist.
	echo %targetedReportDirectory%
	echo.
	echo Absolute path: !workingAbsolutePath!
	echo.
	goto :GetAxoniusReportDate
)


REM Instantiate the csv Axonius report
set "targetedCSV=Windows 11 Not Compatible Apps and Hardware*"
set workingAbsolutePath=!axoniusReportsPath!!targetedReportDirectory!!targetedCSV!
if not exist "%workingAbsolutePath%" (
    echo Error: File does not exist.
	echo %targetedCSV%
	echo.
	echo Absolute path: !workingAbsolutePath!
    echo .
	
    goto :EndError
)


REM Instantiate the column to search in the csv file
set "targetedColumn=Sccm: Collections"=


REM Prints which Axonius directory and file is being searched
echo %targetedReportDirectory%%targetedCSV%


REM Creates temp files
set NonCompatibleFile=%axoniusReportsPath%temp_NonCompatible.txt
> %NonCompatibleFile% echo.
set UniqueNonCompatibleComputersFile=%axoniusReportsPath%temp_UniqueNonCompatibleComputers.txt
> %UniqueNonCompatibleComputersFile% echo.
set UniqueNonCompatibleAppsFile=%axoniusReportsPath%temp_UniqueNonCompatibleApps.txt
> %UniqueNonCompatibleAppsFile% echo.


REM Creates output files
set SortedUniqueNonCompatibleComputersFile=%axoniusReportsPath%NonCompatibleComputers.txt
> %SortedUniqueNonCompatibleComputersFile% echo.
set SortedUniqueNonCompatibleAppsFile=%axoniusReportsPath%NonCompatibleApps.txt
> %SortedUniqueNonCompatibleAppsFile% echo.


REM Prints that the script will begin extracting data
echo ... Extracting data


REM PowerShell command to extract values from the targeted column
powershell -Command "Import-Csv -Path '%workingAbsolutePath%' | Select-Object -Unique -ExpandProperty '%targetedColumn%' | Out-File -FilePath '%NonCompatibleFile%' -Encoding utf8"


REM Prints that the script will begin removing duplicate entries
echo ... Removing duplicate entries


REM Organizes the entries into two files based on content, without duplicate entries
for /f "usebackq delims=" %%A in (%NonCompatibleFile%) do (
    set line=%%A

    :: Trim spaces
    for /f "tokens=* delims=" %%B in ("!line!") do set "line=%%B"

    :: Check if the line starts with 'Dell' or 'HP'
    echo !line! | findstr /b /i "Dell HP" >nul
    if !errorlevel! equ 0 (
        REM Check if the line is unique in computersFile
        findstr /x /c:"!line!" %UniqueNonCompatibleComputersFile% >nul
        if !errorlevel! neq 0 (
            >> %UniqueNonCompatibleComputersFile% echo(!line!
        )
    ) else (
        REM Check if the line is unique in appsFile
        findstr /x /c:"!line!" %UniqueNonCompatibleAppsFile% >nul
        if !errorlevel! neq 0 (
            >> %UniqueNonCompatibleAppsFile% echo(!line!
        )
    )
)


REM Prints that the script will begin sorting the entries alphanumerically
echo ... Sorting alphanumerically


REM Sorts the contents of the unique, noncompatible files into their respective sorted, unique, noncompatible files.
sort %UniqueNonCompatibleComputersFile% /o %SortedUniqueNonCompatibleComputersFile%
sort %UniqueNonCompatibleAppsFile% /o %SortedUniqueNonCompatibleAppsFile%


REM Deletes temp files and open the sorted, unique, noncompatible files
del %NonCompatibleFile%
del %UniqueNonCompatibleComputersFile%
del %UniqueNonCompatibleAppsFile%


REM Prints that the script is completed
echo ... Batch completed


REM Prints the path to the output files
echo %axoniusReportsPath%%SortedUniqueNonCompatibleComputersFile%
echo %axoniusReportsPath%%SortedUniqueNonCompatibleAppsFile%
echo.


REM Function to ask whether the user would like to compare current report to a previous report
:CompareFile


REM Ask the user if they would like to view changes from a previous report
set /p isCompareFile="Would you like to compare a file? (y/n)? "

if /i "!isCompareFile!"=="y" (
    REM Instantiate the path to the parent directory for the previous outputs
    set "previousOutputsPath=%axoniusReportsPath%\PreviousOutputs\"
    
    if not exist "!previousOutputsPath!" (
        echo Error: Path does not exist.
        echo "!previousOutputsPath!"
        goto :EndError
    )
    
    REM Instantiate the date of the previous report you would like to compare
    set /p compareDate="Enter the date of the file you would like to compare in YYYY_MM_DD format: "
    
    REM Check if the required files exist
    if not exist "!previousOutputsPath!\NonCompatibleApps!compareDate!.txt" (
        echo Error: File does not exist.
        echo "!previousOutputsPath!\NonCompatibleApps!compareDate!.txt"
		echo.
        goto :CompareFile
    )
    
    if not exist "!previousOutputsPath!\NonCompatibleComputers!compareDate!.txt" (
        echo Error: File does not exist.
        echo "!previousOutputsPath!\NonCompatibleComputers!compareDate!.txt"
		echo.
        goto :CompareFile
    )
    
    REM Creates file to store the differences
    set "DifferencesFile=%axoniusReportsPath%\Differences.txt"
    echo > "!DifferencesFile!" REM Initializes the differences file

    echo ... Comparing reports
    
    REM Compare files and append differences
    fc "!SortedUniqueNonCompatibleAppsFile!" "!previousOutputsPath!\NonCompatibleApps!compareDate!.txt" >> "!DifferencesFile!" 2>&1
    fc "!SortedUniqueNonCompatibleComputersFile!" "!previousOutputsPath!\NonCompatibleComputers!compareDate!.txt" >> "!DifferencesFile!" 2>&1
    
    REM Open the differences file in Notepad
    start notepad "!DifferencesFile!"

) else if /i "!isCompareFile!"=="n" (
    goto :EndSuccess
) else (
    echo Error: Invalid input.
	echo.
    goto :CompareFile
)


REM End with success
:EndSuccess
echo.


REM Opens the output files
start notepad %SortedUniqueNonCompatibleComputersFile%
start notepad %SortedUniqueNonCompatibleAppsFile%

endlocal


REM End with error
:EndError
echo.
endlocal
