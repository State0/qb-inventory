-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local inInventory = false
local currentWeapon = nil
local CurrentWeaponData = {}
local currentOtherInventory = nil
local Drops = {}
local CurrentDrop = nil
local DropsNear = {}
local CurrentVehicle = nil
local CurrentGlovebox = nil
local CurrentStash = nil
local isCrafting = false
local isHotbar = false
local itemInfos = {}
local WeaponAttachments = {}

-- Functions

local function GetClosestVending()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local object = nil
    for _, machine in pairs(Config.VendingObjects) do
        local ClosestObject = GetClosestObjectOfType(pos.x, pos.y, pos.z, 0.75, GetHashKey(machine), 0, 0, 0)
        if ClosestObject ~= 0 then
            if object == nil then
                object = ClosestObject
            end
        end
    end
    return object
end

local function OpenVending()
    local ShopItems = {}
    ShopItems.label = "Vending Machine"
    ShopItems.items = Config.VendingItem
    ShopItems.slots = #Config.VendingItem
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "Vendingshop_"..math.random(1, 99), ShopItems)
end

local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function FormatWeaponAttachments(itemdata)
    local attachments = {}
    itemdata.name = itemdata.name:upper()
    if itemdata.info.attachments ~= nil and next(itemdata.info.attachments) ~= nil then
        for k, v in pairs(itemdata.info.attachments) do
            if WeaponAttachments[itemdata.name] ~= nil then
                for key, value in pairs(WeaponAttachments[itemdata.name]) do
                    if value.component == v.component then
                        item = value.item
                        attachments[#attachments+1] = {
                            attachment = key,
                            label = QBCore.Shared.Items[item].label
                            --label = value.label
                        }
                    end
                end
            end
        end
    end
    return attachments
end

local function IsBackEngine(vehModel)
    if BackEngineVehicles[vehModel] then return true end
    return false
end

local function OpenTrunk()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorOpen(vehicle, 4, false, false)
    else
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
end

local function CloseTrunk()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorShut(vehicle, 4, false)
    else
        SetVehicleDoorShut(vehicle, 5, false)
    end
end

local function closeInventory()
    SendNUIMessage({
        action = "close",
    })
end

local function ToggleHotbar(toggle)
    local HotbarItems = {
        [1] = PlayerData.items[1],
        [2] = PlayerData.items[2],
        [3] = PlayerData.items[3],
        [4] = PlayerData.items[4],
        [5] = PlayerData.items[5],
        [41] = PlayerData.items[41],
    }

    if toggle then
        SendNUIMessage({
            action = "toggleHotbar",
            open = true,
            items = HotbarItems
        })
    else
        SendNUIMessage({
            action = "toggleHotbar",
            open = false,
        })
    end
end

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

local function openAnim()
    LoadAnimDict('pickup_object')
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'putdown_low', 5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
end

local function ItemsToItemInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 22x, " ..QBCore.Shared.Items["plastic"]["label"] .. ": 32x."},
		[2] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 30x, " ..QBCore.Shared.Items["plastic"]["label"] .. ": 42x."},
		[3] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 30x, " ..QBCore.Shared.Items["plastic"]["label"] .. ": 45x, "..QBCore.Shared.Items["aluminum"]["label"] .. ": 28x."},
		[4] = {costs = QBCore.Shared.Items["electronickit"]["label"] .. ": 2x, " ..QBCore.Shared.Items["plastic"]["label"] .. ": 52x, "..QBCore.Shared.Items["steel"]["label"] .. ": 40x."},
		[5] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 10x, " ..QBCore.Shared.Items["plastic"]["label"] .. ": 50x, "..QBCore.Shared.Items["aluminum"]["label"] .. ": 30x, "..QBCore.Shared.Items["iron"]["label"] .. ": 17x, "..QBCore.Shared.Items["electronickit"]["label"] .. ": 1x."},
		[6] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 36x, " ..QBCore.Shared.Items["steel"]["label"] .. ": 24x, "..QBCore.Shared.Items["aluminum"]["label"] .. ": 28x."},
		[7] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 32x, " ..QBCore.Shared.Items["steel"]["label"] .. ": 43x, "..QBCore.Shared.Items["plastic"]["label"] .. ": 61x."},
		[8] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 50x, " ..QBCore.Shared.Items["steel"]["label"] .. ": 37x, "..QBCore.Shared.Items["copper"]["label"] .. ": 26x."},
		[9] = {costs = QBCore.Shared.Items["iron"]["label"] .. ": 60x, " ..QBCore.Shared.Items["glass"]["label"] .. ": 30x."},
		[10] = {costs = QBCore.Shared.Items["aluminum"]["label"] .. ": 60x, " ..QBCore.Shared.Items["glass"]["label"] .. ": 30x."},
		[11] = {costs = QBCore.Shared.Items["iron"]["label"] .. ": 33x, " ..QBCore.Shared.Items["steel"]["label"] .. ": 44x, "..QBCore.Shared.Items["plastic"]["label"] .. ": 55x, "..QBCore.Shared.Items["aluminum"]["label"] .. ": 22x."},
		[12] = {costs = QBCore.Shared.Items["iron"]["label"] .. ": 50x, " ..QBCore.Shared.Items["steel"]["label"] .. ": 50x, "..QBCore.Shared.Items["screwdriverset"]["label"] .. ": 3x, "..QBCore.Shared.Items["advancedlockpick"]["label"] .. ": 2x."},
	}

	local items = {}
	for k, item in pairs(Config.CraftingItems) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.CraftingItems = items
end

local function ItemsToFoodInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["burger-meat"]["label"] .. ": 1x, " ..QBCore.Shared.Items["burger-bun"]["label"] .. ": 1x. "},
		[2] = {costs = QBCore.Shared.Items["burger-bun"]["label"] .. ": 2x, " ..QBCore.Shared.Items["lettuce"]["label"] .. ": 2x, " ..QBCore.Shared.Items["hasenrücken"]["label"] .. ": 2x. "},
        [3] = {costs = QBCore.Shared.Items["rehrücken"]["label"] .. ": 2x. "},
        [4] = {costs = QBCore.Shared.Items["burger-bun"]["label"] .. ": 2x, " ..QBCore.Shared.Items["filetsteak"]["label"] .. ": 2x, " ..QBCore.Shared.Items["lettuce"]["label"] .. ": 2x. "},
        [5] = {costs = QBCore.Shared.Items["taubenfleisch"]["label"] .. ": 2x. "},
        [6] = {costs = QBCore.Shared.Items["meat"]["label"] .. ": 2x, " ..QBCore.Shared.Items["shell"]["label"] .. ": 2x, " ..QBCore.Shared.Items["lettuce"]["label"] .. ": 2x. "},
        [7] = {costs = QBCore.Shared.Items["gebirgslöwenfilet"]["label"] .. ": 2x. "},
        [8] = {costs = QBCore.Shared.Items["meatpig"]["label"] .. ": 2x. "},
	}

	local items = {}
	for k, item in pairs(Config.CraftingFood["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.CraftingFood["items"] = items
end

local function ItemsToCutInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["weed_zero-haze_plant"]["label"] .. ": 1x. "},
	}

	local items = {}
	for k, item in pairs(Config.WeedCutting["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.WeedCutting["items"] = items
end

local function ItemsToDryInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["weed_zero-haze_leaves"]["label"] .. ": 1x. "},
	}

	local items = {}
	for k, item in pairs(Config.WeedDrying["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.WeedDrying["items"] = items
end

local function ItemsToPackInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["weed_zero-haze_dried_leaves"]["label"] .. ": 1x, " ..QBCore.Shared.Items["empty_weed_bag"]["label"] .. ": 1x. "},
	}

	local items = {}
	for k, item in pairs(Config.WeedPacking["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.WeedPacking["items"] = items
end

local function ItemsToRollInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["weed_zero-haze"]["label"] .. ": 1x, " ..QBCore.Shared.Items["rolling_paper"]["label"] .. ": 1x. "},
	}

	local items = {}
	for k, item in pairs(Config.WeedRolling["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.WeedRolling["items"] = items
end

local function ItemsToBackInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["salami"]["label"] .. ": 5x, " ..QBCore.Shared.Items["cheese"]["label"] .. ": 5x, " ..QBCore.Shared.Items["sauce"]["label"] .. ": 2x, " ..QBCore.Shared.Items["dough"]["label"] .. ": 1x. "},
		-- [2] = {costs = QBCore.Shared.Items["mascarpone"]["label"] .. ": 1x, " ..QBCore.Shared.Items["kaffeepulver"]["label"] .. ": 1x, " ..QBCore.Shared.Items["rum"]["label"] .. ": 1x. "},
		[2] = {costs = QBCore.Shared.Items["nudelplatten"]["label"] .. ": 6x, " ..QBCore.Shared.Items["hackfleisch"]["label"] .. ": 6x, " ..QBCore.Shared.Items["cheese"]["label"] .. ": 6x. "},
		[3] = {costs = QBCore.Shared.Items["mozza"]["label"] .. ": 3x, " ..QBCore.Shared.Items["paniermehl"]["label"] .. ": 3x. "},
		[4] = {costs = QBCore.Shared.Items["tomate"]["label"] .. ": 1x, " ..QBCore.Shared.Items["baguette"]["label"] .. ": 1x, " ..QBCore.Shared.Items["knoblauch"]["label"] .. ": 1x. "},
		[5] = {costs = QBCore.Shared.Items["spaghetti"]["label"] .. ": 5x, " ..QBCore.Shared.Items["hackfleisch"]["label"] .. ": 3x, " ..QBCore.Shared.Items["sauce"]["label"] .. ": 3x. "},
		[6] = {costs = QBCore.Shared.Items["spaghetti"]["label"] .. ": 5x, " ..QBCore.Shared.Items["speiseöl"]["label"] .. ": 3x, " ..QBCore.Shared.Items["knoblauch"]["label"] .. ": 3x. "},
		[7] = {costs = QBCore.Shared.Items["zucker"]["label"] .. ": 2x, " ..QBCore.Shared.Items["eier"]["label"] .. ": 2x, " ..QBCore.Shared.Items["milch"]["label"] .. ": 2x. "},
		-- [9] = {costs = QBCore.Shared.Items["salbei"]["label"] .. ": 10x, " ..QBCore.Shared.Items["kalbsfleisch"]["label"] .. ": 10x, " ..QBCore.Shared.Items["schinken"]["label"] .. ": 10x, " ..QBCore.Shared.Items["kreuter"]["label"] .. ": 10x. "},
    }

	local items = {}
	for k, item in pairs(Config.PizzaBacking["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.PizzaBacking["items"] = items
end

local function ItemsToBackInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["bloodpackl"]["label"] .. ": 1x. "},
        [2] = {costs = QBCore.Shared.Items["bloodpackl"]["label"] .. ": 1x. "},
        [3] = {costs = QBCore.Shared.Items["bloodpackl"]["label"] .. ": 1x. "},
        [4] = {costs = QBCore.Shared.Items["bloodpackl"]["label"] .. ": 1x. "},
        [5] = {costs = QBCore.Shared.Items["bloodpackl"]["label"] .. ": 1x. "},
        [6] = {costs = QBCore.Shared.Items["bloodpackl"]["label"] .. ": 1x. "},
        [7] = {costs = QBCore.Shared.Items["bloodpackl"]["label"] .. ": 1x. "},
        [8] = {costs = QBCore.Shared.Items["bloodpackl"]["label"] .. ": 1x. "},
   }

	local items = {}
	for k, item in pairs(Config.BloodWork["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.BloodWork["items"] = items
end

local function ItemsToBackInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["rezepte"]["label"] .. ": 1x. "},
        [2] = {costs = QBCore.Shared.Items["rezeptb"]["label"] .. ": 1x. "},
        [3] = {costs = QBCore.Shared.Items["rezeptp"]["label"] .. ": 1x. "},
        [4] = {costs = QBCore.Shared.Items["rezepta"]["label"] .. ": 1x. "},
        [5] = {costs = QBCore.Shared.Items["rezeptm"]["label"] .. ": 1x. "},
        [6] = {costs = QBCore.Shared.Items["rezepti"]["label"] .. ": 1x. "},
        [7] = {costs = QBCore.Shared.Items["rezepto"]["label"] .. ": 1x. "},
   }

	local items = {}
	for k, item in pairs(Config.MedBay["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.MedBay["items"] = items
end

local function ItemsBroilerInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["haehnchen"]["label"] .. ": 1x. "},
		[2] = {costs = QBCore.Shared.Items["kartoffel"]["label"] .. ": 2x. "},
		[3] = {costs = QBCore.Shared.Items["haehnchen"]["label"] .. ": 1x. "},
		[4] = {costs = QBCore.Shared.Items["broiler"]["label"] .. ": 1x, " ..QBCore.Shared.Items["broilernuggets"]["label"] .. ": 1x, " ..QBCore.Shared.Items["lettuce"]["label"] .. ": 2x. "},
		[5] = {costs = QBCore.Shared.Items["lettuce"]["label"] .. ": 2x. "},
	}

	local items = {}
	for k, item in pairs(Config.GoldBroiler["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.GoldBroiler["items"] = items
end

local function SetupAttachmentItemsInfo()
	itemInfos = {
		[1] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 140x, " .. QBCore.Shared.Items["steel"]["label"] .. ": 250x, " .. QBCore.Shared.Items["rubber"]["label"] .. ": 60x"},
		[2] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 165x, " .. QBCore.Shared.Items["steel"]["label"] .. ": 285x, " .. QBCore.Shared.Items["rubber"]["label"] .. ": 75x"},
		[3] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 190x, " .. QBCore.Shared.Items["steel"]["label"] .. ": 305x, " .. QBCore.Shared.Items["rubber"]["label"] .. ": 85x, " .. QBCore.Shared.Items["smg_extendedclip"]["label"] .. ": 1x"},
		[4] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 205x, " .. QBCore.Shared.Items["steel"]["label"] .. ": 340x, " .. QBCore.Shared.Items["rubber"]["label"] .. ": 110x, " .. QBCore.Shared.Items["smg_extendedclip"]["label"] .. ": 2x"},
		[5] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 230x, " .. QBCore.Shared.Items["steel"]["label"] .. ": 365x, " .. QBCore.Shared.Items["rubber"]["label"] .. ": 130x"},
		[6] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 255x, " .. QBCore.Shared.Items["steel"]["label"] .. ": 390x, " .. QBCore.Shared.Items["rubber"]["label"] .. ": 145x"},
		[7] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 270x, " .. QBCore.Shared.Items["steel"]["label"] .. ": 435x, " .. QBCore.Shared.Items["rubber"]["label"] .. ": 155x"},
		[8] = {costs = QBCore.Shared.Items["metalscrap"]["label"] .. ": 300x, " .. QBCore.Shared.Items["steel"]["label"] .. ": 469x, " .. QBCore.Shared.Items["rubber"]["label"] .. ": 170x"},
	}

	local items = {}
	for k, item in pairs(Config.AttachmentCrafting["items"]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] or "",
			weight = itemInfo["weight"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.AttachmentCrafting["items"] = items
end

local function GetThresholdItems()
	ItemsToItemInfo()
	local items = {}
	for k, item in pairs(Config.CraftingItems) do
		if PlayerData.metadata["craftingrep"] >= Config.CraftingItems[k].threshold then
			items[k] = Config.CraftingItems[k]
		end
	end
	return items
end

local function GetThresholdItems()
	ItemsToItemInfo()
	local items = {}
	for k, item in pairs(Config.CraftingItems) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.CraftingItems[k].threshold then
			items[k] = Config.CraftingItems[k]
		end
	end
	return items
end

local function GetFoodThresholdItems()
	ItemsToFoodInfo()
	local items = {}
	for k, item in pairs(Config.CraftingFood["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.CraftingFood["items"][k].threshold then
			items[k] = Config.CraftingFood["items"][k]
		end
	end
	return items
end

local function GetCutThresholdItems()
	ItemsToCutInfo()
	local items = {}
	for k, item in pairs(Config.WeedCutting["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.WeedCutting["items"][k].threshold then
			items[k] = Config.WeedCutting["items"][k]
		end
	end
	return items
end

local function GetDryThresholdItems()
	ItemsToDryInfo()
	local items = {}
	for k, item in pairs(Config.WeedDrying["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.WeedDrying["items"][k].threshold then
			items[k] = Config.WeedDrying["items"][k]
		end
	end
	return items
end

local function GetPackThresholdItems()
	ItemsToPackInfo()
	local items = {}
	for k, item in pairs(Config.WeedPacking["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.WeedPacking["items"][k].threshold then
			items[k] = Config.WeedPacking["items"][k]
		end
	end
	return items
end

local function GetRollThresholdItems()
	ItemsToRollInfo()
	local items = {}
	for k, item in pairs(Config.WeedRolling["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.WeedRolling["items"][k].threshold then
			items[k] = Config.WeedRolling["items"][k]
		end
	end
	return items
end

local function GetBackThresholdItems()
	ItemsToBackInfo()
	local items = {}
	for k, item in pairs(Config.PizzaBacking["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.PizzaBacking["items"][k].threshold then
			items[k] = Config.PizzaBacking["items"][k]
		end
	end
	return items
end

local function GetBackThresholdItems()
	ItemsToBackInfo()
	local items = {}
	for k, item in pairs(Config.BloodWork["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.BloodWork["items"][k].threshold then
			items[k] = Config.BloodWork["items"][k]
		end
	end
	return items
end

local function GetBackThresholdItems()
	ItemsToBackInfo()
	local items = {}
	for k, item in pairs(Config.MedBay["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.MedBay["items"][k].threshold then
			items[k] = Config.MedBay["items"][k]
		end
	end
	return items
end

local function GetBroilerThresholdItems()
	ItemsBroilerInfo()
	local items = {}
	for k, item in pairs(Config.GoldBroiler["items"]) do
		if QBCore.Functions.GetPlayerData().metadata["craftingrep"] >= Config.GoldBroiler["items"][k].threshold then
			items[k] = Config.GoldBroiler["items"][k]
		end
	end
	return items
end


local function GetAttachmentThresholdItems()
	SetupAttachmentItemsInfo()
	local items = {}
	for k, item in pairs(Config.AttachmentCrafting["items"]) do
		if PlayerData.metadata["attachmentcraftingrep"] >= Config.AttachmentCrafting["items"][k].threshold then
			items[k] = Config.AttachmentCrafting["items"][k]
		end
	end
	return items
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LocalPlayer.state:set("inv_busy", false, true)
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set("inv_busy", true, true)
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:UpdateObject', function()
	QBCore = exports['qb-core']:GetCoreObject()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('inventory:client:CheckOpenState', function(type, id, label)
    local name = QBCore.Shared.SplitStr(label, "-")[2]
    if type == "stash" then
        if name ~= CurrentStash or CurrentStash == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "trunk" then
        if name ~= CurrentVehicle or CurrentVehicle == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "glovebox" then
        if name ~= CurrentGlovebox or CurrentGlovebox == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    elseif type == "drop" then
        if name ~= CurrentDrop or CurrentDrop == nil then
            TriggerServerEvent('inventory:server:SetIsOpenState', false, type, id)
        end
    end
end)

RegisterNetEvent('weapons:client:SetCurrentWeapon', function(data, bool)
    CurrentWeaponData = data or {}
end)

RegisterNetEvent('inventory:client:ItemBox', function(itemData, type)
    SendNUIMessage({
        action = "itemBox",
        item = itemData,
        type = type
    })
end)

RegisterNetEvent('inventory:client:requiredItems', function(items, bool)
    local itemTable = {}
    if bool then
        for k, v in pairs(items) do
            itemTable[#itemTable+1] = {
                item = items[k].name,
                label = QBCore.Shared.Items[items[k].name]["label"],
                image = items[k].image,
            }
        end
    end

    SendNUIMessage({
        action = "requiredItem",
        items = itemTable,
        toggle = bool
    })
end)

RegisterNetEvent('inventory:server:RobPlayer', function(TargetId)
    SendNUIMessage({
        action = "RobMoney",
        TargetId = TargetId,
    })
end)

RegisterNetEvent('inventory:client:OpenInventory', function(PlayerAmmo, inventory, other)
    if not IsEntityDead(PlayerPedId()) then
        ToggleHotbar(false)
        SetNuiFocus(true, true)
        if other then
            currentOtherInventory = other.name
        end
        SendNUIMessage({
            action = "open",
            inventory = inventory,
            slots = MaxInventorySlots,
            other = other,
            maxweight = QBCore.Config.Player.MaxWeight,
            Ammo = PlayerAmmo,
            maxammo = Config.MaximumAmmoValues,
        })
        inInventory = true
    end
end)

RegisterNetEvent('inventory:client:UpdatePlayerInventory', function(isError)
    SendNUIMessage({
        action = "update",
        inventory = PlayerData.items,
        maxweight = QBCore.Config.Player.MaxWeight,
        slots = MaxInventorySlots,
        error = isError,
    })
end)

RegisterNetEvent('inventory:client:CraftItems', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Crafting..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:CraftItems", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:CraftFood', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Crafting..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:CraftFood", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:CutWeed', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Schneiden..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:CutWeed", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:DryWeed', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Trocknen..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:DryWeed", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:PackWeed', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Abpacken..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:PackWeed", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:RollWeed', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Drehen..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:RollWeed", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:BackePizza', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Backe..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:BackePizza", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:BloodWork', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Entnehme Blut..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:BloodWork", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:MedBay', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Löse Rezept ein..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:MedBay", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:GoldBroiler', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Brate..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:GoldBroiler", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)


RegisterNetEvent('inventory:client:CraftAttachment', function(itemName, itemCosts, amount, toSlot, points)
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    isCrafting = true
    QBCore.Functions.Progressbar("repair_vehicle", "Crafting..", (math.random(2000, 5000) * amount), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "mini@repair",
		anim = "fixing_a_player",
		flags = 16,
	}, {}, {}, function() -- Done
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        TriggerServerEvent("inventory:server:CraftAttachment", itemName, itemCosts, amount, toSlot, points)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[itemName], 'add')
        isCrafting = false
	end, function() -- Cancel
		StopAnimTask(ped, "mini@repair", "fixing_a_player", 1.0)
        QBCore.Functions.Notify("Failed", "error")
        isCrafting = false
	end)
end)

RegisterNetEvent('inventory:client:PickupSnowballs', function()
    local ped = PlayerPedId()
    LoadAnimDict('anim@mp_snowball')
    TaskPlayAnim(ped, 'anim@mp_snowball', 'pickup_snowball', 3.0, 3.0, -1, 0, 1, 0, 0, 0)
    QBCore.Functions.Progressbar("pickupsnowball", "Collecting snowballs..", 1500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(ped)
        TriggerServerEvent('QBCore:Server:AddItem', "snowball", 1)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["snowball"], "add")
    end, function() -- Cancel
        ClearPedTasks(ped)
        QBCore.Functions.Notify("Canceled", "error")
    end)
end)

RegisterNetEvent('inventory:client:UseSnowball', function(amount)
    local ped = PlayerPedId()
    GiveWeaponToPed(ped, `weapon_snowball`, amount, false, false)
    SetPedAmmo(ped, `weapon_snowball`, amount)
    SetCurrentPedWeapon(ped, `weapon_snowball`, true)
end)

RegisterNetEvent('inventory:client:UseWeapon', function(weaponData, shootbool)
    local ped = PlayerPedId()
    local weaponName = tostring(weaponData.name)
    if currentWeapon == weaponName then
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        RemoveAllPedWeapons(ped, true)
        TriggerEvent('weapons:client:SetCurrentWeapon', nil, shootbool)
        currentWeapon = nil
    elseif weaponName == "weapon_stickybomb" or weaponName == "weapon_pipebomb" or weaponName == "weapon_smokegrenade" or weaponName == "weapon_flare" or weaponName == "weapon_proxmine" or weaponName == "weapon_ball"  or weaponName == "weapon_molotov" or weaponName == "weapon_grenade" or weaponName == "weapon_bzgas" then
        GiveWeaponToPed(ped, GetHashKey(weaponName), 1, false, false)
        SetPedAmmo(ped, GetHashKey(weaponName), 1)
        SetCurrentPedWeapon(ped, GetHashKey(weaponName), true)
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    elseif weaponName == "weapon_snowball" then
        GiveWeaponToPed(ped, GetHashKey(weaponName), 10, false, false)
        SetPedAmmo(ped, GetHashKey(weaponName), 10)
        SetCurrentPedWeapon(ped, GetHashKey(weaponName), true)
        TriggerServerEvent('QBCore:Server:RemoveItem', weaponName, 1)
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    else
        TriggerEvent('weapons:client:SetCurrentWeapon', weaponData, shootbool)
        QBCore.Functions.TriggerCallback("weapon:server:GetWeaponAmmo", function(result)
            local ammo = tonumber(result)
            if weaponName == "weapon_petrolcan" or weaponName == "weapon_fireextinguisher" then
                ammo = 4000
            end
            GiveWeaponToPed(ped, GetHashKey(weaponName), 0, false, false)
            SetPedAmmo(ped, GetHashKey(weaponName), ammo)
            SetCurrentPedWeapon(ped, GetHashKey(weaponName), true)
            if weaponData.info.attachments ~= nil then
                for _, attachment in pairs(weaponData.info.attachments) do
                    GiveWeaponComponentToPed(ped, GetHashKey(weaponName), GetHashKey(attachment.component))
                end
            end
            currentWeapon = weaponName
        end, CurrentWeaponData)
    end
end)

RegisterNetEvent('inventory:client:CheckWeapon', function(weaponName)
    local ped = PlayerPedId()
    if currentWeapon == weaponName then
        TriggerEvent('weapons:ResetHolster')
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        RemoveAllPedWeapons(ped, true)
        currentWeapon = nil
    end
end)

RegisterNetEvent('inventory:client:AddDropItem', function(dropId, player, coords)
    local forward = GetEntityForwardVector(GetPlayerPed(GetPlayerFromServerId(player)))
	local x, y, z = table.unpack(coords + forward * 0.5)
    Drops[dropId] = {
        id = dropId,
        coords = {
            x = x,
            y = y,
            z = z - 0.3,
        },
    }
end)

RegisterNetEvent('inventory:client:RemoveDropItem', function(dropId)
    Drops[dropId] = nil
    DropsNear[dropId] = nil
end)

RegisterNetEvent('inventory:client:DropItemAnim', function()
    local ped = PlayerPedId()
    SendNUIMessage({
        action = "close",
    })
    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Wait(7)
    end
    TaskPlayAnim(ped, "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
    Wait(2000)
    ClearPedTasks(ped)
end)

RegisterNetEvent('inventory:client:SetCurrentStash', function(stash)
    CurrentStash = stash
end)

-- Commands

RegisterCommand('closeinv', function()
    closeInventory()
end, false)

RegisterCommand('inventory', function()
    if not isCrafting and not inInventory then
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] and not IsPauseMenuActive() then
            local ped = PlayerPedId()
            local curVeh = nil
            if not Config.UseTarget then VendingMachine = GetClosestVending() or CaampFire end

            if IsPedInAnyVehicle(ped) then -- Is Player In Vehicle
                local vehicle = GetVehiclePedIsIn(ped, false)
                CurrentGlovebox = QBCore.Functions.GetPlate(vehicle)
                curVeh = vehicle
                CurrentVehicle = nil
            else
                local vehicle = QBCore.Functions.GetClosestVehicle()
                if vehicle ~= 0 and vehicle ~= nil then
                    local pos = GetEntityCoords(ped)
                    local dimensionMin, dimensionMax = GetModelDimensions(GetEntityModel(vehicle))
		    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, (dimensionMin.y), 0.0)
                    if (IsBackEngine(GetEntityModel(vehicle))) then
                        trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, (dimensionMax.y), 0.0)
                    end
                    if #(pos - trunkpos) < 1.5 and not IsPedInAnyVehicle(ped) then
                        if GetVehicleDoorLockStatus(vehicle) < 2 then
                            CurrentVehicle = QBCore.Functions.GetPlate(vehicle)
                            curVeh = vehicle
                            CurrentGlovebox = nil
                        else
                            QBCore.Functions.Notify("Vehicle Locked", "error")
                            return
                        end
                    else
                        CurrentVehicle = nil
                    end
                else
                    CurrentVehicle = nil
                end
            end

            if CurrentVehicle then -- Trunk
                local vehicleClass = GetVehicleClass(curVeh)
                local maxweight = 0
                local slots = 0
                if vehicleClass == 0 then
                    maxweight = 38000
                    slots = 30
                elseif vehicleClass == 1 then
                    maxweight = 50000
                    slots = 40
                elseif vehicleClass == 2 then
                    maxweight = 75000
                    slots = 50
                elseif vehicleClass == 3 then
                    maxweight = 42000
                    slots = 35
                elseif vehicleClass == 4 then
                    maxweight = 38000
                    slots = 30
                elseif vehicleClass == 5 then
                    maxweight = 30000
                    slots = 25
                elseif vehicleClass == 6 then
                    maxweight = 30000
                    slots = 25
                elseif vehicleClass == 7 then
                    maxweight = 30000
                    slots = 25
                elseif vehicleClass == 8 then
                    maxweight = 15000
                    slots = 15
                elseif vehicleClass == 9 then
                    maxweight = 60000
                    slots = 35
                elseif vehicleClass == 12 then
                    maxweight = 120000
                    slots = 35
                elseif vehicleClass == 13 then
                    maxweight = 0
                    slots = 0
                elseif vehicleClass == 14 then
                    maxweight = 120000
                    slots = 50
                elseif vehicleClass == 15 then
                    maxweight = 120000
                    slots = 50
                elseif vehicleClass == 16 then
                    maxweight = 120000
                    slots = 50
                else
                    maxweight = 360000
                    slots = 50
                end
                local other = {
                    maxweight = maxweight,
                    slots = slots,
                }
                TriggerServerEvent("inventory:server:OpenInventory", "trunk", CurrentVehicle, other)
                OpenTrunk()
            elseif CurrentGlovebox then
                TriggerServerEvent("inventory:server:OpenInventory", "glovebox", CurrentGlovebox)
            elseif CurrentDrop then
                TriggerServerEvent("inventory:server:OpenInventory", "drop", CurrentDrop)
            elseif VendingMachine then
                local ShopItems = {}
                ShopItems.label = "Vending Machine"
                ShopItems.items = Config.VendingItem
                ShopItems.slots = #Config.VendingItem
                TriggerServerEvent("inventory:server:OpenInventory", "shop", "Vendingshop_"..math.random(1, 99), ShopItems)
            else
                openAnim()
                TriggerServerEvent("inventory:server:OpenInventory")
            end
        end
    end
end)

RegisterKeyMapping('inventory', 'Open Inventory', 'keyboard', 'TAB')

RegisterCommand('hotbar', function()
    isHotbar = not isHotbar
    if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] and not IsPauseMenuActive() then
        ToggleHotbar(isHotbar)
    end
end)

RegisterKeyMapping('hotbar', 'Toggles keybind slots', 'keyboard', 'z')

for i = 1, 6 do
    RegisterCommand('slot' .. i,function()
        if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] and not IsPauseMenuActive() then
            if i == 6 then
                i = MaxInventorySlots
            end
            TriggerServerEvent("inventory:server:UseItemSlot", i)
        end
    end)
    RegisterKeyMapping('slot' .. i, 'Uses the item in slot ' .. i, 'keyboard', i)
end

RegisterNetEvent('qb-inventory:client:giveAnim', function()
    LoadAnimDict('mp_common')
	TaskPlayAnim(PlayerPedId(), 'mp_common', 'givetake1_b', 8.0, 1.0, -1, 16, 0, 0, 0, 0)
end)

RegisterNetEvent('inventory:client:craftTarget',function(data)
    local crafting = {}
    crafting.label = "Crafting"
    crafting.items = GetThresholdItems()
    TriggerServerEvent("inventory:server:OpenInventory", "crafting", math.random(1, 99), crafting)
end)

-- NUI

RegisterNUICallback('RobMoney', function(data)
    TriggerServerEvent("police:server:RobPlayer", data.TargetId)
end)

RegisterNUICallback('Notify', function(data)
    QBCore.Functions.Notify(data.message, data.type)
end)

RegisterNUICallback('GetWeaponData', function(data, cb)
    local data = {
        WeaponData = QBCore.Shared.Items[data.weapon],
        AttachmentData = FormatWeaponAttachments(data.ItemData)
    }
    cb(data)
end)

RegisterNUICallback('RemoveAttachment', function(data, cb)
    local ped = PlayerPedId()
    local WeaponData = QBCore.Shared.Items[data.WeaponData.name]
    local label = QBCore.Shared.Items
    local Attachment = WeaponAttachments[WeaponData.name:upper()][data.AttachmentData.attachment]

    QBCore.Functions.TriggerCallback('weapons:server:RemoveAttachment', function(NewAttachments)
        if NewAttachments ~= false then
            local Attachies = {}
            RemoveWeaponComponentFromPed(ped, GetHashKey(data.WeaponData.name), GetHashKey(Attachment.component))
            for k, v in pairs(NewAttachments) do
                for wep, pew in pairs(WeaponAttachments[WeaponData.name:upper()]) do
                    if v.component == pew.component then
                        item = pew.item
                        Attachies[#Attachies+1] = {
                            attachment = pew.item,
                            label = QBCore.Shared.Items[item].label,
                        }
                    end
                end
            end
            local DJATA = {
                Attachments = Attachies,
                WeaponData = WeaponData,
            }
            cb(DJATA)
        else
            RemoveWeaponComponentFromPed(ped, GetHashKey(data.WeaponData.name), GetHashKey(Attachment.component))
            cb({})
        end
    end, data.AttachmentData, data.WeaponData)
end)

RegisterNUICallback('getCombineItem', function(data, cb)
    cb(QBCore.Shared.Items[data.item])
end)

RegisterNUICallback("CloseInventory", function()
    if currentOtherInventory == "none-inv" then
        CurrentDrop = nil
        CurrentVehicle = nil
        CurrentGlovebox = nil
        CurrentStash = nil
        SetNuiFocus(false, false)
        inInventory = false
        ClearPedTasks(PlayerPedId())
        return
    end
    if CurrentVehicle ~= nil then
        CloseTrunk()
        TriggerServerEvent("inventory:server:SaveInventory", "trunk", CurrentVehicle)
        CurrentVehicle = nil
    elseif CurrentGlovebox ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "glovebox", CurrentGlovebox)
        CurrentGlovebox = nil
    elseif CurrentStash ~= nil then
        TriggerServerEvent("inventory:server:SaveInventory", "stash", CurrentStash)
        CurrentStash = nil
    else
        TriggerServerEvent("inventory:server:SaveInventory", "drop", CurrentDrop)
        CurrentDrop = nil
    end
    SetNuiFocus(false, false)
    inInventory = false
end)

RegisterNUICallback("UseItem", function(data)
    TriggerServerEvent("inventory:server:UseItem", data.inventory, data.item)
end)

RegisterNUICallback("combineItem", function(data)
    Wait(150)
    TriggerServerEvent('inventory:server:combineItem', data.reward, data.fromItem, data.toItem)
end)

RegisterNUICallback('combineWithAnim', function(data)
    local ped = PlayerPedId()
    local combineData = data.combineData
    local aDict = combineData.anim.dict
    local aLib = combineData.anim.lib
    local animText = combineData.anim.text
    local animTimeout = combineData.anim.timeOut

    QBCore.Functions.Progressbar("combine_anim", animText, animTimeout, false, true, {
        disableMovement = false,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = aDict,
        anim = aLib,
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(ped, aDict, aLib, 1.0)
        TriggerServerEvent('inventory:server:combineItem', combineData.reward, data.requiredItem, data.usedItem)
    end, function() -- Cancel
        StopAnimTask(ped, aDict, aLib, 1.0)
        QBCore.Functions.Notify("Failed!", "error")
    end)
end)

RegisterNUICallback("SetInventoryData", function(data)
    TriggerServerEvent("inventory:server:SetInventoryData", data.fromInventory, data.toInventory, data.fromSlot, data.toSlot, data.fromAmount, data.toAmount)
end)

RegisterNUICallback("PlayDropSound", function()
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
end)

RegisterNUICallback("PlayDropFail", function()
    PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
end)

RegisterNUICallback("GiveItem", function(data)
    local player, distance = QBCore.Functions.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    if player ~= -1 and distance < 3 then
        if (data.inventory == 'player') then
            local playerId = GetPlayerServerId(player)
            SetCurrentPedWeapon(PlayerPedId(),'WEAPON_UNARMED',true)
            TriggerServerEvent("inventory:server:GiveItem", playerId, data.item.name, data.amount, data.item.slot)
        else
            QBCore.Functions.Notify("You do not own this item!", "error")
        end
    else
        QBCore.Functions.Notify("No one nearby!", "error")
    end
end)

-- Threads

CreateThread(function()
    while true do
        local sleep = 1000
        if DropsNear then
            for k, v in pairs(DropsNear) do
                if DropsNear[k] then
                    sleep = 0
                    DrawMarker(2, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 120, 10, 20, 155, false, false, false, 1, false, false, false)
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if Drops and next(Drops) then
            local pos = GetEntityCoords(PlayerPedId(), true)
            for k, v in pairs(Drops) do
                if Drops[k] then
                    local dist = #(pos - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if dist < 7.5 then
                        DropsNear[k] = v
                        if dist < 2 then
                            CurrentDrop = k
                        else
                            CurrentDrop = nil
                        end
                    else
                        DropsNear[k] = nil
                    end
                end
            end
        else
            DropsNear = {}
        end
        Wait(500)
    end
end)

CreateThread(function()
    if Config.UseTarget then
        exports['qb-target']:AddTargetModel(Config.VendingObjects, {
            options = {
                {
                    icon = "fa-solid fa-cash-register",
                    label = "Vending Machine",
                    action = function()
                        OpenVending()
                    end
                },
            },
            distance = 2.5
        })
    end
end)


CreateThread(function()
    if Config.UseTarget then
        exports['qb-target']:AddTargetModel(Config.CraftingObject, {
            options = {
                {
                    event = "inventory:client:craftTarget",
                    icon = "fas fa-tools",
                    label = "Craft",
                },
            },
            distance = 2.5,
        })
    else
        while true do
            local sleep = 1000
            if LocalPlayer.state['isLoggedIn'] then
                local pos = GetEntityCoords(PlayerPedId())
                local craftObject = GetClosestObjectOfType(pos, 2.0, Config.CraftingObject, false, false, false)
                if craftObject ~= 0 then
                    local objectPos = GetEntityCoords(craftObject)
                    if #(pos - objectPos) < 1.5 then
                        sleep = 0
                        DrawText3Ds(objectPos.x, objectPos.y, objectPos.z + 1.0, "~g~E~w~ - Craft")
                        if IsControlJustReleased(0, 38) then
                            local crafting = {}
                            crafting.label = "Crafting"
                            crafting.items = GetThresholdItems()
                            TriggerServerEvent("inventory:server:OpenInventory", "crafting", math.random(1, 99), crafting)
                            sleep = 100
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.FoodCraftingLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.FoodCraftingLocation.x, Config.FoodCraftingLocation.y, Config.FoodCraftingLocation.z, "~g~E~w~ - Cook")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Cooking"
					crafting.items = GetFoodThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "food_crafting", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.WeedCuttingLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.WeedCuttingLocation.x, Config.WeedCuttingLocation.y, Config.WeedCuttingLocation.z, "~g~E~w~ - Schneiden")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Schneide"
					crafting.items = GetCutThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "weed_cutting", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.WeedDryingLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.WeedDryingLocation.x, Config.WeedDryingLocation.y, Config.WeedDryingLocation.z, "~g~E~w~ - Trocknen")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Trockne"
					crafting.items = GetDryThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "weed_drying", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.WeedPackingLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.WeedPackingLocation.x, Config.WeedPackingLocation.y, Config.WeedPackingLocation.z, "~g~E~w~ - Abpacken")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Abpacken"
					crafting.items = GetPackThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "weed_packing", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.WeedRollingLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.WeedRollingLocation.x, Config.WeedRollingLocation.y, Config.WeedRollingLocation.z, "~g~E~w~ - Joints Drehen")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Drehen"
					crafting.items = GetRollThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "weed_rolling", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.PizzaBackingLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.PizzaBackingLocation.x, Config.PizzaBackingLocation.y, Config.PizzaBackingLocation.z, "~g~E~w~ - Pizzaofen")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Pizzaofen"
					crafting.items = GetBackThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "pizza_backing", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.BloodWorkLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.BloodWorkLocation.x, Config.BloodWorkLocation.y, Config.BloodWorkLocation.z, "~g~E~w~ - Blutspende")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Blutspene"
					crafting.items = GetBackThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "blood_working", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.MedBayLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.MedBayLocation.x, Config.MedBayLocation.y, Config.MedBayLocation.z, "~g~E~w~ - Apotheke")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Apotheke"
					crafting.items = GetBackThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "med_bay", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId())
		local inRange = false
		local distance = #(pos - vector3(Config.GoldBroilerLocation))

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3Ds(Config.GoldBroilerLocation.x, Config.GoldBroilerLocation.y, Config.GoldBroilerLocation.z, "~g~E~w~ - Hähnchengrill")
				if IsControlJustPressed(0, 38) then
					local crafting = {}
					crafting.label = "Hähnchengrill"
					crafting.items = GetBroilerThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "gold_broiler", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Wait(1000)
		end

		Wait(3)
	end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if LocalPlayer.state['isLoggedIn'] then
            local pos = GetEntityCoords(PlayerPedId())
            local distance = #(pos - Config.AttachmentCraftingLocation)
            if distance < 10 then
                if distance < 1.5 then
                    sleep = 0
                    DrawText3Ds(Config.AttachmentCraftingLocation.x, Config.AttachmentCraftingLocation.y, Config.AttachmentCraftingLocation.z, "~g~E~w~ - Craft")
                    if IsControlJustPressed(0, 38) then
                        local crafting = {}
                        crafting.label = "Attachment Crafting"
                        crafting.items = GetAttachmentThresholdItems()
                        TriggerServerEvent("inventory:server:OpenInventory", "attachment_crafting", math.random(1, 99), crafting)
                        sleep = 100
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
