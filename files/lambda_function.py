import boto3
import json

def lambda_handler(event, context):
    sns             = boto3.client('sns')
    sagemaker       = boto3.client('sagemaker',region_name='us-east-1')
    ec2             = boto3.client('ec2', region_name='us-east-1')
    ec2_resource    = boto3.resource('ec2', region_name='us-east-1')
    glue            = boto3.client('glue', region_name='us-east-2')

    ec2_response        = ec2.describe_instances()
    sagemaker_response  = sagemaker.list_notebook_instances()
    sagemaker_endpoint  = sagemaker.list_endpoints()
    glue_endpoint       = glue.get_dev_endpoints()

    ec2_message         = "   InstanceId      '\t \t'        Launch Time      '\t \t'       Instance Type   '\t \t' + Platform " + '\t \t' +  "Instance name " + "\n"
    ebs_message         = "   VolumeID        '\t \t \t'     Creation Date    '\t \t'       Volume Size "   "\n"
    sagemaker_message   = "   InstanceName    '\t \t \t'     Launch Time      '\t \t'       Instance Type "  "\n"
    sagemaker_endpoint__message   = "   InstanceName    '\t \t \t'     Launch Time   "  "\n"
    glue_endpoint_message   = "   InstanceName    '\t \t \t' "  "\n"

    for reservation in ec2_response["Reservations"]:
        for ec2_instance in reservation["Instances"]:
            try:

                if(ec2_instance["State"].get('Name') == "running"):
                    try:
                        for tags in ec2_instance["Tags"]:
                            InstanceTag = tags["Value"]
                            ec2_message += ec2_instance["InstanceId"] + '\t \t'  + str(ec2_instance["LaunchTime"]) + '\t \t' + ec2_instance["InstanceType"] +  '\t \t' + ec2_instance["Platform"] + '\t \t' + tags["Value"] + '\n'
                            break
                    except Exception, e:
                        ec2_message += ec2_instance["InstanceId"] + '\t \t'  + str(ec2_instance["LaunchTime"]) + '\t \t' + ec2_instance["InstanceType"] +  '\t' + ec2_instance["Platform"] + '\t' + "No Name specified" + '\n'

            except Exception, e:
                ec2_message += ec2_instance["InstanceId"] + '\t \t'  + str(ec2_instance["LaunchTime"]) + '\t \t' + ec2_instance["InstanceType"] +  '\t \t' + "Unix" + '\t \t' + InstanceTag + '\n'

                print "number:" + ec2_instance["InstanceType"][1]
                if(int(ec2_instance["InstanceType"][1]) > 3):
                    ec2.stop_instances(InstanceIds= [ec2_instance["InstanceId"]])
                    ec2_message += '\n' + "Stopping Instance:-" + '\t \t' + ec2_instance["InstanceId"] + '\n'

    for volume in ec2_resource.volumes.all():
        if volume.state=='available':
            ebs_message += volume.id + '\t \t \t'  + str(volume.create_time) + '\t \t' + volume.size +  '\n'


    for sagemaker_instance in sagemaker_response['NotebookInstances']:

        if(sagemaker_instance['NotebookInstanceStatus'] == "InService"):
            sagemaker_message += sagemaker_instance['NotebookInstanceName'] + '\t \t \t'  + str(sagemaker_instance['CreationTime']) + '\t \t' + sagemaker_instance["InstanceType"] +  '\n'

    for endpoint in sagemaker_endpoint['Endpoints']:

        if(endpoint['EndpointStatus'] == "InService"):
            sagemaker_endpoint__message += endpoint['EndpointName'] + '\t \t \t'  + str(endpoint['CreationTime']) +  '\n'

    for endpoint in glue_endpoint['DevEndpoints']:
        if(endpoint['Status'] == "READY"):
            glue_endpoint_message += endpoint['EndpointName'] + '\t \t \t' +  '\n'

    response = sns.publish(
        TargetArn = "arn:aws:sns:us-east-1:<Acc>:StopEC2Instances",
        Message = '********************************************EC2 Status********************************************** \n' +
                  ec2_message + '\n' +
                  '***************************************EBS Volumes Status****************************************** \n' +
                  ebs_message + '\n' +
                  '************************************Sagemaker Notebook Status************************************** \n' +
                  sagemaker_message + '\n' +
                  '************************************Sagemaker Endpoints Status************************************* \n' +
                  sagemaker_endpoint__message + '\n' +
                  '************************************Glue Dev Endpoints Status************************************** \n' +
                  glue_endpoint_message,
        Subject="AWS Sannbox account services status after 9 PM "
    )
