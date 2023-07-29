# Import the AWS module
Import-Module AWSPowerShell.NetCore

# Retrieve AWS credentials from environment variables
$accessKey = $env:AWS_ACCESS_KEY_ID
$secretKey = $env:AWS_SECRET_ACCESS_KEY

# Check if the credentials are available
if ([string]::IsNullOrEmpty($accessKey) -or [string]::IsNullOrEmpty($secretKey)) {
    Write-Error "AWS credentials not found. Make sure AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables are set."
    Exit
}

# Set the AWS region
Set-DefaultAWSRegion -Region "eu-west-1"

# Set up AWS credentials
Initialize-AWSDefaultConfiguration -AccessKey $accessKey -SecretKey $secretKey

function Show-WhatsUp {
    # Retrieve registered AMIs
    Write-Output "Registered AMIs:"
    $registeredAMIs = Get-EC2Image -Owner self
    $registeredAMIs | Select-Object -Property ImageId, Name, CreationDate | Format-List

    # Retrieve running spot requests
    Write-Output "`nRunning Spot Requests:"
    $spotRequests = Get-EC2SpotInstanceRequest
    $spotRequests | Select-Object -Property SpotInstanceRequestId, State, InstanceId, SpotPrice, LaunchSpecification | Format-List

    Write-Output "`nRunning Instances:"
    $instances = Get-EC2Instance

    # Iterate through each instance and display its ID and status
    foreach ($instance in $instances.Instances) {
        $instanceId = $instance.InstanceId
        $status = $instance.State.Name
    
        Write-Output "Instance ID: $instanceId"
        Write-Output "Status: $status"
    }

    Write-Output "`nVolumes:"
    $volumes = Get-EC2Volume

    # Iterate through each volume and display its ID and status
    foreach ($volume in $volumes) {
        $volumeId = $volume.VolumeId
        $status = $volume.State

        Write-Output "Volume ID: $volumeId"
        Write-Output "Status: $status"
    }
}

function New-Ami {
    Write-Output "Creating a new AMI"

    $startTime = Get-Date

    $packerBuildCommand = "packer build -var-file='parsec-dcv-gaming-svr.pkrvars.hcl' parsec-dcv-gaming-svr.pkr.hcl"
    Invoke-Expression -Command $packerBuildCommand

    $endTime = Get-Date
    $executionTime = $endTime - $startTime

    Write-Output "`nExecution Time: $executionTime"
}

function SpinUp-Inst {
    param ($AmiId, $InstType, $InstSize)

    Write-Output "Spinning up a spot request for AMI $AmiId"

    $startTime = Get-Date
    $terraformApplyCommand = "terraform -chdir='./Terraform' apply -var='ami_id=$AmiId' -var='instance_type=$InstType' -var='instance_size=$InstSize'"
    Invoke-Expression -Command $terraformApplyCommand
    $endTime = Get-Date
    $executionTime = $endTime - $startTime

    Write-Output "`nExecution Time: $executionTime"
}

function Destroy-Inst {
    Write-Output "Destroying instance $AmiId - note this will only work if terraform is managing state for a running instance"

    $startTime = Get-Date
    $terraformApplyCommand = "terraform -chdir='./Terraform' destroy -var='ami_id=dummy'"
    Invoke-Expression -Command $terraformApplyCommand
    $endTime = Get-Date
    $executionTime = $endTime - $startTime

    Write-Output "`nExecution Time: $executionTime"
}

function Save-Inst {
    param ($InstId, $AmiName)

    Write-Output "Creating an AMI from instance $InstId"

    $startTime = Get-Date
    $newImageId = New-EC2Image -InstanceId $InstId -Name $AmiName -Description "Mid-game: Saved AMI from running instance"

    $endTime = Get-Date
    $executionTime = $endTime - $startTime

    Write-Output "`nExecution Time: $executionTime"

    Write-Output "`nYou'll need to wait for the AMI $newImageId to become available - use"
    Write-Output "     aws ec2 wait image-available --image-ids $newImageId"
    Write-Output ".. to check on the status"
}

Write-Output "Gaming Server CLI (arf)"

Write-Output "`nHere's what's up:"
Show-WhatsUp

Write-Output "`nWhat do you want to do?"
Write-Output " 1. Create a new AMI"
Write-Output " 2. Spin up an instance from an existing AMI"
Write-Output " 3. Save an AMI and snapshot of a running instance"
Write-Output " 4. Destroy a running instance"
Write-Output " 5. (Or any other input) Just quit"

$opt = Read-Host "`nWell?"
Switch ($opt) {
    "1" { New-Ami }
    "2" { 
        $Id = Read-Host "Give me the AMI ID" 
        $Instance_Type = "Give me the instance type"
        $Instance_Size = "Give me the EBS volume size"
        SpinUp-Inst -AmiId $Id -InstType $Instance_Type -InstSize $Instance_Size
    }
    "3" {
        $InstId = Read-Host "Give me the ID of the instance to save"
        $AmiName = Read-Host "Name your new AMI"
        Save-Inst $InstId $AmiName
    }
    "4" { 
        Destroy-Inst
    }
    default {
        Write-Output "I'm assuming you said 'quit'."
    }
}