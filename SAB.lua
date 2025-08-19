if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot v1", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    local Players, RunService = game:GetService("Players"), game:GetService("RunService")
    local playerESPEnabled, brainrotESPEnabled = false, false

    -- Separate tables for player and brainrot ESPs
    local playerESPObjects, brainrotESPObjects = {}, {}

    local function createESP(part, text, color, espType)
        if not part then warn("[ESP] createESP called with nil part.") return end
        local espObjects = espType == "Player" and playerESPObjects or brainrotESPObjects

        if espObjects[part] then return end

        local bb = Instance.new("BillboardGui")
        bb.Name = "[ESP]"
        bb.Adornee = part  -- Attach to the Spawn part (not Attachment)
        bb.Size = UDim2.new(0, 100, 0, 30)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 250
        bb.Parent = game.Players.LocalPlayer.PlayerGui  -- Parent to PlayerGui for better rendering

        local lbl = Instance.new("TextLabel")
        lbl.Parent = bb
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextScaled = true

        espObjects[part] = bb
        print("[ESP] Created ESP for part:", part:GetFullName(), "with text:", text)
    end

    local function removeESP(part, espType)
        local espObjects = espType == "Player" and playerESPObjects or brainrotESPObjects
        if espObjects[part] then
            espObjects[part]:Destroy()
            espObjects[part] = nil
            print("[ESP] Removed ESP for part:", part:GetFullName())
        end
    end

    local function togglePlayerESP(state)
        playerESPEnabled = state
        print("[ESP] Player ESP toggled:", state)
        for _, p in pairs(Players:GetPlayers()) do
            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if state then
                    createESP(hrp, p.Name, Color3.fromRGB(0, 162, 255), "Player")
                else
                    removeESP(hrp, "Player")
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
        if not plotsFolder then
            warn("[Brainrot] No 'Plots' folder found in workspace!")
            return best
        end

        for _, plot in pairs(plotsFolder:GetChildren()) do
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then continue end

            for _, podium in pairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                if not base then continue end

                local spawn = base:FindFirstChild("Spawn")
                if not spawn then continue end

                local attachment = spawn:FindFirstChild("Attachment")
                if not attachment then continue end

                local animalOverhead = attachment:FindFirstChild("AnimalOverhead")
                if not animalOverhead then continue end

                local nameLabel = animalOverhead:FindFirstChild("DisplayName")
                local gen = animalOverhead:FindFirstChild("Generation")

                if gen and gen:IsA("TextLabel") and gen.Text:find("/s") then
                    local value = parseMoneyPerSec(gen.Text)
                    if value and value > best.value then
                        best.value = value
                        best.raw = gen.Text
                        best.name = nameLabel and nameLabel.Text or "Unknown"
                        best.part = spawn  -- Attach to the Spawn part for Brainrot ESP (instead of attachment)
                        print("[Brainrot] New best found:", best.name, best.raw, "at", spawn:GetFullName())
                    end
                else
                    warn("[Brainrot] Generation text does not contain '/s' or missing:", gen and gen.Text or "nil")
                end
            end
        end

        return best
    end

    local function toggleBrainrotESP(state)
        brainrotESPEnabled = state
        print("[ESP] Brainrot ESP toggled:", state)

        -- Clear old ESP for brainrot
        for part, gui in pairs(brainrotESPObjects) do
            if gui and gui.Adornee and gui.Name == "[ESP]" then
                removeESP(part, "Brainrot")
            end
        end

        if not state then return end

        local best = findBestBrainrot()
        if best.part then
            createESP(best.part, best.name .. " - " .. best.raw, Color3.fromRGB(255, 215, 0), "Brainrot")
        else
            warn("[ESP] No best brainrot part found to attach ESP!")
        end
    end

    RunService.RenderStepped:Connect(function()
        if playerESPEnabled then togglePlayerESP(true) end
        if brainrotESPEnabled then toggleBrainrotESP(true) end

        -- Clean up any ESP that no longer exists or isn't visible
        for part in pairs(playerESPObjects) do
            if not part or not part.Parent then
                removeESP(part, "Player")
            end
        end

        for part in pairs(brainrotESPObjects) do
            if not part or not part.Parent then
                removeESP(part, "Brainrot")
            end
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(c)
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            if playerESPEnabled and hrp then
                createESP(hrp, p.Name, Color3.fromRGB(0, 162, 255), "Player")
            end
        end)
    end)

    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})
    MiscTab:AddToggle({Name="Player ESP", Default=false, Callback=togglePlayerESP})
    MiscTab:AddToggle({Name="Best Brainrot ESP", Default=false, Callback=toggleBrainrotESP})

    OrionLib:Init()
end
