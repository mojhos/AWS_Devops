import boto3, datetime
from typing import Dict, Any, List, Optional
from config import Config

session = boto3.Session(region_name=Config.AWS_REGION)
ec2 = session.client("ec2")
asg = session.client("autoscaling")
cw = session.client("cloudwatch")
ssm = session.client("ssm")

def list_instances(filters: Optional[List[Dict[str, Any]]] = None) -> List[Dict[str, Any]]:
    resp = ec2.describe_instances(Filters=filters or [])
    items = []
    for r in resp["Reservations"]:
        for i in r["Instances"]:
            items.append(i)
    return items

def get_asgs() -> List[Dict[str, Any]]:
    resp = asg.describe_auto_scaling_groups()
    return resp.get("AutoScalingGroups", [])

def set_asg_capacity(asg_name: str, desired: int):
    asg.update_auto_scaling_group(AutoScalingGroupName=asg_name, DesiredCapacity=desired)

def cw_metric(namespace: str, metric: str, dim: List[Dict[str, str]], stat="Average", period=300, minutes=60):
    end = datetime.datetime.utcnow()
    start = end - datetime.timedelta(minutes=minutes)
    resp = cw.get_metric_statistics(
        Namespace=namespace,
        MetricName=metric,
        Dimensions=dim,
        StartTime=start,
        EndTime=end,
        Period=period,
        Statistics=[stat],
    )
    dps = sorted(resp.get("Datapoints", []), key=lambda x: x["Timestamp"])
    return dps

def ssm_run_command(instance_ids: List[str], commands: List[str], comment="AdminPanel Command"):
    resp = ssm.send_command(
        InstanceIds=instance_ids,
        DocumentName="AWS-RunShellScript",
        Parameters={"commands": commands},
        Comment=comment,
    )
    cmd_id = resp["Command"]["CommandId"]
    return cmd_id

def ssm_command_output(command_id: str, instance_id: str) -> str:
    try:
        out = ssm.get_command_invocation(CommandId=command_id, InstanceId=instance_id)
        return f"Status: {out.get('Status')}\n\nSTDOUT:\n{out.get('StandardOutputContent','')}\n\nSTDERR:\n{out.get('StandardErrorContent','')}"
    except ssm.exceptions.InvocationDoesNotExist:
        return "Pending..."
