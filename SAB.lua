if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name = "ABI │ Steal A Brainrot", IntroEnabled = false})

    -- Tabs
    local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4299432428", PremiumOnly = false})
    local EspTab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4299432428", PremiumOnly = false})
    local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4299432428", PremiumOnly = false})

    -- Function to parse money per second from the TextLabel
    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)/s")
        local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
        return num and tonumber(num) * (multipliers[suffix] or 1) or nil
    end

    -- Function to find the best brainrot in the game
    local function findBestBrainrot()
        local best = {value = 0, raw = "", name = "", part = nil}
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return best end

        local foundBrainrotInPlot = false
        for _, plot in pairs(plotsFolder:GetChildren()) do
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then continue end
            for _, podium in pairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                if not base then continue end

                local decorations = base:FindFirstChild("Decorations")
                if not decorations then continue end

                local part = decorations:FindFirstChild("Part")
                if not part then continue end  -- Skip if no part found

                local spawn = base:FindFirstChild("Spawn")
                if not spawn then continue end

                local attachment = spawn:FindFirstChild("Attachment")
                if not attachment then continue end

                local animalOverhead = attachment:FindFirstChild("AnimalOverhead")
                if not animalOverhead then continue end

                local gen = animalOverhead:FindFirstChild("Generation")
                if gen and gen:IsA("TextLabel") then
                    local value = parseMoneyPerSec(gen.Text)
                    if value and value > best.value then
                        best.value = value
                        best.raw = gen.Text
                        best.name = animalOverhead:FindFirstChild("DisplayName") and animalOverhead.DisplayName.Text or "Unknown"
                        best.part = part  -- Attach to the correct part
                        foundBrainrotInPlot = true
                    end
                end
            end
        end

        if not foundBrainrotInPlot then
            print("[Debug] No brainrot found in this plot.")
        end
        return best
    end

    -- Function to create the ESP for the brainrot
    local function createESPForBrainrot(part, name)
        -- Create a BillboardGui to display the brainrot's name above the part
        local espGui = Instance.new("BillboardGui")
        espGui.Adornee = part
        espGui.Size = UDim2.new(0, 200, 0, 50)  -- Size of the label
        espGui.StudsOffset = Vector3.new(0, 3, 0)  -- Position above the part
        espGui.Parent = part

        -- Create a TextLabel to show the brainrot's name
        local espLabel = Instance.new("TextLabel")
        espLabel.Size = UDim2.new(1, 0, 1, 0)
        espLabel.BackgroundTransparency = 1
        espLabel.Text = name  -- Display the brainrot's name
        espLabel.TextColor3 = Color3.fromRGB(255, 255, 0)  -- Neon yellow color
        espLabel.TextSize = 18
        espLabel.Font = Enum.Font.GothamBold
        espLabel.TextStrokeTransparency = 0.8
        espLabel.TextScaled = true
        espLabel.Parent = espGui
    end

    -- Toggle for the best brainrot ESP in the ESP tab
    local bestBrainrotESPEnabled = false

    EspTab:AddToggle({
        Name = "Show Best Brainrot ESP",
        Default = false,  -- Default state (off)
        Callback = function(state)
            bestBrainrotESPEnabled = state
            local bestBrainrot = findBestBrainrot()
            if bestBrainrot.part then
                if state then
                    createESPForBrainrot(bestBrainrot.part, bestBrainrot.name)
                    print("[Best Brainrot] ESP Enabled")
                else
                    -- Remove ESP (if needed)
                    for _, child in pairs(bestBrainrot.part:GetChildren()) do
                        if child:IsA("BillboardGui") then
                            child:Destroy()
                        end
                    end
                    print("[Best Brainrot] ESP Disabled")
                end
            else
                print("[Debug] No valid brainrot found for ESP.")
            end
        end
    })

    OrionLib:Init()
end
