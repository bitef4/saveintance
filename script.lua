local HTTP = cloneref(game:GetService('HttpService'))

local function decompileScript(script)
    local success, bytecode = pcall(getscriptbytecode, script)
    if not success then
        return `Bytecode fetch failed: { bytecode }`
    end

    local response = request({
        Url = 'https://unluau.lonegladiator.dev/unluau/decompile',
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json',
        },
        Body = HTTP:JSONEncode({
            version = 5,
            bytecode = crypt.base64.encode(bytecode)
        })
    })

    local decoded = HTTP:JSONDecode(response.Body)
    if decoded.status ~= 'ok' then
        return `Decompilation failed: { decoded.status }`
    end

    return decoded.output
end

for _, script in pairs(game:GetDescendants()) do
    if script and (script:IsA("LocalScript") or script:IsA("ModuleScript") or (script:IsA("Script") and script.RunContext == Enum.RunContext.Client)) then
        script.Source = decompileScript(script)
    end
end

-- Reference: https://docs.krampus.gg/api-reference/instance-saving-functions/saveinstance
saveinstance(game, {FileName = "saved-" .. tostring(game.PlaceId)})
