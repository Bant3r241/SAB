if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot vasfa", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    -- Money per second parsing (using your proposed method)
    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)/s")
        local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
        return num and tonumber(num) * (multipliers[suffix] or 1) or nil
    end

    -- Create a BillboardGui with the name and money per second displayed
    local function createBrainrotLabel(part, name, value)
        -- Create the BillboardGui
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 200, 0, 50)  -- Set the size of the BillboardGui
        billboard.StudsOffset = Vector3.new(0, 3, 0)  -- Adjust the position above the part
        billboard.Parent = part

        -- Create the TextLabel
        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.BackgroundTransparency = 1
        textLabel.Text = name .. "\n" .. value  -- Format the text as: Name\nGeneration
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)  -- Yellow text (as in the image)
        textLabel.TextSize = 18
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0.8  -- Add a stroke to make text clearer
        textLabel.TextScaled = true  -- Make sure the text scales properly
    end

    -- Find the best brainrot in the game
    local function findBestBrainrot()
        local best = {value = 0, raw = "", name = "", part = nil}
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then
            return best
        end

        local foundBrainrotInPlot = false  -- Flag to check if there's any brainrot in the plot

        -- Iterate through all the plots
        for _, plot in pairs(plotsFolder:GetChildren()) do
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then continue end

            -- Iterate through each podium in the plot
            for _, podium in pairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                if not base then continue end

                local spawn = base:FindFirstChild("Spawn")
                if not spawn then continue end

                local attachment = spawn:FindFirstChild("Attachment")
                if not attachment then continue end  -- Skip this podium if no brainrot

                local animalOverhead = attachment:FindFirstChild("AnimalOverhead")
                if not animalOverhead then continue end

                local gen = animalOverhead:FindFirstChild("Generation")
                if gen and gen:IsA("TextLabel") then
                    local value = parseMoneyPerSec(gen.Text)
                    if value and value > best.value then
                        best.value = value
                        best.raw = gen.Text
                        best.name = animalOverhead:FindFirstChild("DisplayName") and animalOverhead.DisplayName.Text or "Unknown"
                        best.part = podium:FindFirstChild("Claim") and podium.Claim:FindFirstChild("Main")  -- Attach to Main part under Claim
                        foundBrainrotInPlot = true  -- Found at least one brainrot in this plot
                    end
                end
            end
        end

        if not foundBrainrotInPlot then
            print("[Debug] No brainrot found in this plot.")
        end

        return best
    end

    -- Show or hide the best brainrot and highlight it
    local function toggleBestBrainrotVisibility(state)
        if state then
            local bestBrainrot = findBestBrainrot()
            if bestBrainrot.part then
                -- Highlight the best brainrot part by changing its color
                bestBrainrot.part.BrickColor = BrickColor.new("Bright red")  -- Example: highlight with red
                -- Create the label for the best brainrot
                createBrainrotLabel(bestBrainrot.part, bestBrainrot.name, bestBrainrot.raw)
                -- Print to Output
                print("[Best Brainrot]")
                print("Name: " .. bestBrainrot.name)
                print("Generation: " .. bestBrainrot.raw)
                print("Value per second: " .. bestBrainrot.value)
            else
                print("[Debug] No valid brainrot found.")
            end
        else
            -- Remove the label and reset the highlight
            if lastBestBrainrot then
                lastBestBrainrot.BrickColor = BrickColor.new("Medium stone grey")  -- Reset to original color (or other neutral color)
                lastBestBrainrot = nil  -- Clear the saved part
            end
            -- Remove any existing labels from the BillboardGui
            for _, billboard in pairs(workspace:FindPartsInRegion3(workspace.CurrentCamera.CFrame:pointToWorldSpace(Vector3.new(0, 0, 0)), Vector3.new(500, 500, 500), nil)) do
                if billboard:IsA("BillboardGui") then
                    billboard:Destroy()
                end
            end
        end
    end

    -- One-liner toggle for the Brainrot ESP functionality
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    -- The one-liner toggle for controlling the visibility of the best brainrot
    MiscTab:AddToggle({Name = "Brainrot ESP", Default = false, Callback = function(v) toggleBestBrainrotVisibility(v) end})

    OrionLib:Init()
end
