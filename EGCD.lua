-- Add new abilities here. Order is determined as shown.
local defaultAbilities = {
  caster = {
    { spellid = 6552, duration = 1.5},    -- Pummel
    { spellid = 72, duration = 1.5},    -- Shield Bash
    { spellid = 1680, duration = 1.5},   -- Whirlwind
    { spellid = 25208, duration = 1.5},    -- Rend
    { spellid = 30330, duration = 1.5},    -- Mortal Strike
    { spellid = 25212, duration = 1.5},   -- Hamstring
    { spellid = 25264, duration = 1.5},   -- Thunder Clap
    { spellid = 25266, duration = 1.5},   -- Mocking Blow
    { spellid = 11585, duration = 1.5},   -- Overpower
    { spellid = 5246, duration = 1.5},   -- Intimidating Shout
    { spellid = 2048, duration = 1.5},   -- Battle Shout
    { spellid = 469, duration = 1.5},	-- Commanding Shout
    { spellid = 25203, duration = 1.5},    -- Demoralizing Shout
    { spellid = 25236, duration = 1.5},   -- Execute
    { spellid = 12323, duration = 1.5},   -- Piercing Howl
    { spellid = 25225, duration = 1.5},  -- Sunder Armor
    { spellid = 676, duration = 1.5},   -- Disarm
    { spellid = 12292, duration = 1.5},   -- Death Wish
    { spellid = 18499, duration = 1.5},   -- Berserker Rage
	{ spellid = 20594, duration = 1.5},   -- Stoneform
	{ spellid = 20589, duration = 1.5},   -- Escape Artist
	{ spellid = 1766, duration = 1},   -- Kick
    { spellid = 26862, duration = 1},   -- Sinister Strike
    { spellid = 26863, duration = 1},   -- Backstab
	{ spellid = 26864, duration = 1},   -- Hemorrhage
	{ spellid = 14278, duration = 1},   -- Ghostly Strike
	{ spellid = 34097, duration = 1},   -- riposte
	{ spellid = 5940, duration = 1},   -- Shiv
	{ spellid = 34413, duration = 1},   -- Mutilate
	{ spellid = 38764, duration = 1},   -- Gouge
	{ spellid = 31224, duration = 1},   -- Cloak of Shadows
	{ spellid = 2094, duration = 1},   -- Blind					    
	{ spellid = 1725, duration = 1},   -- Distract
	{ spellid = 26679, duration = 1},   -- Deadly Throw
	{ spellid = 32684, duration = 1},   -- Envenom
	{ spellid = 26867, duration = 1},   -- Rupture
	{ spellid = 26866, duration = 1},   -- Expose Armor
	{ spellid = 26865, duration = 1},   -- Eviscerate
	{ spellid = 8643, duration = 1},   -- Kidney Shot
	{ spellid = 6774, duration = 1},   -- Slice and Dice
	{ spellid = 13877, duration = 1},   -- Blade Flurry
	{ spellid = 13750, duration = 1},   -- Adrenaline Rush
	{ spellid = 7744, duration = 1},   -- Will of the Forsaken
	{ spellid = 20600, duration = 1},   -- Perception
  },
}

local frame
local bar
local monitoredBars = {}

local defaultConfig = {
  scale = 1,
  hide = false,
  lock = false,
  columns = 0,
  alpha = 1,
  preset = "caster",
  abilities = defaultAbilities
}

local band = bit.band
local GetTime = GetTime
local ipairs = ipairs
local pairs = pairs
local floor = math.floor
local ceil = math.ceil
local band = bit.band
local GetSpellInfo = GetSpellInfo

local function Egcd_ShowHelp()
  ChatFrame1:AddMessage("Egcd Options | /Egcd <option>", 0, 1, 0)
  ChatFrame1:AddMessage("-- scale <number> | value: " .. EgcdDB.scale, 0, 1, 0)
  ChatFrame1:AddMessage("-- alpha <number> | value: " .. tostring(EgcdDB.alpha), 0, 1, 0)
  ChatFrame1:AddMessage("-- add <spellid> <duration>", 0, 1, 0)
  ChatFrame1:AddMessage("-- hide (toggle) | value: " .. tostring(EgcdDB.hide), 0, 1, 0)
  ChatFrame1:AddMessage("-- lock (toggle) | value: " .. tostring(EgcdDB.lock), 0, 1, 0)
  ChatFrame1:AddMessage("-- test (execute)", 0 , 1, 0)
  ChatFrame1:AddMessage("-- reset (execute)", 0, 1, 0)
end

local function Egcd_GetAbilities()
  return EgcdDB.abilities[EgcdDB.preset]
end

-- main frame update function, this is what updates the current cooldown of each icon
local function Egcd_OnUpdateIcon(self)
  local cooldown = self.start + self.duration - GetTime()
  if cooldown <= 0 then
    self.deactivate()
  else
    self.settimeleft(ceil(cooldown))
  end
end

local function Egcd_CreateIcon(ability)
  local btn = CreateFrame("Frame", nil, bar)
  btn:SetWidth(30)
  btn:SetHeight(30)
  btn:SetFrameStrata("LOW")

  local cd = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
  cd.noomnicc = true
  cd.noCooldownCount = true
  cd:SetAllPoints(true)
  cd:SetFrameStrata("MEDIUM")
  cd:SetDrawEdge(false)
  cd:SetHideCountdownNumbers(true)
  cd:Hide()

  local texture = btn:CreateTexture(nil, "BACKGROUND")
  texture:SetAllPoints(true)
  texture:SetTexture(ability.icon)
  texture:SetTexCoord(0.07, 0.9, 0.07, 0.90)

  local text = cd:CreateFontString(nil, "ARTWORK")
  text:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
  text:SetTextColor(1, 1, 0, 1)
  text:SetPoint("LEFT", btn, "LEFT", 2,0)

  btn.texture = texture
  btn.text = text
  btn.duration = ability.duration
  btn.cd = cd
  btn.spellid = ability.spellid

  -- called when a spell has been cast to start the cooldown tracker
  btn.activate = function()
    if btn.active then return end
    if EgcdDB.hide then btn:Show() end

    btn.start = GetTime()
    btn.cd:Show()
    btn.cd:SetCooldown(GetTime() - 0.1, btn.duration)
    btn.start = GetTime()
    btn.settimeleft(btn.duration)
    btn:SetScript("OnUpdate", Egcd_OnUpdateIcon)
    btn.active = true
  end

  -- called when a cooldown tracker has finished
  btn.deactivate = function()
    if EgcdDB.hide then btn:Hide() end

    btn.text:SetText("")						
    btn.cd:Hide()
    btn:SetScript("OnUpdate", nil)
    btn.active = false
  end

  btn.settimeleft = function(timeleft)
    if timeleft < 10 then
      if timeleft <= 0.5 then
        btn.text:SetText("")
      else
        btn.text:SetFormattedText("", timeleft)
      end
    else
      btn.text:SetFormattedText("", timeleft)
    end

    -- red color when the spell is almost ready, yellow otherwise
    if timeleft < 6 then
      btn.text:SetTextColor(1, 0, 0, 1)
    else
      btn.text:SetTextColor(1, 1, 0, 1)
    end

    -- set smaller font if the time left is too big, so it can fit in the icon
    if timeleft > 60 then
      btn.text:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    else
      btn.text:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
    end
  end

  return btn
end

local function Egcd_PositionSpellIcons(abilitiesCollection)
  local x = -45
  local row = 0
  local colCounter = 1

  -- position every icon, take account of the number of icons per row
  for _, ability in ipairs(abilitiesCollection) do
    local icon = monitoredBars[ability.name]
    if not icon then
      icon = Egcd_CreateIcon(ability)
    end

    if EgcdDB.columns > 0 and colCounter > EgcdDB.columns then
      colCounter = 1
      row = row + 1
      x = -45
    end

    icon:SetPoint("CENTER", bar, "CENTER", x, row * -30)

    x = x
    colCounter = colCounter + 1

    monitoredBars[ability.name] = icon
  end
end

local function Egcd_AddSpell(spellid, duration)
  for _, ability in ipairs(Egcd_GetAbilities()) do
    -- the spell already exists, just update it
    if ability.spellid == spellid then
      return
    end
  end

  -- create a new ability if it doesnt exist already
  local newAbility = {}
  local name, _, spellicon = GetSpellInfo(spellid)

  if not spellicon then return end

  newAbility.spellid = spellid
  newAbility.duration = duration
  newAbility.icon = spellicon
  newAbility.name = name

  table.insert(Egcd_GetAbilities(), newAbility)
  Egcd_PositionSpellIcons(Egcd_GetAbilities())
end

local function Egcd_SavePosition()
  local point, _, relativePoint, xOfs, yOfs = bar:GetPoint()

  if not EgcdDB.Position then 
    EgcdDB.Position = {}
  end

  EgcdDB.Position.point = point
  EgcdDB.Position.relativePoint = relativePoint
  EgcdDB.Position.xOfs = xOfs
  EgcdDB.Position.yOfs = yOfs - 24
end

local function Egcd_LoadPosition()
  if EgcdDB.Position then
    bar:SetPoint(EgcdDB.Position.point, UIParent, EgcdDB.Position.relativePoint, EgcdDB.Position.xOfs, EgcdDB.Position.yOfs)
  else
    bar:SetPoint("CENTER", UIParent, "CENTER")
  end
end

local function Egcd_UpdateBar()
  bar:SetScale(EgcdDB.scale)
  bar:SetAlpha(EgcdDB.alpha)

  if EgcdDB.hide then
    for _, btn in pairs(monitoredBars) do btn:Hide() end
  else
    for _, btn in pairs(monitoredBars) do btn:Show() end
  end

  if EgcdDB.lock then
    bar:EnableMouse(false)
  else
    bar:EnableMouse(true)
  end
end

-- gather the data about the abilities that will be monitored
local function Egcd_InitializeAbilities(abilitiesCollection)
  for _, ability in ipairs(abilitiesCollection) do
    local name, _, spellicon = GetSpellInfo(ability.spellid)
  
    ability.icon = spellicon
    ability.name = name
  end
end

local function Egcd_CreateBar()
  Egcd_InitializeAbilities(Egcd_GetAbilities())

  bar = CreateFrame("Frame", nil, UIParent)
  bar:SetMovable(true)
  bar:SetWidth(120)
  bar:SetHeight(30)
  bar:SetClampedToScreen(true) 
  bar:SetScript("OnMouseDown", function(self, button) if button == "LeftButton" then self:StartMoving() end end)
  bar:SetScript("OnMouseUp", function(self, button) if button == "LeftButton" then self:StopMovingOrSizing() Egcd_SavePosition() end end)
  bar:Show()
  
  Egcd_PositionSpellIcons(Egcd_GetAbilities())
  Egcd_UpdateBar()
  Egcd_LoadPosition()
end

-- combat log event has happened
local function Egcd_COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, _, _, srcName, srcFlags, _, _, dstName, dstFlags, _, spellid, spellName)
  if srcFlags and band(srcFlags, 0x00000040) == 0x00000040 and (eventtype == "SPELL_CAST_SUCCESS" or eventtype == "SPELL_AURA_APPLIED" or event == "SPELL_DAMAGE" or event == "SPELL_CAST_FAILED") then

    -- check if the spell id is being monitored by us and activate it
    local btn = monitoredBars[spellName]
    if btn then
      btn.activate()
    end
  end
end

local function Egcd_ResetAllTimers()
  for _, btn in pairs(monitoredBars) do
    btn.deactivate()
  end
end

local function Egcd_PLAYER_ENTERING_WORLD(self)
  Egcd_ResetAllTimers()
end

local function Egcd_Reset()
  Egcd_ResetAllTimers()

  EgcdDB = defaultConfig

  Egcd_InitializeAbilities(Egcd_GetAbilities())

  Egcd_UpdateBar()
  Egcd_LoadPosition()

  ChatFrame1:AddMessage("Egcd Configuration reset, /reload the UI", 0, 1, 0)
end

local function Egcd_Test()
  Egcd_ResetAllTimers()
  
  for _, btn in pairs(monitoredBars) do
    btn.activate()
  end
end

local cmdfuncs = {
  scale = function(v)
    if (type(v) == "number") then
      EgcdDB.scale = v;
      Egcd_UpdateBar()
    else
      Egcd_ShowHelp()
    end
  end,
  columns = function(v)
    if (type(v) == "number") and (floor(v) == v) then
      EgcdDB.columns = v;
      Egcd_PositionSpellIcons(Egcd_GetAbilities())
    else
      Egcd_ShowHelp()
    end
  end,
  alpha = function(v)
    if (type(v) == "number") and v <= 1 and v >= 0 then
      EgcdDB.alpha = v
      Egcd_UpdateBar()
    else
      Egcd_ShowHelp()
    end
  end,
  add = function(spellid, duration)
    Egcd_AddSpell(spellid, duration)
    Egcd_UpdateBar()
  end,
  hide = function() EgcdDB.hide = not EgcdDB.hide; Egcd_UpdateBar() end,
  lock = function() EgcdDB.lock = not EgcdDB.lock; Egcd_UpdateBar() end,
  reset = function() Egcd_Reset() end,
  test = function() Egcd_Test() end,
}

-- command handler, called for every command run by the player
local cmdtbl = {}
function Egcd_Command(cmd)
  -- clear the previous command
  for k in ipairs(cmdtbl) do
    cmdtbl[k] = nil
  end

  -- add the new command parameters
  for v in gmatch(cmd, "[^ ]+") do
    tinsert(cmdtbl, v)
  end

  -- try to get the first command
  local commandCallback = cmdfuncs[cmdtbl[1]] 
  if commandCallback then
    commandCallback(tonumber(cmdtbl[2]), tonumber(cmdtbl[3]))
  else
    -- not a valid command so show the help
    Egcd_ShowHelp()
  end
end

local function Egcd_InitializeDB()
  -- initialize the saved variables
  if EgcdDB == nil then
    EgcdDB = defaultConfig
  end;

  -- initialize any missing parameters
  if not EgcdDB.scale then EgcdDB.scale = 1 end
  if not EgcdDB.hide then EgcdDB.hide = false end
  if not EgcdDB.lock then EgcdDB.lock = false end
  if not EgcdDB.columns then EgcdDB.columns = 0 end
  if not EgcdDB.alpha then EgcdDB.alpha = 1 end
  if not EgcdDB.abilities then EgcdDB.abilities = defaultAbilities end
  if not EgcdDB.preset then EgcdDB.preset = "caster" end
end

local function Egcd_OnLoad(self)
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  Egcd_InitializeDB()

  Egcd_CreateBar()

  SlashCmdList["Egcd"] = Egcd_Command
  SLASH_Egcd1 = "/Egcd"

  ChatFrame1:AddMessage("Egcd by Drainlock, based on InterruptBar by Rdmx. Type /Egcd for options.", 0, 1, 0)
end

local function isInArena()
	local _,type = IsInInstance()
	if (type == "arena") then
		return true
	end
	return false
	
end

local eventhandler = {
  ["ADDON_LOADED"] = function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == "Egcd" then
      Egcd_OnLoad(self)
    end;
  end,
  ["PLAYER_ENTERING_WORLD"] = function(self, ...) Egcd_PLAYER_ENTERING_WORLD(self)	arena=isInArena() end,
  ["COMBAT_LOG_EVENT_UNFILTERED"] = function(self, ...) Egcd_COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo()) end,
}

local function Egcd_OnEvent(self, event, arg1, ...)
  eventhandler[event](self, event, arg1, ...)
end

frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", Egcd_OnEvent)
frame:RegisterEvent("ADDON_LOADED")
