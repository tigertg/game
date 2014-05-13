local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNBar = requires(IMG_PATH, "GameLuaScript/Common/KNBar")
local Config_Propertys = requires(IMG_PATH , "GameLuaScript/Config/Property")

local skillinfo = {layer,id,jump,lv,cur_exp,max_exp,other_exp,property,property_hp,old_font,lv_bar_font,lv_bar,add_exp,updata,my_exp,max_hp,the_stone,pet_data,old_exp,buff_name,old_buf}

function skillinfo:new(id,updata)
	local this = {}
	setmetatable(this,self)
	self.__index = self
	this.layer = display.newLayer()
	this.id = id
	this.updata = updata
	local skill_exp = DATA_Bag:get_skillexp()--星级系数
	local cur = 0
	local star = 0
	local skill_cid = 0
	local skill_name = ""
	
	this.buff_name = ""
	local the_pet_data = {}
	this.other_exp = nil
	if this.updata.mode == "petskill" then
		---幻兽天赋技能
		this.pet_data = getConfig("petskill")
		dump(id)
		the_pet_data = this.pet_data[DATA_Bag:get("pet",id,"skill_k")..""][DATA_Bag:get("pet",id,"skill_lv")..""]
		cur = DATA_Bag:get("pet",id,"skill_exp")
		star = the_pet_data["star"]
		skill_cid = DATA_Bag:get("pet",id,"skill_k")
		skill_lv = DATA_Bag:get("pet",id,"skill_lv")
		skill_name = the_pet_data["name"]
		--this.old_exp = the_pet_data["success"]
		this.old_buf = the_pet_data["success"]
		this.property = Config_Propertys[the_pet_data["department"]]
		
		if the_pet_data["department"] == "thunder" then
			this.buff_name = "  抗破甲概率:"
		elseif the_pet_data["department"] == "ice" then
			this.buff_name = "  抗冰冻概率:"
		elseif the_pet_data["department"] == 'fire' then
			this.buff_name = "  抗虚弱概率:"
		elseif the_pet_data["department"] == 'wind' then
			this.buff_name = "  抗中毒概率:"
		elseif the_pet_data["department"] == 'water' then
			this.buff_name = "  触发概率:"
		end
		
		
	elseif this.updata.mode == "petplainskill" then
		---幻兽普通技能
		if DATA_Bag:get("skill" , id)["lv"] == 1 then
			cur = DATA_Bag:get("skill" , id)["exp"]
		else
			cur = DATA_Bag:get("skill" , id)["exp"]
		end
		star = DATA_Bag:get("skill" , id)["star"]
		skill_cid = DATA_Bag:get("skill" , id)["cid"]
		dump(skill_cid)
		skill_lv = DATA_Bag:get("skill" , id)["lv"]
		skill_name = DATA_Bag:get("skill" , id)["name"]
		
		this.pet_data = getConfig("petskill")
		the_pet_data = this.pet_data[DATA_Bag:get("skill" , id)["cid"]..""][skill_lv..""]
		
		this.old_exp = the_pet_data["success"]
		this.old_buf = the_pet_data["debuff"]
		
		this.property = Config_Propertys[the_pet_data["department"]]
		this.jump = 0
		if the_pet_data["department"] == 'thunder' then
			this.buff_name = "  触发概率:"
		elseif the_pet_data["department"] == 'ice' then
			this.buff_name = "  触发概率:"
			this.jump = 1
		elseif the_pet_data["department"] == 'fire' then
			this.buff_name = "  触发概率:"
		elseif the_pet_data["department"] == 'wind' then
			this.buff_name = "  触发概率:"
		elseif the_pet_data["department"] == 'water' then
			this.buff_name = "  触发概率:"
		end
		
	elseif this.updata.mode == "heroskill" then
		---英雄技能
		if DATA_Bag:get("skill" , id)["lv"] == 1 then
			cur = DATA_Bag:get("skill" , id)["exp"]
		else
			cur = DATA_Bag:get("skill" , id)["exp"]
		end
		star = DATA_Bag:get("skill" , id)["star"]
		skill_cid = DATA_Bag:get("skill" , id)["cid"]
		skill_lv = DATA_Bag:get("pet",id,"skill_lv")
		skill_name = DATA_Bag:get("skill" , id)["name"]
	end
	
	this.add_exp = cur
	
	this.lv,this.cur_exp,this.max_exp = self:get_skillexp(star,this.add_exp)
	
	
	this.the_stone = nil 
				this.the_stone = KNBtn:new(IMG_PATH.."image/scene/common" , {"skill_frame1.png","yes.png"} , 100 ,589 , {
												front = getImageByType(skill_cid , "s"),
												scale = true,
												noHide = true,
												callback = function()
													
												end
											})
	this.layer:addChild(this.the_stone:getLayer())
	
	local name = display.strokeLabel(skill_name , 105 + this.the_stone:getLayer():getContentSize().width, 635 , 16 , ccc3( 0x00 , 0x00 , 0x00 )  )
	this.layer:addChild( name )
	
	local lv_font = display.strokeLabel("Lv "..this.lv , 135 + this.the_stone:getLayer():getContentSize().width + name:getLabel():getContentSize().width, 635 , 16 , ccc3( 0x00 , 0x00 , 0x00 )  )
	this.layer:addChild( lv_font )
	
	this.max_hp = nil
	this.property_hp = nil
	this.my_exp = nil
	if this.updata.mode == "petskill" then
		this.max_hp = display.strokeLabel(this.buff_name..this.old_buf.."% ", 105 + this.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
		this.layer:addChild( this.max_hp )
		--this.property_hp = display.strokeLabel(this.property..this.old_exp..":".."% ", 105 + this.the_stone:getLayer():getContentSize().width + this.max_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
		--this.layer:addChild( this.property_hp )
	elseif this.updata.mode == "petplainskill" then
		this.max_hp = display.strokeLabel(this.buff_name..this.old_exp.."% ", 105 + this.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
		this.layer:addChild( this.max_hp )
		if this.jump == 0 then
			this.property_hp = display.strokeLabel(this.property..":"..this.old_buf.."%", 105 + this.the_stone:getLayer():getContentSize().width + this.max_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
			this.layer:addChild( this.property_hp )
		end
	elseif this.updata.mode == "heroskill" then
		local type_str = ""
		if getConfig("skill",DATA_Bag:get("skill" , id)["cid"],"target") == 1 then
			type_str = "单体攻击："
		elseif getConfig("skill",DATA_Bag:get("skill" , id)["cid"],"target") == 2 then
			type_str = "双体攻击："
		elseif getConfig("skill",DATA_Bag:get("skill" , id)["cid"],"target") == 3 then
			type_str = "群体攻击："
		end

		this.old_font = display.strokeLabel(type_str .. (getConfig("skill" , DATA_Bag:get("skill" , id)["cid"] , "1" , "effect")).."% ", 105 + this.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
		this.layer:addChild( this.old_font )

		if this.lv > 1 then
			local effect_add = getConfig("skill" , DATA_Bag:get("skill" , this.id)["cid"] , this.lv .. "" , "effect") - getConfig("skill",DATA_Bag:get("skill" , this.id)["cid"] , "1" , "effect")
			this.my_exp = display.strokeLabel("+".. effect_add .."%", this.old_font:getLabel():getContentSize().width + 105 + this.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
			this.layer:addChild( this.my_exp )
		end
	end
	
	this.lv_bar_font = display.strokeLabel("Lv "..this.lv , 50 , 537 , 16 , ccc3( 0x00 , 0x00 , 0x00 )  )
	this.layer:addChild( this.lv_bar_font )
	
	this.lv_bar = KNBar:new("exp" , 90 , 309 , { maxValue = this.max_exp , curValue = this.cur_exp })
	this.layer:addChild( this.lv_bar )
	
	for i = 1,star do
		local srat = display.newSprite(IMG_PATH.."image/common/star.png")
		setAnchPos(srat , 170 + (i-1)*30, 609)
		this.layer:addChild(srat )
	end
	
	--宠物排序规则	
	local function petSort(l,r) --自定义顺序
		local sortValueL = 0
		local sortValueR = 0
		--若是上阵宠物，其权值最大 
		if l == DATA_Pet:getFighting()..""	then
			sortValueL = sortValueL + 999
		elseif r == DATA_Pet:getFighting().."" then
			sortValueR = sortValueR + 999
		else
		--首先按照星级排序，然后再加等级
			local starL = getConfig(getCidType(DATA_Bag:get("skill",r,"cid")),DATA_Bag:get("skill",r,"cid"),"star")
			local starR	= getConfig(getCidType(DATA_Bag:get("skill",l,"cid")),DATA_Bag:get("skill",l,"cid"),"star")
			sortValueL = starL * 100 + DATA_Bag:get("skill",r,"lv")
			sortValueR = starR * 100 + DATA_Bag:get("skill",l,"lv")
		end
		
		return sortValueL > sortValueR
	end
	
	local type_skill =  math.modf(skill_cid/1000) 
	local get_data = {}
	if type_skill == 3 then
		get_data = DATA_Bag:getTable("skill","generalskill")
	elseif type_skill == 4 then
		get_data = DATA_Bag:getTable("skill","petskill")
	end
	
	local keyList = getSortList(get_data,petSort)
	local is_empty = false
	local sv = KNScrollView:new(20,208,439,308,0,false)
	local temp_count = 0
	local temp_line = 1
	local layers = {}
	local star_font = {"一星","二星","三星","四星","五星"}
	
	for i = 1,table.getn(keyList) do
		local temp_skill_info = nil
		temp_skill_info = get_data[keyList[i]]
		if temp_skill_info ~= nil then
			local is_retrieve = false
			if type_skill == 3 then
				if DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(temp_skill_info["id"]), "skill") ~= nil then
					is_retrieve = true
				end
			elseif type_skill == 4 then
				--if this.updata.mode == "petskill" then
					if DATA_PetSkillDress:isDress(tonumber(temp_skill_info["id"]))  ~= nil then
						is_retrieve = true
					end
				--elseif this.updata.mode == "petplainskill" then
				--	if DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(temp_skill_info["id"]), "skill") ~= nil then
				--		is_retrieve = true
				--	end
				--end
			end
			
			if is_retrieve then
				
			else
				is_empty = true
				temp_count = temp_count + 1
				if layers[ temp_line ] == nil then
					layers[ temp_line ] = display.newLayer()
					layers[ temp_line ]:setContentSize( CCSizeMake(480 , 100) )
				end
				local stone 
					stone = KNBtn:new(IMG_PATH.."image/scene/common" , {"skill_frame1.png","yes.png"} , 65 + 80 * (temp_count - 1),10 , {
													front = getImageByType(temp_skill_info["cid"] , "s"),
													other = {{IMG_PATH .. "image/common/egg_num_bg.png",46,46}},
													text = {{temp_skill_info["lv"],18,ccc3(0xff,0xff,0xff),ccp(23,24),nil,100},
															{star_font[temp_skill_info["star"]],18,ccc3(0x00,0x00,0x00),ccp(0,-45),nil,100}
														   },
													noHide = true,
													parent = sv,
													selectable = true,
													selectZOrder = 20,
													selectOffset = {17,-16},
													callback = function()
														if stone:isSelect() == true then
															
															local exp_cur = getConfig("data_skillexp",get_data[keyList[i]]["star"])[get_data[keyList[i]]["lv"]..""]*skill_exp[get_data[keyList[i]]["star"]..""]
															local exp_int,exp_double = math.modf(exp_cur)
															if exp_double >= 0.5 then
																exp_int = exp_int + 1
															else
															
															end
															this:set_exp(exp_int,"reduce",star)
															this.updata:remove_array(get_data[keyList[i]]["id"])
														else 
															local exp_cur = getConfig("data_skillexp",get_data[keyList[i]]["star"])[get_data[keyList[i]]["lv"]..""]*skill_exp[get_data[keyList[i]]["star"]..""]
															local exp_int,exp_double = math.modf(exp_cur)
															if exp_double >= 0.5 then
																exp_int = exp_int + 1
															else
															
															end
															
															this:set_exp(exp_int,"add",star)
															this.updata:set_array(get_data[keyList[i]]["id"])
														end
													end
												})
				layers[ temp_line ]:addChild(stone:getLayer())
				if temp_count == 4 then
					temp_line = temp_line + 1
					temp_count = 0
				end
			end
		end
		
		
	end
	
	for i = 1 , #layers do
		sv:addChild( layers[i] )
	end
	
	this.layer:addChild(sv:getLayer())
	
	if is_empty == false then
		local tisp = display.strokeLabel("当前没有技能" , 160 , 353 , 20 , ccc3( 0x00 , 0x00 , 0x00 )  )
		this.layer:addChild( tisp )
	end
	return this
end

function skillinfo:get_skillexp(star,exp_data,exp_lv)
	local data = getConfig("data_skillexp",star)
	local lv_num = 1
	local is_true = true
	local cur_init = 0
	local cur_exp = 0
	local max_exp = 0
	local lv = 1
	while(is_true)do
		if lv_num < 10 then
			local cur_data = data[(lv_num)..""]
			local next_data = data[(lv_num + 1)..""]
			local cur = 0
			if lv_num == 1 then
				cur_data = 0
			else
				
			end
			if exp_data >= cur_data and exp_data < next_data then
				cur_exp = exp_data - cur_data
				max_exp = next_data - cur_data
				lv = lv_num
				is_true = false
			else
				lv_num = lv_num + 1
			end
		else
			is_true = false
		end
		
	end

	return lv , cur_exp,max_exp
end

function skillinfo:getLayer()
	return self.layer
end

function skillinfo:set_exp(exp_temp,ages,star)
	if ages == "add" then
		self.add_exp = self.add_exp + exp_temp
		local lv,cur_exp,max_exp = self:get_skillexp(star,self.add_exp)
		self.lv = lv
		self.lv_bar:setCurValue(cur_exp)
		self.lv_bar:setMaxValue(max_exp)
		if self.lv_bar_font ~= nil then
			self.layer:removeChild(self.lv_bar_font,true)
			self.lv_bar_font = display.strokeLabel("Lv "..self.lv , 50 , 537 , 16 , ccc3( 0x00 , 0x00 , 0x00 )  )
			self.layer:addChild( self.lv_bar_font )
		end
		
		if self.updata.mode == "petskill" then
			local the_pet_data = self.pet_data[DATA_Bag:get("pet",self.id,"skill_k")..""][lv..""]
			
			if the_pet_data["success"] - self.old_buf > 0 then
				if self.max_hp ~= nil then
					self.layer:removeChild(self.max_hp,true)
				end
				
				--if self.property_hp ~= nil then
				--	self.layer:removeChild(self.property_hp,true)
				--end
				
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
				
				if self.other_exp ~= nil then
					self.layer:removeChild(self.other_exp,true)
				end
				
				self.max_hp = display.strokeLabel(self.buff_name..self.old_buf.."%", 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				self.layer:addChild( self.max_hp )
				
				self.my_exp = display.strokeLabel("+"..(the_pet_data["success"] - self.old_buf).."% ", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
				self.layer:addChild( self.my_exp )
				
				--self.property_hp = display.strokeLabel(self.property..":"..self.old_exp.."%", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width + self.my_exp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				--self.layer:addChild( self.property_hp )
				
				--self.other_exp = display.strokeLabel("+"..(the_pet_data["success"] - self.old_exp).."%", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width + self.my_exp:getLabel():getContentSize().width + self.property_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
				--self.layer:addChild( self.other_exp )
				
			else
				if self.max_hp ~= nil then
					self.layer:removeChild(self.max_hp,true)
				end
				
				--if self.property_hp ~= nil then
				--	self.layer:removeChild(self.property_hp,true)
				--end
				
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
				
				if self.other_exp ~= nil then
					self.layer:removeChild(self.other_exp,true)
				end
				
				self.max_hp = display.strokeLabel(self.buff_name..self.old_buf.."% ", 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				self.layer:addChild( self.max_hp )
				
				--self.property_hp = display.strokeLabel(self.property..":"..self.old_exp.."% ", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				--self.layer:addChild( self.property_hp )
				
			end
		elseif self.updata.mode == "petplainskill" then
			local the_pet_data = self.pet_data[DATA_Bag:get("skill" , self.id)["cid"]..""][lv..""]
			
			if the_pet_data["success"] - self.old_exp > 0 then
				if self.max_hp ~= nil then
					self.layer:removeChild(self.max_hp,true)
				end
				
				if self.property_hp ~= nil then
					self.layer:removeChild(self.property_hp,true)
				end
				
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
				
				if self.other_exp ~= nil then
					self.layer:removeChild(self.other_exp,true)
				end
				
				self.max_hp = display.strokeLabel(self.buff_name..self.old_exp.."%", 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				self.layer:addChild( self.max_hp )
				
				self.my_exp = display.strokeLabel("+"..(the_pet_data["success"] - self.old_exp).."% ", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
				self.layer:addChild( self.my_exp )
				if self.jump == 0 then
					self.property_hp = display.strokeLabel(self.property..":"..self.old_buf.."%", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width + self.my_exp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
					self.layer:addChild( self.property_hp )
				
					self.other_exp = display.strokeLabel("+"..(the_pet_data["debuff"] - self.old_buf).."%", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width + self.my_exp:getLabel():getContentSize().width + self.property_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
					self.layer:addChild( self.other_exp )
				end
			else
				if self.max_hp ~= nil then
					self.layer:removeChild(self.max_hp,true)
				end
				
				if self.property_hp ~= nil then
					self.layer:removeChild(self.property_hp,true)
				end
				
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
				
				if self.other_exp ~= nil then
					self.layer:removeChild(self.other_exp,true)
				end
				
				self.max_hp = display.strokeLabel(self.buff_name..self.old_exp.."% ", 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				self.layer:addChild( self.max_hp )
				if self.jump == 0 then
					self.property_hp = display.strokeLabel(self.property..":"..self.old_buf.."% ", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
					self.layer:addChild( self.property_hp )
				end
			end
		elseif self.updata.mode == "heroskill" then
			if lv > 1 then
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end

				local effect_add = getConfig("skill",DATA_Bag:get("skill" , self.id)["cid"] , lv .. "" , "effect") - getConfig("skill",DATA_Bag:get("skill" , self.id)["cid"] , "1" , "effect")
				self.my_exp = display.strokeLabel("+".. effect_add .. "%" , self.old_font:getLabel():getContentSize().width + 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
				self.layer:addChild( self.my_exp )
			else
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
			end
		end
	elseif ages == "reduce" then
		self.add_exp = self.add_exp - exp_temp
		local lv,cur_exp,max_exp = self:get_skillexp(star,self.add_exp)
		self.lv = lv
		self.lv_bar:setCurValue(cur_exp)
		self.lv_bar:setMaxValue(max_exp)
		if self.lv_bar_font ~= nil then
			self.layer:removeChild(self.lv_bar_font,true)
			self.lv_bar_font = display.strokeLabel("Lv "..self.lv , 50 , 537 , 16 , ccc3( 0x00 , 0x00 , 0x00 )  )
			self.layer:addChild( self.lv_bar_font )
		end
		
		if self.updata.mode == "petskill" then
			local the_pet_data = self.pet_data[DATA_Bag:get("pet",self.id,"skill_k")..""][lv..""]
			if the_pet_data["success"] - self.old_buf > 0 then
				if self.max_hp ~= nil then
					self.layer:removeChild(self.max_hp,true)
				end
				
				--if self.property_hp ~= nil then
				--	self.layer:removeChild(self.property_hp,true)
				--end
				
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
				
				if self.other_exp ~= nil then
					self.layer:removeChild(self.other_exp,true)
				end
				
				self.max_hp = display.strokeLabel(self.buff_name..self.old_buf.."%", 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				self.layer:addChild( self.max_hp )
				
				self.my_exp = display.strokeLabel("+"..(the_pet_data["success"] - self.old_buf).."% ", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
				self.layer:addChild( self.my_exp )
				
				--self.property_hp = display.strokeLabel(self.property..":"..self.old_exp.."%", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width + self.my_exp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				--self.layer:addChild( self.property_hp )
				
				--self.other_exp = display.strokeLabel("+"..(the_pet_data["success"] - self.old_exp).."%", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width + self.my_exp:getLabel():getContentSize().width + self.property_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
				--self.layer:addChild( self.other_exp )
				
			else
				if self.max_hp ~= nil then
					self.layer:removeChild(self.max_hp,true)
				end
				
				if self.property_hp ~= nil then
					self.layer:removeChild(self.property_hp,true)
				end
				
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
				
				if self.other_exp ~= nil then
					self.layer:removeChild(self.other_exp,true)
				end
				
				self.max_hp = display.strokeLabel(self.buff_name..self.old_buf.."% ", 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				self.layer:addChild( self.max_hp )
				
				--self.property_hp = display.strokeLabel(self.property..":"..self.old_exp.."% ", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				--self.layer:addChild( self.property_hp )
				
			end
		elseif self.updata.mode == "petplainskill" then
			local the_pet_data = self.pet_data[DATA_Bag:get("skill" , self.id)["cid"]..""][lv..""]
			if the_pet_data["success"] - self.old_exp > 0 then
				if self.max_hp ~= nil then
					self.layer:removeChild(self.max_hp,true)
				end
				
				if self.property_hp ~= nil then
					self.layer:removeChild(self.property_hp,true)
				end
				
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
				
				if self.other_exp ~= nil then
					self.layer:removeChild(self.other_exp,true)
				end
				
				self.max_hp = display.strokeLabel(self.buff_name..self.old_exp.."%", 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				self.layer:addChild( self.max_hp )
				
				self.my_exp = display.strokeLabel("+"..(the_pet_data["success"] - self.old_exp).."% ", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
				self.layer:addChild( self.my_exp )
				
				if self.jump == 0 then
					self.property_hp = display.strokeLabel(self.property..":"..self.old_buf.."%", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width + self.my_exp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
					self.layer:addChild( self.property_hp )
					
					self.other_exp = display.strokeLabel("+"..(the_pet_data["debuff"] - self.old_buf).."%", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width + self.my_exp:getLabel():getContentSize().width + self.property_hp:getLabel():getContentSize().width, 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
					self.layer:addChild( self.other_exp )
				end
			else
				if self.max_hp ~= nil then
					self.layer:removeChild(self.max_hp,true)
				end
				
				if self.property_hp ~= nil then
					self.layer:removeChild(self.property_hp,true)
				end
				
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
				
				if self.other_exp ~= nil then
					self.layer:removeChild(self.other_exp,true)
				end
				
				self.max_hp = display.strokeLabel(self.buff_name..self.old_exp.."% ", 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
				self.layer:addChild( self.max_hp )
				if self.jump == 0 then
					self.property_hp = display.strokeLabel(self.property..":"..self.old_buf.."% ", 105 + self.the_stone:getLayer():getContentSize().width + self.max_hp:getLabel():getContentSize().width , 592 , 14 , ccc3( 0x00 , 0x00 , 0x00 )  )
					self.layer:addChild( self.property_hp )
				end
			end
		elseif self.updata.mode == "heroskill" then
			if lv > 1 then
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end

				local effect_add = getConfig("skill" , DATA_Bag:get("skill" , self.id)["cid"] , lv .. "" , "effect") - getConfig("skill",DATA_Bag:get("skill" , self.id)["cid"] , "1" , "effect")
				self.my_exp = display.strokeLabel("+".. effect_add .."%", self.old_font:getLabel():getContentSize().width + 105 + self.the_stone:getLayer():getContentSize().width , 592 , 14 , ccc3( 0xff , 0x00 , 0x00 )  )
				self.layer:addChild( self.my_exp )
			else
				if self.my_exp ~= nil then
					self.layer:removeChild(self.my_exp,true)
				end
			end
		end
	end
	
end

return skillinfo
