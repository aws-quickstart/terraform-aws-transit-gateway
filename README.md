https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-isolated-shared.html


You can configure your transit gateway as multiple isolated routers that use a shared service. This is similar to using multiple transit gateways, but provides more flexibility in cases where the routes and attachments might change. In this scenario, each isolated router has a single route table. All attachments associated with an isolated router propagate and associate with its route table. Attachments associated with one isolated router can route packets to each other, but cannot route packets to or receive packets from the attachments for another isolated router. Attachments can route packets to or receive packets from the shared services. You can use this scenario when you have groups that need to be isolated, but use a shared service, for example a production system.

Contents

Overview
Routing
Overview
The following diagram shows the key components of the configuration for this scenario. Packets from the subnets in VPC A, VPC B, and VPC C that have the internet as a destination, first route through the transit gateway and then route to the Site-to-Site VPN. Packets from subnets in VPC A, VPC B, or VPC C that have a destination of a subnet in VPC A, VPC B, or VPC C (for example from 10.1.0.0 to 10.2.0.0) route through the transit gateway, where they are blocked because there is no route for them in the transit gateway route table. Packets from VPC A, VPC B, and VPC C that have VPC D as the destination route through the transit gateway and then to VPC D.

![private subnet public load balancer](images/transit.png)

In this scenario, you create the following entities:

Four VPCs. For information about creating a VPC, see [Getting started with Amazon VPC](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-getting-started.html#getting-started-create-vpc).

A transit gateway. For more information, see [Create a transit gateway](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-transit-gateways.html#create-tgw).

Four attachments on the transit gateway for the four VPCs. For more information, see Create a transit gateway attachment to a VPC.

A Site-to-Site VPN attachment on the transit gateway. For more information, see Create a transit gateway attachment to a VPN. Ensure that you review the requirements for your customer gateway device in the AWS Site-to-Site VPN User Guide.

When the VPN connection is up, the BGP session is established and the VPN CIDR propagates to the transit gateway route table and the VPC CIDRs are added to the customer gateway BGP table.

Routing
Each VPC has a route table, and the transit gateway has two route tables—one for the VPCs and one for the VPN connection and shared services VPC.

VPC A, VPC B, VPC C, and VPC D route tables
Each VPC has a route table with 2 entries. The first entry is the default entry for local IPv4 routing in the VPC; this entry enables the instances in this VPC to communicate with each other. The second entry routes all other IPv4 subnet traffic to the transit gateway. The following table shows the VPC A routes.

Destination	Target
10.1.0.0/16

local

0.0.0.0/0	
tgw-id

Transit gateway route tables
This scenario uses one route table for the VPCs and one route table for the VPN connection.

The VPC A, B, and C attachments are associated with the following route table, which has a propagated route for the VPN attachment and a propagated route for the attachment for VPC D.

Destination	Target	Route type
10.99.99.0/24	
Attachment for VPN connection

propagated

10.4.0.0/16	
Attachment for VPC D

propagated

The VPN attachment and shared services VPC (VPC D) attachment are associated with the following route table, which has entries that point to each of the VPC attachments. This enables communication to the VPCs from the VPN connection and the shared services VPC.

Destination	Target	Route type
10.1.0.0/16

Attachment for VPC A

propagated

10.2.0.0/16

Attachment for VPC B

propagated

10.3.0.0/16

Attachment for VPC C

propagated

10.4.0.0/16	
Attachment for VPC D

propagated
For more information about propagating routes in a transit gateway route table, see Propagate a route to a transit gateway route table.

