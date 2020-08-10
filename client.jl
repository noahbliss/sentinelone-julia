#!/usr/bin/env julia
import HTTP
import JSON
using DelimitedFiles
using JuliaDB
#settingsfile = "settings.conf"
backupsettingsfile = "$(homedir())/.config/sentinelone-julia/settings.conf"
@isdefined(settingsfile) || isfile(backupsettingsfile) && (settingsfile = backupsettingsfile)
isfile(settingsfile) || println("Settings file is missing.") && exit(1)

importedvars = readdlm(settingsfile, '=', String; skipblanks=true)
a2var(key, a) = (c=1; for i in getindex(a, :, 1); key == i && return getindex(a, c, 2) ; c=c+1; end || error("$key not found"))


tenant = a2var("tenant", importedvars)
apitoken = a2var("apitoken", importedvars)


function webreq(tenant, apitoken, query)
        url = "$tenant/web/api/v2.1/$query"
        headers = ["Authorization" => "ApiToken $apitoken"]
        response = HTTP.request("GET", url, headers; require_ssl_verification = true)
        #return String(response.body)
        return JSON.parse(String(response.body))
        # return response.body
end

fire(query) = webreq(tenant, apitoken, query)

result = fire("agents")

for i in result["data"]
        println(i)
        println("\n\n")
end
