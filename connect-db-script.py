import pyodbc

# Connecting to Azure SQl the standard way
server = 'crgar-aks-msi-db-server.database.windows.net' 
database = 'crgar-aks-msi-db' 
driver = '{ODBC Driver 17 for SQL Server}'


with pyodbc.connect(
    "Driver="
    + driver
    + ";Server="
    + server
    + ";PORT=1433;Database="
    + database
    + ";Authentication=ActiveDirectoryMsi"
    + ";Encrypt=yes;TrustServerCertificate=no",
) as conn:
    with conn.cursor() as cursor:
        #Sample select query
        cursor.execute("SELECT TOP 3 [name] FROM [dbo].[Pets]") 
        peopleNames = ''
        row = cursor.fetchone() 
        while row: 
            peopleNames += str(row[0]).strip() + " " 
            row = cursor.fetchone()
