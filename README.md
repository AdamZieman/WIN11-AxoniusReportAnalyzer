# WIN11 Axonius Report Processor

## Overview
This script processes Axonius reports for Windows 11 compatibility, extracting and organizing information on incompatible hardware and software. It also facilitates comparison between current and previous reports to identify changes over time.

## Directory Structure
The script assumes the following directory structure:

```
C:\Users\d18284\LocalDocuments\Projects\WIN11\
├── AxoniusReports\
│   └── Axonius Report <YYYY_MM_DD>\
│       └── Windows 11 Not Compatible Apps and Hardware*.csv
├── PreviousOutputs\
```

- **AxoniusReports\\**: Stores decompressed Axonius report directories. Each directory should follow the naming convention `Axonius Report <YYYY_MM_DD>`.
- **PreviousOutputs\\**: Stores output files from previous script executions for comparison.

## Prerequisites
1. The decompressed Axonius report directories must follow the naming convention: `Axonius Report <YYYY_MM_DD>`.
2. The `AxoniusReports\` directory must contain the report directories with the CSV file named `Windows 11 Not Compatible Apps and Hardware*`.

## Script Functionality
1. **Initialization**
   - Validates the existence of necessary directories and files.
   - Prompts the user to input the report date to target a specific Axonius report.

2. **Data Extraction and Processing**
   - Extracts the `Sccm: Collections` field from the targeted CSV file.
   - Removes duplicate entries.
   - Classifies entries into hardware or software based on keywords (e.g., `Dell`, `HP`, `Lenovo`).

3. **Sorting and Output**
   - Sorts the classified data alphanumerically.
   - Saves the sorted results to `incompatibleHardware.txt` and `incompatibleSoftware.txt`.
   - Creates a copy of the output files in the `PreviousOutputs\` directory for future comparisons.

4. **Comparison (Optional)**
   - Prompts the user to compare the current report with a previous report.
   - Outputs differences to `differences.txt` and opens it in Notepad.

## Usage
1. **Run the Script**
   Execute the script from the Command Prompt.

2. **Input Report Date**
   Enter the report date in `YYYY_MM_DD` format when prompted.

3. **Optional Comparison**
   Choose whether to compare the current report with a previous one. If yes, enter the date of the previous report in `YYYY_MM_DD` format.

## Output
- **`incompatibleHardware.txt`**: Sorted list of incompatible hardware.
- **`incompatibleSoftware.txt`**: Sorted list of incompatible software.
- **`differences.txt`** (optional): Differences between current and previous reports.

## Error Handling
- If a required directory or file is missing, the script outputs an error message and allows the user to retry or exit.
- Invalid input prompts are handled with clear error messages and retries.

## Dependencies
- PowerShell: Used for CSV processing.
- Notepad: Opens the output files and comparison results.

## Notes
- Ensure that the directory structure and file naming conventions are strictly followed.
- Review the output files and comparison results to verify the accuracy of the data.

## Screenshots
![image](https://github.com/user-attachments/assets/b3526626-b069-4e6a-8e4d-8f7d4dbd4e10)
![image](https://github.com/user-attachments/assets/f045c2da-2631-4803-a867-0a23eaca5c6c)
