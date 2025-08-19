if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot",HidePremium=false,IntroEnabled=false,IntroText="ABI",SaveConfig=true,ConfigFolder="XlurConfig"})

    local Players, RunService = game:GetService("Players"), game:GetService("RunService")
    local playerESPEnabled, espObjects = false, {}

    local function createESP(part, name)
        if not part or espObjects[part] then return end
        local bb = Instance.new("BillboardGui", part)
        bb.Adornee, bb.Size, bb.StudsOffset, bb.AlwaysOnTop = part, UDim2.new(0,100,0,30), Vector3.new(0,3,0), true
        local lbl = Instance.new("TextLabel", bb)
        lbl.BackgroundTransparency, lbl.Size, lbl.Text, lbl.TextColor3, lbl.TextStrokeTransparency, lbl.Font, lbl.TextScaled =
            1, UDim2.new(1,0,1,0), name, Color3.fromRGB(0,162,255), 0, Enum.Font.SourceSansBold, true
        espObjects[part] = bb
    end

    local function removeESP(part)
        if espObjects[part] then espObjects[part]:Destroy() espObjects[part] = nil end
    end

    local function togglePlayerESP(state)
        playerESPEnabled = state
        for _, p in pairs(Players:GetPlayers()) do
            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if state then createESP(hrp, p.Name) else removeESP(hrp) end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if playerESPEnabled then togglePlayerESP(true) end
        for part in pairs(espObjects) do if not part or not part.Parent then removeESP(part) end end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(c)
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            if playerESPEnabled and hrp then createESP(hrp, p.Name) end
        end)
    end)

    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})
    MiscTab:AddToggle({Name="Player ESP", Default=false, Callback=togglePlayerESP})

    OrionLib:Init()
end
