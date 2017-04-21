<#
################################################################################################
Parameters
################################################################################################
#>
Param(
#Working directory
    [string]$workdirectoryPath = "C:\Users\CCamilJu\Desktop\MyTest",    #Work directory in which all will be done
    [bool]$createWorkdirectory = $true,                                 #If true, creates the work directory

#Database settings
    [string]$dbServerName = 'localhost',                                #Database server name
    [string]$databaseName = 'TestDb',                                   #Database name

#Others
    [int]$myInt = 1,
    [int[]]$myIntArray = (3,4,5,6)
)



<#
################################################################################################
Main
################################################################################################
#>
# Include other powershell files
. .\Functions.ps1

# Function that creates an Xml file
Function Create-Xml-File{
    Param([string]$pFileName, [string]$pDirectoryPath, [string]$pXmlContent, 
          [string]$pEncoding = "utf-8" #UTF-8 by default
    )

    Test-Path-And-Handle-Error $pDirectoryPath
    Write-Host "Creating xml file: $pFilePath"
    $streamWriter = $null
    try
    {
        $streamWriter = New-Object IO.streamWriter  (Join-Path $pDirectoryPath ($pFileName + ".xml")) -ErrorAction Stop
        $streamWriter.WriteLine('<?xml version="1.0" encoding="'+ $pEncoding + '"?>')
        $streamWriter.Write($pXmlContent)
        Write-Host "Xml file created successfully"
    }
    catch{
        Throw New-Object System.IO.IOException ("There was an error creating xml file: $_")
        exit
    }
    finally{
        $streamWriter.Close()
        $streamWriter.Dispose()
    }
}


# Keeping track of time
$mainTimer = [System.Diagnostics.Stopwatch]::StartNew() 

Write-Section-Header "Parameters"

#Different ways of writing in the console
Write-Host "Work directory path" "-" $workdirectoryPath       #Sending arguments. In this case it automatically concatenates space
Write-Host "Create new root directory - $createWorkdirectory" #Putting the variable inside double cuotes
Write-Host ("My Int - " + $myInt)                             #Concatenating using parenthesis

#Using the pipeline: this a simple example. To the right of the pipeline you specify what to do with
#                    the list you provide to the left. You should use $_ to access each element
$index = 0
Write-Host "My int array - "
$myIntArray | ForEach{
    Write-Host "$tab$tab$tab$tab$Element[$index]: " $_ 
    $index++
}

Write-Section-Header "Parameter Validation"

Write-Host "Validating Work directory path..."
if($workdirectoryPath -eq $null -or $workdirectoryPath -eq ''){
	Throw New-Object System.FormatException ("Working directory cannot be null or empty.")
	exit
}
Write-Host "Validating database server name..."
if($dbServerName -eq $null -or $dbServerName -eq ''){
	Throw New-Object System.FormatException ("Database server name cannot be null or empty.")
	exit
}
Write-Host "Validating database name..."
if($databaseName -eq $null -or $databaseName -eq ''){
	Throw New-Object System.FormatException ("Database name cannot be null or empty.")
	exit
}

Write-Section-Header "Work directory Setting"

#If $createWorkdirectory is true, work directory is created
#If $createWorkdirectory is false, it means the directory already exists, therefore, the directory path is tested
if($createWorkdirectory){
    Create-New-directory $workdirectoryPath
}else{
    Test-Path-And-Handle-Error $workdirectoryPath
}

Write-Section-Header "Database creation"
# Set connection string and object
$masterDbConnectionString = "Server=$dbServerName;Initial Catalog=master;Trusted_Connection=True;Connection Timeout=0"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $masterDbConnectionString
try
{
    Write-Host "Testing Server connection $masterDbConnectionString..."
	$sqlConnection.Open()
    Write-Host "Connection successful!"

    Write-Host "Dropping dababase $databaseName if it already exists"
    $sqlScript = "
    IF (EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ('[' + name + ']' = '$databaseName' OR name = '$databaseName')))
    BEGIN
        --Kill all current transactions
        ALTER DATABASE [$databaseName] SET single_user WITH ROLLBACK IMMEDIATE
        --Drop the database
        DROP DATABASE [$databaseName]
    END
    "
    $sqlCommand = New-Object Data.SqlClient.SqlCommand $sqlScript, $sqlConnection
    $sqlCommand.ExecuteNonQuery() | Out-Null

    Write-Host "Creating $databaseName"
    $sqlScript = "CREATE DATABASE [$databaseName]"

    $sqlCommand = New-Object Data.SqlClient.SqlCommand $sqlScript, $sqlConnection
    $sqlCommand.ExecuteNonQuery()  | Out-Null
         
    Write-Host "Database $databaseName created successfully!"      
}
catch
{
	Throw New-Object System.FormatException ("There was an error in datababase creation: $nl$_")
	exit
}finally{
    # Close connection and dispose objects
	$sqlConnection.Close()
    $sqlConnection.Dispose()    
}

Write-Section-Header "Database population"
# Set connection string and object
$connectionString = "Server=$dbServerName;Initial Catalog=$databaseName;Trusted_Connection=True;Connection Timeout=0"

#Creation of tables
Execute-Sql-File -pFileName "tblProfession.sql" -pConnectionString $connectionString
Execute-Sql-File -pFileName "tblPerson.sql" -pConnectionString $connectionString
    
#Creation of store procedures
Execute-Sql-File -pFileName "spGetAllPeople.sql" -pConnectionString $connectionString
Execute-Sql-File -pFileName "spGetAllPeopleAsXml.sql" -pConnectionString $connectionString
Execute-Sql-File -pFileName "spGetPeopleByBirthDate.sql" -pConnectionString $connectionString
Execute-Sql-File -pFileName "SpGetPeopleBySex.sql" -pConnectionString $connectionString   

Write-Section-Header "Get a result set from database and generate a csv file"

$resultset = Execute-Store-Procedure -pName "spGetAllPeople" -pServerName $dbServerName -pDatabaseName $databaseName
Create-Csv-File-From-Array -pFileName "People" -pDirectoryPath $workdirectoryPath -pArray $resultset

Write-Section-Header "Get an xml from database and save it somewhere"

$xml = Execute-Store-Procedure -pName "spGetAllPeopleAsXml" -pServerName $dbServerName -pDatabaseName $databaseName
Create-Xml-File -pFileName "People" -pDirectoryPath $workdirectoryPath -pXmlContent $xml.Xml

# Shows time taken to process data
Write-Host "Process completed successfully in $($mainTimer.Elapsed.ToString())." 
$mainTimer.Stop()