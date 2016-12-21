function Create-SqlTable {
    <#
    .Synopsis
    Create a Table in a SQL Database on a target server. Will also create the Database if it does not exist

    .Description
    Create a Table in a SQL Database on a target server. Will also create the Database if it does not exist

    .Parameter SqlServerName
    This is the name of the server SQL is installed on

    .Parameter DatabaseName
    The name of the database to create the table on. This function will also create the database if it does not exist

    .Parameter TableName
    The name of the table to create

    .Parameter TableCreationSQL
    Save the column info to a variable.

    .Example
    $SQL = "text_column text,varchar_column varchar,int_column int"
    Create-SqlTable -SqlServerName Server01 -DatabaseName MyDatabase -TableName MyTable -TableCreationSQL $SQL

    #>
        [CmdletBinding()]

        param (
            [Parameter(Mandatory=$true)]
            [string]$SqlServerName,
            [Parameter(Mandatory=$true)]
            [string]$DatabaseName,
            [Parameter(Mandatory=$true)]
            [string]$TableName,
            [Parameter(Mandatory=$true)]
            [string]$TableCreationSQL
        )

        BEGIN {
            Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: Starting script..."
            Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: SQL Server Name is $SqlServerName"
            Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: SQL Database Name is $DatabaseName"
            Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: Table to be created is $TableName"
            Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: Args for Table Creation $TableCreationSQL"
            Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: Loading Microsoft.SqlServer.Smo from .NET Assembly..."
            [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
            $DatabaseName = $DatabaseName.ToUpper()
            $SqlServerName = $SqlServerName.ToUpper()
        }
    
        PROCESS {
            Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: Begin Processing"
            $SqlDB = (New-Object ("Microsoft.SqlServer.Management.Smo.Server") $SqlServerName).databases | Where-Object {$_.Name -like "$DatabaseName"}
            if (! $SqlDB) {
                try {
                    Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: $DatabaseName Database not found, creating..."
                    Invoke-Sqlcmd -ServerInstance $SqlServerName -Query "CREATE DATABASE $DatabaseName;"
                    $SqlDB = (New-Object ("Microsoft.SqlServer.Management.Smo.Server") $SqlServerName).databases | Where-Object {$_.Name -like "$DatabaseName"}
                    if ($SqlDB) {
                        Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: $DatabaseName created Successfully!"
                    }
                    else {
                        Write-Error "[$((Get-Date -Format u))][Create-SqlTable]: Failed to create $DatabaseName Database."
                    }
                }
                catch {
                    Write-Error "[$((Get-Date -Format u))][Create-SqlTable]: Failed to create $DatabaseName Database."
                }
            }
            else {
                Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: $DatabaseName Database already exists!"
            }
            if (! ($SqlDB.Tables | Where-Object {$_.name -like "$TableName"})) {
                Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: $TableName table not found. Attempting to create..."
                Invoke-Sqlcmd -ServerInstance $SqlServerName -Database $DatabaseName -Query "CREATE TABLE $TableName($TableCreationSQL);"
                $SqlDB = (New-Object ("Microsoft.SqlServer.Management.Smo.Server") $SqlServerName).databases | Where-Object {$_.Name -like "$DatabaseName"}
                if ($SqlDB.Tables | Where-Object {$_.name -like "$TableName"}) {
                    Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: $TableName table created Successfully!"
                }
                else {
                    Write-Error "[$((Get-Date -Format u))][Create-SqlTable]: Failed to create $TableName table."
                }
            }
            else {
                Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: $TableName already exists!"
            }
        }

        END{
            Write-Verbose "[$((Get-Date -Format u))][Create-SqlTable]: Function Complete..."
        }
    }
