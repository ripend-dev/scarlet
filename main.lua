-------------------------------------
----        wordbomb-exp2        ----
----     made by: ripend-dev     ----
----          01/10/2025         ----
-------------------------------------

-----  USER-SPECIFIC SETTINGS  ------
local writingSpeed                = 240     -- How fast is the autotyper going to write
local firstMultiplier             = 2       -- Autotyping time multiplier (bigger number == longer wait time)
local randomFloor                 = 1       -- Numerical floor of the first randomizer (bigger number == longer wait time, cannot be bigger than roof)
local randomRoof                  = 60      -- Numerical roof of the first randomizer (bigger number == longer wait time)
local randomDelayFloor            = 0.05    -- Changes the numerical floor of the last task.wait before pressing enter (cannot be bigger than roof)
local randomDelayRoof             = 0.15    -- Changes the numerical roof of the last task.wait before pressing enter (bigger number == longer wait time)
local preparationRandomDelayFloor = 1       -- Modifies the random floor of the preparation time (before the autotyper starts writing to simulate thinking)
local preparationRandomDelayRoof  = 1.4     -- Modifies the random roof of the preparation time (before the autotyper starts writing to simulate thinking)

local realisticAutotyping         = false

----  WORDBOMB-EXP2 SOURCE CODE  -----
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local localPlayer = game:GetService("Players").LocalPlayer
local virtualUser = game:GetService("VirtualUser")

local wordBlacklist = {}

local UserInterfaceEnabled = false

-- Allows running the script multiple times in one session without having to rejoin the server
if getgenv().executed then
	warn("Resetting the connection\n\n")
	-- local screenGui = lp.PlayerGui:FindFirstChild("ScreenGui")

	-- if screenGui then
	-- 	screenGui:Destroy()
	-- end

	if getgenv().connection then
		getgenv().connection:Disconnect()
		getgenv().connection = nil
	end
end

getgenv().executed = true

-- Generating the user interface of the client
local gamename = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

local Window = Fluent:CreateWindow({
    Title = "Scarlet | ",
    SubTitle = gamename,
    TabWidth = 130,
    Size = UDim2.fromOffset(490, 400),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Updates = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Main", Icon = "play" }),
}

local Side = nil

local Toggle = Tabs.Updates:AddToggle("Toggle", {
    Title = "Autotyper",
    Description = "Automatically Writes words for you",
    Default = false
})

Toggle:SetValue(false)


game.GuiService.MenuOpened:Connect(function()
    if Toggle.Value then
        _G.Toggled = true
        Toggle:SetValue(false)
    end
end)

game.GuiService.MenuClosed:Connect(function()
    if not Toggle.Value and _G.Toggled then
        _G.Toggled = false
        Toggle:SetValue(true)
    end
end)

local Keybind = Tabs.Updates:AddKeybind("Keybind", {
    Title = "Autotyping keybind",
    Mode = "Toggle",
    Default = "Insert",

    Callback = function(Value)
        if Toggle.Value then
            Toggle:SetValue(false)
        else
            Toggle:SetValue(true)
        end
    end,
})


Tabs.Updates:AddSection("Adjustments")

local Dropdown = Tabs.Updates:AddDropdown("Dropdown", {
    Title = "Sorting mode",
    Values = {"Longest", "Shortest", "Random", "Hyphened"},
    Multi = false,
    Default = 3,
    Callback = function(Value)
        _G.Mode = Value
    end
})

loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

Window:SelectTab(1)

Tabs.Updates:AddButton({
    Title = "Run Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
if backpack:FindFirstChild("Ui") then
    backpack:FindFirstChild("Ui"):Destroy()
end

local tool = Instance.new("Tool")
tool.Name = "Ui"
tool.RequiresHandle = false
tool.TextureId = "rbxassetid://11104447788"
tool.Parent = backpack

Open = true
tool.Activated:Connect(function()
    if Open then
        Window:Minimize()
    else
        Window:Minimize()
    end
end)


-- Autotyping with highly-customizable and realistic human-like form
function autotype(result)
	local typebox = lp.PlayerGui.GameUI.Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.Typebar.Typebox
	local currentString = ""
	local disposableArray = {}
	local disposableCounter = 1

	if not realisticAutotyping then
		for _, v in next, result:split("") do
			t ..= v
			typebox.Text = t
			task.wait(1 / ((writingSpeed * 5) / 60))
		end
	else
		task.wait(math.random(preparationRandomDelayFloor, preparationRandomDelayRoof))

		while disposableCounter <= 20 do
			table.insert(disposableArray, math.random(1, 4096))
			disposableCounter += 1
			task.wait()
		end

		for _, v in next, result:split("") do
			currentString ..= v
			typebox.Text = currentString

			task.wait(1 / ((writingSpeed * firstMultiplier) / math.random(randomFloor, randomRoof))
            + 1 / (disposableArray[math.random(1, 20)] * math.random(1, 3)) / math.random(randomFloor, randomRoof))

			task.wait(math.random(randomDelayFloor, randomDelayRoof))
		end
	end

	table.insert(wordBlacklist, result)

	virtualUser:TypeKey("0x0D")
end
