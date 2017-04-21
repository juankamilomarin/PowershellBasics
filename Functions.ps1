<#
################################################################################################
Functions
################################################################################################
#>

# Include other powershell files
. .\Constants.ps1

# Function that creates a new directory and handles the exception in case of error
Function Create-New-directory{
    Param ([string]$pDirectoryPath) 
    Write-Host "Creating directory $pDirectoryPath..."
    try{
        #Force directive omits the error if the directory already exists
        #The result is piped to Out-Null, so details of the creation are not printed in console
	    New-Item $pDirectoryPath -type directory -force | Out-Null
        # Delete the contents of the directory, in case this one already exists
        Remove-Item (Join-Path $pDirectoryPath "*") -recurse
    }
    catch
    {
	    Write-Warning 'directory creation failed'
	    Throw New-Object System.IO.FileFormatException ("directory creation failed: $_")
	    exit
    }
    Write-Host 'Directory successfully created'
}

# Function that tests a path and handles the error
Function Test-Path-And-Handle-Error{
    Param ([string]$pDirectoryPath) 
    Write-Host "Testing directory path $pDirectoryPath..."
    if((Test-Path $pDirectoryPath) -eq $false){
        Throw New-Object System.IO.FileFormatException ("Incorrect path")
	    exit
    }  
}

# Function that writes a section header in the console
Function Write-Section-Header{
    Param ([string]$pSectionName)         
    Write-Host "
----------------------------------------------------------------------------
$pSectionName
----------------------------------------------------------------------------"
}

# Function that gets the content from a file
Function Get-Content-From-File{
    Param ([string]$pFilePath)       
    
    Test-Path-And-Handle-Error $pFilePath
    try{
        Write-Host "Loading content from file $pFilePath"
        $file = Get-ChildItem -Path $pFilePath
        $fileContent = [IO.File]::ReadAllText($file)
        return $fileContent
    }catch{
        Throw New-Object System.IO.IOException ("Error loading content: $_")
	    exit
    }
}

# Function that executes a sql file located in the script directory
Function Execute-Sql-File{
    Param ([string]$pFileName, [string]$pConnectionString) 

    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $pConnectionString
    try{
        Write-Host "Executing $pFileName script..."
        $sqlConnection.Open()
        $completeFilePath = Join-Path $currentDirectorypath $pFileName
        $sqlScript = (Get-Content-From-File $completeFilePath)
        $sqlCommand = New-Object Data.SqlClient.SqlCommand $sqlScript, $sqlConnection
        $sqlCommand.ExecuteNonQuery()  | Out-Null
    }catch{
        Throw New-Object System.Exception ("Error: $_")
	    exit
    }finally{
        # Close connection and dispose objects
	    $sqlConnection.Close()
        $sqlConnection.Dispose()  
    }
}

# Function that executes a store procedure
Function Execute-Store-Procedure{
    Param ([string]$pName, [string]$pParameters, [string]$pServerName, [string]$pDatabaseName) 
    Write-Host "Executing $pName store procedure"
    $sqlQuery = "exec $pName"
    if($pParameters -ne $null){
        $sqlQuery = $sqlQuery + " " + $pParameters
    }
    $result = $null
    try{
        # 1. Call the store procedure in the given database and server
        # 2. Set timeouts
        # 3. If there is an error during the calling stops the execution (jumping to catch block)
        # 4. Set the max length for chars to the maximum. By default this is set to 4000
	    $result = Invoke-Sqlcmd -Query $sqlQuery -ServerInstance $pServerName -Database $pDatabaseName `
                    -ConnectionTimeout 65535 -QueryTimeout 65535 `
                    -ErrorAction Stop  `
                    -MaxCharLength ([int]::MaxValue)
        return $result
    }catch{
        Throw New-Object System.Exception ("There was an issue executing $pName - $_")
        exit
    }
}

# Function that creates a CSV file from an array of objects
Function Create-Csv-File-From-Array{
    Param([string]$pFileName, [string]$pDirectoryPath, [System.Array]$pArray)
    Test-Path-And-Handle-Error $pDirectoryPath
    $fileName = Join-Path $pDirectoryPath ($pFileName + ".csv")
    try{
        Write-Host "Creating csv file: $fileName"
        # NoTypeInformation omits the information type comment that is set at the beginning of the csv file
        # Encoding Unicode is used to support rara characters such as Japanese or Chinese
        $pArray | Export-Csv $fileName -NoTypeInformation -Encoding Unicode
        Write-Host "Csv file created successfully"
    }catch{
        Throw New-Object System.Exception ("There was an issue creating csv file: $_")
        exit
    }
}

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
