import json
import boto3

def lambda_handler(event, context):
    try:
        ec2client = boto3.client('ec2')
        response = ec2client.describe_volumes()
        
        for volume in response["Volumes"]:
            
            volumeID = volume["VolumeId"]
            if "Tags" in volume:
                for tag in volume["Tags"]:
                    if tag["Key"].lower() == "backup" and tag["Value"].lower() == "yes":
                        instanceID = "::None::"
                        for attachment in volume["Attachments"]:
                            if "InstanceId" in attachment:
                                instanceID = attachment["InstanceId"]
                        
                        print("Creating Snapshot for EBS Volume " + volumeID + " attached to " + instanceID)
                        snapshotResponse = ec2client.create_snapshot(VolumeId=volumeID,
                        TagSpecifications=[{
                            'ResourceType': 'snapshot',
                            'Tags': [
                                {'Key': 'OriginalVolumeID','Value': volumeID},
                                {'Key': 'OriginalVolumeTags','Value': str(volume["Tags"])},
                                {'Key': 'InstanceId','Value': instanceID},
                                {'Key': 'Encrypted','Value': str(volume["Encrypted"])},
                                {'Key': 'Name','Value': "Auto Backup for " + volumeID + " attached to " + instanceID},
                                {'Key': 'Expiry','Value': 7 },
                                ]
                            }])
                        if snapshotResponse["SnapshotId"]:
                            print("Created Snapshot " + snapshotResponse["SnapshotId"])
                        else:
                            print("Error Creating Snapshot for EBS Volume " + volumeID)
        return {
            "statusCode": 200,
            "body": json.dumps('Successful Backup')
        }
    except:
        return {
        "statusCode": 400,
        "body": json.dumps('Error in backing up EBS Volumes')
        }
