if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot v4", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    local Players, RunService, espObjects = game:GetService("Players"), game:GetService("RunService"), {}
    local playerESPEnabled, brainrotESPEnabled = false, false

    local function createESP(part, text, color)
        if not part or espObjects[part] then return end
        local bb = Instance.new("BillboardGui", part)
        bb.Adornee = part
        bb.Size = UDim2.new(0, 100, 0, 30)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel", bb)
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextScaled = true
        espObjects[part] = bb
    end

    local function removeESP(part)
        if espObjects[part] then
            espObjects[part]:Destroy()
            espObjects[part] = nil
        end
    end

    local function togglePlayerESP(state)
        playerESPEnabled = state
        for _, p in pairs(Players:GetPlayers()) do
            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if state then
                    createESP(hrp, p.Name, Color3.fromRGB(0, 162, 255))
                else
                    removeESP(hrp)
                end
            end
        end
    end

    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)/s")
        local mult = {K=1e3, M=1e6, B=1e9, T=1e12}
        return num and tonumber(num) * (mult[suffix] or 1) or nil
    end

    local function findBestBrainrot()
        local best = {value = 0, raw = "", name = "", part = nil}
        local plotsFolder = workspace:FindFirstChild("Plots")
        if plotsFolder then
            for _, plot in pairs(plotsFolder:GetChildren()) do
                local podiums = plot:FindFirstChild("AnimalPodiums")
                if podiums then
                    for _, podium in pairs(podiums:GetChildren()) do
                        local base = podium:FindFirstChild("Base")
                        if base and base:FindFirstChild("Spawn") then
                            local attach = base.Spawn:FindFirstChild("Attachment")
                            if attach and attach:FindFirstChild("AnimalOverhead") then
                                local animalOverhead = attach.AnimalOverhead

                                local nameLabel
                                for _, child in pairs(animalOverhead:GetChildren()) do
                                    if child:IsA("TextLabel") and child.Name == "DisplayName" then
                                        nameLabel = child
                                        break
                                    end
                                end

                                local gen = animalOverhead:FindFirstChild("Generation")
                                if gen and gen:IsA("TextLabel") then
                                    local text = gen.Text
                                    if text and text:find("/s") then
                                        local value = parseMoneyPerSec(text)
                                        if value and value > best.value then
                                            best.value = value
                                            best.raw = text
                                            best.name = nameLabel and nameLabel.Text or "Unknown"
                                            -- Attach ESP to the Spawn part, NOT Base model
                                            best.part = base:FindFirstChild("Spawn")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local function toggleBrainrotESP(state)
        brainrotESPEnabled = state

        -- Clear old ESP for brainrot
        for part, gui in pairs(espObjects) do
            if gui and gui.Adornee and gui.Adornee.Name == "Spawn" then
                removeESP(part)
            end
        end

        if not state then return end

        local best = findBestBrainrot()
        if best.part then
            createESP(best.part, best.name .. " - " .. best.raw, Color3.fromRGB(255, 215, 0))
        end
    end

    RunService.RenderStepped:Connect(function()
        if playerESPEnabled then togglePlayerESP(true) end
        if brainrotESPEnabled then toggleBrainrotESP(true) end
        for part in pairs(espObjects) do
            if not part or not part.Parent then
                removeESP(part)
            end
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(c)
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            if playerESPEnabled and hrp then
                createESP(hrp, p.Name, Color3.fromRGB(0, 162, 255))
            end
        end)
    end)

    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})
    MiscTab:AddToggle({Name="Player ESP", Default=false, Callback=togglePlayerESP})
    MiscTab:AddToggle({Name="Best Brainrot ESP", Default=false, Callback=toggleBrainrotESP})

    OrionLib:Init()
end
