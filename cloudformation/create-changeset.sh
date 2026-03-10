#!/bin/bash
# CostNova CloudFormation Change Set Script
# Creates a change set to preview changes before applying

STACK_NAME="costnova-staging"
CHANGESET_NAME="costnova-changeset-$(date +%Y%m%d-%H%M%S)"
TEMPLATE_FILE="file://costnova-stack.yaml"
REGION="us-east-1"

echo "=== CostNova CloudFormation Change Set ==="
echo "Stack:      $STACK_NAME"
echo "ChangeSet:  $CHANGESET_NAME"
echo "Region:     $REGION"
echo ""

# Determine change set type (CREATE for new stack, UPDATE for existing)
STACK_EXISTS=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" 2>&1)

if echo "$STACK_EXISTS" | grep -q "does not exist"; then
  CHANGE_SET_TYPE="CREATE"
  echo "Stack does not exist — creating a CREATE change set"
else
  CHANGE_SET_TYPE="UPDATE"
  echo "Stack exists — creating an UPDATE change set"
fi

echo ""

# Create the change set
echo "Creating change set..."
aws cloudformation create-change-set \
  --stack-name "$STACK_NAME" \
  --change-set-name "$CHANGESET_NAME" \
  --template-body "$TEMPLATE_FILE" \
  --change-set-type "$CHANGE_SET_TYPE" \
  --region "$REGION" \
  --parameters \
    ParameterKey=Environment,ParameterValue=staging \
    ParameterKey=InstanceType,ParameterValue=t3.medium \
    ParameterKey=DBInstanceClass,ParameterValue=db.t3.medium \
    ParameterKey=DBAllocatedStorage,ParameterValue=100 \
    ParameterKey=DBName,ParameterValue=costnova \
    ParameterKey=DBUsername,ParameterValue=admin \
    ParameterKey=DBPassword,ParameterValue=CHANGE_ME_BEFORE_RUNNING \
  --tags \
    Key=Client,Value=costnova \
    Key=Environment,Value=staging

echo ""
echo "Waiting for change set to be created..."
aws cloudformation wait change-set-create-complete \
  --stack-name "$STACK_NAME" \
  --change-set-name "$CHANGESET_NAME" \
  --region "$REGION" 2>&1

# Describe the change set (preview)
echo ""
echo "=== Change Set Preview ==="
aws cloudformation describe-change-set \
  --stack-name "$STACK_NAME" \
  --change-set-name "$CHANGESET_NAME" \
  --region "$REGION" \
  --query '{Status:Status,Changes:Changes[].{Action:ResourceChange.Action,Resource:ResourceChange.LogicalResourceId,Type:ResourceChange.ResourceType,Replacement:ResourceChange.Replacement}}' \
  --output table

echo ""
echo "To execute this change set, run:"
echo "  aws cloudformation execute-change-set \\"
echo "    --stack-name $STACK_NAME \\"
echo "    --change-set-name $CHANGESET_NAME \\"
echo "    --region $REGION"
echo ""
echo "To delete this change set without applying:"
echo "  aws cloudformation delete-change-set \\"
echo "    --stack-name $STACK_NAME \\"
echo "    --change-set-name $CHANGESET_NAME \\"
echo "    --region $REGION"
