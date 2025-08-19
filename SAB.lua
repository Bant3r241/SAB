if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot v3", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    -- Tabs
    local MainTab = Window:MakeTab({Name="Main", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local EspTab = Window:MakeTab({Name="ESP", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    -- Money per second parsing function
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

                local animalOverhead = base:FindFirstChild("AnimalOverhead")
                if animalOverhead then
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
        end

        if not foundBrainrotInPlot then
            print("[Debug] No brainrot found in this plot.")
        end
        return best
    end

    -- Add a button that finds the best brainrot and prints its details in the console
    MiscTab:AddButton({
        Name = "Find Best Brainrot",
        Callback = function()
            local bestBrainrot = findBestBrainrot()
            if bestBrainrot.part then
                -- Print the details of the best brainrot to the console
                print("[Best Brainrot] Name: " .. bestBrainrot.name)
                print("[Best Brainrot] Generation: " .. bestBrainrot.raw)
                print("[Best Brainrot] Value per second: " .. bestBrainrot.value)
            else
                print("[Debug] No valid brainrot found.")
            end
        end
    })

    OrionLib:Init()
end
