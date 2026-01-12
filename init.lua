local pRandom = PcgRandom(os.time() + 42) -- H2G2

--------------------------------
-- Fake player, needed since we call nodes' on_place function, if existing
--------------------------------
local function create_fake_player()
  local fakePlayer = {
    get_player_name = function() return "" end,
    is_player = function() return true end,
    is_fake_player = true,
    get_player_control = function() return {
        jump = false, right = false, left = false, LMB = false, RMB = false,
        sneak = false, aux1 = false, down = false, up = false
      } end,
    get_player_control_bits = function() return 0 end,
  }
  return fakePlayer
end

local minimalFakePlayer = create_fake_player()

--------------------------------
-- General setup
--------------------------------

local function clamp(v, min, max)
  v = tonumber(v) or min
  if v < min then return min
  elseif v > max then return max
  else return v end
end

local minSpreadTime = clamp(core.settings:get("flowerbeds_minSpreadTime") or 25, 5, 600)
local maxSpreadTime = clamp(core.settings:get("flowerbeds_maxSpreadTime") or 45, minSpreadTime, 600)
local minRemovedTime = clamp(core.settings:get("flowerbeds_minRemovedTime") or 80, 5, 600)
local maxRemovedTime = clamp(core.settings:get("flowerbeds_maxRemovedTime") or 120, minRemovedTime, 600)
local spreadChance = clamp(core.settings:get("flowerbeds_chance") or 25, 1, 100)

local blockGroups = { flowerbed = 1 }
local addMclHardness = false
local seeds = {}

local baseMatsAndTextures = {}
local sounds = {}
local materials = {}

-- compat with default and mcl
if core.get_modpath("default") then
  baseMatsAndTextures = {
    {"default:wood", "default_wood.png"},
    {"default:junglewood", "default_junglewood.png"},
    {"default:acacia_wood", "default_acacia_wood.png"},
    {"default:pine_wood", "default_pine_wood.png"},
    {"default:aspen_wood", "default_aspen_wood.png"},
  }
	blockGroups.choppy = 3
	blockGroups.oddly_breakable_by_hand = 3
	sounds = default.node_sound_wood_defaults()
  sounds.footstep = default.node_sound_dirt_defaults().footstep
  materials.coal_lump = "default:coal_lump"
  materials.dirt = "default:dirt"
elseif core.get_modpath("mcl_trees") and mcl_trees.woods and core.get_modpath("mcl_sounds") then -- only mineclonia has mcl_trees.woods
	addMclHardness = true
	sounds = mcl_sounds.node_sound_wood_defaults()
  sounds.footstep = mcl_sounds.node_sound_dirt_defaults().footstep
  materials.coal_lump = "mcl_core:coal_lump"
  materials.dirt = "mcl_core:dirt"
  seeds = {
    "mcl_farming:wheat_seeds",
    "mcl_farming:potato_item",
    "mcl_farming:carrot_item",
    "mcl_farming:beetroot_seeds",
  }

  local wood_types = {"bark", "wood", "stripped"}
  blockGroups.grass_block = 1
  blockGroups.soil = 1
  blockGroups.soil_sapling = 2
  blockGroups.soil_sugarcane = 1
  blockGroups.soil_bamboo = 1
  blockGroups.soil_fungus = 1
  blockGroups.supports_mushrooms = 1
	blockGroups.handy = 1
	blockGroups.axey = 1

  for name, _ in pairs(mcl_trees.woods) do
    for _, wood_type in ipairs(wood_types) do
      local nodeName = "mcl_trees:" .. wood_type .. "_" .. name
      local nodeDef = core.registered_nodes[nodeName]
      if nodeDef then
        local texture = nodeDef.tiles[1]
        if #nodeDef.tiles >= 3 then texture = nodeDef.tiles[3] end
        table.insert(baseMatsAndTextures, {nodeName, texture})
      end
    end
  end
elseif core.get_modpath("mcl_core") then -- voxelibre support, couldn't find wood table, hardcode some woods
	addMclHardness = true
	sounds = mcl_sounds.node_sound_wood_defaults()
  sounds.footstep = mcl_sounds.node_sound_dirt_defaults().footstep
  materials.coal_lump = "mcl_core:coal_lump"
  materials.dirt = "mcl_core:dirt"
  blockGroups.grass_block = 1
	blockGroups.handy = 1
	blockGroups.axey = 1

  local plankNodes = {
    "mcl_bamboo:bamboo_plank", "mcl_cherry_blossom:cherrywood", "mcl_core:acaciawood", "mcl_core:birchwood",
    "mcl_core:darkwood", "mcl_core:junglewood", "mcl_core:sprucewood", "mcl_core:wood","mcl_mangrove:mangrove_wood",
  }
  for _, nodeName in ipairs(plankNodes) do
    local nodeDef = core.registered_nodes[nodeName]
    if nodeDef then
      local texture = nodeDef.tiles[1]
      table.insert(baseMatsAndTextures, {nodeName, texture})
    end
  end
end

local function start_flowerbed_timer(pos, min, max)
  local timer = core.get_node_timer(pos)
  timer:stop()
  timer:start(pRandom:next(min, max))
end

local function on_flowerbed_timer(pos, _)
  local flower_pos = vector.offset(pos, 0, 1, 0)
  local nodeAbove = core.get_node_or_nil(flower_pos)

  if nodeAbove and nodeAbove.name == "air" then
    local p1 = vector.offset(flower_pos, 1, 0, 1)
    local p2 = vector.offset(flower_pos, -1, 0, -1)
    local flowers = core.find_nodes_in_area(p1, p2, {"group:flower", "group:flora"})
    if flowers and #flowers > 0 then
      if pRandom:next(1, 100) <= spreadChance then
        local chosen = flowers[pRandom:next(1, #flowers)]
        if false and table.indexof(seeds, chosen) ~= -1 then chosen = seeds[chosen] end

        local node = core.get_node(chosen)
        local def = core.registered_nodes[node.name]
        if def.drop and type(def.drop) == "string" and def.drop ~= '' then
          if string.find(def.drop, ' ') then
            node.name = string.sub(def.drop, 1, string.find(def.drop, ' ') - 1)
          else
            node.name = def.drop
          end
        end

        if node then
          local itemDef = core.registered_items[node.name]
          if itemDef and type(itemDef.on_place) == "function" then
            itemDef.on_place(ItemStack(node.name), minimalFakePlayer, {type = "node", above = flower_pos, under = pos})
          else
            core.set_node(flower_pos, node)
          end
        end
      end
    end
    start_flowerbed_timer(pos, minSpreadTime, maxSpreadTime)
    return false
  else -- node above was air, or nil
    if nodeAbove then
      local wild = core.get_item_group(nodeAbove.name, "wildflower")

      if wild > 0 and wild < 4 then
        local node_name, num = nodeAbove.name:match("(.-)(%d*)$")
        num = tonumber(num) or 0
        local new_name = node_name .. (num + 1)
        core.swap_node(flower_pos, {name = new_name})
        start_flowerbed_timer(pos, minRemovedTime * 3, maxRemovedTime * 6)
        return false
      end
    end

    -- If we are covered then run timer slower to see if it's been removed
    start_flowerbed_timer(pos, minRemovedTime, maxRemovedTime)
    return false
  end
end

local flowebedLipHeight = 9/16
local getBasicFlowerbedDef = function(baseTexture)
  local ret = {
    drawtype = "nodebox",
    description = "Flowerbed",
    tiles = {baseTexture .. "^flowerbed_basic.png", baseTexture .. "^flowerbed_trim.png"},
    connects_to = {"group:flowerbed"},
    node_box = {
      type = "connected",
      fixed = {
        -1/2, -1/2, -1/2, 1/2, 1/2, 1/2
      },
      disconnected_left = {
        -8/16, -8/16, -8/16, -7/16, flowebedLipHeight, 8/16
      },
      disconnected_right = {
        8/16, -8/16, 8/16, 7/16, flowebedLipHeight, -8/16
      },
      disconnected_front = {
        -8/16, -8/16, -8/16, 8/16, flowebedLipHeight, -7/16
      },
      disconnected_back = {
       8/16, -8/16, 8/16, -8/16, flowebedLipHeight, 7/16
      },
    },
    groups = blockGroups,
    sounds = sounds,
    on_timer = on_flowerbed_timer,
    on_construct = function(pos) start_flowerbed_timer(pos, minSpreadTime, maxSpreadTime) end,
  }
	if addMclHardness then
		ret._mcl_blast_resistance = 0.8
		ret._mcl_hardness = 0.6
	end
	return ret
end

--------------------------------
-- Luanti calls
--------------------------------

for _, data in pairs(baseMatsAndTextures) do
  local nodeName = data[1]
  if core.registered_nodes[nodeName] ~= nil then
    local texture = data[2]
    local def = getBasicFlowerbedDef(texture)
    local name = "flowerbeds:basic_" .. string.sub(nodeName, string.find(nodeName, ':') + 1, -1)

    core.register_node(name, def)

    core.register_craft({
      output = name,
      recipe = {
        {materials.coal_lump},
        {materials.dirt},
        {data[1]},
      }
    })
  end
end

core.register_lbm({
  label = "Enable node timers on existing flower beds",
  name = "flowerbeds:start_flowerbed_timer",
  nodenames = {"group:flowerbed"},
  run_at_every_load = false,
  action = function(pos)
    local timer = core.get_node_timer(pos)
    if not timer:is_started() then start_flowerbed_timer(pos, minSpreadTime, maxSpreadTime) end
  end,
})
