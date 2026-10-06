@echo off
setlocal enabledelayedexpansion

:: Date/time via PowerShell, independent of the Windows display language.
:: (The original approach parsed the output of the "date" command, which
:: broke on non-English locales because the header format differs.)
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "BatchDate=%%i"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format HH-mm-ss"') do set "BatchTime=%%i"

:: ---------------------------------------------------------------------
:: Credentials
:: Cloudflare has two authentication schemes and they are NOT interchangeable:
::   - Global API Key (legacy): requires X-Auth-Email + X-Auth-Key
::   - API Token (created from the dashboard, recommended): requires only
::     the "Authorization: Bearer <token>" header, no email needed
:: Create a Token with Read access to all zones at:
:: https://dash.cloudflare.com/profile/api-tokens
:: ---------------------------------------------------------------------

set "APIToken=[REPLACE WITH YOUR CLOUDFLARE API TOKEN]"

:: ---------------------------------------------------------------------
:: Zone discovery
:: Zones are fetched dynamically from the API (paginated), so there is no
:: fixed list to maintain by hand when a domain is added or removed.
:: ---------------------------------------------------------------------

set "ZonesFile=%TEMP%\cf_zones_%RANDOM%.txt"
powershell -NoProfile -Command "$headers=@{'Authorization'='Bearer %APIToken%';'Content-Type'='application/json'}; $page=1; $all=@(); do { $resp = Invoke-RestMethod -Uri ('https://api.cloudflare.com/client/v4/zones?per_page=50&page=' + $page) -Headers $headers; $all += $resp.result; $page++ } while ($page -le $resp.result_info.total_pages); $all | ForEach-Object { $_.id + '|' + $_.name + '|' + $_.account.id } | Out-File -Encoding ascii '%ZonesFile%'"

set "ZoneCount=0"
for /f "usebackq tokens=1-3 delims=|" %%a in ("%ZonesFile%") do (
	set /a ZoneCount+=1
	set "ZoneID!ZoneCount!=%%a"
	set "Domain!ZoneCount!=%%b"
	set "AccountID!ZoneCount!=%%c"
)
del "%ZonesFile%" >nul 2>&1

echo Found !ZoneCount! zone^(s^) to back up.
echo.

if !ZoneCount! EQU 0 (
	echo No zones found: check that APIToken is set and valid.
	pause
	exit /b 1
)

:: Loop through all zones found (nothing to update by hand)

for /L %%i in (1,1,!ZoneCount!) do (
	set "FullFolder=!Domain%%i!\%BatchDate% %BatchTime%"

	echo ZoneID=!ZoneID%%i!
	echo Domain=!Domain%%i!
	echo FullFolder=!FullFolder!
	
	md "!FullFolder!"
	
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/rules?per_page=100" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\WAF.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/custom_pages" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Custom-Pages.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/email/routing" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Email-Routing-Settings.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/email/routing/rules?per_page=50" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Email-Routing-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/email/routing/rules/catch_all" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Email-Routing-CatchAll.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/dns_records" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\DNS.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/dns_records/export" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\DNS-Export-BIND.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/dnssec" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\DNSSEC.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/access_rules/rules" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\IP-Access-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/load_balancers" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Load-Balancers.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/page_shield" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Page_Shield.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_firewall_custom/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Custom-Rules-WAF.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_ratelimit/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Rate-Limiting-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_firewall_managed/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Managed-Rules-Overrides.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Rulesets-Inventory.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/pagerules" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Page-Rules-Legacy.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rate_limits" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Rate-Limits-Legacy.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_transform/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Transform-Rewrite-URL.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_late_transform/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Transform-Modify-Request-Header.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_response_headers_transform/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Transform-Modify-Response-Headers.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/managed_headers" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Transform-Managed-Transforms.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_cache_settings/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Cache-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_dynamic_redirect/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Redirect-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_request_origin/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Origin-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/rulesets/phases/http_config_settings/entrypoint" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Configuration-Rules.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/url_normalization" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\URL-Normalisation.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/ua_rules" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\UA-Blocking.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/firewall/waf/overrides" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\WAF-Overrides.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/settings" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Settings.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/settings/advanced_ddos" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Security-Advanced-DDoS.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/settings/browser_check" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Security-Browser-Check.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/settings/challenge_ttl" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Security-Challenge-TTL.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/settings/replace_insecure_js" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Security-replace-insecure-js.txt"
	curl -X GET "https://api.cloudflare.com/client/v4/zones/!ZoneID%%i!/healthchecks" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FullFolder!\Healthchecks.txt"
	echo.
)

:: ---------------------------------------------------------------------
:: Account-level data
:: ---------------------------------------------------------------------

set "FolderAccount=account\%BatchDate% %BatchTime%"

md "!FolderAccount!"

:: The response already includes the full configuration of every pool
:: (origins, monitor, steering, etc.), so no separate per-pool call is needed.
curl -X GET "https://api.cloudflare.com/client/v4/user/load_balancers/pools" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FolderAccount!\Load-Balancers-Pools.txt"

:: Email Routing destination addresses live at the account level, not the
:: zone level. This uses the AccountID of the first zone found: fine if the
:: token only covers a single account (the typical case); if it covers more
:: than one, repeat this call with the other AccountID# values.
curl -X GET "https://api.cloudflare.com/client/v4/accounts/!AccountID1!/email/routing/addresses?per_page=50" -H "Authorization: Bearer !APIToken!" -H "Content-Type: application/json" -o "!FolderAccount!\Email-Routing-Destination-Addresses.txt"

endlocal
