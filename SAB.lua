if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot",HidePremium=false,IntroEnabled=false,IntroText="ABI",SaveConfig=true,ConfigFolder="XlurConfig"})

    local Players, RunService = game:GetService("Players"), game:GetService("RunService")
    local playerESPEnabled, brainrotESPEnabled, espObjects = false, false, {}

    local function createESP(part, text, color)
        if not part or espObjects[part] then return end
        local bb = Instance.new("BillboardGui", part)
        bb.Adornee, bb.Size, bb.StudsOffset, bb.AlwaysOnTop = part, UDim2.new(0,100,0,30), Vector3.new(0,3,0), true
        local lbl = Instance.new("TextLabel", bb)
        lbl.BackgroundTransparency, lbl.Size, lbl.Text, lbl.TextColor3, lbl.TextStrokeTransparency, lbl.Font, lbl.TextScaled =
            1, UDim2.new(1,0,1,0), text, color, 0, Enum.Font.SourceSansBold, true
        espObjects[part] = bb
    end

    local function removeESP(part)
        if espObjects[part] then espObjects[part]:Destroy() espObjects[part] = nil end
    end

    local function togglePlayerESP(state)
        playerESPEnabled = state
        for _, p in pairs(Players:GetPlayers()) do
            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if state then createESP(hrp, p.Name, Color3.fromRGB(0,162,255)) else removeESP(hrp) end
            end
        end
    end

    local function parseMoney(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)")
        local mult = {K=1e3,M=1e6,B=1e9,T=1e12}
        return tonumber(num) and tonumber(num)*(mult[suffix] or 1)
    end

    local function getBestBrainrot()
        local best, bestPart = 0, nil
        for _, plot in pairs(workspace:FindFirstChild("Plots"):GetChildren()) do
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, pod in pairs(podiums:GetChildren()) do
                    local att = pod:FindFirstDescendant("Attachment")
                    local gen = att and att:FindFirstChild("Generation")
                    local name = att and att:FindFirstChild("DisplayName")
                    local part = att and att.Parent
                    if gen and name and gen:IsA("TextLabel") then
                        local val = parseMoney(gen.Text)
                        if val and val > best then
                            best, bestPart = val, part
                        end
                    end
                end
            end
        end
        return bestPart
    end

    local function toggleBrainrotESP(state)
        brainrotESPEnabled = state
        for part, gui in pairs(espObjects) do
            if gui and gui.Adornee and gui.Adornee.Name == "BrainrotESP" then removeESP(part) end
        end
        if not state then return end
        local bestPart = getBestBrainrot()
        if bestPart then
            local attach = bestPart:FindFirstChild("Attachment")
            local gen = attach and attach:FindFirstChild("Generation")
            local name = attach and attach:FindFirstChild("DisplayName")
            if gen and name then
                createESP(bestPart, name.Text .. " - " .. gen.Text, Color3.fromRGB(255,215,0)) -- Gold
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if playerESPEnabled then togglePlayerESP(true) end
        if brainrotESPEnabled then toggleBrainrotESP(true) end
        for part in pairs(espObjects) do if not part or not part.Parent then removeESP(part) end end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(c)
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            if playerESPEnabled and hrp then createESP(hrp, p.Name, Color3.fromRGB(0,162,255)) end
        end)
    end)

    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})
    MiscTab:AddToggle({Name="Player ESP", Default=false, Callback=togglePlayerESP})
    MiscTab:AddToggle({Name="Best Brainrot ESP", Default=false, Callback=toggleBrainrotESP})

    OrionLib:Init()
end
