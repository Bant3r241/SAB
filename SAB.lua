-- Parse the money per second (already provided in the script)
local function parseMoneyPerSec(text)
    local num, suffix = text:match("%$([%d%.]+)([KMBT]?)/s")
    local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
    return num and tonumber(num) * (multipliers[suffix] or 1) or nil
end

-- Function to find the best brainrot and get the part associated with it
local function findBestBrainrot()
    local best = {value = 0, raw = "", name = "", part = nil}  -- store the best brainrot information
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

-- Function to create the label for the best brainrot part (on the part itself)
local function createBrainrotLabel(part, name, generation)
    local label = Instance.new("BillboardGui")
    label.Adornee = part
    label.Size = UDim2.new(0, 100, 0, 50)
    label.StudsOffset = Vector3.new(0, 3, 0)
    label.Parent = part

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = label
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name .. "\n" .. generation
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.8
    textLabel.TextScaled = true
end

-- Reset the part's changes (remove name and neon effect)
local function resetPart(part)
    local label = part:FindFirstChild("BillboardGui")
    if label then
        label:Destroy()
    end
end

-- Add Button to show the Best Brainrot and fetch the part
MiscTab:AddButton({
    Name = "Show Best Brainrot",
    Callback = function()
        local bestBrainrot = findBestBrainrot()
        if bestBrainrot.part then
            -- Show the best brainrot by creating the label
            createBrainrotLabel(bestBrainrot.part, bestBrainrot.name, bestBrainrot.raw)
            print("[Best Brainrot]")
            print("Name: " .. bestBrainrot.name)
            print("Generation: " .. bestBrainrot.raw)
            print("Value per second: " .. bestBrainrot.value)

            -- Apply ESP to the Best Brainrot part
            if _G.ESP then
                ESP:Add(bestBrainrot.part, {
                    Name = bestBrainrot.name,
                    Player = game.Players.LocalPlayer,
                    PrimaryPart = bestBrainrot.part,
                    Color = ESP.Color,
                    Size = ESP.BoxSize,
                    IsEnabled = true,
                })
            end
        else
            print("[Debug] No valid brainrot found.")
        end
    end
})
