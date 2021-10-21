Set-ExecutionPolicy RemoteSigned 
Initialize-AWSDefaults

$MainJen = "C:\Jen"
$JobsDirPath = $MainJen + "\jobs"
$SecretsDirPath = $MainJen + "\secrets"
$JenkinsDirPath = "C:\Windows\System32\config\systemprofile\AppData\Local\Jenkins.jenkins\"
$ZipFilePath = "C:\scriptsforJenkins\" + "jen.zip"
# Constants
$s3Bucket = "xx"
$s3Folder = "JenkinsJobsZips"

# Constants – Amazon S3 Credentials
$accessKeyID=""
$secretAccessKey=""
$RegionEndPoint = "us-west-2"

# Cretae folder with path provided
function CreateDirectory([string]$path) {

    if(-not (Test-Path $path)) {
        try {
            New-Item -Path $path -ItemType directory
        }
        catch {
            Write-Error -Message "Unable to create directory '$path'. Error was: $_" -ErrorAction Stop
        }

    }
}

CreateDirectory($JobsDirPath)

$FolderNames = Get-ChildItem -Path ($JenkinsDirPath + "jobs\") -Name

# Create folder names as in jobs folder and copy congig file  
for($num=0;$num -lt $FolderNames.Length; $num++){
    
    $ConfigxmlSouPath = $JenkinsDirPath + "jobs\"+ $FolderNames[$num] + "\config.xml"
    $ConfigxmlDestPath = $JobsDirPath + "\" + $FolderNames[$num]
    CreateDirectory($ConfigxmlDestPath)
    $res = Copy-Item $ConfigxmlSouPath $ConfigxmlDestPath    
}

Copy-Item -Path ($JenkinsDirPath + "\secrets") $MainJen -Recurse
Copy-Item -Path ($JenkinsDirPath + "\credentials.xml") $MainJen
Compress-Archive -Path ($MainJen + "\*") -CompressionLevel Optimal -DestinationPath $ZipFilePath

Remove-Item $MainJen -Recurse

# Instantiate the AmazonS3Client object
Initialize-AWSDefaults -Region $RegionEndPoint -AccessKey $accessKeyID -SecretKey $secretAccessKey


$year = Get-Date -Format "yyyy"
$month = Get-Date -Format "MM"
$day = Get-Date -Format "dd"


$s3Path = "/" + $s3Folder + "/" + $year + "/" + $month + "/" + $day + "/jen.zip"

Write-S3Object -BucketName $s3Bucket -File $ZipFilePath -Key $s3Path
 
Remove-Item $ZipFilePath