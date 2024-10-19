### Scenario: Securing a Web Application in a VPC

**Background:**
You have deployed a web application in an AWS VPC. The application is hosted in a public subnet and needs to be accessible from the internet. However, you want to restrict access to certain IP ranges and protect your resources from malicious traffic.

**Requirements:**
1. Allow HTTP (port 80) and HTTPS (port 443) traffic from the internet.
2. Deny all other inbound traffic.
3. Allow all outbound traffic to maintain functionality for the web application.
4. Restrict access from specific IP ranges (e.g., only your corporate office’s IP range).

### Steps to Implement AWS VPC Network ACLs

1. **Create a VPC:**
   - Name the VPC `WebAppVPC` with a CIDR block of `10.0.0.0/16`.

2. **Create a Public Subnet:**
   - Name the subnet `PublicSubnet` with a CIDR block of `10.0.1.0/24`.

3. **Set Up the Network ACL:**
   - Create a new Network ACL called `WebAppACL` for the `PublicSubnet`.

4. **Configure Inbound Rules:**
   - Allow HTTP traffic from anywhere.
   - Allow HTTPS traffic from anywhere.
   - Deny all other inbound traffic.

   | Rule # | Type        | Protocol | Port Range | Source            | Allow/Deny |
   |--------|-------------|----------|------------|-------------------|------------|
   | 100    | HTTP       | TCP      | 80         | 0.0.0.0/0         | ALLOW      |
   | 200    | HTTPS      | TCP      | 443        | 0.0.0.0/0         | ALLOW      |
   | 300    | All Traffic | ALL     | ALL        | 0.0.0.0/0         | DENY       |

5. **Configure Outbound Rules:**
   - Allow all outbound traffic.

   | Rule # | Type        | Protocol | Port Range | Destination       | Allow/Deny |
   |--------|-------------|----------|------------|-------------------|------------|
   | 100    | All Traffic | ALL      | ALL        | 0.0.0.0/0         | ALLOW      |

6. **Restrict Access from Specific IP Ranges:**
   - If your corporate office has a static IP of `203.0.113.0/24`, you may want to allow SSH access for management purposes.

   | Rule # | Type        | Protocol | Port Range | Source            | Allow/Deny |
   |--------|-------------|----------|------------|-------------------|------------|
   | 400    | SSH        | TCP      | 22         | 203.0.113.0/24    | ALLOW      |

### Conclusion

By configuring a VPC Network ACL with specific inbound and outbound rules, you can effectively control the traffic to and from your web application. This setup ensures that your application is accessible to users while protecting it from unwanted traffic and potential attacks. The use of Network ACLs provides an additional layer of security alongside security groups, allowing for more granular control over traffic.