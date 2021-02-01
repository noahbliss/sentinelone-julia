# sentinelone-julia
Julialang API client for SentinelOne

## Usage.
Edit client.jl and remove comment from line for `settingsfile=`  

Edit `settings.conf` with your tenant url and SentinelOne API key.  

Modify client.jl to your needs. Examples are included below.  

## Agents.  
Agents operations for the examples below require an "agents" vector. Make it with: 
```
agents = pq("agents")
```

### See if S1 is installed on machines in a list.  
```
complist = "computer_names_list.txt"
open(complist) do file
        foundnum = 0
        linenum = 0
        for ln in eachline(file)
                linenum += 1
                found = false
                for agent in agents
                        if ln == agent["computerName"]
                                found = true
                                foundnum += 1
                        end
                end
                println("$ln -- $found")
        end
        println("--")
        println("$foundnum of $linenum systems were found in S1.")
end
```

### Print everything for the first agent.
```
for key in agents[1]
        println(key[1]," = ",key[2]) #note some keys are themselves dictionaries or arrays, e.g. locations and networkInterfaces
end
```

### Print out everything on all agents.
```
for agent in agents
        for key in agent
                println(key[1]," = ",key[2]) #note some keys are themselves dictionaries or arrays, e.g. locations and networkInterfaces
        end
end
```

### For Agent 1, get the computer name and first IPv4 address in the first network adapter.
```
name = agents[1]["computerName"]
ip = agents[1]["networkInterfaces"][1]["inet"][1]
println("$name - $ip")
```

