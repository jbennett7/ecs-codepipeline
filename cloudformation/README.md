# CloudFormation scripts
## Performing ECS blue/green deployment through CodeDeploy using AWS CloudFormation.
You can use CloudFormation to perform ECS blue/green deployments through CodeDeploy. Blue/green deployments are a safe deployment strategy provided by AWS CodeDeploy for minimizing interruptions caused by changing application versions. This is accomplished by creating your new application environment, referred to as _green_, alongside your current application that is serving your live traffic, referred to as _blue_. This allows for a period of time for monitoring and testing of the green environment before your live traffic is routed from blue to green and subsequently turning off the blue resources.

When using CloudFormation to perform ECS blue/green deployments, you start by creating a stack template that defines the resources for both your blue and green application environments, including specifying the traffic routing and stabilization settings to use. Next, you create a stack from that template; this generates your blue (current) application. CloudFormation only creates the blue resources during stack creation. Resources for a green deployment are not created until they are required.

Then, if in a future stack update you update the stask definition or task set resources in your blue application, CloudFormation does the following:
  * Generates all the necessary green application environment resources
  * Shifts the traffic based on the specified traffic routing parameters
  * Deletes the blue resources

If an error occurs at any point before the green deployment is successful and finalized, CloudFormation rolls the stack back to its state before the entire green deployment was initiated.

To enable CloudFormation to perform blue/green deployments on a stack, include the following information in its stack template:
  * A `Transform` section in your template that invokes the `AWS::CodeDeployBlueGreen` transform, as well as a `Hook` section that invokes the `AWS::CodeDeploy::BlueGreen` hook.
  * At least one of the ECS resources that will trigger a blue/green deployment if replaced during a stack update. Currently, those resources are `AWS::ECS::TaskDefinition` and `AWS::ECS::TaskSet`.

Then, if you initiate a stack update that updates any properties of the above resources that requires CloudFormation to replace the resource, CloudFormation performs a blue/green deployment as described above. For more information on resource update behavior, see [Update behaviors of stack resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-update-behaviors.html).

In many cases, you'll want to set up your stack template to enable blue/green deployments _before_ you create the stack. However, you can also add the ability to have CloudFormation perform blue/green deployments to an existing stack. To do so, add the necessary information to the stack's existing template.

In addition, we recommend you have CloudFormation generate a [change set](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html) for the green deployment, prior to initiating the stack update. This enables you to review the actual changes that will be made to the stack.
### Modeling your blue/green deployment using CloudFormation resources
In order to perform ECS blue/green deployment using CodeDeploy through CloudFormation, your template needs to include the resources that model your deployment, such as an Amazon ECS service and load balancer. For more details on what these resources represent, see [Before you begin an Amazon ECS deployment](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-steps-ecs.html#deployment-steps-prerequisites-ecs) in the _AWS CodeDeploy User Guide_.
| Requirement                               | Resource                                            | Required/Optional                         | Triggers blue/green deployment if replaced |
|-------------------------------------------|-----------------------------------------------------|-------------------------------------------|--------------------------------------------|
| Amazon ECS Cluster                        | [AWS::ECS::Cluster](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-cluster.html)                                   | Optional. The default cluster can be used | No                                         |
| Amazon ECS Service                        | [AWS::ECS::Service](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-service.html)                                   | Required                                  | No                                         |
| Application or Network Load Balancer      | [AWS::ECS::ServiceLoadBalancer](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ecs-service-loadbalancers.html)                       | Required                                  | No                                         |
| Production Listener                       | [AWS::ElasticLoadBalancerV2::Listener](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-listener.html)                | Required                                  | No                                         |
| Test Listener                             | [AWS::ElasticLoadBalancerV2::Listener](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-listener.html)                | Optional                                  | No                                         |
| Two Target Groups                         | [AWS::ElasticLoadBalancerV2::TargetGroup](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-targetgroup.html)             | Required                                  | No                                         |
| Amazon ECS Task Definition                | [AWS::ECS::TaskDefinition](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-taskdefinition.html)                            | Required                                  | Yes                                        |
| Container for your Amazon ECS application | [AWS::ECS::TaskDefinition Container Definition Name](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ecs-taskdefinition-containerdefinitions.html#cfn-ecs-taskdefinition-containerdefinition-name.html)  | Required                                  | No                                         |
| Port for your replacement task set        | [AWS::ECS::TaskDefinition PortMapping Container Port](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ecs-taskdefinition-containerdefinitions-portmappings.html#cfn-ecs-taskdefinition-containerdefinition-portmappings-containerport.html) | Required                                  | No                                         |
### Resource updates that trigger green deployments
If you perform a stack update that updates any property that requires [replacement](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-update-behaviors.html) for the followign ECS resources, CloudFormation inititates a green deployment:
  * [AWS::ECS::TaskDefinition](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-taskdefinition.html)
  * [AWS::ECS::TaskSet](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-taskset.html)

Updating properties in these resources that do not require resource replacement does not trigger a green deployment.

You cannot include updates to the above resources with updates to other resources in the same stack update. If you need to update resources in the list above as well as other resources in the same stack, do one of the following:
  * Perform two seperate stack update operations: one that includes only the updates to the above resources, and a separate stack update that includes changes to any other resources.
  * Remove the `Transform` and `Hook` sections from your template and then perform the stack update. In this case, CloudFormation will not perform a green deployment.
### Considerations when managing ECS blue/green deployments using CloudFormation
You should consider the following when defining your blue/green deployment using CloudFormation:
  * Only updates to certain resources will trigger a green deployment, as discussed in [Resource updates that trigger ECS blue/green deployments](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/blue-green.html#blue-green-resources).
  * You cannot include updates to resources that trigger green deployments and updtes to other resources in the same stack update, as discussed in [Resource updates that trigger ECS blue/green deployments](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/blue-green.html#blue-green-resources).
  * You can only specify a single ECS service as the deployment target.
  * Parameters whose values are obfuscated by CloudFormation cannot be updated by the CodeDeploy service during a green deployment, and will lead to an error and stack update failure. These include:
    - Parameters defined with the `NoEcho` attribute.
    - Parameters that use dynamic references to retrieve their values from external services. For more information, see [Using dynamic references to specify template values](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/dynamic-references.html).
  * To cancel a green deployment that is still in progress, cancel the stack update in CloudFormation, not CodeDeploy or ECS. For more information, see [Canceling a stack update](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn--stack-update-cancel.html). (After an update has finished, you cannot cancel it. You can, however, update a stack again with any previous settings.)
  * Declaring [output values](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) or [importing values](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-importvalue.html) from other stacks is not currently supported for templates defining blue/green ECS deployments.
  * [Importing existing resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/resource-import.html) is not currently supported for templates defining blue/green ECS deployments.
  * You cannot use the `AWS::CodeDeploy::BlueGreen` hook in a template that includes nested stack resources.
  * You cannot use the `AWS::CodeDeploy::BlueGreen` hook in a [nested stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html).

For information on how using CloudFormation to perform your ECS blue/green deployments through CodeDeploy differs from a standard Amazon ECS deployment using just CodeDeploy, see [Differences between Amazon ECS Blue/Green deployments through AWS CloudFormation and standard Amazon ECS deployments](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-create-prerequisites.html) in the _AWS CodeDeploy User Guide_.
### Preparing your template to perform ECS blue/green deployments

