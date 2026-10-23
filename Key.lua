
local Config = {
    -- [1] PlatoBoost Settings
    ServiceId       = 35564, -- Your PlatoBoost Service ID
    PlatoSecret     = "57131355-df4b-45f6-b896-67fe03fe612c", -- Your PlatoBoost Secret Key

    -- [2] Anti-Bypass / Global Secret Variable
    Secret          = "VY_D0(3)VDD./", -- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key, they won't be able to!

    -- [3] Scripts & Links
    MainScriptURL   = "https://raw.githubusercontent.com/HosLog-bot/Lua/refs/heads/Loader/String3.lua", -- The raw URL of your main script

    -- [3.1] Key links shown when pressing GET KEY (paste your links here)
    LinkvertiseURL      = "LINKVERTISE_LINK", -- Linkvertise link
    LinkvertiseDuration = "6h",               -- label shown on the card
    LootLabsURL         = "LOOTLABS_LINK",    -- LootLabs link
    LootLabsDuration    = "12h",              -- label shown on the card

    -- [4] Social Media Settings (Set to true to show, false to hide)
    ShowDiscord     = true,
    DiscordURL      = "https://discord.gg/kT55J724BK",

    ShowInstagram   = false,
    InstagramURL    = "YourInstaHere",

    ShowYoutube     = true,
    YoutubeURL      = "https://www.youtube.com/@RyvexDevs",

    -- [5] File System
    KeyFileName     = "CCD_Key.txt", -- The name of the file where the valid key will be saved for auto-login

    -- [6] GUI Management
    OldGuiName      = "anything", -- Name of the old GUI to destroy if it's already open
    MainGuiName     = "anything", -- Name of the main script's GUI to check if it's already executing

    -- [7] Hub Information & UI Text
    HubName         = "Vertese Client", -- The main title shown at the top of the GUI
    HubDescription  = "Get your key, paste it below and press VERIFY." -- The text shown below the title
}

-------------------------------------------------------------------------------
--! LIBRARIES (JSON & CRYPTOGRAPHY) - DO NOT MODIFY
-------------------------------------------------------------------------------
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
local lEncode, lDecode, lDigest = a3, aw, Z;

-------------------------------------------------------------------------------
--! CORE FUNCTIONS (REQUESTS & VERIFICATION)
-------------------------------------------------------------------------------

local useNonce = true

local function safeRequest(options)
    local req = request or http_request or syn_request or (http and http.request )
    if not req then return nil, "HTTP requests not supported" end
    local success, response = pcall(function() return req(options) end)
    if success and type(response) == "table" then
        return response
    else
        return nil, "Connection Error: " .. tostring(response or "Unknown")
    end
end

local hasClipboard = (setclipboard or toclipboard) ~= nil
local fSetClipboard = setclipboard or toclipboard or function() end
local fStringChar, fToString, fMathRandom, fMathFloor = string.char, tostring, math.random, math.floor
local fGetHwid = gethwid or function() return game:GetService("RbxAnalyticsService"):GetClientId() end

local host = "https://api.platoboost.com"
local hostChecked = false

local function checkConnectivity( )
    local response, err = safeRequest({Url = host .. "/public/connectivity", Method = "GET"})
    if not response or (response.StatusCode ~= 200 and response.StatusCode ~= 429) then
        host = "https://api.platoboost.net"
        local fallbackResponse, fallbackErr = safeRequest({Url = host .. "/public/connectivity", Method = "GET"})
        if not fallbackResponse then
            return false
        end
    end
    return true
end

local function generateNonce()
    local str = ""
    for _ = 1, 16 do str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97) end
    return str
end

local function saveKey(key)
    if writefile then pcall(writefile, Config.KeyFileName, key) end
end

local function redeemKey(key)
    if not hostChecked then
        hostChecked = true
        checkConnectivity()
    end

    local nonce = generateNonce()
    local body = {identifier = lDigest(fGetHwid()), key = key}
    if useNonce then body.nonce = nonce end

    local response, err = safeRequest({
        Url = host .. "/public/redeem/" .. fToString(Config.ServiceId),
        Method = "POST",
        Body = lEncode(body),
        Headers = {["Content-Type"] = "application/json"}
    })

    if response and response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data.valid then
            if useNonce then
                if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. Config.PlatoSecret) then
                    saveKey(key)
                    return true, "Success"
                end
                return false, "Integrity Check Failed"
            end
            saveKey(key)
            return true, "Success"
        end
        return false, decoded.message or "Invalid Key"
    end
    return false, err or "Server Error"
end

-- Never lets a malformed server answer break the interface.
local function safeRedeem(key)
    local ok, success, msg = pcall(redeemKey, key)
    if not ok then
        return false, "Unexpected error: " .. tostring(success)
    end
    return success, msg
end

-------------------------------------------------------------------------------
--! GUI & MAIN SCRIPT EXECUTION
-------------------------------------------------------------------------------

local function StartMainScript()
    local player = game:GetService("Players").LocalPlayer
    local pGui = player:WaitForChild("PlayerGui")

    if Config.OldGuiName ~= "" and pGui:FindFirstChild(Config.OldGuiName) then
        pGui[Config.OldGuiName]:Destroy()
        task.wait(0.1)
    end

    _G[Config.Secret] = true

    loadstring(game:HttpGet(Config.MainScriptURL))()
end

local function CreateGUI()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local player = Players.LocalPlayer

    local ICON = "rbxassetid://77141434675284"
    local WIDTH = 360
    local Theme = {
        Background = Color3.fromRGB(16, 14, 28),
        TopbarA = Color3.fromRGB(46, 28, 92),
        TopbarB = Color3.fromRGB(20, 18, 40),
        Element = Color3.fromRGB(30, 26, 52),
        ElementHover = Color3.fromRGB(42, 35, 74),
        Stroke = Color3.fromRGB(56, 48, 96),
        Accent = Color3.fromRGB(139, 92, 246),
        AccentText = Color3.fromRGB(196, 176, 255),
        Accent2 = Color3.fromRGB(34, 211, 238),
        Accent3 = Color3.fromRGB(244, 114, 182),
        Text = Color3.fromRGB(240, 236, 255),
        SubText = Color3.fromRGB(152, 144, 192),
        Success = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(251, 191, 36),
        Danger = Color3.fromRGB(248, 113, 113),
    }
    local White = Color3.new(1, 1, 1)
    local Gradient = ColorSequence.new(Theme.Accent, Theme.Accent2)
    local Ring = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.35, Theme.Accent2),
        ColorSequenceKeypoint.new(0.7, Theme.Accent3),
        ColorSequenceKeypoint.new(1, Theme.Accent),
    })
    local TI_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local TI_MED = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local TI_BACK = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local TI_POP = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local function make(class, props)
        local inst = Instance.new(class)
        local parent
        for k, v in pairs(props) do
            if k == "Parent" then parent = v else inst[k] = v end
        end
        if parent then inst.Parent = parent end
        return inst
    end
    local function tween(inst, goal, info)
        local t = TweenService:Create(inst, info or TI_MED, goal)
        t:Play()
        return t
    end
    local function corner(inst, r) return make("UICorner", {CornerRadius = UDim.new(0, r), Parent = inst}) end
    local function stroke(inst, color, thickness)
        return make("UIStroke", {Color = color or Theme.Stroke, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = inst})
    end
    local function gradient(inst, rotation, seq)
        return make("UIGradient", {Color = seq or Gradient, Rotation = rotation or 0, Parent = inst})
    end
    local function label(props)
        local base = {BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = ""}
        for k, v in pairs(props) do base[k] = v end
        return make("TextLabel", base)
    end

    -- Parent selection: gethui -> CoreGui -> PlayerGui
    local candidates = {}
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and typeof(result) == "Instance" then table.insert(candidates, result) end
    end
    table.insert(candidates, game:GetService("CoreGui"))
    table.insert(candidates, player:WaitForChild("PlayerGui"))
    for _, p in ipairs(candidates) do
        pcall(function()
            local old = p:FindFirstChild("RYV_KeySystem")
            if old then old:Destroy() end
        end)
    end

    local gui = make("ScreenGui", {Name = "RYV_KeySystem", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    local attached = false
    for _, p in ipairs(candidates) do
        local ok = pcall(function() gui.Parent = p end)
        if ok and gui.Parent == p then attached = true break end
    end
    if not attached then
        gui:Destroy()
        warn("[RYV Client] Could not attach the key system interface.")
        return
    end

    local conns, spins = {}, {}
    local closed = false
    local function closeGui()
        if closed then return end
        closed = true
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        for _, s in ipairs(spins) do pcall(function() s:Cancel() end) end
        gui:Destroy()
    end

    -- Window --------------------------------------------------------------
    local main = make("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(WIDTH, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Background, BorderSizePixel = 0, ClipsDescendants = true, Parent = gui,
    })
    corner(main, 14)
    local mainStroke = stroke(main, White, 1.5)
    local ring = gradient(mainStroke, 0, Ring)
    local spin = TweenService:Create(ring, TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360})
    spin:Play()
    table.insert(spins, spin)
    local mainScale = make("UIScale", {Scale = 0.85, Parent = main})
    make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = main})

    -- Header
    local header = make("Frame", {Name = "Header", BackgroundColor3 = White, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 58), LayoutOrder = 1, Parent = main})
    gradient(header, 0, ColorSequence.new(Theme.TopbarA, Theme.TopbarB))
    make("ImageLabel", {Name = "Icon", BackgroundTransparency = 1, Image = ICON, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(30, 30), Parent = header})
    local title = label({
        Name = "Title", Text = Config.HubName, Font = Enum.Font.GothamBold, TextSize = 17, TextColor3 = White,
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 54, 0.5, -8), Size = UDim2.new(1, -110, 0, 20),
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
    })
    gradient(title, 0, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(196, 176, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 225, 250)),
    }))
    label({Name = "Sub", Text = "Key System", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 54, 0.5, 10), Size = UDim2.new(1, -110, 0, 14), Parent = header})
    local closeBtn = make("TextButton", {
        Name = "Close", Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.SubText,
        AutoButtonColor = false, BackgroundColor3 = Theme.Danger, BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(30, 30), Parent = header,
    })
    corner(closeBtn, 8)
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, {BackgroundTransparency = 0, TextColor3 = White}, TI_FAST) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, {BackgroundTransparency = 1, TextColor3 = Theme.SubText}, TI_FAST) end)
    closeBtn.MouseButton1Click:Connect(function()
        tween(mainScale, {Scale = 0.85}, TI_MED)
        task.delay(0.2, closeGui)
    end)

    -- Drag (kept inside the screen)
    local dragging, dragStart, startPos = false, Vector2.new(), UDim2.new()
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = main.Position
            local c
            c = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if c then c:Disconnect() end
                end
            end)
        end
    end)
    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            local vp = gui.AbsoluteSize
            local limitX = vp.X / 2 + main.AbsoluteSize.X / 2 - 70
            local limitY = vp.Y / 2 + main.AbsoluteSize.Y / 2 - 50
            main.Position = UDim2.new(0.5, math.clamp(startPos.X.Offset + d.X, -limitX, limitX), 0.5, math.clamp(startPos.Y.Offset + d.Y, -limitY, limitY))
        end
    end))

    -- Body ----------------------------------------------------------------
    local body = make("Frame", {Name = "Body", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = main})
    make("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = body})
    make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = body})
    local order = 0
    local function nextOrder() order = order + 1 return order end

    label({Name = "Description", Text = Config.HubDescription, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.SubText,
        TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = body})

    -- Status (declared early so every handler can use it)
    local status = label({Name = "StatusLabel", Text = "Waiting for input...", Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 100, Parent = body})
    local function setStatus(text, color)
        status.Text = tostring(text)
        status.TextColor3 = color or Theme.SubText
        status.TextTransparency = 1
        tween(status, {TextTransparency = 0}, TI_MED)
    end

    -- Button factory: gradient background lives on the button, text on a child label
    local function makeButton(parent, text, primary, props)
        local base = {Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = primary and White or Theme.Element, Parent = parent}
        for k, v in pairs(props or {}) do base[k] = v end
        local btn = make("TextButton", base)
        corner(btn, 10)
        local scale = make("UIScale", {Parent = btn})
        local outline
        if primary then gradient(btn, 0) else outline = stroke(btn, Theme.Stroke, 1) end
        local lbl = label({Name = "Label", Text = text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = White,
            TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = btn})
        btn.MouseEnter:Connect(function()
            tween(scale, {Scale = 1.03}, TI_BACK)
            if not primary then
                tween(btn, {BackgroundColor3 = Theme.ElementHover}, TI_FAST)
                tween(outline, {Color = Theme.Accent}, TI_MED)
            end
        end)
        btn.MouseLeave:Connect(function()
            tween(scale, {Scale = 1}, TI_BACK)
            if not primary then
                tween(btn, {BackgroundColor3 = Theme.Element}, TI_FAST)
                tween(outline, {Color = Theme.Stroke}, TI_MED)
            end
        end)
        btn.MouseButton1Down:Connect(function() tween(scale, {Scale = 0.96}, TI_FAST) end)
        btn.MouseButton1Up:Connect(function() tween(scale, {Scale = 1.03}, TI_BACK) end)
        return btn, lbl
    end

    -- Social buttons (only the enabled ones)
    local socials = {}
    if Config.ShowDiscord then table.insert(socials, {"DISCORD", Color3.fromRGB(88, 101, 242), "rbxassetid://18505728201", Config.DiscordURL, "Discord Link Copied!", true}) end
    if Config.ShowInstagram then table.insert(socials, {"INSTAGRAM", Color3.fromRGB(225, 48, 108), "rbxassetid://18355586382", Config.InstagramURL, "Instagram Link Copied!"}) end
    if Config.ShowYoutube then table.insert(socials, {"YOUTUBE", Color3.fromRGB(255, 0, 0), "rbxassetid://82532989017804", Config.YoutubeURL, "YouTube Link Copied!"}) end
    if #socials > 0 then
        local row = make("Frame", {Name = "Socials", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = nextOrder(), Parent = body})
        make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row})
        local n = #socials
        for index, s in ipairs(socials) do
            local btn = make("TextButton", {
                Name = s[1], Text = s[1], Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = White, AutoButtonColor = false,
                BackgroundColor3 = s[2], BorderSizePixel = 0, LayoutOrder = index,
                Size = UDim2.new(1 / n, -(6 * (n - 1)) / n, 1, 0), Parent = row,
            })
            corner(btn, 10)
            make("UIPadding", {PaddingLeft = UDim.new(0, 22), Parent = btn})
            make("ImageLabel", {BackgroundTransparency = 1, Image = s[3], Position = UDim2.new(0, -18, 0.5, -9), Size = UDim2.fromOffset(18, 18), Parent = btn})
            local sc = make("UIScale", {Parent = btn})
            btn.MouseEnter:Connect(function() tween(sc, {Scale = 1.04}, TI_BACK) end)
            btn.MouseLeave:Connect(function() tween(sc, {Scale = 1}, TI_BACK) end)
            btn.MouseButton1Click:Connect(function()
                fSetClipboard(s[4])
                setStatus(hasClipboard and s[5] or "Clipboard unavailable on this executor.", s[2]:Lerp(White, 0.35))
                if s[6] then
                    local inviteCode = string.match(s[4], "discord%.gg/([%w-]+)")
                    if syn and syn.request and inviteCode then
                        pcall(syn.request, {Url = "http://localhost:1111/discord?invite=" .. inviteCode, Method = "GET"})
                    end
                end
            end)
        end
    end

    -- Key input
    local keyInput = make("TextBox", {
        Name = "KeyInput", PlaceholderText = "Enter your key...", PlaceholderColor3 = Theme.SubText, Text = "",
        Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text, ClearTextOnFocus = false,
        BackgroundColor3 = Theme.Element, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = nextOrder(), Parent = body,
    })
    corner(keyInput, 10)
    make("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = keyInput})
    local keyStroke = stroke(keyInput, Theme.Stroke, 1)
    keyInput.Focused:Connect(function() tween(keyStroke, {Color = Theme.Accent}, TI_MED) end)
    keyInput.FocusLost:Connect(function() tween(keyStroke, {Color = Theme.Stroke}, TI_MED) end)

    -- Buttons row
    local btnRow = make("Frame", {Name = "Buttons", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = nextOrder(), Parent = body})
    local verifyBtn, verifyLbl = makeButton(btnRow, "VERIFY", true, {Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0, 0, 0, 0)})
    local getKeyBtn, getKeyLbl = makeButton(btnRow, "GET KEY", false, {Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0)})

    -- Link chooser: Linkvertise (6h) + LootLabs (12h)
    local CARD_H, CARD_GAP = 58, 8
    local CHOOSER_H = CARD_H * 2 + CARD_GAP
    local chooser = make("Frame", {Name = "Chooser", BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = nextOrder(), Parent = body})
    make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, CARD_GAP), Parent = chooser})

    local linkBox = make("TextBox", {
        Name = "LinkBox", Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.AccentText, TextEditable = false,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ClipsDescendants = true,
        BackgroundColor3 = Theme.Element, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), Visible = false, LayoutOrder = nextOrder(), Parent = body,
    })
    corner(linkBox, 8)
    make("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = linkBox})
    stroke(linkBox, Theme.Stroke, 1)

    local function isLinkSet(url)
        return type(url) == "string" and url:match("^https?://") ~= nil
    end

    local function copyLink(name, url, copyLbl)
        if not isLinkSet(url) then
            setStatus(name .. " link is not configured yet.", Theme.Warning)
            return
        end
        if hasClipboard then
            local ok = pcall(fSetClipboard, url)
            if ok then
                setStatus(name .. " link copied! Open it in your browser.", Theme.Success)
                copyLbl.Text = "Copied!"
                task.delay(1.6, function()
                    if copyLbl.Parent then copyLbl.Text = "COPY" end
                end)
                return
            end
        end
        linkBox.Text = url
        linkBox.Visible = true
        setStatus("Clipboard unavailable. Select and copy the link below.", Theme.Warning)
    end

    local function makeCard(index, name, duration, url, color)
        local card = make("Frame", {Name = name, BackgroundColor3 = Theme.Element, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, CARD_H), LayoutOrder = index, Parent = chooser})
        corner(card, 10)
        local cardStroke = stroke(card, Theme.Stroke, 1)
        local pill = make("Frame", {BackgroundColor3 = color, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(46, 28), Parent = card})
        corner(pill, 8)
        label({Text = duration, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(20, 16, 36), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = pill})
        label({Text = name, Font = Enum.Font.GothamBold, TextSize = 14, Position = UDim2.new(0, 68, 0, 10), Size = UDim2.new(1, -150, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card})
        label({Text = "Key valid for " .. duration, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText, Position = UDim2.new(0, 68, 0, 30), Size = UDim2.new(1, -150, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card})
        local copyBtn, copyLbl = makeButton(card, "COPY", true, {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(66, 30)})
        copyLbl.TextSize = 12
        copyBtn.MouseButton1Click:Connect(function() copyLink(name, url, copyLbl) end)
        card.MouseEnter:Connect(function() tween(cardStroke, {Color = color}, TI_MED) end)
        card.MouseLeave:Connect(function() tween(cardStroke, {Color = Theme.Stroke}, TI_MED) end)
        return card
    end
    makeCard(1, "Linkvertise", Config.LinkvertiseDuration, Config.LinkvertiseURL, Theme.Accent2)
    makeCard(2, "LootLabs", Config.LootLabsDuration, Config.LootLabsURL, Theme.Accent3)

    local chooserOpen = false
    getKeyBtn.MouseButton1Click:Connect(function()
        chooserOpen = not chooserOpen
        tween(chooser, {Size = UDim2.new(1, 0, 0, chooserOpen and CHOOSER_H or 0)}, TI_POP)
        getKeyLbl.Text = chooserOpen and "HIDE LINKS" or "GET KEY"
        if chooserOpen then
            setStatus("Pick a provider, copy the link and open it in your browser.", Theme.AccentText)
        else
            linkBox.Visible = false
        end
    end)

    -- Verification ----------------------------------------------------------
    local busy = false
    local function finishSuccess(text)
        setStatus(text, Theme.Success)
        task.wait(0.5)
        tween(mainScale, {Scale = 0.85}, TI_MED)
        task.wait(0.2)
        closeGui()
        local ok, err = pcall(StartMainScript)
        if not ok then warn("[RYV Client] Failed to start the main script: " .. tostring(err)) end
    end

    verifyBtn.MouseButton1Click:Connect(function()
        if busy then return end
        local key = (keyInput.Text or ""):gsub("%s+", "")
        if key == "" then
            setStatus("Enter a key!", Theme.Warning)
            tween(keyStroke, {Color = Theme.Danger}, TI_FAST)
            task.delay(0.6, function() if keyStroke.Parent then tween(keyStroke, {Color = Theme.Stroke}, TI_MED) end end)
            return
        end
        busy = true
        verifyLbl.Text = "..."
        setStatus("Verifying...", Theme.AccentText)
        local success, msg = safeRedeem(key)
        if success then
            finishSuccess("Success! Loading...")
        else
            busy = false
            if verifyLbl.Parent then verifyLbl.Text = "VERIFY" end
            setStatus(msg, Theme.Danger)
        end
    end)

    -- Auto-login with the saved key
    if isfile and readfile then
        local okFile, exists = pcall(isfile, Config.KeyFileName)
        if okFile and exists then
            local okRead, savedKey = pcall(readfile, Config.KeyFileName)
            if okRead and savedKey ~= "" then
                busy = true
                setStatus("Found saved key, verifying...", Theme.AccentText)
                task.spawn(function()
                    local success = safeRedeem(savedKey)
                    if success then
                        finishSuccess("Auto-login success!")
                    else
                        busy = false
                        setStatus("Saved key expired or invalid.", Theme.Warning)
                    end
                end)
            end
        end
    end

    -- Entrance animation
    tween(mainScale, {Scale = 1}, TI_POP)
end

local player = game:GetService("Players").LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

if Config.MainGuiName ~= "" and pGui:FindFirstChild(Config.MainGuiName) then
    StartMainScript()
    return
end

CreateGUI()
