### Scenario: Protecting an E-commerce Website

**Context:**
You run an e-commerce website that handles sensitive customer data and transactions. Recently, you noticed an increase in suspicious activity, including SQL injection attempts and DDoS attacks. To enhance your website's security, you decide to implement AWS WAF.

**Objectives:**
1. Protect against common web exploits (e.g., SQL injection, cross-site scripting).
2. Block malicious IP addresses.
3. Rate limit requests to prevent DDoS attacks.

**Implementation Steps:**

1. **Create a Web ACL:**
   - In the AWS WAF console, create a Web Access Control List (Web ACL) for your e-commerce application.

2. **Define Rules:**
   - **SQL Injection Rule:** Create a rule using AWS Managed Rules that automatically identifies and blocks SQL injection attempts.
   - **XSS Rule:** Add another rule for cross-site scripting (XSS), also leveraging AWS Managed Rules.
   - **IP Blocklist Rule:** Manually add a rule to block known malicious IP addresses that have been flagged in previous logs.
   - **Rate Limiting Rule:** Implement a rate limit rule to restrict requests from a single IP address to a maximum of 100 requests per minute.

3. **Set Rule Priorities:**
   - Arrange the rules in order of priority, ensuring that the SQL Injection Rule and XSS Rule are evaluated before the IP Blocklist Rule.

4. **Associate Web ACL with Resources:**
   - Associate the Web ACL with the Amazon CloudFront distribution serving your e-commerce site to ensure all incoming traffic is filtered.

5. **Monitoring and Logging:**
   - Enable AWS WAF logging to Amazon S3 to keep track of requests that are blocked or allowed. Use Amazon CloudWatch to set up alarms for unusual activity levels.

6. **Testing:**
   - Conduct penetration testing to simulate attacks and ensure that the WAF rules are functioning as intended.

7. **Review and Adjust:**
   - Regularly review the logs and adjust the rules based on new threats or changes in traffic patterns.

### Outcome:
With AWS WAF in place, your e-commerce website is better protected from common web vulnerabilities and malicious traffic. You can confidently handle customer transactions, knowing that AWS WAF is actively monitoring and defending against threats.