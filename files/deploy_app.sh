#!/bin/bash
# Script to deploy a very simple web application.
# The web app displays a professional resume.

sudo apt -y update
sudo apt -y install apache2 cowsay
sudo systemctl start apache2
sudo chown -R ubuntu:ubuntu /var/www/html

cat << EOM > /var/www/html/index.html
<html>
  <head>
    <title>${project} Resume</title>
    <style>
      body { font-family: Arial, sans-serif; line-height: 1.6; margin: 20px; background-color: #f8f9fa; }
      h1, h2, h3 { color: #333; }
      ul { list-style-type: disc; padding-left: 20px; }
      .contact { text-align: center; font-weight: bold; margin-bottom: 20px; }
      .section { margin-bottom: 20px; }
      .success-story { text-align: center; margin-bottom: 20px; }
      .success-story a { 
        display: inline-block; 
        background-color: #007bff; 
        color: white; 
        padding: 10px 20px; 
        text-decoration: none; 
        border-radius: 5px; 
        font-weight: bold; 
        transition: background-color 0.3s ease; 
      }
      .success-story a:hover { background-color: #0056b3; }
    </style>
  </head>
  <body>
  <img src="https://chase-mitchell-resume-images-development-jain.s3.us-east-1.amazonaws.com/datacenterleft.png" 
       style="position:absolute; top:10px; left:10px; width:360px;">

  <img src="https://chase-mitchell-resume-images-development-jain.s3.us-east-1.amazonaws.com/datacenterright.png" 
       style="position:absolute; top:10px; right:10px; width:360px;">

  <div style="max-width: 800px; margin: 0 auto;">

      <!-- SUCCESS STORY LINK -->
      <div class="success-story">
        <a href="https://nexgent.com/zero-to-engineer-from-college-debt-to-debt-free-network-engineer/" target="_blank">Discover My Success Story: From College Debt to Debt-Free Network Engineer</a>
      </div>

      <!-- RESUME CONTENT -->
      <div class="contact">
        <h1>Chase Loyd Mitchell</h1>
        <p>cmitchellangelo@gmail.com | (830) 357-8935</p>
      </div>

      <div class="section">
        <h2>Career Summary</h2>
        <p>AWS and Cisco-certified Principal Cloud Engineer recognized for automating multi-cloud solutions. Skilled in building AWS/Azure infrastructures using Terraform, Python, Kubernetes, and implementing CI/CD pipelines while meeting government compliance requirements and optimizing containerized app performance. Thrives in fast-paced environments, quickly mastering new technologies to deliver scalable, cost-effective solutions.</p>
      </div>

      <div class="section">
        <h2>Core Competencies</h2>
        <ul>
          <li>AWS/Azure Solutions</li>
          <li>Network Management</li>
          <li>Solution Development</li>
          <li>Agile methodologies</li>
          <li>Troubleshooting</li>
          <li>Communication</li>
          <li>Automation/Terraform Cloud</li>
          <li>Client Engagement</li>
          <li>Process Improvement</li>
          <li>Pipelines</li>
          <li>Linux and Windows administration</li>
          <li>Customer Service</li>
        </ul>
      </div>

      <div class="section">
        <h2>Education</h2>
        <ul>
          <li>Bachelor of Business Administration, Management Information Systems, 2012<br>Angelo State University, San Angelo Texas</li>
        </ul>
      </div>

      <div class="section">
        <h2>Certifications</h2>
        <ul>
          <li>AWS Certified Solutions Architect Associate: License RN658QDK2BBE1DWY</li>
          <li>CCNA Routing and Switching Cisco ID: CSCO12792230</li>
          <li>CCNA Data Center (640-911) Cisco ID: CSCO12792230</li>
          <li>Network Plus</li>
        </ul>
      </div>

      <div class="section">
        <h2>Information Technology Experience</h2>

        <h3>SAIC, Remote (05/2023-Present)</h3>
        <p><strong>Principal Cloud Engineer</strong></p>
        <ul>
          <li>Key Achievement &ndash; Spearheaded the inaugural rollout of automated AWS/Azure solutions via catalog items, delivering fully configured environments to fifteen Virginia State (VITA) agencies and eliminating manual deployment processes.</li>
          <li>Streamlining Cloud Resource Management: Leveraging Infrastructure as Code (Terraform) and Python-based workflows within the Morpheus Data platform to build AWS/Azure catalog items, eliminating manual customer provisioning and accelerating the deployment process.</li>
          <li>EKS Management and Compliance Expertise: Managing and maintaining EKS clusters in an AWS GovCloud environment to host the Morpheus Data platform, ensuring compliance with VITA Standard SEC 530 and FedRAMP requirements. Responsible for optimizing cluster performance, ensuring high availability, and supporting integrated services like M2, GitLab, and Apptio. Utilizing HELM for efficient application deployment and configuration management within the cluster.</li>
        </ul>

        <h3>TEK Systems Contractor for Walt Disney, Remote (11/2021-4/2023)</h3>
        <p><strong>Cloud Systems Engineer</strong></p>
        <ul>
          <li>Key Achievement &ndash; Implemented the first Azure Stack HCI solution for Disney&rsquo;s resorts and waterparks, establishing a robust on-premises backup environment for Azure-based AKS clusters. Ensured minimal downtime and maintained business continuity whenever the primary cloud environment experienced disruptions</li>
          <li>Designed and Deployed Kubernetes projects using Azure DevOps Pipelines, ensuring efficient and reliable application delivery.</li>
          <li>Developed and Maintained Terraform code to provision and manage new AWS infrastructure for application teams.</li>
          <li>Automated Infrastructure Tasks by managing Run Deck jobs to streamline version control and deployment processes for Infrastructure as Code (IaC) projects.</li>
          <li>Proactively Monitored and Troubleshot applications using Splunk and AppDynamics, resolving issues before they impacted performance.</li>
        </ul>

        <h3>Prometheus Group, Remote (4/2021 &ndash; 11/2021)</h3>
        <p><strong>Cloud Operations Engineer</strong></p>
        <ul>
          <li>Key Achievement &ndash; Placed on high performance list two quarters in a row for deploying many new customer environments. Bonus and raise my 3rd month on the team. </li>
          <li>Developed and Deployed automated AWS infrastructure solutions using Terraform, streamlining the onboarding process for new customers.</li>
          <li>Engineered and Optimized HELM charts and Kubernetes configurations tailored to the Terraform-built environments.</li>
          <li>Oversaw and Managed end-to-end customer environments, ensuring seamless operations from application deployment to infrastructure maintenance.</li>
          <li>Authored and maintained comprehensive documentation detailing processes and best practices for building and managing customer environments.</li>
          <li>Interfaced with customers, Project Managers, SRE&rsquo;s to hash out internal/external SAP and/or SSO problems with current builds.</li>
          <li>Scripted/Updated/Used; AWS Config documents to help automate older applications.</li>
        </ul>

        <h3>Apex Contractor for Whole Foods Market, Austin Texas (9/2019 - 3/2021)</h3>
        <p><strong>Cloud Engineer</strong></p>
        <ul>
          <li>Key Achievement &ndash; Built the first automated pipeline using Code Commit, AWS Config, and Systems Manager, while managing and guiding the evolution of enterprise cloud-based environments.</li>
          <li>Participate in projects associated with infrastructure management, system admin, system monitoring, making improvements to development environments, application load testing and automation efforts.</li>
          <li>Assist with efforts related to agile software release process, release engineering and application deployment.</li>
          <li>Establish and maintain effective relationships with Internal Infrastructure, Application and Business partners to understand needs, use, process problems and to facilitate effective implementation and transfer of cloud technologies.</li>
          <li>Plan and complete projects with minimal direction.</li>
          <li>Complete project documentation including diagram, data flow, status and usage reports, and support.</li>
          <li>Develop and manage capacity and growth projection forecasts of the environment within budgets.</li>
        </ul>

        <h3>Tangoe, Austin Texas (4/2016 &ndash; 9/2019)</h3>
        <p><strong>Associate Cloud Engineer (11/2018 &ndash; 9/2019)</strong></p>
        <ul>
          <li>Key Achievement &ndash; implemented first Infrastructure as Code builds to help streamline application environments. </li>
          <li>Wrote Terraform Infrastructure as Code, built entire environments from scratch, backed up in S3 </li>
          <li>Executed technical expertise to support the implementation and modernization of client-facing servers and networks</li>
          <li>Created and managed Kubernetes clusters with EKS</li>
          <li>Only IT member involved with JIRA workflows for software development in new DevOps space</li>
        </ul>

        <p><strong>Network Engineer (4/2016 &ndash; 11/2018)</strong></p>
        <ul>
          <li>Key Achievement &ndash; Major Data Foundry data center VSS upgrade to achieve higher throughput for all network and       server systems along with AWS solutions architect &ndash; associate certification. </li>
          <li>Research/Training &ndash; DevOps/CICD integration from legacy infrastructure using Jenkins, Ansible, &amp; Kubernetes</li>
          <li>Delivers hands-on support for Cisco routers, firewalls, VPN tunnels, switches, and wireless controllers, while maintaining and implementing updates to the broader Cisco network infrastructure alongside configuration adjustments for Palo Alto firewalls.</li>
          <li>AWS support and guidance for management, allowing for more reliable solutions</li>
          <li>Deployed Terraform and Ansible automation for Tangoe AWS and Oracle platforms</li>
          <li>Worked hand in hand with software team configuring Kubernetes and Docker PODs for new micro service app</li>
          <li>Upheld IP network design and allocation across the enterprise keeping standards in mind</li>
          <li>Preserved detailed knowledge of company network standards and the overall global network environments.</li>
          <li>Closely monitored Solar Winds platform to track network performance keeping downtimes to a minimum.</li>
          <li>Executed technical expertise to support the implementation and modernization of client-facing server and network systems as well as the applications they support.</li>
          <li>Conducted analysis of network characteristics, troubleshoots problems and recommends procurement, removals, and modifications to network and system components for Cisco base networks.</li>
        </ul>

        <h3>eLoyalty, Austin Texas (2015 - 2016) </h3>
        <p><strong>Cisco Service Desk Analyst</strong></p>
        <ul>
          <li>Key Achievement &ndash; Built out successful Care20/20 platform for the IRS and SSA to benefit their VOIP solutions. </li>
          <li>Collaborated with clients in providing troubleshooting of primarily Cisco UCCE solutions involving the Unified Contact Center Enterprise product suite</li>
          <li>Troubleshot cisco routers such as voice gateways, gatekeepers, and cisco switches, established if incidents are actual network problems, and performed problem isolation</li>
        </ul>
      </div>

      <!-- END RESUME CONTENT -->

    </div>
  </body>
</html>
EOM

cowsay ${project} Resume - Deployed!