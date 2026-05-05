-- code-writing assisted with AI
local function get_cassette_formspec(channel)
	return "size[8,9]" ..
		"field[0.5,1;7,1;channel;Channel;" .. (channel or "") .. "]" ..
		"button_exit[3,1.5;2,1;save;Save]" ..
		"list[context;main;3,3;1,1;]" ..
		"list[current_player;main;0,5;8,4;]" ..
		"listring[context;main]" ..
		"listring[current_player;main]"
end

core.register_node("digicassettes:writer", {
	description = "Cassette Writer",
	tiles = {"digicassettes_writer.png"},
	groups = {cracky = 1},
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
		meta:set_string("formspec", get_cassette_formspec(""))
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.save or fields.key_enter == "true" then
			local meta = core.get_meta(pos)
			meta:set_string("channel", fields.channel)
			meta:set_string("formspec", get_cassette_formspec(fields.channel))
		end
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function(pos, node, channel, msg)
				local meta = core.get_meta(pos)
				local set_channel = meta:get_string("channel")
				if channel ~= set_channel then return end

				local inv = meta:get_inventory()
				local stack = inv:get_stack("main", 1)

				if stack:get_name() == "digicassettes:cassette" then
					stack:get_meta():set_string("data", tostring(msg))
					inv:set_stack("main", 1, stack)
				end
			end
		}
	}
})

core.register_node("digicassettes:reader", {
	description = "Cassette Reader",
	tiles = {"digicassettes_reader_back.png","digicassettes_reader_back.png","digicassettes_reader_back.png","digicassettes_reader_back.png","digicassettes_reader_back.png","digicassettes_reader.png"},
	paramtype2 = "facedir",
	groups = {cracky = 1},
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
		meta:set_string("formspec", get_cassette_formspec(""))
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.save or fields.key_enter == "true" then
			local meta = core.get_meta(pos)
			meta:set_string("channel", fields.channel)
			meta:set_string("formspec", get_cassette_formspec(fields.channel))
		end
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function(pos, node, channel, msg)
				local meta = core.get_meta(pos)
				local set_channel = meta:get_string("channel")
				if channel ~= set_channel or msg ~= "get" then return end

				local inv = meta:get_inventory()
				local stack = inv:get_stack("main", 1)

				if stack:get_name() == "digicassettes:cassette" then
                    local data = stack:get_meta():get_string("data")
                    digilines.receptor_send(pos, digilines.rules.default, channel, data)
                else
                    digilines.receptor_send(pos, digilines.rules.default, channel, "Error: No Cassette")
                end
			end
		}
	}
})

core.register_craftitem("digicassettes:cassette", {
	description = "Cassette",
	inventory_image = "digicassettes_cassette.png",
	stack_max = 1,
})