local replicatedStorage = game:GetService("ReplicatedStorage")
local network = require(replicatedStorage:WaitForChild("Framework"):WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("2 - Network"))

local function getUpvalueSafe(func, index)
    local success, value = pcall(getupvalue, func, index)
    return success and value or nil
end

local u115 = getUpvalueSafe(network.Fire, 2)
if not u115 then warn("v_u_115 not found") return end

local u87 = getUpvalueSafe(u115, 1)
if not u87 then warn("v_u_87 not dounf") return end

local remoteMap = getUpvalueSafe(u87, 1)
if not remoteMap or type(remoteMap) ~= "table" then
    warn("remoteMap not found")
    return
end

local eventMap = remoteMap[1] or {}
local funcMap = remoteMap[2] or {}

print("=== Remote Beautifier ===")
print("RemoteEvents gefunden:", #eventMap)
for origName, remoteObj in pairs(eventMap) do
    if remoteObj and remoteObj.Parent then
        print("  " .. origName .. " -> " .. remoteObj:GetFullName())
        remoteObj:SetAttribute("OriginalName", origName)
        remoteObj.Name = origName
    end
end

print("Found RemoteFunctions:", #funcMap)
for origName, remoteObj in pairs(funcMap) do
    if remoteObj and remoteObj.Parent then
        print("  " .. origName .. " -> " .. remoteObj:GetFullName())
        remoteObj:SetAttribute("OriginalName", origName)
        remoteObj.Name = origName
    end
end

print("Finished Hexing Remotes!")


local function computeHash(p19)
    local v20 = #p19 * 8
    local v21 = v20 + 8
    local v22 = p19 .. string.char(128)
    local v23 = 4
    local function v33(p24, p25, p26, p27)
        if p24 <= 19 then
            local v28 = bit32.bxor(p26, p27)
            local v29 = bit32.band(p25, v28)
            return bit32.bxor(p27, v29)
        end
        if p24 <= 39 then
            return bit32.bxor(p25, p26, p27)
        end
        if p24 > 59 then
            return bit32.bxor(p25, p26, p27)
        end
        local v30 = bit32.bor(p26, p27)
        local v31 = bit32.band(p25, v30)
        local v32 = bit32.band(p26, p27)
        return bit32.bor(v31, v32)
    end
    local function v35(p34)
        return p34 <= 19 and 1518500249 or (p34 <= 39 and 1859775393 or (p34 <= 59 and 2400959708 or 3395469782))
    end
    local function v40(p36, p37, p38, p39)
        return bit32.lshift(p36, 24) + bit32.lshift(p37, 16) + bit32.lshift(p38, 8) + p39
    end
    while (v21 + 64) % 512 ~= 0 do
        v23 = v23 + 1
        v21 = v21 + 8
    end
    local v42 = (v22 .. string.rep("\0", v23)) .. string.char((function(p41)
        return bit32.extract(p41, 24, 8), bit32.extract(p41, 16, 8), bit32.extract(p41, 8, 8), bit32.extract(p41, 0, 8)
    end)(v20))
    local v43 = 1732584193
    local v44 = 4023233417
    local v45 = 2562383102
    local v46 = 271733878
    local v47 = 3285377520
    local v48 = 1
    local v49 = #v42
    local v50
    if v49 <= v48 then
        v50 = v43
    else
        local v51 = {}
        while true do
            local v52 = 0
            if v52 < 16 then
                local v53 = v48
                repeat
                    local v54 = v53 + 3
                    v51[v52] = v40(string.byte(v42, v53, v54))
                    v53 = v53 + 4
                    v52 = v52 + 1
                until v52 >= 16
            end
            local v55 = 16
            if v55 < 80 then
                repeat
                    local v56 = v51[v55 - 3]
                    local v57 = v51[v55 - 8]
                    local v58 = v51[v55 - 14]
                    local v59 = v51[v55 - 16]
                    local v60 = bit32.bxor(v56, v57, v58, v59)
                    v51[v55] = bit32.lrotate(v60, 1)
                    v55 = v55 + 1
                until v55 >= 80
            end
            local v61 = 0
            local v62, v63, v64, v65, v66
            if v61 >= 80 then
                v62 = v46
                v63 = v45
                v64 = v43
                v43 = v44
                v65 = v64
                v66 = v47
                local v67 = v64
                v64 = v65
                v67 = v65
                v65 = v64
            else
                local v68 = v44
                v66 = v46
                v65 = v43
                v62 = v45
                while true do
                    v63 = bit32.lrotate(v68, 30)
                    v64 = (bit32.lrotate(v43, 5) + v33(v61, v43, v63, v62) + v66 + v51[v61] + v35(v61)) % 4294967296
                    v61 = v61 + 1
                    if v61 >= 80 then
                        break
                    end
                    v68 = v43
                    v43 = v64
                    v66 = v62
                    v62 = v63
                end
            end
            v50 = (v65 + v64) % 4294967296
            v44 = (v44 + v43) % 4294967296
            v45 = (v45 + v63) % 4294967296
            v46 = (v46 + v62) % 4294967296
            v47 = (v47 + v66) % 4294967296
            v48 = v48 + 64
            if v49 < v48 then
                break
            end
            v43 = v50
        end
    end
    return string.format("%08x%08x%08x%08x%08x", v50, v44, v45, v46, v47):reverse():sub(5, 36)
end

local function getHashForRemote(typ, realName)
    local input = string.format("Network3//%s/%s/%s/%s/%d/%s",
        game.GameId,
        game.PlaceId,
        game.PlaceVersion,
        game.JobId,
        typ,
        realName
    )
    return computeHash(input)
end

local realNames = {
    "Accept Bank Invite", "Achievement Completed", "Activate Boost", "Admin Cmds Notification",
    "Bank Deposit", "Bank Refresh", "Bank Withdraw", "Boost Activated", "Boost Ended",
    "Buy 15 Pets", "Buy Area", "Buy Auto Hatch Gamepass", "Buy Bank", "Buy Boost", "Buy Boost Bundle",
    "Buy DiamondPack", "Buy Dominus Gate", "Buy Egg", "Buy Exclusive Pet", "Buy Gamepass",
    "Buy Hacker Gate", "Buy Hoverboard Gamepass", "Buy Merchant Item", "Buy Teleport Area",
    "Buy Teleport Gamepass", "Buy Trading Plaza", "Buy Upgrade", "Cancel Bank Outgoing Invites",
    "Cannon Fire", "Cannon Fired", "Change Pet Target", "Chat Msg", "Check Chat Status",
    "CheckDoubleCoins", "Claim Orbs", "clear entites update", "Clear Inventory Notifications",
    "Closing Now", "Coin Bonus", "Collect Bank Interest", "Collect Lootbag", "Convert To Dark Matter",
    "Create Merch Code", "Damage Coin", "Dark Matter Machine Redeemed", "Dark Matter Machine Used",
    "Dark Matter Timer Skipped", "Decline All Bank Invites", "Decline Bank Invite", "Delete Several Pets",
    "Dex", "Enchant Pet", "Enchanted Pets", "Equip Best Pets", "Equip Hoverboard", "Equip Pet",
    "Exclusive Pet Purchased", "Farm Coin", "Fireworks Animation", "Force Load World", "Gamepass Bought",
    "Get Bank", "Get Bank Invites", "Get BIG Admin Commands", "Get Coin Targets", "Get Coins",
    "Get Dark Matter Machine Info", "Get Enchant Pets Info", "Get Exclusive Pet Owned",
    "Get Exclusive Pets Config", "Get Fuse Pets Info", "Get Global Leaderboard", "Get Golden Machine Info",
    "Get Local Leaderboard", "Get Merchant Items", "Get Merchant Timer", "Get My Banks", "Get OSTime",
    "Get Pet Positions", "Get Pet Rarity DB", "Get Rainbow Machine Info", "Get Stats", "grab entities",
    "Hoverboard Unlocked", "Inventory Slots Given", "Invite To Bank", "Is Merchant Here", "Join Coin",
    "Kick From Bank", "Leave Bank", "Leave Coin", "Merchant Arrival", "Merchant Departed",
    "Merchant Updated", "Message", "ModeratorUtil", "New Stats", "Notification", "Open Egg",
    "OpenAdminPanel: Mobile", "OpenAdminPanel: PC", "Opening Egg", "Orb Added", "Orb Removed",
    "Panel: 1000x Luck", "Panel: BlackLuckyBlock", "Panel: Create Boosts", "Panel: Create Currency",
    "Panel: Messages", "Panel: Notifications", "Panel: Open Eggs", "Panel: Spawn Pet",
    "Panel: Unlock Hoverboards", "Performed Teleport", "Pet Target Coin", "Pet Target Player",
    "Pet Update", "Pick Starter", "Player Teleported", "playthesound", "Product Bought", "Product Failed",
    "Prompt Dark Matter Skip", "Prompt Upgrade Bank", "Purchase Exclusive Pet", "Rain Diamonds",
    "Rank Changed", "Read Changelog", "Redeem Dark Matter Pet", "Redeem Merch Code",
    "Redeem Pet Collection", "Redeem Rank Rewards", "Redeem Twitter Code", "Redeem VIP Rewards",
    "Remove Coin", "Rename Pet", "Request Cannon Launch", "Request World", "Rewards Redeemed",
    "Save Fail", "Send Message", "Sent Progress Notification", "Spooky Upgrade Animation",
    "Teleport To Trading Plaza", "Toggle Auto Delete", "Toggle Auto Hatch Setting", "Toggle Setting",
    "Unequip All Pets", "Unequip Pet", "Update Coin Health", "Update Coin Pets", "update entites",
    "Update Hoverboard State", "Upgrade Bank", "Upgrade Bought", "Upgrade Station Animation",
    "Use Fuse Machine", "Use Golden Machine", "Use Rainbow Machine", "Using Fuse Pets Machine",
    "Using Golden Machine", "Using Rainbow Machine", "Verify Twitter"
}

local renamedCount = 0
for _, realName in ipairs(realNames) do
    local hashEvent = getHashForRemote(1, realName)
    local remote = game.ReplicatedStorage:FindFirstChild(hashEvent)
    if remote then
        remote.Name = realName
        renamedCount = renamedCount + 1
        print("[EVENT] " .. hashEvent .. " -> " .. realName)
    else
        local hashFunc = getHashForRemote(2, realName)
        remote = game.ReplicatedStorage:FindFirstChild(hashFunc)
        if remote then
            remote.Name = realName
            renamedCount = renamedCount + 1
            print("[FUNCTION] " .. hashFunc .. " -> " .. realName)
        end
    end
end

print(string.format("Finished: %d von %d Remotes renamed.", renamedCount, #realNames))
