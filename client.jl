#!/usr/bin/env julia
import HTTP
import JSON
using DelimitedFiles

#settingsfile = "settings.conf"
backupsettingsfile = "$(homedir())/.config/sentinelone-julia/settings.conf"
@isdefined(settingsfile) || isfile(backupsettingsfile) && (settingsfile = backupsettingsfile)
isfile(settingsfile) || println("Settings file is missing.") && exit(1)

importedvars = readdlm(settingsfile, '=', String; skipblanks=true)
a2var(key, a) = (c=1; for i in a[:, 1]; i == key && return a[c, 2]; c+=1; end || error("$key not found"))

tenant = a2var("tenant", importedvars)
apitoken = a2var("apitoken", importedvars)


function req(tenant, apitoken, query)
        url = "$tenant/web/api/v2.1/$query"
        headers = ["Authorization" => "ApiToken $apitoken"]
        response = HTTP.request("GET", url, headers; require_ssl_verification = true)
        #return String(response.body)
        return JSON.parse(String(response.body))
        # return response.body
end

function pagedreq(tenant, apitoken, query)
        cursor = "staged"
        result = Vector{Any}()
        while cursor !== nothing
                #Check if first run.
                if cursor !== "staged"
                        newquery = "$query?cursor=$cursor"
                else
                        newquery = query
                end
                #Make the request.
                response = req(tenant, apitoken, newquery)
                #Initialize or append result.
                if ! @isdefined(result)
                        result = response["data"]
                else
                        append!(result, response["data"])
                end
                #Move the cursor.
                cursor = (response["pagination"])["nextCursor"]
        end
        return result
end

# Function fire
q(query) = webreq(tenant, apitoken, query)
pq(query) = pagedreq(tenant, apitoken, query)

# Store all agent data as vector "agents"
# agents = pq("agents")

# Get group information
# groups = pq("groups")
