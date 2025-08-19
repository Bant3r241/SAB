if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot v2", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    -- Money per second parsing (using your proposed method)
    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)/s")
        local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
        return num and tonumber(num) * (multipliers[suffix] or 1) or nil
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

    -- Display the best brainrot's details in the console
    local function showBestBrainrot()
        local bestBrainrot = findBestBrainrot()
        if bestBrainrot.part then
            -- Print the best brainrot's details to the console
            print("[Best Brainrot]")
            print("Name: " .. bestBrainrot.name)
            print("Generation: " .. bestBrainrot.raw)
            print("Value per second: " .. bestBrainrot.value)

            -- Optionally, change the part's color to highlight it
            bestBrainrot.part.BrickColor = BrickColor.new("Bright red")  -- Example: highlight with red

            -- Optionally, create a GUI element to display it in the UI
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 300, 0, 50)
            label.Position = UDim2.new(0, 10, 0, 10)
            label.Text = "Best Brainrot: " .. bestBrainrot.name .. "\nGeneration: " .. bestBrainrot.raw .. "\nValue per second: " .. bestBrainrot.value
            label.Parent = Window.MainFrame  -- Assuming there's a "MainFrame" in your window
        else
            print("[Debug] No valid brainrot found.")
        end
    end

    -- Create the UI toggle buttons for showing the best brainrot
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})
    MiscTab:AddButton({
        Name = "Show Best Brainrot",
        Callback = function()
            showBestBrainrot()
        end
    })

    OrionLib:Init()
end
