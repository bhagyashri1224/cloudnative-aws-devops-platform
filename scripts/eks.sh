eksctl create cluster \
  --name production-eks \
  --region us-east-1 \
  --nodegroup-name workers \
  --node-type c7i-flex.large \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 2 \
  --managed