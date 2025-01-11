-------------------------------------
----           SCARLET           ----
----     made by: ripend-dev     ----
----          01/11/2025         ----
-------------------------------------

-----  USER-SPECIFIC SETTINGS  ------
local writingSpeed 				  = 240 -- How fast is the autotyper going to write
local firstMultiplier			  = 2 -- Autotyping time multiplier (bigger number == longer wait time)
local randomFloor				  = 1 -- Numerical floor of the first randomizer (bigger number == longer wait time, cannot be bigger than roof)
local randomRoof 				  = 60 -- Numerical roof of the first randomizer (bigger number == longer wait time)
local randomDelayFloor			  = 0.05 -- Changes the numerical floor of the last task.wait before pressing enter (cannot be bigger than roof)
local randomDelayRoof 			  = 0.15 -- Changes the numerical roof of the last task.wait before pressing enter (bigger number == longer wait time)
local preparationRandomDelayFloor = 1 -- Modifies the random floor of the preparation time (before the autotyper starts writing to simulate thinking)
local preparationRandomDelayRoof  = 1.4 -- Modifies the random roof of the preparation time (before the autotyper starts writing to simulate thinking)

local realisticAutotyping		  = false
local hyphenated				  = false
local currentSort				  = 0
local parseAmount				  = 25000

-----    SCARLET SOURCE CODE    -----
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local localPlayer = game:GetService("Players").LocalPlayer
local virtualUser = game:GetService("VirtualUser")

local site = game:HttpGet("https://raw.githubusercontent.com/Artzified/WordBombDictionary/refs/heads/main/words.txt", true)
local words = string.split(site, "\n")
local wordBlacklist = {}
local UserInterfaceEnabled = false
local inProgress = false

local ifn =
	localPlayer.PlayerGui.GameUI.Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.InfoFrameContainer.InfoFrame
local tx = ifn.TextFrame

-- Allows running the script multiple times in one session without having to rejoin the server
if getgenv().executed then
	for _, v in next, localPlayer.PlayerGui:GetDescendants() do
		if v.Name == "suggestedWord" then
			v:Destroy()
		end
	end

	if getgenv().connection then
		getgenv().connection:Disconnect()
		getgenv().connection = nil
	end
end

getgenv().executed = true

-- Finds all usable words for the letter sequence
function findWords(letters)
	local wordlist = {}
	for _, v in next, words do
		if string.find(string.upper(v), string.upper(letters)) then
			table.insert(wordlist, v)
		end
	end

	for i = #wordlist, 2, -1 do
		local j = math.random(1, i)
		wordlist[i], wordlist[j] = wordlist[j], wordlist[i]
	end

	local result = {}
	for i = 1, math.min(parseAmount, #wordlist) do
		table.insert(result, wordlist[i])
	end

	return result
end

-- Generating the user interface of the client
local gamename = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

local Window = Fluent:CreateWindow({
	Title = "Scarlet |",
	SubTitle = gamename,
	TabWidth = 130,
	Size = UDim2.fromOffset(490, 400),
	Acrylic = true,
	Theme = "Rose",
	MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
	Updates = Window:AddTab({ Title = "Home", Icon = "home" }),
	Main = Window:AddTab({ Title = "Autotyper", Icon = "play" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Side = nil

local Toggle = Tabs.Updates:AddToggle("Toggle", {
	Title = "Autotyper",
	Description = "Automatically Writes words for you",
	Default = false,

	Callback = function()
		autotyping = not autotyping
	end,
})

Toggle:SetValue(false)

local humanLikeToggle = Tabs.Main:AddToggle("Toggle", {
	Title = "Human-like autotyping",
	Description = "Autotyping will try to simulate how a real person would write the words",
	Default = false,

	Callback = function()
		realisticAutotyping = not realisticAutotyping
	end,
})

Toggle:SetValue(false)

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
	Values = { "Longest", "Shortest", "Random" },
	Multi = false,
	Default = 3,
	Callback = function(Value)
		_G.Mode = Value
	end,
})

Dropdown:OnChanged(function(Value)
    if Value == "Longest" then
		currentSort = 1

	elseif Value == "Shortest" then
		currentSort = 2
	
	elseif Value == "Random" then
		currentSort = -1
	end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

Window:SelectTab(1)

Tabs.Updates:AddButton({
	Title = "Run Infinite Yield",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end,
})

local Toggle = Tabs.Settings:AddToggle("Toggle", {
	Title = "Hyphenated words",
	Description = "Prioritizes writing words that include hyphens",
	Default = false,

	Callback = function()
		hyphenated = not hyphenated
	end,
})

local InputParseAmount = Tabs.Settings:AddInput("Input", {
	Title = "Words parse amount",
	Description = "bigger >> more unique",
	Default = parseAmount,
	Placeholder = parseAmount,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		parseAmount = Value
	end,
})

local InputWriteSpeed = Tabs.Main:AddInput("Input", {
	Title = "Writing speed (WPM)",
	Default = writingSpeed,
	Placeholder = writingSpeed,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		writingSpeed = Value
	end,
})

Tabs.Main:AddSection("Specific settings")

local InputMultiplier = Tabs.Main:AddInput("Input", {
	Title = "First multiplier",
	Default = firstMultiplier,
	Placeholder = firstMultiplier,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		firstMultiplier = Value
	end,
})

local InputRandomFloor = Tabs.Main:AddInput("Input", {
	Title = "RND number floor",
	Default = randomFloor,
	Placeholder = randomFloor,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		randomFloor = Value
	end,
})

local InputRandomRoof = Tabs.Main:AddInput("Input", {
	Title = "RND number roof",
	Default = randomRoof,
	Placeholder = randomRoof,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		randomRoof = Value
	end,
})

local InputRandomDelayFloor = Tabs.Main:AddInput("Input", {
	Title = "RND delay floor",
	Default = randomDelayFloor,
	Placeholder = randomDelayFloor,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		randomDelayFloor = Value
	end,
})

local InputRandomDelayRoof = Tabs.Main:AddInput("Input", {
	Title = "RND delay roof",
	Default = randomDelayRoof,
	Placeholder = randomDelayRoof,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		randomDelayRoof = Value
	end,
})

local InputPreparationRandomDelayFloor = Tabs.Main:AddInput("Input", {
	Title = "Intermission floor",
	Default = preparationRandomDelayFloor,
	Placeholder = preparationRandomDelayFloor,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		preparationRandomDelayFloor = Value
	end,
})

local InputPreparationRandomDelayRoof = Tabs.Main:AddInput("Input", {
	Title = "Intermission roof",
	Default = preparationRandomDelayRoof,
	Placeholder = preparationRandomDelayRoof,
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		preparationRandomDelayRoof = Value
	end,
})

autotyping = false
realisticAutotyping = false
hyphenated = false

local suggestedWord = Instance.new("TextLabel")
local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)

suggestedWord.Parent = localPlayer.PlayerGui.ScreenGui
suggestedWord.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
suggestedWord.Size = UDim2.new(0.4, 0, 0.1, 0)
suggestedWord.Position = UDim2.new(0.22, 0, 0.65, 0)
suggestedWord.Text = ""
suggestedWord.BackgroundTransparency = 1
suggestedWord.TextSize = 32
suggestedWord.TextColor3 = Color3.new(1, 1, 1)
suggestedWord.Name = "suggestedWord"

local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
if backpack:FindFirstChild("Ui") then
	backpack:FindFirstChild("Ui"):Destroy()
end

-- Autotyping with highly-customizable and realistic human-like form
function autotype(result)
	local typebox = localPlayer.PlayerGui.GameUI.Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.Typebar.Typebox
	local currentString = ""
	local disposableArray = {}
	local disposableCounter = 1

	if not realisticAutotyping then
		for _, v in next, result:split("") do
			currentString ..= v
			typebox.Text = currentString
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

			task.wait(
						1 / ((writingSpeed * firstMultiplier) / math.random(randomFloor, randomRoof))
						+ 1
						/ (disposableArray[math.random(1, 20)] * math.random(1, 3))
						/ math.random(randomFloor, randomRoof)
			)

			task.wait(math.random(randomDelayFloor, randomDelayRoof))
		end
	end

	table.insert(wordBlacklist, result)

	virtualUser:TypeKey("0x0D")
end

-- Main function that gives the script its purpose
function handler(ifn, tx)
	if ifn:FindFirstChild("Title").Text == "Quick! Type an English word containing:" then
		local sequence = {}
		print("type and english word")

		for _, v in next, tx:GetChildren() do
			if not v:IsA("Frame") then
				continue
			end

			if v.Visible then
				table.insert(sequence, {
					letter = v.Letter.TextLabel.Text,
					x = v.Letter.TextLabel.AbsolutePosition.X,
				})
			end
		end

		table.sort(sequence, function(a, b)
			return a.x < b.x
		end)

		local letters = ""

		for _, v in next, sequence do
			letters ..= v.letter
		end

		local result = findWords(letters)
		local a = 1

		if currentSort == 1 then
			table.sort(result, function(a, b)
				return #b < #a
			end)

		elseif currentSort == 2 then
			table.sort(result, function(a, b)
				return #a < #b
			end)
		end

		if hyphenated then
			print("smearing")

			table.sort(result, function(a, b)
				return a:find("-") and not b:find("-")
			end)
		end

		if autotyping then
			if table.find(wordBlacklist, result[a]) then
				warn("Blacklisted word found: " .. result[rnd] .. ". Skipping...")
				a += 1
			end

			suggestedWord.Text = result[a]
			autotype(result[a])
		else
			suggestedWord.Text = result[1]
		end
	else
		suggestedWord.Text = ""
	end
end

function create_connection(ifn, tx)
	getgenv().connection = ifn:FindFirstChild("Title"):GetPropertyChangedSignal("Text"):Connect(function()
		handler(ifn, tx)
	end)
	handler(ifn, tx)

	local c = ifn:GetPropertyChangedSignal("Parent"):Connect(function()
		if not ifn or not ifn.Parent then
			warn("Deleting connection")
			drop_connection()

			if c then
				c:Disconnect()
				c = nil
			end
		end
	end)
end

function drop_connection()
	if getgenv().connection then
		getgenv().connection:Disconnect()
		getgenv().connection = nil
	end

	inProgress = false
end

-- Intermission between turns
task.spawn(function()
	while true do
		task.wait(0.1)

		if inProgress then
			continue
		end

		suggestedWord.Text = ""

		if not localPlayer.PlayerGui.GameUI.Container.GameSpace.DefaultUI:FindFirstChild("GameContainer") then
			continue
		end

		local ifn =
			localPlayer.PlayerGui.GameUI.Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.InfoFrameContainer.InfoFrame
		local tx = ifn.TextFrame

		create_connection(ifn, tx)
		inProgress = true
	end
end)
