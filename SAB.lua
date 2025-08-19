if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot",HidePremium=false,IntroEnabled=false,IntroText="ABI",SaveConfig=true,ConfigFolder="XlurConfig"})

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    -- Player ESP variables
    local playerESPEnabled = false
    local playerESPObjects = {}

    -- Best Brainrot ESP variables
    local brainrotESPEnabled = false
    local brainrotESPObjects = {}

    -- Utility to create ESP BillboardGui
    local function createESP(part, textLines)
        if not part then return end
        if brainrotESPObjects[part] or playerESPObjects[part] then return end
        
        local bb = Instance.new("BillboardGui")
        bb.Adornee = part
        bb.Size = UDim2.new(0, 120, 0, 40)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true

        for i, text in ipairs(textLines) do
            local lbl = Instance.new("TextLabel", bb)
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.Position = UDim2.new(0, 0, 0, (i-1)*20)
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(0, 162, 255)
            lbl.TextStrokeTransparency = 0
            lbl.Font = Enum.Font.SourceSansBold
            lbl.TextScaled = true
        end

        return bb
    end

    -- Remove ESP helper
    local function removeESP(objectsTable, part)
        if objectsTable[part] then
            objectsTable[part]:Destroy()
            objectsTable[part] = nil
        end
    end

    -- Player ESP toggle function
    local function togglePlayerESP(state)
        playerESPEnabled = state
        for _, p in pairs(Players:GetPlayers()) do
            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if state then
                    playerESPObjects[hrp] = createESP(hrp, {p.Name})
                else
                    removeESP(playerESPObjects, hrp)
                end
            end
        end
    end

    -- Best Brainrot ESP toggle function
    local function toggleBrainrotESP(state)
        brainrotESPEnabled = state
        if not state then
            -- Clear existing ESPs when toggled off
            for part, esp in pairs(brainrotESPObjects) do
                esp:Destroy()
            end
            brainrotESPObjects = {}
        end
    end

    -- Parse money per second text, e.g. "$3.5M/s"
    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)")
        if not num then return nil end
        num = tonumber(num)
        if not num then return nil end
        local multipliers = {
            K = 1e3,
            M = 1e6,
            B = 1e9,
            T = 1e12
        }
        return num * (multipliers[suffix] or 1)
    end

    -- Find all brainrots and update ESP
    local function updateBrainrotESP()
        if not brainrotESPEnabled then return end

        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return end

        -- Keep track of brainrot parts seen this frame to clean up old ESPs
        local currentParts = {}

        for _, plot in pairs(plotsFolder:GetChildren()) do
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, podium in pairs(podiums:GetChildren()) do
                    local base = podium:FindFirstChild("Base")
                    if base and base:FindFirstChild("Spawn") then
                        local attach = base.Spawn:FindFirstChild("Attachment")
                        if attach and attach:FindFirstChild("AnimalOverhead") then
                            local animalOverhead = attach.AnimalOverhead

                            local nameLabel, genLabel
                            for _, child in pairs(animalOverhead:GetChildren()) do
                                if child:IsA("TextLabel") then
                                    if child.Name == "DisplayName" then
                                        nameLabel = child
                                    elseif child.Name == "Generation" then
                                        genLabel = child
                                    end
                                end
                            end

                            if nameLabel and genLabel then
                                local moneyText = genLabel.Text -- e.g. "$3.5M/s"
                                local nameText = nameLabel.Text

                                local espText = {
                                    nameText,
                                    moneyText
                                }

                                currentParts[base] = true

                                if not brainrotESPObjects[base] then
                                    brainrotESPObjects[base] = createESP(base, espText)
                                    brainrotESPObjects[base].Parent = game.CoreGui -- or workspace, depends on your needs
                                else
                                    -- Update existing ESP text
                                    local bb = brainrotESPObjects[base]
                                    for i, lbl in ipairs(bb:GetChildren()) do
                                        if lbl:IsA("TextLabel") then
                                            lbl.Text = espText[i]
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Remove ESPs for brainrots that no longer exist or visible
        for part, esp in pairs(brainrotESPObjects) do
            if not currentParts[part] or not part.Parent then
                removeESP(brainrotESPObjects, part)
            end
        end
    end

    -- Cleanup old player ESPs on character removing
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(c)
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            if playerESPEnabled and hrp then
                playerESPObjects[hrp] = createESP(hrp, {p.Name})
                playerESPObjects[hrp].Parent = game.CoreGui
            end
        end)
        p.CharacterRemoving:Connect(function(c)
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                removeESP(playerESPObjects, hrp)
            end
        end)
    end)

    -- Update player ESPs on toggle
    for _, p in pairs(Players:GetPlayers()) do
        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if hrp and playerESPEnabled then
            playerESPObjects[hrp] = createESP(hrp, {p.Name})
            playerESPObjects[hrp].Parent = game.CoreGui
        end
    end

    -- UI setup
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    MiscTab:AddToggle({
        Name = "Player ESP",
        Default = false,
        Callback = togglePlayerESP
    })

    MiscTab:AddToggle({
        Name = "Best Brainrot ESP",
        Default = false,
        Callback = toggleBrainrotESP
    })

    OrionLib:Init()

    -- RunService loop to update ESP
    RunService.RenderStepped:Connect(function()
        if playerESPEnabled then
            togglePlayerESP(true)  -- Keeps player ESP updated
        end
        if brainrotESPEnabled then
            updateBrainrotESP()
        end

        -- Cleanup player ESP for removed parts
        for part in pairs(playerESPObjects) do
            if not part or not part.Parent then
                removeESP(playerESPObjects, part)
            end
        end
    end)
end
