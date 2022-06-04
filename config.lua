Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.VendingObjects = {
    "prop_vend_soda_01",
    "prop_vend_soda_02",
    "prop_vend_water_01"
}

Config.BinObjects = {
    "prop_bin_05a",
}

Config.CraftingObject = `prop_toolchest_05`

Config.VendingItem = {
    [1] = {
        name = "kurkakola",
        price = 25,
        amount = 50,
        info = {},
        type = "item",
        slot = 1,
    },
    [2] = {
        name = "water_bottle",
        price = 25,
        amount = 50,
        info = {},
        type = "item",
        slot = 2,
    },
    [3] = {
        name = "zeroade",
        price = 250,
        amount = 50,
        info = {},
        type = "item",
        slot = 3,
    },
    [4] = {
        name = "snikkel_candy",
        price = 10,
        amount = 50,
        info = {},
        type = "item",
        slot = 4,
    },
    -- [2] = {
    --     name = "water_bottle",
    --     price = 25,
    --     amount = 50,
    --     info = {},
    --     type = "item",
    --     slot = 2,
    -- },
}

Config.CraftingItems = {
    [1] = {
        name = "lockpick",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 10,
            ["plastic"] = 10,
        },
        type = "item",
        slot = 1,
        threshold = 0,
        points = 1,
    },
    [2] = {
        name = "screwdriverset",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 41,
            ["plastic"] = 58,
        },
        type = "item",
        slot = 2,
        threshold = 0,
        points = 2,
    },
    [3] = {
        name = "electronickit",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 75,
            ["plastic"] = 110,
            ["aluminum"] = 90,
        },
        type = "item",
        slot = 3,
        threshold = 0,
        points = 3,
    },
    [4] = {
        name = "radioscanner",
        amount = 50,
        info = {},
        costs = {
            ["electronickit"] = 1,
            ["plastic"] = 30,
            ["steel"] = 100,
        },
        type = "item",
        slot = 4,
        threshold = 0,
        points = 4,
    },
    [5] = {
        name = "gatecrack",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 16,
            ["plastic"] = 83,
            ["aluminum"] = 50,
            ["iron"] = 28,
            ["electronickit"] = 1,
        },
        type = "item",
        slot = 5,
        threshold = 110,
        points = 5,
    },
    [6] = {
        name = "handcuffs",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 220,
            ["steel"] = 220,
            ["aluminum"] = 222,
        },
        type = "item",
        slot = 6,
        threshold = 160,
        points = 6,
    },
    [7] = {
        name = "repairkit",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 32,
            ["steel"] = 43,
            ["plastic"] = 61,
        },
        type = "item",
        slot = 7,
        threshold = 200,
        points = 7,
    },
    [8] = {
        name = "pistol_ammo",
        amount = 50,
        info = {},
        costs = {
            ["metalscrap"] = 50,
            ["steel"] = 61,
            ["copper"] = 43,
        },
        type = "item",
        slot = 8,
        threshold = 250,
        points = 8,
    },
    [9] = {
        name = "ironoxide",
        amount = 50,
        info = {},
        costs = {
            ["iron"] = 100,
            ["glass"] = 66,
        },
        type = "item",
        slot = 9,
        threshold = 300,
        points = 9,
    },
    [10] = {
        name = "aluminumoxide",
        amount = 50,
        info = {},
        costs = {
            ["aluminum"] = 100,
            ["glass"] = 66,
        },
        type = "item",
        slot = 10,
        threshold = 300,
        points = 10,
    },
    -- [11] = {
    --     name = "armor",
    --     amount = 50,
    --     info = {},
    --     costs = {
    --         ["iron"] = 13,
    --         ["steel"] = 19,
    --         ["plastic"] = 15,
    --         ["aluminum"] = 11,
    --     },
    --     type = "item",
    --     slot = 11,
    --     threshold = 350,
    --     points = 11,
    -- },
    [11] = {
        name = "drill",
        amount = 50,
        info = {},
        costs = {
            ["iron"] = 25,
            ["steel"] = 25,
            ["screwdriverset"] = 1,
            ["advancedlockpick"] = 1,
        },
        type = "item",
        slot = 11,
        threshold = 1750,
        points = 12,
    },
}

Config.FoodCraftingLocation = vector3(-1197.98, -899.1, 13.98)

Config.CraftingFood = {
    ["items"] = {
        [1] = {
            name = "superwich",
            amount = 50,
            info = {},
            costs = {
                ["burger-meat"] = 1,
                ["burger-bun"] = 1,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
        [2] = {
            name = "ksandwich",
            amount = 100,
            info = {},
            costs = {
                ["burger-bun"] = 2,
                ["hasenrücken"] = 2,
                ["lettuce"] = 2,
            },
            type = "item",
            slot = 2,
            threshold = 0,
            points = 1,
        },
        [3] = {
            name = "bnuggets",
            amount = 100,
            info = {},
            costs = {
                ["rehrücken"] = 2,
            },
            type = "item",
            slot = 3,
            threshold = 0,
            points = 1,
        },
        [4] = {
            name = "pburger",
            amount = 100,
            info = {},
            costs = {
                ["burger-bun"] = 2,
                ["filetsteak"] = 2,
                ["lettuce"] = 2,
            },
            type = "item",
            slot = 4,
            threshold = 0,
            points = 1,
        },
        [5] = {
            name = "twings",
            amount = 100,
            info = {},
            costs = {
                ["taubenfleisch"] = 2,
            },
            type = "item",
            slot = 5,
            threshold = 0,
            points = 1,
        },
        [6] = {
            name = "rtaco",
            amount = 100,
            info = {},
            costs = {
                ["meat"] = 2,
                ["shell"] = 2,
                ["lettuce"] = 2,
            },
            type = "item",
            slot = 6,
            threshold = 0,
            points = 1,
        },
        [7] = {
            name = "meat",
            amount = 100,
            info = {},
            costs = {
                ["gebirgslöwenfilet"] = 2,
            },
            type = "item",
            slot = 7,
            threshold = 0,
            points = 1,
        },
        [8] = {
            name = "burger-meat",
            amount = 100,
            info = {},
            costs = {
                ["meatpig"] = 2,
            },
            type = "item",
            slot = 8,
            threshold = 0,
            points = 1,
        },
    }
}

Config.WeedCuttingLocation = vector3(1950.63, 4652.48, 40.59)

Config.WeedCutting = {
    ["items"] = {
        [1] = {
            name = "weed_zero-haze_leaves",
            amount = 2000,
            info = {},
            costs = {
                ["weed_zero-haze_plant"] = 1,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
    }
}

Config.WeedDryingLocation = vector3(259.73, 2584.9, 44.95)

Config.WeedDrying = {
    ["items"] = {
        [1] = {
            name = "weed_zero-haze_dried_leaves",
            amount = 2000,
            info = {},
            costs = {
                ["weed_zero-haze_leaves"] = 1,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
    }
}

Config.WeedPackingLocation = vector3(657.96, -1023.15, 22.72)

Config.WeedPacking = {
    ["items"] = {
        [1] = {
            name = "weed_zero-haze",
            amount = 2000,
            info = {},
            costs = {
                ["weed_zero-haze_dried_leaves"] = 1,
                ["empty_weed_bag"] = 1,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
    }
}

Config.WeedRollingLocation = vector3(-1089.64, -1666.03, 4.7)

Config.WeedRolling = {
    ["items"] = {
        [1] = {
            name = "joint",
            amount = 2000,
            info = {},
            costs = {
                ["weed_zero-haze"] = 1,
                ["rolling_paper"] = 1,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
    }
}

Config.PizzaBackingLocation = vector3(419.49, -1502.07, 30.16)

Config.PizzaBacking = {
    ["items"] = {
        [1] = {
            name = "pizza_salieri",
            amount = 50,
            info = {},
            costs = {
                ["salami"] = 5,
                ["cheese"] = 5,
                ["sauce"] = 2,
                ["dough"] = 1,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
        -- [2] = {
        --     name = "triamisu",
        --     amount = 50,
        --     info = {},
        --     costs = {
        --         ["mascarpone"] = 1,
        --         ["kaffeepulver"] = 1,
        --         ["rum"] = 1,
        --     },
        --     type = "item",
        --     slot = 2,
        --     threshold = 0,
        --     points = 1,
        -- },
        [2] = {
            name = "lasagne",
            amount = 50,
            info = {},
            costs = {
                ["nudelplatten"] = 6,
                ["hackfleisch"] = 6,
                ["cheese"] = 6,
            },
            type = "item",
            slot = 2,
            threshold = 0,
            points = 1,
        },
        [3] = {
            name = "mozzarellastick",
            amount = 50,
            info = {},
            costs = {
                ["mozza"] = 3,
                ["paniermehl"] = 3,
            },
            type = "item",
            slot = 3,
            threshold = 0,
            points = 1,
        },
        [4] = {
            name = "bruschetta",
            amount = 50,
            info = {},
            costs = {
                ["tomate"] = 1,
                ["baguette"] = 1,
                ["knoblauch"] = 1,
            },
            type = "item",
            slot = 4,
            threshold = 0,
            points = 1,
        },
        [5] = {
            name = "spaghettibolo",
            amount = 50,
            info = {},
            costs = {
                ["spaghetti"] = 5,
                ["hackfleisch"] = 3,
                ["sauce"] = 3,
            },
            type = "item",
            slot = 5,
            threshold = 0,
            points = 1,
        },
        [6] = {
            name = "spaghettiaglio",
            amount = 50,
            info = {},
            costs = {
                ["spaghetti"] = 5,
                ["speiseöl"] = 3,
                ["knoblauch"] = 3,
            },
            type = "item",
            slot = 6,
            threshold = 0,
            points = 1,
        },
        [7] = {
            name = "gelato",
            amount = 50,
            info = {},
            costs = {
                ["zucker"] = 2,
                ["eier"] = 2,
                ["milch"] = 2,
            },
            type = "item",
            slot = 7,
            threshold = 0,
            points = 1,
        },
        -- [8] = {
        --     name = "saltimbocca",
        --     amount = 50,
        --     info = {},
        --     costs = {
        --         ["salbei"] = 10,
        --         ["kalbsfleisch"] = 10,
        --         ["schinken"] = 10,
        --         ["kreuter"] = 10,
        --     },
        --     type = "item",
        --     slot = 8,
        --     threshold = 0,
        --     points = 1,
        -- },
        -- [9] = {
        --     name = "tiramisu",
        --     amount = 50,
        --     info = {},
        --     costs = {
        --         ["mascarpone"] = 1,
        --         ["kaffeepulver"] = 1,
        --         ["rum"] = 1,
        --     },
        --     type = "item",
        --     slot = 9,
        --     threshold = 0,
        --     points = 1,
        -- },
    }
}

Config.GoldBroilerLocation = vector3(1248.19, -349.6, 69.21)

Config.GoldBroiler = {
    ["items"] = {
        [1] = {
            name = "broiler",
            amount = 2000,
            info = {},
            costs = {
                ["haehnchen"] = 1,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
        [2] = {
            name = "broilerpomme",
            amount = 2000,
            info = {},
            costs = {
                ["kartoffel"] = 2,
            },
            type = "item",
            slot = 2,
            threshold = 0,
            points = 1,
        },
        [3] = {
            name = "broilernuggets",
            amount = 2000,
            info = {},
            costs = {
                ["haehnchen"] = 1,
            },
            type = "item",
            slot = 3,
            threshold = 0,
            points = 1,
        },
        [4] = {
            name = "broilermenu",
            amount = 2000,
            info = {},
            costs = {
                ["broiler"] = 1,
                ["broilernuggets"] = 1,
                ["lettuce"] = 2,
            },
            type = "item",
            slot = 4,
            threshold = 0,
            points = 1,
        },
        [5] = {
            name = "broilersalat",
            amount = 2000,
            info = {},
            costs = {
                ["lettuce"] = 2,
            },
            type = "item",
            slot = 5,
            threshold = 0,
            points = 1,
        },
    }
}

Config.AttachmentCraftingLocation = vector3(88.91, 3743.88, 40.77)

Config.AttachmentCrafting = {
    ["items"] = {
        [1] = {
            name = "pistol_extendedclip",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 140,
                ["steel"] = 250,
                ["rubber"] = 60,
            },
            type = "item",
            slot = 1,
            threshold = 0,
            points = 1,
        },
        [2] = {
            name = "pistol_suppressor",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 165,
                ["steel"] = 285,
                ["rubber"] = 75,
            },
            type = "item",
            slot = 2,
            threshold = 10,
            points = 2,
        },
        [3] = {
            name = "smg_extendedclip",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 190,
                ["steel"] = 305,
                ["rubber"] = 85,
            },
            type = "item",
            slot = 3,
            threshold = 25,
            points = 3,
        },
        [4] = {
            name = "microsmg_extendedclip",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 205,
                ["steel"] = 340,
                ["rubber"] = 110,
            },
            type = "item",
            slot = 4,
            threshold = 50,
            points = 4,
        },
        [5] = {
            name = "smg_drum",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 230,
                ["steel"] = 365,
                ["rubber"] = 130,
            },
            type = "item",
            slot = 5,
            threshold = 75,
            points = 5,
        },
        [6] = {
            name = "smg_scope",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 255,
                ["steel"] = 390,
                ["rubber"] = 145,
            },
            type = "item",
            slot = 6,
            threshold = 100,
            points = 6,
        },
        [7] = {
            name = "assaultrifle_extendedclip",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 270,
                ["steel"] = 435,
                ["rubber"] = 155,
                ["smg_extendedclip"] = 1,
            },
            type = "item",
            slot = 7,
            threshold = 150,
            points = 7,
        },
        [8] = {
            name = "assaultrifle_drum",
            amount = 50,
            info = {},
            costs = {
                ["metalscrap"] = 300,
                ["steel"] = 469,
                ["rubber"] = 170,
                ["smg_extendedclip"] = 2,
            },
            type = "item",
            slot = 8,
            threshold = 200,
            points = 8,
        },
    }
}

MaxInventorySlots = 41

BackEngineVehicles = {
    [`ninef`] = true,
    [`adder`] = true,
    [`vagner`] = true,
    [`t20`] = true,
    [`infernus`] = true,
    [`zentorno`] = true,
    [`reaper`] = true,
    [`comet2`] = true,
    [`comet3`] = true,
    [`jester`] = true,
    [`jester2`] = true,
    [`cheetah`] = true,
    [`cheetah2`] = true,
    [`prototipo`] = true,
    [`turismor`] = true,
    [`pfister811`] = true,
    [`ardent`] = true,
    [`nero`] = true,
    [`nero2`] = true,
    [`tempesta`] = true,
    [`vacca`] = true,
    [`bullet`] = true,
    [`osiris`] = true,
    [`entityxf`] = true,
    [`turismo2`] = true,
    [`fmj`] = true,
    [`re7b`] = true,
    [`tyrus`] = true,
    [`italigtb`] = true,
    [`penetrator`] = true,
    [`monroe`] = true,
    [`ninef2`] = true,
    [`stingergt`] = true,
    [`surfer`] = true,
    [`surfer2`] = true,
    [`gp1`] = true,
    [`autarch`] = true,
    [`tyrant`] = true
}

Config.MaximumAmmoValues = {
    ["pistol"] = 250,
    ["smg"] = 250,
    ["shotgun"] = 200,
    ["rifle"] = 250,
}
