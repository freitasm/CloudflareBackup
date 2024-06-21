# CloudflareBackup
A Windows script to create Cloudflare configuration backups using curl.

## Prepare the script

1. Create a folder for your backups
2. Download the batch file to the new folder
3. Updated the batch file as required (*)

## To run this script via File Explorer

1. Browse to the backup folder
2. Double-click the batch file

## To run this script via Command Prompt

1. Open the command prompt
2. Navigate to the backup folder
3. Execute the script

## Output structure

1. The folder name convention will be
      - Backup root (where you drop the script)
         - Backup root\Domain 
            - Backup root\Domain\YYYY-MM-DD HH:MM:SS
         - Backup root\account (for Load Balancer Pools) 

## Comments

1. This is not a full backup, as most account settings are not being copied
2. This script was tested with Free and Pro zones in the same account

## (*) Updating the batch file

1. Find the following items to replace:
   - [REPLACE WITH YOUR CLOUDFLARE LOGIN EMAIL]: Enter your Cloudflare login email
   - [REPLACE WITH YOUR API KEY]: Enter an API key with Read rights to all zones
2. For each Zone you want to create a backup for:
   - Update the line ZoneID#, Domain#
      - The sample script has nine zones ZoneID1 ... ZoneID9 and corresponding Domain1 ... Domain9
      - You can remove pairs if you have less than nine zones
      - You can add pairs if you have more than nine zones, remembering to name the pair correctly with the sequential numbers
      - If you add or remove pairs, adjust the "for /L %%i in (1,1,9) do (" statement replacing 9 with the correct number of pairs
   - [REPLACE WITH ZONE ID TO BACKUP]: Enter the Zone ID
   - [REPLACE WITH DOMAIN NAME FOR THIS ZONE]: Enter the domain name to be used as a sub-folder
3. Load Balancer pools are copied from account, so these need to be manually updated, with the correct Load Balance Pool
   - If you don't use Load Balancers you can remove the commands between the comments :: Backup account level data and :: End Backup account level data - 
