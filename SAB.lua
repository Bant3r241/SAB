if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({
        Name="ABI │ Steal A Brainrot v66", 
        HidePremium=false, 
        IntroEnabled=false, 
        IntroText="ABI", 
        SaveConfig=true, 
        ConfigFolder="XlurConfig"
    })

    -- External ESP Script Load
    local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()

    -- Configuring the ESP
    ESP.Players = false
    ESP.Boxes = false
    ESP.Names = true  -- Show player names
    ESP:Toggle(true)  -- Enable the ESP

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

    -- Make the part neon and visible through walls (ESP-like effect)
    local function makePartVisibleThroughWalls(part, name)
        -- Set the part's material to Neon for a glowing effect
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(0, 255, 255)  -- Neon cyan (adjust as needed)
        part.CanCollide = false  -- Make it passable through walls
        part.Transparency = 0.1  -- Low transparency for better visibility

        -- Create a BillboardGui to display the brainrot's name above the part
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = part
        billboard.Parent = part
        billboard.Size = UDim2.new(0, 200, 0, 50)  -- Size of the label
        billboard.StudsOffset = Vector3.new(0, 3, 0)  -- Position above the part

        -- Create a TextLabel to show the brainrot's name
        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.BackgroundTransparency = 1  -- No background
        textLabel.Text = name  -- Display the brainrot's name
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)  -- Neon yellow color
        textLabel.TextSize = 18
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0.8  -- Slight stroke to make the text clearer
        textLabel.TextScaled = true  -- Make text scale with the label size
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

    -- Toggle the visibility and highlight of the best brainrot
    local function toggleBestBrainrotVisibility(state)
        local bestBrainrot = findBestBrainrot()
        if bestBrainrot.part then
            if state then
                -- Make the part neon, visible through walls, and show the name above the part
                makePartVisibleThroughWalls(bestBrainrot.part, bestBrainrot.name)
                
                -- Create the label for the best brainrot at the correct part
                createBrainrotLabel(bestBrainrot.part, bestBrainrot.name, bestBrainrot.raw)

                -- Add the best brainrot part to the object ESP listener
                ESP:AddObjectListener(Workspace, {
                    Name = bestBrainrot.part.Name,  -- Use the part name
                    CustomName = bestBrainrot.name,  -- Use the custom name for display
                    Color = Color3.fromRGB(255, 0, 0),  -- Red color for the ESP
                    IsEnabled = "BestBrainrotESP"  -- Custom toggle name
                })
                ESP.BestBrainrotESP = true  -- Enable the ESP for this part

                print("[Best Brainrot] Name: " .. bestBrainrot.name)
                print("Generation: " .. bestBrainrot.raw)
                print("Value per second: " .. bestBrainrot.value)
            else
                -- Reset the part's changes (remove name and neon effect)
                resetPart(bestBrainrot.part)
                print("[Debug] Best Brainrot visibility toggled off.")
                ESP.BestBrainrotESP = false  -- Disable the ESP for the best brainrot part
            end
        else
            print("[Debug] No valid brainrot found.")
        end
    end

    -- OrionLib UI Setup
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    -- Add the toggle for showing the best brainrot
    MiscTab:AddToggle({
        Name = "Show Best Brainrot",
        Default = false,  -- Default state (off)
        Callback = function(state)
            toggleBestBrainrotVisibility(state)
        end
    })

    -- Add the ESP Toggle
    MiscTab:AddToggle({
        Name = "Player ESP",
        Default = false,  -- Default state (off)
        Callback = function(state)
            _G.ESP = state
        end
    })

    -- Add the ESP Color Picker
    MiscTab:AddColorPicker({
        Name = "ESP Color",
        Default = Color3.fromRGB(255, 255, 255),  -- Default color (White)
        Callback = function(color)
            _G.ESPColor = color
        end
    })

    OrionLib:Init()
end
