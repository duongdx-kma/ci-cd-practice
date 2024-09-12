# stop - start using AWS CLI:

```powershell

# list running instances:
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output text

# stop instance
aws ec2 stop-instances --instance-ids i-06b4cfa5e229d7ec2
aws ec2 stop-instances --instance-ids i-02773a54ce5296841

# start instance
aws ec2 start-instances --instance-ids i-02773a54ce5296841
aws ec2 start-instances --instance-ids i-06b4cfa5e229d7ec2
```