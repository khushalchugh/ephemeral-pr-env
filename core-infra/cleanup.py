import boto3
from datetime import datetime, timezone, timedelta

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    max_age_in_hours = 168
    now = datetime.now(timezone.utc)

    response = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:Environment', 'Values': ['ephemeral']},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )

    instance_to_terminate = []

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            if (now - instance['LaunchTime']) > timedelta(hours=max_age_in_hours):
                instance_to_terminate.append(instance['InstanceId'])

    if instance_to_terminate:
        ec2.terminate_instances(InstanceIds=instance_to_terminate)
        print(f"Terminated: {instance_to_terminate}")
    else:
        print("No action needed.")