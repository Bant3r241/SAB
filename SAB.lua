if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot v5", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    -- Money per second parsing
    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)/s")
        local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
        return num and tonumber(num) * (multipliers[suffix] or 1) or nil
    end

    -- Create a BillboardGui with the name and money per second displayed
    local function createBrainrotLabel(part, name, value)
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = part

        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.BackgroundTransparency = 1
        textLabel.Text = name .. "\n" .. value
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        textLabel.TextSize = 18
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0.8
        textLabel.TextScaled = true
    end

    -- Make the part glow yellow and visible through walls
    local function makePartGlow(part)
        -- Set the part's material to Neon for a glowing effect
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 255, 0)  -- Yellow color
        part.CanCollide = false  -- Make it passable through walls
        part.Transparency = 0.5  -- Make it semi-transparent (so it can be seen through walls)

        -- Optionally add a light to make it glow more
        local pointLight = Instance.new("PointLight")
        pointLight.Parent = part
        pointLight.Color = Color3.fromRGB(255, 255, 0)
        pointLight.Range = 20  -- Set range of the light (adjust for visibility)
        pointLight.Brightness = 10  -- Increase brightness for glow effect
    end

    -- Find the best brainrot
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

    -- Toggle the visibility and highlight of the best brainrot (without red color)
    local function toggleBestBrainrotVisibility(state)
        local bestBrainrot = findBestBrainrot()
        if bestBrainrot.part then
            if state then
                -- Make the part glow and visible through walls
                makePartGlow(bestBrainrot.part)
                
                -- Create the label for the best brainrot at the correct part
                createBrainrotLabel(bestBrainrot.part, bestBrainrot.name, bestBrainrot.raw)
                print("[Best Brainrot]")
                print("Name: " .. bestBrainrot.name)
                print("Generation: " .. bestBrainrot.raw)
                print("Value per second: " .. bestBrainrot.value)
            else
                -- Optionally hide or reset the part color and glow effect
                print("[Debug] Best Brainrot visibility toggled off.")
            end
        else
            print("[Debug] No valid brainrot found.")
        end
    end

    -- Create the UI toggle for showing the best brainrot
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    -- Add the toggle for showing the best brainrot
    MiscTab:AddToggle({
        Name = "Show Best Brainrot",
        Default = false,  -- Default state (off)
        Callback = function(state)
            toggleBestBrainrotVisibility(state)
        end
    })

    OrionLib:Init()
end
