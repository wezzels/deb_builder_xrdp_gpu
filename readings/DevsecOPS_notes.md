# DevSecOps Overview

DevSecOps has finally become popular within the wider IT industry in 2019. I started as a web developer in 2001, learned about testing automation, system deployment automation, and "infrastructure as code" in 2012, when DevOps has becoming a popular term. DevOps became common after the release of The Phoenix Project in Jan 2013. It has taken 7 years for security to become integrated within the devops methodology. The following is a list of concepts I go through with project owners, project managers, operations, developers, and security teams, to help establish how mature their devops and security automation is, and to help them increase that maturity over time. This model is based on experience consulting with a variety of US Financial, Healthcare, and Department of Defense, organizations, and combines:
- [PCI DSS](https://www.pcisecuritystandards.org/)
- [NYDFS](https://www.dfs.ny.gov/industry_guidance/cybersecurity)
- [HITRUST CSF](https://hitrustalliance.net/product-tool/hitrust-csf/)
- [HIPAA](https://www.hipaajournal.com/hipaa-compliance-checklist/)
- [NIST 800-series](https://www.nist.gov/itl/publications-0/nist-special-publication-800-series-general-information)
- [FIPS 140-2](https://csrc.nist.gov/publications/detail/fips/140/2/final)
- [FISMA](https://www.cisa.gov/federal-information-security-modernization-act)
- [FedRAMP](https://www.fedramp.gov/documents-templates/)
- [GDPR](https://gdpr.eu/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [Microsoft Azure CAF (Cloud Adoption Framework)](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Microsoft SDL (Secure Development Lifecycle)](https://www.microsoft.com/en-us/securityengineering/sdl)

# Criticality
PII and public facing = high<br/>
PII and internal facing = medium<br/>
no PII and public facing = medium<br/>
no PII and internal facing = low<br/>

# What is a production system?
- public facing
- uses PII data
- costs more than $5,000 / month

# Self-service responses
1. Use, a shared platform
2. Ask, for platform support
3. Buy, 3rd Party Hosted
4. Train, your engineers
5. Hire, new engineers

# Maturity Levels
1. None
2. Ad-hoc, manually
3. Quarterly, manually
4. Monthly, semi-automated
5. Weekly, fully-automated

Level 5 includes:
- tests
- reports
- alerts
- dashboards

# Maturity Aspects

This list is a combination of multiple other security and devops maturity models. It is ordered in a way which enables each aspect to build upon the previous aspects. The specific ordering can be modified slightly, but will lead to missing coverage.

## Summary
1. [Inventory Management](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#1-inventory-management)
2. [Financial Cost Management](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#2-financial-cost-management)
3. [Access Management](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#3-access-management)
4. [CI/CD Build Automation](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#4-cicd-build-automation)
5. [Install and Patch Management](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#5-install-and-patch-management)
6. [Configuration Management](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#6-configuration-management)
7. [Secrets Management](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#7-secrets-management)
8. [Deploy Management](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#8-deploy-management)
9. [Backup and Restore](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#9-backup-and-restore)
10. [Resiliency](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#10-resiliency)
11. [Metrics and Logging](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#11-metrics-and-logging)
12. [Alerts](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#12-alerts)
13. [Response Playbooks](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#13-response-playbooks)
14. [Automated Remediation](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#14-automated-remediation)
15. [Threat Modeling](https://gist.github.com/apolloclark/d1a87d11ef990a2dad03eefa6c51f647#15-threat-modeling)
<br/><br/>


## 1. Inventory Management
### Threats
- unaccounted resources will be exploited without notice
- unaccounted resources will not be patched
- unaccounted resources will be used at maximum cost
### Solutions
- [AWS Security Hub](https://aws.amazon.com/security-hub/)
- [AWS skew (opensource)](https://github.com/scopely-devops/skew)
- [NCC Group, aws-inventory (opensource)](https://github.com/nccgroup/aws-inventory)
- [Duo Security / cloudmapper (opensource)](https://github.com/duo-labs/cloudmapper)
- [Azure Resource Inventory](https://www.microsoft.com/en-us/itshowcase/azure-resource-inventory-helps-manage-operational-efficiency-and-compliance)
- [Google Cloud Asset Inventory](https://cloud.google.com/resource-manager/docs/cloud-asset-inventory/overview)
### Advice
The security teams should work with the Financial, Ops, and Dev teams (in that order) to establish how many cloud provider accounts are being paid for, who owns them, and who has access
<br/><br/>


## 2. Financial Cost Management
### Threats
- unncessary cost over-runs
- unaccounted resources can be exploited financially, ex: bitcoin mining
### Solutions
- [AWS Trusted Advisor](https://aws.amazon.com/premiumsupport/technology/trusted-advisor/)
- [VMWare Cloudhealth](https://www.cloudhealthtech.com/partners/cloud-and-infrastructure-platforms/vmware)
- [CloudDYN](https://www.cloudyn.com/)
- [Cloudcheckr](https://cloudcheckr.com/)
- [Cloudability](https://www.cloudability.com/)
- [ManageEngine](https://www.manageengine.com/products/applications_manager/)
- [FlexNet Manager](https://www.flexera.com/products/spend-optimization/flexnet-manager.html)
### Advice
The security teams should work with the Finance, Ops, and Dev teams to establish cloud account and resource ownership. A good rule of thumb is: "It you are paying for it, you own it, and you need to maintain it."
<br/><br/>


## 3. Access Management
### Threats
- insecure default passwords, or old passwords , or shared passwords, or reused passwords, will be exploited
### Solutions
- [Boundary](https://www.boundaryproject.io/)
- [Okta](https://www.okta.com/products/)
- [Lastpass](https://www.lastpass.com/products/enterprise-password-management-and-sso)
- [Duo Security](https://duo.com/)
- [CMD - Linux](https://cmd.com/)
- [onelogin](https://www.onelogin.com/product/sso)
- [JumpCloud](https://jumpcloud.com/)
- [Identity IQ](https://www.identityiq.com/)
### Advice
The security teams should work with the Ops and Dev teams to establish who has access to cloud accounts and resources. Any form of access should be known and managed in a centralized system. Within AWS for example, this would mean every engineer has their own dedicated IAM User account, and is allowed to use IAM STS Assume Role to manage resources in multiple AWS accounts. Passwords should be complex and long, and rotated regularly. Engineers should be given password managers.
<br/><br/>


## 4. CI/CD Build Automation
### Threats
- old services without updates will be exploited
- mitigation will be time consuming
### Solutions
- [Jenkins (opensource)](https://jenkins.io/)
- [TravisCI](https://travis-ci.org/)
- [CircleCI](https://circleci.com/)
- [Atlassian Bamboo](https://www.atlassian.com/software/bamboo)
- [Jenkins, Ansible plugin (opensource)](https://wiki.jenkins.io/display/JENKINS/Ansible+Plugin)
- [Puppet Pipelines](https://puppet.com/docs/pipelines)
- [Chef Habitat](https://www.habitat.sh/docs/)
### Advice
I have found Jenkins to be the most robust build platform. It has the highest number of plugins and integrations. For my open source projects, I use TravisCI for simple scoped builds to test Ansible roles, building Docker images, and building VM images. Avoid calling the command line directly at all costs. Also avoid using shell scripts. Both of them are difficult to maintain, debug, and are unreliable.
<br/><br/>


## 5. Install and Patch Management
### Threats
- insecure components will be attacked
- mitigation will be time consuming
### Solutions
- [Gradle - task runner, Java (opensource)](https://gradle.org/)
- [Grunt - task runner, node.js (opensource)](https://gruntjs.com/)
- [Fabric - task runner, Python (opensource)](http://www.fabfile.org/)
- [Hashicorp Packer - image builder (opensource)](https://www.packer.io/)
- [Ansible Molecule](https://molecule.readthedocs.io/en/stable/)
- [Chef Kitchen](https://docs.chef.io/kitchen.html)

### Advice
I've used Grandle, Grunt, Packer, and Ansible Molecule. I've found Gradle to be the most mature of the three, though I prefer the simple Javascript syntax of Grunt. I have seen very few competitors to Hashicorp's Packer. I use Ansible roles, and therefor use Molecule.
<br/><br/>


## 6. Configuration Management
### Threats
- having a wide range of the same service, with different versions, is tedious and time consuming to manage, ex: multiple versions of Java
- builds should be consistent and repeatable
- insecure defaults, and insecure configurations, will be attacked
- auditing will be time consuming to manually track configurations
- mitigation will be time consuming
### Solutions
- Manager
  - [Ansible AWX (opensource)](https://github.com/ansible/awx)
  - [Ansible Tower](https://www.ansible.com/products/tower)
  - [Puppet Enterprise](https://puppet.com/products/puppet-enterprise)
  - [Chef Automate](https://www.chef.io/products/automate/)
- Server config
  - [Augeas - service config retrieval (opensource)](http://augeas.net/)
  - [osquery - server config monitoring (opensource)](https://osquery.io/)
  - [DevSec Hardening Framework - Chef, Puppet, Ansible for CIS Benchmarks  (opensource)](https://dev-sec.io/baselines/linux/)
  - [Serverspec - BDD, internal infrastructure testing (opensource)](https://serverspec.org/)
  - [Infrataster - BDD, external infrastructure testing (opensource)](https://github.com/ryotarai/infrataster)
  - [gauntlt - BDD, security infrastructure testing (opensource)](http://gauntlt.org/)
  - [continuum security / bdd-security](https://github.com/continuumsecurity/bdd-security)
  - [F-Secure mittn](https://github.com/F-Secure/mittn)
  - [Chef Inspec](https://www.chef.io/products/chef-inspec/)
- Docker images
  - [20 Docker Security Tools](https://sysdig.com/blog/20-docker-security-tools/)
  - [Top 10 Open Source Tools for Docker security](https://techbeacon.com/security/10-top-open-source-tools-docker-security)
  - [Docker Bench Security - security audit Docker hosts](https://github.com/docker/docker-bench-security)
  - [anchor-cli - Docker image security scanner](https://github.com/anchore/anchore-cli)
  - [Clair - Docker image security scanner](https://coreos.com/clair/docs/latest/)
  - [Dagda - Docker image security scanner](https://github.com/eliasgranderubio/dagda)
  - [Banyan Collector - Docker image security scanner](https://github.com/banyanops/collector)
  - [OpenSCAP - security scanner](https://www.open-scap.org/)
  - [Vuls - security scanner](https://vuls.io/)
  - [Sysdig Falco - Docker image and Host security monitor](https://github.com/falcosecurity/falco)
  - [Cilium - Docker network security scanner](https://github.com/cilium/cilium)
- Amazon AWS
  - [toniblyx / my-arsenal-of-aws-security-tools](https://github.com/toniblyx/my-arsenal-of-aws-security-tools)
  - [pacu - AWS Attack Framework](https://github.com/RhinoSecurityLabs/pacu)
  - [Cloudsploit - IAM policy audit](https://github.com/cloudsploit/scans)
  - [Duo Labs / Cloudtracker - IAM policy audit](https://github.com/duo-labs/cloudtracker)
  - [NCC Group / PMapper - IAM policy mapper](https://github.com/nccgroup/PMapper)
  - [Netflix / repokid - IAM policy remediation](https://github.com/Netflix/repokid)
  - [Prowler - AWS Security Scanner](https://github.com/toniblyx/prowler)
### Advice
Focus on what is already deployed and collect how it is configured, using [Augeas](https://github.com/hercules-team/augeas). Then, setup alerts on when a configuration has changed, using [osquery](https://github.com/osquery/osquery) w/ the [Augeaus plugin](https://osquery.io/schema/3.3.2#augeas). The [DevSec Hardening Framework](https://dev-sec.io/) is a collection of Chef, Puppet, and Ansible scripts, to help ensure compliance such as the CIS Benchmark. Use [Severspec](https://serverspec.org/resource_types.html) / [Goss](https://github.com/aelsabbahy/goss/blob/master/docs/manual.md#available-tests) (config), [Infrataster](https://github.com/ryotarai/infrataster) (e2e), and [Gauntlt](http://gauntlt.org/) (e2e security) to perform BDD testing. Use one of the Docker image scanners. Use the AWS security scanners.
<br/><br/>


## 7. Secrets Management
### Threats
- insecure default passwords, or old passwords, or shared passwords, or reused passwords, will be exploited
- insecure passwords will be time consuming to update and rotate
### Solutions
- [Vault](https://www.vaultproject.io/)
- [maxvt/infra-secret-management-overview.md](https://gist.github.com/maxvt/bb49a6c7243163b8120625fc8ae3f3cd)
- [Jenkins Credentials Manager (opensource)](https://jenkins.io/doc/book/pipeline/jenkinsfile/#handling-credentials)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [Hashicorp Vault](https://www.vaultproject.io/)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [Puppet Hiera](https://puppet.com/blog/my-journey-securing-sensitive-data-puppet-code#finalproduct)
- [Chef Data Bags](https://docs.chef.io/secrets.html)
### Advice
I have a gist for doing this within [Jenkins](https://gist.github.com/apolloclark/042faf1475abb08c22a4dd6cee80ed5d).
<br/><br/>


## 8. Deploy Management
### Threats
- insecure cloud service configurations will be attacked
- cloud service auditing will be time consuming to manually track configurations
- cloud service mitigation will be time consuming for all untracked configurations
### Solutions
- [Hashicorp Terraform (opensource)](https://www.terraform.io/)
- [Hashicorp Sentinel](https://www.hashicorp.com/sentinel)
- [AWS Cloudformation](https://aws.amazon.com/cloudformation/)
- [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview)
- [Google Deployment Manager](https://cloud.google.com/deployment-manager/)
### Advice
I've worked with over a dozen development teams, all using AWS. The AWS Cloudformation tool is not usable for [medium](https://stackoverflow.com/questions/42894202/aws-cloudformation-resource-limit-of-200) to [large](https://serverless.com/blog/serverless-workaround-cloudformation-200-resource-limit/) scale projects. There are [multiple](https://aws.amazon.com/cloudformation/faqs/#Limits_and_Restrictions) [resource](http://buildvirtual.net/study-aid-aws-cloudformation-limits-flashcards/) [limits](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html), which [cannot be increased](https://sanderknape.com/2018/08/two-years-with-cloudformation-lessons-learned/#know-your-limits) by talking with an AWS Account Manager. The Cloudformation template format is [tedious to maintain](https://www.reddit.com/r/aws/comments/5zd5id/dealing_with_cloudformation_parameter_limit/), [confusing to debug](https://news.ycombinator.com/item?id=17743899), and [crashes in unexpected ways](https://forums.aws.amazon.com/thread.jspa?messageID=809516&#809516). However I have had very few issues using Hashicorp Terraform, which also allows for [multi-cloud support](https://www.terraform.io/docs/providers/index.html).
<br/><br/>


## 9. Backup and Restore
### Threats
- data will be exfilled
- data may be deleted irrecoverably
### Solutions
- [AWS RDS Backup](https://aws.amazon.com/rds/details/backup/)
- [AWS RDS Backup, docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html)
- [Azure SQL Automated Backups](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-automated-backups)
- [GCP - MySQL, Overview of Backups](https://cloud.google.com/sql/docs/mysql/backup-recovery/backups)
- [GCP - Postgres, Overview of Backups](https://cloud.google.com/sql/docs/postgres/backup-recovery/backups)
### Advice
This is more left to the Ops team, with some cross-training for Devs, and monthly checkins from the Security teams. Customers and internal clients will ask about "backup and restore strategy" during the start of a project, and before a go-live.
<br/><br/>


## 10. Resiliency
### Threats
- Unexpected downtime
- DDoS attacks
### Solutions
- [AWS Auto Scaling](https://aws.amazon.com/autoscaling/)
- [AWS Auto Scaling, docs](https://docs.aws.amazon.com/autoscaling/index.html)
- [Azure Autoscale](https://azure.microsoft.com/en-us/features/autoscale/)
- [Azure Autoscale, docs](https://docs.microsoft.com/en-us/azure/architecture/best-practices/auto-scaling)
- [GCP, Load Balancing](https://cloud.google.com/load-balancing/)
- [GCP Autoscaler, docs](https://cloud.google.com/compute/docs/autoscaler/)
### Advice
This is more left to the Ops team, with some cross-training for Devs, and monthly checkins from the Security teams. Customers and internal clients will ask about "backup and restore strategy" during the start of a project, and before a go-live.
<br/><br/>


## 11. Metrics and Logging
### Threats
- unmonitored assets will be attacked, without alerts
- unmonitored assets will be difficult and time consuming to remediate
### Solutions
#### Metrics
- [Elastic Metricbeat (opensource)](https://www.elastic.co/products/beats/metricbeat)
- [Elastic Packetbeat (opensource)](https://www.elastic.co/products/beats/packetbeat)
- [Elastic Heartbeat (opensource)](https://www.elastic.co/products/beats/heartbeat)
- [Prometheus (opensource)](https://prometheus.io/)
- [Pingdom](https://www.pingdom.com/)
- [Icinga](https://icinga.com/)
- [Nagios](https://www.nagios.org/)
- [SignalFX](https://www.signalfx.com/)
- [Datadog](https://www.datadoghq.com/)
- [New Relic](https://newrelic.com/)
- [Wavefront](https://www.wavefront.com/)
#### Logging
- [Elastic Filebeat (opensource)](https://www.elastic.co/products/beats/filebeat)
- [rsyslog (opensource)](https://www.rsyslog.com/)
- [fluentd (opensource)](https://www.fluentd.org/)
- [greylog (opensource)](https://www.graylog.org/)
- [Splunk](https://www.splunk.com/)
- [LogRhythm](https://logrhythm.com/)
- [Loggly](https://www.loggly.com/)
- [LogDNA](https://logdna.com/)
- [Sumologic](https://www.sumologic.com/)
#### Behavior
- [Elastic Auditbeat (opensource)](https://www.elastic.co/products/beats/auditbeat)
- [RITA - Real Intelligence Threat Analytics (opensource)](https://github.com/ocmdev/rita)
- [Carbon Black CB Defense](https://www.carbonblack.com/products/cb-defense/)
- [Threastack](https://www.threatstack.com/)
- [Alert Logic](https://www.alertlogic.com/)
- [Crowdstrike](https://www.crowdstrike.com/)
- [Darktrace](https://www.darktrace.com/en/)
- [Malware Bytes](https://www.malwarebytes.com/business/endpointprotection/)
- [FireEye](https://www.fireeye.com/solutions/hx-endpoint-security-products.html)
- [TrendMicro](https://www.trendmicro.com/en_us/business/products/hybrid-cloud/cloud-security.html)
- [Symantec Endpoint Protection](https://www.symantec.com/products/endpoint-protection)
### Advice
I've used almost every product in this list. Splunk is the most powerful, but also the most expensive. Surprisingly fluentd is used natively within [Microsoft Azure](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-log-analytics), [Google GCP](https://cloud.google.com/logging/docs/agent/), and by [Kubernetes](https://docs.fluentd.org/v/0.12/articles/kubernetes-fluentd), despite the parent company Treasure Data no longer offering [enterprise support](https://www.cncf.io/announcement/2019/04/11/cncf-announces-fluentd-graduation/). I'm a huge fan of the Elastic ELK stack. I've been very impressed by Carbon Black's CB Defense.
<br/><br/>


## 12. Alerts
### Threats
- unmonitored assets will be attacked, without alerts
- unmonitored assets will be difficult and time consuming to remediate
### Solutions
- [Yelp / elastalert (opensource)](https://github.com/Yelp/elastalert)
- [PagerDuty](https://www.pagerduty.com/)
- [OpsGenie](https://www.opsgenie.com/)
- [VictorOps](https://victorops.com/)
### Advice
Resist the urge to turn on alerts for everything. Only critical and high findings should have automated alerts. As those alerts become less frequent, and the response more automated, then you should slowly include medium severity finding alerts.
<br/><br/>


## 13. Response Playbooks
### Threats
- threat responses will be ad-hoc, inconsistent, and slow
### Solutions
- create Response Playbooks
### Advice
In my experience, between multiple projects and companies, the playbook threats will be the same, ex: "Unauthorized Access from a Foriegn IP Address." The response will be very different, and will be a reflection of the companies social structure.
<br/><br/>


## 14. Automated Remediation
### Threats
- vulnerable and exploited assets will be time consuming to remediate
### Solutions
- [Divvycloud](https://divvycloud.com/)
- [Rapid7 SOAR](https://www.rapid7.com/solutions/security-orchestration-and-automation/)
- [Evident.io](https://www.paloaltonetworks.com/cloud-security/prisma-public-cloud)
- [CloudDYN](https://www.cloudyn.com/)
- [BetterCloud](https://www.bettercloud.com/)
### Advice
This is a very new space, with lots of marketing hype and confusing, even from experienced DevOps + Security practicioners. My general advice is that the more homogenous and generic an environment, the easier automation will be. If there are custom Docker images, custom compiled languages, custom plugins, etc. then these automation tools will not know how to interact and manage them.
<br/><br/>


## 15. Threat Modeling
### Threats
- lack of visibility into risk
### Solutions
- owners
- support engineers
- architecture diagrams
- dataflow transitions
- data classifications
- malicious user stories
### Advice
For your first pass, just go through the DevSecOps Maturity Model, and get a scoring of where a given team / project is in their maturity. Wherever they have scored below a 5 in the model, should be where they should focus. The intention should not be to reward teams which are more mature, but to put more focus on the most immature teams, track their progress, and reward growth. Going from a 70pts to 75pts is not as impressive as going from a 15pts to 25pts.
<br/><br/>


# References

https://blog.sonatype.com/a-devsecops-maturity-model-in-7-words

https://tech.gsa.gov/guides/dev_sec_ops_guide/

https://2018.open-security-summit.org/outcomes/tracks/owasp-samm/working-sessions/devsecops-maturity-model/

https://www.owasp.org/index.php/OWASP_DevSecOps_Maturity_Model

https://cloud.google.com/free/docs/map-aws-google-cloud-platform

