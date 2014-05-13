local moduleChipLayer = {layer,font_num,the_exp,lv_bar,max_exp,parent,updata,array,the_pulse,cid,stone_exp,font_lv_bar,old_lv,add_font}
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local Config_Property = requires(IMG_PATH , "GameLuaScript/Config/Prop")
local Config_Propertys = requires(IMG_PATH , "GameLuaScript/Config/Property")
local KNBar = requires(IMG_PATH, "GameLuaScript/Common/KNBar")
local stonelist = requires(IMG_PATH, "GameLuaScript/Scene/mosaic/stonelist")
--[[经脉]]
function moduleChipLayer:new(x,y,parm,parents)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.layer = display.newLayer()
	local gid = parm.gid
	this.the_exp = 0
	this.parent = parents
	local font = {"天庭","任脉","督脉","带脉","冲脉"}
	
	local hero_pdata = nil
	local hero_pulse = nil
	this.the_pulse = nil
	local font_array = {}
	
	function init()
		hero_pdata = DATA_Pulse:get_data()
		hero_pulse = hero_pdata["pulse"]
		for k,v in pairs(hero_pulse) do
			if v["index"] == parm.index then
				this.the_pulse = v
				break
			end
		end
		
		if parm.mode == 1 then
			font_array[1] = font[parm.index]
			font_array[2] = lv
			font_array[3] = this.the_pulse["cur_max_lv"]
			font_array[4] = this.the_pulse["lv"]
			font_array[5] = this.the_pulse["next_max_lv"]
			font_array[6] = this.the_pulse["martial_need"]
			font_array[7] = "upgrade"
		else
			font_array[1] = font[parm.index]
			font_array[2] = 0
			font_array[3] = this.the_pulse["cur_max_lv"]
			font_array[4] = 0
			font_array[5] = this.the_pulse["next_max_lv"]
			font_array[6] = this.the_pulse["martial_need"]
			font_array[7] = "upgrade"
			
		end
	end
	init()
	this.stone_exp = this.the_pulse["exp"]
	this.cid = this.the_pulse["cid"]
	local lv,cur_exp,max_exp = get_data(this.the_pulse["exp"],this.the_pulse["cid"])
	this.max_exp = max_exp
	this.the_exp = cur_exp
	font_array[2] = lv
	this.old_lv = lv
	this.add_font = nil
	local Groove = display.newSprite(IMG_PATH.."image/scene/Pulse/Groove.png")
	setAnchPos(Groove, 45,630)
	this.layer:addChild(Groove)
	
	local font_gro = display.strokeLabel( font_array[1] ,  45 + 5,600 , 20 , ccc3( 0x2c , 0x00 , 0x00 ) )
	this.layer:addChild( font_gro )
	
	if parm.mode == 1 then
		
	else
		array = {}
		
		local ston_font = display.newSprite(IMG_PATH .. "image/scene/mosaic/font_lv.png")
		setAnchPos(ston_font,(this.layer:getContentSize().width - ston_font:getContentSize().width)/2,694 )
		this.layer:addChild(ston_font)
		
		local box = display.newSprite(IMG_PATH .. "image/scene/common/skill_frame1.png")
		setAnchPos(box,132,610 )
		this.layer:addChild(box)
		
		local img = display.newSprite(IMG_PATH .. "image/prop/s_"..this.the_pulse["cid"]..".png")
		setAnchPos(img,134,612 )
		this.layer:addChild(img)
		
		local font_name = display.strokeLabel( Config_Property[this.the_pulse["cid"]..""]["name"] , 210,645, 20 , ccc3( 0x2c , 0x00 , 0x00 ), 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
		this.layer:addChild( font_name )
		
		
		this.font_num = display.strokeLabel( Config_Propertys[Config_Property[this.the_pulse["cid"]..""]["effect"]].." +"..getConfig("data_stonefigure",this.the_pulse["cid"])[lv..""] , 210,625, 14 , ccc3( 0x00 , 0x00 , 0x00 ) )
		this.layer:addChild( this.font_num )
		
		local font_num = display.strokeLabel( "通过吞噬其他宝石可对当前宝石进行升级" , 80,173, 18 , ccc3( 0x00 , 0x00 , 0x00 ) )
		this.layer:addChild( font_num )
		
		local font_the_lv = display.strokeLabel( "lv "..lv , 220 + font_name:getLabel():getContentSize().width,645, 18 , ccc3( 0x2c , 0x00 , 0x00 ) )
		this.layer:addChild( font_the_lv )
		
		--摘取
		local frei = KNBtn:new(COMMONPATH , {"btn_bg.png"} , 350,620 , {
			front = IMG_PATH.."image/scene/mosaic/frei.png",
			scale = true,
			noHide = true,
			callback = function()
				KNMsg:getInstance():boxShow(" 【温馨提示】\n宝石摘取下来后，等级下降1级\n 是否确认摘取？",{
				confirmFun=function()
					HTTP:call("pulse" , "dig", 
							{ id = parm.gid,index = parm.index} ,
							{success_callback= 
							function()
								switchScene("pulse",parm.gid)
							end}
						)
				end,
				cancelFun=function()

				end})
			end
		})
		this.layer:addChild(frei:getLayer())
		
		this.font_lv_bar = display.strokeLabel( "Lv "..lv , 80 , 556, 18 , ccc3( 0x2c , 0x00 , 0x00 ), 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
		this.layer:addChild( this.font_lv_bar )
		
		this.lv_bar = KNBar:new("exp" , this.font_lv_bar:getLabel():getContentSize().width + 80 , 287 , { maxValue = this.max_exp , curValue = this.the_exp })
		this.layer:addChild( this.lv_bar )
		
		local is_stone = false
		for k,v in pairs(DATA_Bag:getTable("prop")) do
			if v["type"] == "stone" then
				is_stone = true
			end
		end
		
		if is_stone == true then
			this.updata = stonelist:new(this,0,0,{cid = this.the_pulse["cid"],data = DATA_Bag:getTable("prop")})
			this.layer:addChild(this.updata:getLayer())
		else
			local font_stone = display.strokeLabel( "通过任务，副本，商场购买宝石" , 80,300, 22 , ccc3( 0x00 , 0x00 , 0x00 ), 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
			this.layer:addChild( font_stone )
		end
		
	end
	return this
end

function moduleChipLayer:set_exp(exp_temp)
	self.stone_exp = self.stone_exp + exp_temp
	
	local lv,cur_exp,max_exp = get_data(self.stone_exp,self.cid)
	
	if self.font_lv_bar ~= nil then self.layer:removeChild(self.font_lv_bar,true) end
	self.font_lv_bar = display.strokeLabel( "Lv "..lv , 80 , 556, 18 , ccc3( 0x2c , 0x00 , 0x00 ), 2 , ccc3( 0x40 , 0x1d , 0x0c ) )
	self.layer:addChild( self.font_lv_bar )
	
	if self.lv_bar ~= nil then self.layer:removeChild(self.lv_bar,true) end
	self.lv_bar = KNBar:new("exp" , self.font_lv_bar:getLabel():getContentSize().width + 80 , 287 , { maxValue = max_exp , curValue = cur_exp })
	self.layer:addChild( self.lv_bar )
	
	if self.add_font ~= nil then
		self.layer:removeChild(self.add_font,true)
	end
	
	if lv > self.old_lv then
		local the_num = getConfig("data_stonefigure",self.the_pulse["cid"])[lv..""] - getConfig("data_stonefigure",self.the_pulse["cid"])[self.old_lv..""]
		self.add_font = display.strokeLabel( " +"..the_num , 210 + self.font_num:getLabel():getContentSize().width,625, 14 , ccc3( 0xff , 0x00 , 0x00 ) )
		self.layer:addChild( self.add_font )
	end
	
end

function get_data(exp_data,cid)
	local data = getConfig("data_stoneexp")
	local lv_num = 1
	local is_true = true
	local cur_init = 0
	local temp_cur = 0
	local temp_max = 0
	local lv = 1
	while(is_true)do
		if lv_num < 10 then
			local cur_data = data[(lv_num)..""]
			local next_data = data[(lv_num + 1)..""]
			local cur = 0
			if lv_num == 1 then
				--cur_data = 0
				
				
			else
				
			end
			if exp_data >= cur_data and exp_data < next_data then
				
				temp_cur = exp_data - cur_data
				temp_max = next_data - cur_data
				lv = lv_num
				is_true = false
			else
				lv_num = lv_num + 1
			end
		else
			is_true = false
		end
		
	end
		
	return lv , temp_cur,temp_max
end

function moduleChipLayer:get_exp()
	return self.the_exp
end

function moduleChipLayer:getLayer()
	return self.layer
end

function moduleChipLayer:get_max_exp()
	return self.max_exp
end

function moduleChipLayer:set_array(array)
	self.array = array
	self.parent.array = array
	
end

function moduleChipLayer:get_array()
	return self.array
end
return moduleChipLayer


