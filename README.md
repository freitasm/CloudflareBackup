# CloudflareBackup
A Windows script to back up Cloudflare zone configuration using curl and PowerShell.

## Prepare the script

1. Create a folder for your backups
2. Download the batch file to the new folder
3. Create a Cloudflare API Token (see below) and paste it into the script

## Authentication

This script authenticates using a Cloudflare **API Token**, not the legacy
Global API Key. Create one at:
https://dash.cloudflare.com/profile/api-tokens

The token needs **Read** access to:
- Account > Load Balancing: Monitors and Pools
- Account > Email Routing Addresses
- Account > Transform Rule
- Zone > Cache Rules
- Zone > Config Rules
- Zone > DNS
- Zone > Email Routing Rules
- Zone > Firewall Services
- Zone > Managed Headers
- Zone > Origin Rules
- Zone > Page Rules
- Zone > Single Redirect
- Zone > Transform Rules
- Zone > Web3 (Custom Pages) — optional, only if used
- Zone > Zone Settings
- Zone > Zone (to list zones)
- Zone > Zone WAF

<img width="552" height="1263" alt="API-token-permissions" src="https://github.com/user-attachments/assets/beea4ce4-a519-4609-91fc-bb3164e30fa8" />

Open the script and replace:
- `[REPLACE WITH YOUR CLOUDFLARE API TOKEN]` with your token

No email address is required with API Tokens.

## Zone discovery

Zones are discovered automatically via the Cloudflare API (paginated), so
there is nothing to configure per domain — the script backs up every zone
the token can see.

## To run this script via File Explorer

1. Browse to the backup folder
2. Double-click the batch file

## To run this script via Command Prompt

1. Open the command prompt
2. Navigate to the backup folder
3. Execute the script

## Output structure

1. The folder name convention is:
      - Backup root (where you drop the script)
         - Backup root\Domain
            - Backup root\Domain\YYYY-MM-DD HH-MM-SS
         - Backup root\account (for Load Balancer Pools and Email Routing addresses)

![Backup folder structure](https://github.com/freitasm/CloudflareBackup/assets/20156997/2165b7d4-7b35-4341-b43e-91ce07d3637d)

2. Per zone, the following are backed up: DNS records (raw JSON and a BIND
   zone file export), DNSSEC, WAF custom rules (legacy and current Rulesets
   engine), Rate Limiting rules, Managed Rules overrides, a full ruleset
   inventory, legacy Page Rules, IP Access Rules, User-Agent blocking,
   Load Balancers, Page Shield, Email Routing (settings, rules, catch-all),
   Transform Rules, Cache Rules, Redirect Rules, Origin Rules, Configuration
   Rules, URL normalisation, Custom Pages, and zone Settings.

3. At the account level: Load Balancer Pools and Email Routing destination
   addresses.

## Comments

1. This is not a full disaster-recovery backup. It does not cover: domain
   registration (relevant if the domain is registered through Cloudflare
   Registrar), private keys for custom SSL certificates (the API never
   returns them), or other Cloudflare products such as Workers, Pages,
   R2/KV, Zero Trust/Access, or Tunnels.
2. A handful of endpoints (legacy Rate Limits, legacy WAF Overrides) are
   deprecated by Cloudflare in favour of the Rulesets API, but are still
   queried and saved (suffixed `-Legacy`) for reference; the current
   equivalents are captured through the Rulesets endpoints.
3. This script only reads data (GET requests). It does not implement a
   restore/import — most of the saved JSON would need to be replayed
   manually against the corresponding write endpoints, except for DNS
   records, which can be restored directly from the BIND export via the
   `dns_records/import` endpoint.
4. This script was tested with free- and pro-plan zones in the same account.

## Updating the API Token later

If you rotate your API Token, just replace the value assigned to
`APIToken` near the top of the script — nothing else needs to change.
