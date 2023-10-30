-- flowerbeds = {}
-- local flowerbedNodes = {}
local baseMatsAndTextures = {
	{"default:wood", "default_wood.png"},
	{"default:junglewood", "default_junglewood.png"},
	{"default:acacia_wood", "default_acacia_wood.png"},
	{"default:pine_wood", "default_pine_wood.png"},
	{"default:aspen_wood", "default_aspen_wood.png"}
	-- perhaps too many, unecessary
	-- {"default:stonebrick", "default_stone_brick.png"},
	-- {"default:stone_block", "default_stone_block.png"},
	-- {"default:desert_stonebrick", "default_desert_stone_brick.png"},
	-- {"default:desert_stone_block", "default_desert_stone_block.png"},
	-- {"default:sandstonebrick", "default_sandstone_brick.png"},
	-- {"default:sandstone_block", "default_sandstone_block.png"},
	-- {"default:desert_sandstone_brick", "default_desert_sandstone_brick.png"},
	-- {"default:desert_sandstone_block", "default_desert_sandstone_block.png"},
	-- {"default:silver_sandstone_brick", "default_silver_sandstone_brick.png"},
	-- {"default:silver_sandstone_block", "default_silver_sandstone_block.png"}
}

local getBasicFlowerbedDef = function(baseTexture) 
	return {
		drawtype = "normal",--"glasslike_framed",
		description = "Basic Flowerbed",
		tiles = {
				baseTexture.."^flowerbed_basic.png",
				baseTexture.."^flowerbed_trim.png"
		},
		connects_to = {"group:basicFlowerbed"},
		groups = {choppy = 3, oddly_breakable_by_hand = 3, flowerbed = 1},
		sounds = default.node_sound_wood_defaults()
	}
end

local basic_flowerbed_abm = function(pos, node, active_object_count, active_object_count_wider)
	local checkAdj = {{1, 1}, {1, 0}, {1, -1}, {0, 1}, {0, -1}, {-1, 1}, {-1, 0}, {-1, -1}}
	pos.y = pos.y + 1
	local nodeAbove = minetest.get_node_or_nil(pos)
	if not nodeAbove or nodeAbove.name ~= "air" then
		return
	end
	for _, adj in pairs(checkAdj) do
		local checkPos = {x = pos.x + adj[1], y = pos.y, z = pos.z + adj[2]}
		local checkNode = minetest.get_node_or_nil(checkPos)
		if checkNode and minetest.get_item_group(checkNode.name, "flower") > 0 then
			minetest.set_node(pos, checkNode) -- copy the flower
			return
		end
	end
end
--------------------------------
-- minetest calls
--------------------------------

for _, data in pairs(baseMatsAndTextures) do
	local def = getBasicFlowerbedDef(data[2])
	local name = "flowerbeds:basic_"..string.sub(data[1],9,-1)
	minetest.register_node(name , def)

	minetest.register_craft({
		output = name,
		recipe = {
			{"default:coal_lump"},
			{"default:dirt"},
			{data[1]}
		}
	})
end

minetest.register_abm({
	label = "ABM for Flowerbeds",
	nodenames = {"group:flowerbed"},
	neighbors = {"air"},
	interval = 11.0,
	chance = 40,
	min_y = -50,
	catch_up = true,
	action = basic_flowerbed_abm
})
