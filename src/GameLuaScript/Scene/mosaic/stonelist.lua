local stonelist = {layer,the_exp,moduleChip,array_data}
--local stones = requires(IMG_PATH , "GameLuaScript/Scene/mosaic/stone")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
function stonelist:new(moduleChip,x,y,proms)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.layer = display.newLayer()
	local stone_data = {}
	--stone_data[1] = {}
	this.the_exp = 0
	this.moduleChip = moduleChip
	local exp_data = requires(IMG_PATH, "GameLuaScript/Config/data_stoneexp") 
	local index_stone = 1
	--dump(proms.data)
	stone_array = {{76 , 85},{156 , 85},{236 , 85},{316 , 85}}
	array_boolean = {false,false,false,false}
	--local ston_data = {}
	local addLyer = nil
	local sv = KNScrollView:new(20,200,439,340,0,false)	
	local temp_count = 0
	local temp_line = 1
	local layers = {}
	for k,v in pairs(proms.data) do
		if v["type"] == "stone" and v["attr"] ~= "none" then
			for i = 0 , v["num"] - 1 do
				temp_count = temp_count + 1
				
				if layers[ temp_line ] == nil then
					layers[ temp_line ] = display.newLayer()
					layers[ temp_line ]:setContentSize( CCSizeMake(480 , 80) )
					-- setAnchPos( layers[temp_line] , 0 , (temp_line - 1) * 80)
				end
				
				local the_stone 
				the_stone = KNBtn:new(IMG_PATH.."image/scene/common" , {"skill_frame1.png","yes.png"} , 65 + 80 * (temp_count - 1),0 , {
												front = getImageByType(v["cid"] , "s"),
												other = {{IMG_PATH .. "image/common/egg_num_bg.png",46,46}},
												text = {v["lv"],18,ccc3(0xff,0xff,0xff),ccp(23,24),nil,17},
												--scale = true,
												noHide = true,
												parent = sv,
												selectable = true,
												selectZOrder = 20,
												selectOffset = {17,-16},
												callback = function()
													if the_stone:isSelect() == true then
														local exp_num = exp_data[v["lv"]..""]
														if tonumber(proms.cid) == tonumber(v["cid"]) then
															
														else
															exp_num = exp_num*0.7
														end
														
														this.moduleChip:set_exp(-(exp_num))
														this:set_array(v["id"],-1)
													else 
														if this.moduleChip:get_exp() < this.moduleChip:get_max_exp() then
															local exp_num = exp_data[v["lv"]..""]
															
															if tonumber(proms.cid) == tonumber(v["cid"]) then
																
															else
																exp_num = exp_num*0.7
															end
															
															this.moduleChip:set_exp(exp_num)
															this:set_array(v["id"],1)
														else
															
															return false
														end
													end
												end
											})
				--stones:new(this.moduleChip,35 + 100 * (temp_count - 1),0 ,{cid = proms.cid,data = v,stonelist = this,index = k},{ callback = function(thiscard) end})
				--setAnchPos(the_stone, x + 80 * (temp_count - 1) , 0 )
				layers[ temp_line ]:addChild(the_stone:getLayer())
				
				if temp_count == 4 then
					temp_line = temp_line + 1
					temp_count = 0
				end
				--[[
				for k1,v1 in pairs(array_boolean) do
					--if k1 == 1 then
					--	addLyer = addlayers:new()
					--end
					
					if v1 == false then
						--print("第"..k.."项："..i)
						--print(k1)
						--local info = stones:new(this.moduleChip,50,stone_array[k1][2] ,{cid = proms.cid,data = v,stonelist = this,index = k},{ callback = function(thiscard) end})
						--this.layer:addChild(info:getLayer())
						--addLyer:add(info:getLayer())
						array_boolean[k1] = true
						index_stone = k1
						--print(k1)
						stone_data[k1] = v
						dump(stone_data)
						--dump(v)
						--table.insert(stone_data,v)
						--stone_data[tonumber(k1)] = v
						--dump(stone_data)
						if k1 == 4 then
							--sv:addChild(addLyer:getLayer(),addLyer)
							index_stone = 1
							--stone_data = {}
							--print("第"..k.."项："..i)
							--dump(stone_data)
							array_boolean[1] = false
							array_boolean[2] = false
							array_boolean[3] = false
							array_boolean[4] = false
							stone_data = {}
						end
						
						break
					end
				end
				]]
			end
		end
	end
	
	for i = 1 , #layers do
		sv:addChild( layers[i] )
	end
	
	
	this.layer:addChild(sv:getLayer())
	
	
			
	this.array_data = {}	
	--[[local index = 1
	local num = 1
	stone_data[1] = {}
	this.array_data = {}
	this.array_data[1] = {}
	for k,v in pairs(proms.data) do
		if v["type"] == "stone" and v["attr"] ~= "none" then
			if num <= 8 then
				stone_data[index][num] = v
				this.array_data[index][num] = {v["id"],0}
				num = num + 1
			else
				num = 1
				index = index + 1
				stone_data[#stone_data + 1] = {}
				this.array_data[#this.array_data + 1] = {}
				this.array_data[index][num] = {v["id"],0}
				stone_data[index][num] = v
				num = num + 1
			end
		end
	end
	
	local s_width = 0
	dump(stone_data)
	for k,v in pairs(stone_data) do
		dump(v)
		for i = 1,v[tonumber(k)]["num"] do
			--print("第"..k.."项："..i)
			--local info = stones:new(this.moduleChip,0,70 ,{cid = proms.cid,data = v,stonelist = this,index = k},{ callback = function(thiscard) end})
			--this.layer:addChild(info:getLayer())
		end
		
	end
	
	]]
	--[[local sv = KNScrollView:new(20,163,439,200,0,true,1)	
	for k,v in pairs(stone_data) do
		local info = stones:new(this.moduleChip,0,70 ,{cid = proms.cid,data = v,stonelist = this,index = k},{ callback = function(thiscard) end})
		sv:addChild(info:getLayer(),info)
	end
	this.layer:addChild(sv:getLayer())
	]]
	return this
end

function stonelist:getLayer()
	return self.layer
end

function stonelist:set_exp(add_exp)
	self.the_exp = self.the_exp + add_exp 
end
function stonelist:set_array(id,num)
	local is_add = false
	for k,v in pairs(self.array_data) do
		if v["id"] == id then
			self.array_data[k]["num"] = self.array_data[k]["num"] + num
			is_add = true
		end
	end
	if is_add == false then
		self.array_data[#self.array_data + 1] = {id = id,num = num}
	end
	--self.array_data[index1][2] =  self.array_data[index1][2] + num
	--dump(self.array_data)
	self.moduleChip:set_array(self.array_data)
end

function stonelist:get_exp()
	return self.the_exp
end

return stonelist

