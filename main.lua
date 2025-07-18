-- Instances

local AgilesAdmin = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Top = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local TextBox = Instance.new("TextBox")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local CommandTemplate = Instance.new("Frame")
local CommandTextLabel = Instance.new("TextLabel")

-- Properties

AgilesAdmin.Name = "Agile's Admin"
AgilesAdmin.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
AgilesAdmin.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = AgilesAdmin
Main.AnchorPoint = Vector2.new(1, 1)
Main.BackgroundColor3 = Color3.new(0.0666667, 0.0666667, 0.0666667)
Main.BorderColor3 = Color3.new(0, 0, 0)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(1, 0, 1, 275)
Main.Size = UDim2.new(0, 200, 0, 300)

Top.Name = "Top"
Top.Parent = Main
Top.BackgroundColor3 = Color3.new(0.0666667, 0.0666667, 0.0666667)
Top.BorderColor3 = Color3.new(0, 0, 0)
Top.BorderSizePixel = 0
Top.Size = UDim2.new(1, 0, 0, 25)

TextLabel.Parent = Top
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderColor3 = Color3.new(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Agile's Admin v1.0"
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 14

TextBox.Parent = Main
TextBox.BackgroundColor3 = Color3.new(0.117647, 0.117647, 0.117647)
TextBox.BorderColor3 = Color3.new(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0, 0, 0, 25)
TextBox.Size = UDim2.new(1, 0, 0, 25)
TextBox.Font = Enum.Font.SourceSans
TextBox.PlaceholderColor3 = Color3.new(0.505882, 0.505882, 0.505882)
TextBox.PlaceholderText = "Command Line"
TextBox.Text = ""
TextBox.TextColor3 = Color3.new(1, 1, 1)
TextBox.TextSize = 14

ScrollingFrame.Parent = Main
ScrollingFrame.Active = true
ScrollingFrame.AnchorPoint = Vector2.new(0, 1)
ScrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 0, 1, 0)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -50)
ScrollingFrame.BottomImage = ""
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.TopImage = ""

UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

CommandTemplate.Name = "CommandTemplate"
CommandTemplate.Parent = nil
CommandTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
CommandTemplate.BackgroundTransparency = 1
CommandTemplate.BorderColor3 = Color3.new(0, 0, 0)
CommandTemplate.BorderSizePixel = 0
CommandTemplate.Size = UDim2.new(1, 0, 0, 25)

CommandTextLabel.Name = "CommandTextLabel"
CommandTextLabel.Parent = CommandTemplate
CommandTextLabel.AnchorPoint = Vector2.new(0, 0)
CommandTextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
CommandTextLabel.BackgroundTransparency = 1
CommandTextLabel.BorderColor3 = Color3.new(0, 0, 0)
CommandTextLabel.BorderSizePixel = 0
CommandTextLabel.Position = UDim2.new(0, 5, 0, 0)
CommandTextLabel.Size = UDim2.new(1, -10, 1, 0)
CommandTextLabel.Font = Enum.Font.SourceSans
CommandTextLabel.TextColor3 = Color3.new(1, 1, 1)
CommandTextLabel.TextSize = 14
CommandTextLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Useful Variables
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
-- Less Useful Variables But Still
local TweenInf = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

-- Agile Ui Lib
local Agile = {}
local commands = {}

function Agile:CreateCommand(commandString, func)
	local commandName = commandString:match("^[^%s]+")

	if commands[commandName] then
		warn("Agile Admin: Command '" .. commandName .. "' already exists, overwriting.")
	end

	local newCommandUI = CommandTemplate:Clone()
	newCommandUI.Parent = ScrollingFrame
	newCommandUI.Visible = true
	newCommandUI.CommandTextLabel.Text = commandString
	newCommandUI.Name = commandName

	commands[commandName] = {
		name = commandName,
		func = func,
		fullCommandString = commandString,
		uiElement = newCommandUI
	}

	Agile:FilterCommands(TextBox.Text)
end

function Agile:FilterCommands(searchText)
	searchText = searchText:lower():match("^[^%s]*") or ""

	for _, data in pairs(commands) do
		local visible = searchText == "" or data.fullCommandString:lower():find(searchText, 1, true)
		data.uiElement.Visible = visible
	end

	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	Agile:FilterCommands(TextBox.Text)
end)

TextBox.FocusLost:Connect(function()
	local Tween = TweenService:Create(Main, TweenInf, {Position = UDim2.new(1,0,1,275)})
	Tween:Play()
	
	local input = TextBox.Text:lower()
	local parts = {}
	for word in input:gmatch("[^%s]+") do
		table.insert(parts, word)
	end

	if #parts == 0 then return end

	local commandName = parts[1]
	local commandData = commands[commandName]

	if commandData then
		local args = {}
		for i = 2, #parts do
			table.insert(args, parts[i])
		end
		commandData.func(unpack(args))
	else
		warn("Agile Admin: Unknown command: " .. commandName)
	end

	TextBox.Text = ""
	Agile:FilterCommands("")
end)

Main.MouseEnter:Connect(function()
	local Tween = TweenService:Create(Main, TweenInf, {Position = UDim2.new(1,0,1,0)})
	Tween:Play()
end)
Main.MouseLeave:Connect(function()
	local Tween = TweenService:Create(Main, TweenInf, {Position = UDim2.new(1,0,1,275)})
	Tween:Play()
end)

UserInputService.InputEnded:Connect(function(Input, processed)
	if not processed and Input.KeyCode == Enum.KeyCode.Semicolon then
		TextBox:CaptureFocus()
		local Tween = TweenService:Create(Main, TweenInf, {Position = UDim2.new(1,0,1,0)})
		Tween:Play()
	end
end)

--Agile:CreateCommand("print <string>", function(string)
--	print(string)
--end)
