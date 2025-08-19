if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot v5", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    local Players, RunService, espObjects = game:GetService("Players"), game:GetService("RunService"), {}
    local playerESPEnabled, brainrotESPEnabled = false, false

    local function createESP(part, text, color)
        if not part then
            warn("[ESP] createESP called without a valid part!")
            return
        end
        if espObjects[part] then return end
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
        print("[ESP] Created ESP for part:", part:GetFullName(), "with text:", text)
    end

    local function removeESP(part)
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
                    createESP(hrp, p.Name, Color3.fromRGB(0, 162, 255))
                else
                    removeESP(hrp)
                end
            else
                warn("[ESP] Player " .. p.Name .. " has no HumanoidRootPart!")
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
            if not podiums then
                warn("[Brainrot] Plot '" .. plot.Name .. "' missing 'AnimalPodiums'")
                continue
            end

            for _, podium in pairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                if not base then
                    warn("[Brainrot] Podium '" .. podium.Name .. "' missing 'Base'")
                    continue
                end

                local spawn = base:FindFirstChild("Spawn")
                if not spawn then
                    warn("[Brainrot] Base '" .. base.Name .. "' missing 'Spawn'")
                    continue
                end

                local attach = spawn:FindFirstChild("Attachment")
                if not attach then
                    warn("[Brainrot] Spawn '" .. spawn.Name .. "' missing 'Attachment'")
                    continue
                end

                local animalOverhead = attach:FindFirstChild("AnimalOverhead")
                if not animalOverhead then
                    warn("[Brainrot] Attachment missing 'AnimalOverhead'")
                    continue
                end

                local nameLabel
                for _, child in pairs(animalOverhead:GetChildren()) do
                    if child:IsA("TextLabel") and child.Name == "DisplayName" then
                        nameLabel = child
                        break
                    end
                end

                local gen = animalOverhead:FindFirstChild("Generation")
                if not gen or not gen:IsA("TextLabel") then
                    warn("[Brainrot] AnimalOverhead missing 'Generation' TextLabel")
                    continue
                end

                local text = gen.Text
                if text and text:find("/s") then
                    local value = parseMoneyPerSec(text)
                    if value and value > best.value then
                        best.value = value
                        best.raw = text
                        best.name = nameLabel and nameLabel.Text or "Unknown"
                        best.part = spawn -- Attach ESP to Spawn part
                        print("[Brainrot] New best found:", best.name, best.raw, "at", spawn:GetFullName())
                    end
                else
                    warn("[Brainrot] Generation text does not contain '/s':", tostring(text))
                end
            end
        end
        if best.value == 0 then
            warn("[Brainrot] No brainrot found with valid money per second!")
        end
        return best
    end

    local function toggleBrainrotESP(state)
        brainrotESPEnabled = state
        print("[ESP] Brainrot ESP toggled:", state)

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
        else
            warn("[ESP] No best brainrot part found to attach ESP!")
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
