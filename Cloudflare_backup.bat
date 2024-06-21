@echo off
setlocal enabledelayedexpansion

for /f "tokens=1-3 delims=/" %%a in ("%date%") do (
    set "year=%%c"
    set "month=%%b"
    set "day=%%c"
	)

if "%date%A" LSS "A" (set toks=1-3) else (set toks=2-4)
	for /f "tokens=2-4 delims=(-)" %%a in ('echo:^|date') do (
		for /f "tokens=%toks% delims=.-/ " %%i in ('date/t') do (
			set '%%a'=%%i
			set '%%b'=%%j
			set '%%c'=%%k))
if %'yy'% LSS 100 set 'yy'=20%'yy'%
set "BatchDate=%'yy'%-%'mm'%-%'dd'%"

for /f "tokens=1-3 delims=:." %%a in ("%time%") do (
    set "hour=%%a"
    set "minute=%%b"
    set "second=%%c"
)

:: Ensure leading zeros for single-digit values
rem if %hour% lss 10 set "hour=0%hour%"
rem if %minute% lss 10 set "minute=0%minute%"
rem if %second% lss 10 set "second=0%second%"

set "BatchTime=%hour%-%minute%-%second%"

:: Credentials and API keys

set "LoginEmail=[REPLACE WITH YOUR CLOUDFLARE LOGIN EMAIL]"
set "APIKey=[REPLACE WITH YOUR API KEY]"

:: Define the value pairs
set "ZoneID1=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain1=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

set "ZoneID2=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain2=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

set "ZoneID3=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain3=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

set "ZoneID4=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain4=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

set "ZoneID5=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain5=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

set "ZoneID6=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain6=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

set "ZoneID7=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain7=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

set "ZoneID8=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain8=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

set "ZoneID9=[REPLACE WITH ZONE ID TO BACKUP]"
set "Domain9=[REPLACE WITH DOMAIN NAME FOR THIS ZONE]"

:: Loop through the value pairs
:: Starts from 1, increment by 1, up to 9
:: Change last number to total number of zones to backup

for /L %%i in (1,1,9) do (
	set "FullFolder=!Domain%%i!\%BatchDate% %BatchTime%"

	echo ZoneID=!ZoneID%%i!
	echo Domain=!Domain%%i!
	echo FullFolder=!FullFolder!
	
	md "!FullFolder!"
	
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/rules?per_page=100" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\WAF.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/custom_pages" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Custom-Pages.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/dns_records" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\DNS.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/dnssec" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\DNSSEC.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/access_rules/rules" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\IP-Access-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/load_balancers" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Load-Balancers.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/page_shield" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Page_Shield.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rate_limits" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Rate-Limits.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_transform/entrypoint" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Transform-Rewrite-URL.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_late_transform/entrypoint" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Transform-Modify-Request-Header.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_response_headers_transform/entrypoint" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Transform-Modify-Response-Headers.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/managed_headers" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Transform-Managed-Transforms.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_cache_settings/entrypoint" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Cache-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_dynamic_redirect/entrypoint" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Redirect-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_origin/entrypoint" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Origin-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/url_normalization" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\URL-Normalisation.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/ua_rules" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\UA-Blocking.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/waf/overrides" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\WAF-Overrides.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/waf/overrides" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\WAF-Overrides.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/settings" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Settings.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_config_settings/entrypoint" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FullFolder!\Configuration-Rules.txt"
    echo.
)


:: Backup account level data

set "FolderAccount=account\%BatchDate% %BatchTime%"

md "!FolderAccount!"

curl -X GET "https://api.cloudflare.com/client/v4//user/load_balancers/pools" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FolderAccount!\Load-Balancers-Pools.txt"
curl -X GET "https://api.cloudflare.com/client/v4//user/load_balancers/pools/[REPLACE WITH LOAD BALANCER POOL ID 1]" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FolderAccount!\Load-Balancers-Pools-Details-1.txt"
curl -X GET "https://api.cloudflare.com/client/v4//user/load_balancers/pools/[REPLACE WITH LOAD BALANCER POOL ID 2]" -H "X-Auth-Email:!LoginEmail!" -H "X-Auth-Key:!APIKey!" -H "Content-Type: application/json" -o "!FolderAccount!\Load-Balancers-Pools-Details-2.txt"

:: End Backup account level data

pause 
endlocal
