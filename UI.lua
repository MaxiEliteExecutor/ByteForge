local KRNL = Instance.new("ScreenGui")
KRNL.Name = "KRNL"

KRNL.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Position = UDim2.new(0.128834, 0, 0.139442, 0)
MainFrame.Size = UDim2.new(0, 602, 0, 361)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
MainFrame.Parent = KRNL

local KRNLText = Instance.new("TextLabel")
KRNLText.Name = "KRNLText"
KRNLText.Position = UDim2.new(0.259624, 0, 0, 0)
KRNLText.Size = UDim2.new(0, 283, 0, 56)
KRNLText.BackgroundColor3 = Color3.new(1, 1, 1)
KRNLText.BackgroundTransparency = 1
KRNLText.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
KRNLText.Transparency = 1
KRNLText.Text = "ByteForge (soon normal executor)"
KRNLText.TextColor3 = Color3.new(1, 1, 1)
KRNLText.TextSize = 19
KRNLText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
KRNLText.TextWrapped = true
KRNLText.Parent = MainFrame

local Input = Instance.new("TextBox")
Input.Name = "Input"
Input.Position = UDim2.new(0.010806, 0, 0.14757, 0)
Input.Size = UDim2.new(0, 589, 0, 254)
Input.BackgroundColor3 = Color3.new(0.294118, 0.294118, 0.294118)
Input.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
Input.Text = "print('Hello world')"
Input.TextColor3 = Color3.new(1, 1, 1)
Input.TextSize = 27
Input.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Input.TextWrapped = true
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.TextYAlignment = Enum.TextYAlignment.Top
Input.Parent = MainFrame

local Execute = Instance.new("TextButton")
Execute.Name = "Execute"
Execute.Position = UDim2.new(0.010806, 0, 0.895416, 0)
Execute.Size = UDim2.new(0, 292, 0, 37)
Execute.BackgroundColor3 = Color3.new(0.266667, 0.266667, 0.266667)
Execute.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
Execute.Text = "Execute"
Execute.TextColor3 = Color3.new(1, 1, 1)
Execute.TextSize = 21
Execute.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Execute.Parent = MainFrame

local Clear = Instance.new("TextButton")
Clear.Name = "Clear"
Clear.Position = UDim2.new(0.508639, 0, 0.895416, 0)
Clear.Size = UDim2.new(0, 289, 0, 37)
Clear.BackgroundColor3 = Color3.new(0.266667, 0.266667, 0.266667)
Clear.BorderColor3 = Color3.new(0.121569, 0.121569, 0.121569)
Clear.Text = "CLEAR"
Clear.TextColor3 = Color3.new(1, 1, 1)
Clear.TextSize = 21
Clear.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Clear.Parent = MainFrame

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Position = UDim2.new(0.903257, 0, 0.0267407, 0)
Close.Size = UDim2.new(0, 42, 0, 35)
Close.BackgroundColor3 = Color3.new(0.309804, 0.309804, 0.309804)
Close.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
Close.Text = "X"
Close.TextColor3 = Color3.new(0, 0, 0)
Close.TextSize = 14
Close.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Close.Parent = MainFrame

Close.MouseButton1Click:Connect(function()
	KRNL:Destroy()
end)

Clear.MouseButton1Click:Connect(function()
	Input.Text = nil
end)

Execute.MouseButton1Click:Connect(function()
	loadstring(tostring(Input.Text))
end)
