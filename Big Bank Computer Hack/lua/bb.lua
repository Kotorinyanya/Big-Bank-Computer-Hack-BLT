-----------------------------------
---         Big Bank            ---
---   Hacking computer 1st try  ---
---         Update #1.2         ---
-----------------------------------
 
-- INGAME CHECK
function inGame()
	if not game_state_machine then return false end
	return string.find(game_state_machine:current_state_name(), "game")
end
 
-- IS PLAYING CHECK
function isPlaying()
	if not BaseNetworkHandler then return false end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
 
-- HOST CHECK
function isHost()
	if not Network then return false end
	return not Network:is_client()
end
 
-- MIDTEXT	
function show_mid_text( msg, msg_title, show_secs )
	if managers and managers.hud then
		managers.hud:present_mid_text( { text = msg, title = msg_title, time = show_secs } )
	end
end
	
if inGame() and isPlaying() then
	_toggleWaypointBB = not _toggleWaypointBB
	_id_101277 = _id_101277 or false
	_bbserv_used = _bbserv_used or false
 
	if _toggleWaypointBB then
		managers.chat:_receive_message(1, "BigBank", "Script activated", tweak_data.system_chat_color)
		if managers.job:current_level_id() == 'big' and _bbserv_used == false then
			if isHost() then
				for _, script in pairs(managers.mission:scripts()) do
					for id, element in pairs(script:elements()) do
						if id == 101277 then
							managers.mission:script("default")._elements[id]._values.on_executed[1].id = 104496
						end
					end
				end
				_id_101277 = true
			end
		end
	else
		RefreshItemWaypoints()
		managers.chat:_receive_message(1, "BigBank", "Script disabled", tweak_data.system_chat_color)
		if managers.job:current_level_id() == 'big' and _bbserv_used == false then
			if isHost() then
				for _, script in pairs(managers.mission:scripts()) do
					for id, element in pairs(script:elements()) do
						if id == 101277 then
							managers.mission:script("default")._elements[id]._values.on_executed[1].id = 104498
						end
					end
				end
				_id_101277 = false
			end
		end
	end
	
	managers.hud.__update_waypoints = managers.hud.__update_waypoints or managers.hud._update_waypoints 
	function HUDManager:_update_waypoints( t, dt ) 
		local result = self:__update_waypoints(t,dt) 
		for id,data in pairs( self._hud.waypoints ) do 
			id = tostring(id) 
			if id:sub(1,5)=='hudz_' then 
				data.move_speed = 0.01
				data.bitmap:set_color( data.bitmap:color():with_alpha( 0.5 ) ) 
			end 
		end 
		return result 
	end  
	
	function RefreshItemWaypoints()
		for id,_ in pairs( clone( managers.hud._hud.waypoints ) ) do
			id = tostring(id)
			if id:sub(1,5)=='hudz_' then
				managers.hud:remove_waypoint( id ) 
			end
		end
		if _toggleWaypointBB then
			local level = managers.job:current_level_id()
			for k,v in pairs(managers.interaction._interactive_units) do
				if managers.job:current_level_id() == 'big' and v:interaction().tweak_data == 'big_computer_server' then
					if _bbserv_used == false then
						managers.hud:add_waypoint( 'hudz_'..k, { icon = 'pd2_computer', distance = true, position = v:position(), no_sync = true, present_timer = 0, state = "present", radius = 1, color = Color.green, blend_mode = "add" }  )
					end
				end
			end
		end
	end
	
	RefreshItemWaypoints()
	
	managers.interaction._remove_unit = managers.interaction._remove_unit or managers.interaction.remove_unit
	function ObjectInteractionManager:remove_unit( unit )
		local interacted = unit:interaction().tweak_data
		local result = self:_remove_unit(unit)
		
		if (managers.job:current_level_id() == 'big' and interacted == 'big_computer_server') and _bbserv_used == false then
			if isHost() and _id_101277 == true then
				for _, script in pairs(managers.mission:scripts()) do
					for id, element in pairs(script:elements()) do
						-- Hacking
						if id == 104532 then
							element:on_executed()
							for _, script in pairs(managers.mission:scripts()) do
								for id, element in pairs(script:elements()) do
									-- Bain message OK
									if id == 106458 then
										element:on_executed()
									end
									if id == 101554 then
										element:on_executed()
									end
								end
							end
						end
						-- Lasers off
						if id == 104569 then
							local RnGLaser = math.random(100)
							-- managers.chat:_receive_message(1, "Lasers", tostring(RnGLaser),  Color.blue)
							show_mid_text("Activated", "Lasers state...", 1.5)
							if RnGLaser <= 50 then	-- Change the value (100 = no lasers, 0 = always)
								element:on_executed()
								show_mid_text("Disabled!", "Lasers state..", 1.5)
							end
						end
					end
				end
			end
			RefreshItemWaypoints()
			_bbserv_used = true
		end
		return result
	end
 
	managers.interaction._add_unit = managers.interaction._add_unit or managers.interaction.add_unit
	function ObjectInteractionManager:add_unit( unit )
		local spawned = unit:interaction().tweak_data
		local result = self:_add_unit(unit)
		return result
	end
end