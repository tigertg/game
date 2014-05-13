--[[

		传功界面

]]

local PATH = IMG_PATH .. "image/scene/byexp/"
local SCENECOMMON = IMG_PATH .. "image/scene/common/"
local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")
local BagItem = requires(IMG_PATH , "GameLuaScript/Scene/common/listitem")
local SelectList = requires(IMG_PATH, "GameLuaScript/Scene/common/selectlist")

local M = {
	baseLayer,
	layer,
}

function M:new( params )
	local this = {}
	setmetatable(this , self)
	self.__index = self
	if params then
		if params.source then
			if tonumber( params.source.lv ) > 1 then
				this.source = params.source
			end
		end
		this.backType = params.backtype
	end
	
	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()

	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	--背景纹理
	local bottomBg = display.newSprite(PATH.."decorative.png")
	--警告信息
	local warningInfo = display.newSprite(PATH.."warningInfo.png")
	--传功标题
	local byExpTitle = display.newSprite(PATH.."title.png")
	--收功者
	local acceptTitle = display.newSprite(PATH.."accept.png")
	--传功者
	local impartTitle = display.newSprite(PATH.."impart.png")
	--箭头
	local arrows = display.newSprite(PATH.."arrows.png")
	--传送50%
	local output50 = display.newSprite(PATH.."output50.png")
	--传送80%
	local output80 = display.newSprite(PATH.."output80.png")
	--分割线
	local division_line = display.newSprite(PATH.."division_line.png")
	
	
	local baseY = 438
	setAnchPos(bg , 0 , 86 )
	
	setAnchPos(bottomBg , display.cx  , baseY - 20 , 0.5 , 0.5 )
	setAnchPos(warningInfo , display.cx  , baseY + 255 , 0.5 , 0.5 )
	setAnchPos(byExpTitle , 36 , baseY + 200 )
	setAnchPos(acceptTitle , 104 , baseY + 170 )
	setAnchPos(impartTitle , 315 , baseY + 170 )
	setAnchPos(arrows , display.cx  , display.cy + 50 , 0.5 , 0.5 )
	setAnchPos(division_line , display.cx , 218 , 0.5 , 0.5)
	setAnchPos(output50 , 51 , 243 )
	setAnchPos(output80 , 267 , 243 )
	

	this.baseLayer:addChild(bg)
	this.layer:addChild(bottomBg)
	this.layer:addChild(warningInfo)
	this.layer:addChild(byExpTitle)
	this.layer:addChild(acceptTitle)
	this.layer:addChild(impartTitle)
	this.layer:addChild(division_line)
	this.layer:addChild(arrows)
	this.layer:addChild(output50)
	this.layer:addChild(output80)
	
		

	
	--花费
	local check = {}
	this.group = KNRadioGroup:new()	
	this.ordinaryNum = {}
	local drugAry = { "ordinary_drug.png" , "advanced_drug.png"}
	local drugIdAry = { 16001 , 16002 }
	for i = 1 , #drugAry do
		local checkBtn = KNBtn:new(COMMONPATH , {"check_false.png" , "check_true.png"},42 + ( i - 1 ) * 217 , 291 , {
			disableWhenChoose = true,
			upSelect = true,
			id = i,
			callback=
			function()
				this:refreshCost( i )
			end
		} , this.group)
		this.layer:addChild( checkBtn:getLayer() )
		
		local propBtn = KNBtn:new(SCENECOMMON , { "skill_frame1.png" },42 + 30 + ( i - 1 ) * 217 , 278 , { front = getImageByType(drugIdAry[i] , "s") })
		this.layer:addChild( propBtn:getLayer() )
		
		local numBg = display.newSprite(IMG_PATH .. "image/scene/incubation/egg_num_bg.png") 
		setAnchPos(numBg , 55 , -5)
		propBtn:getLayer():addChild( numBg )
		local drugNum = DATA_Bag:getDrug( i )
		this.ordinaryNum[i] = display.strokeLabel( drugNum , 57, -6 , 14 , ccc3( 0xff , 0xff , 0xff ) , nil , nil , { dimensions_width = 20 , dimensions_height = 20 , align = 1 } ) 
		propBtn:getLayer():addChild( this.ordinaryNum[i] )
		
		local nameSp = display.newSprite(PATH .. drugAry[i])
		setAnchPos(nameSp , 144 + ( i - 1 ) * 217 , 300 , 0 )
		this.layer:addChild( nameSp )
	end
	self.drugType = 1	--默认设置 传功丹类型为 普通
	this.costText = display.strokeLabel( "" , 67, 190 , 16 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil , { dimensions_width = 346 , dimensions_height = 20 , align = 1 } ) 
	this.layer:addChild( this.costText )
	
	this:refresh()
	
	
	
	--传功按钮
	local conveyingBtn = KNBtn:new(COMMONPATH,{"btn_bg_red.png","btn_bg_red_pre.png"},168,118,{scale = true,front = PATH .. "title.png" , callback=
		function()
			local drugNum , durgTab = DATA_Bag:getDrug( this.drugType )
			local needNum
			
			
			local cruData = tonumber( getConfig("generalexp")[ this.source.lv .. "" ])
			local drugConfig = getConfig("transmission")
			if  this.drugType == 2 then
				needNum = math.ceil( math.ceil( cruData * tonumber( drugConfig["s_discount"] ) ) / tonumber( drugConfig["s_use"] ) )
			else
				needNum = math.ceil( math.ceil( cruData * tonumber( drugConfig["n_discount"] ) ) / tonumber( drugConfig["n_use"] ) )
			end
			if not this.target then
				isSucceed = false
				KNMsg.getInstance():flashShow("请选择收功者")
				return
			end
			
			local isSucceed = true
			if drugNum < needNum then
				isSucceed = false
				KNMsg.getInstance():flashShow("需 ".. needNum .."个传功丹\n传功丹数量不足，请到商城购买")
			end
			
			
			if not this.source then
				isSucceed = false
				KNMsg.getInstance():flashShow("请选择传功者")
			end
			if isSucceed then
						local upFlag , upMaxLv = DATA_Uplevel:getCanUplv( this.target.id )
						if upFlag == 1 then		
							KNMsg.getInstance():flashShow("目标英雄已达到等级上限，请提升玩家等级!")
							return
						end
						
						if upFlag == 2 then	
							KNMsg.getInstance():flashShow("目标英雄已达到等级上限，请进化英雄阶位")
							return
						end
						if this.source.id == this.target.id then
							KNMsg.getInstance():flashShow("自己不可传功给自己")
							return
						end
						if this.source.lv <= 1 then
							KNMsg.getInstance():flashShow("一级武将不可做传功者！")
							return
						end
						
						HTTP:call("general","transmission",{
							id = durgTab[1].id  , 
							from = this.source.id , 
							to = this.target.id ,
						},{success_callback=
							function( data )
								local function tipFun()
									local str = getConfig( getCidType(data.result.cid) , data.result.cid , "name" )
									str = str .. "获得".. data.result.exp .."点经验，"
									if upFlag == 1 and data.result.lv >= upMaxLv  then		str = str + "传功成功，由于玩家等级限制，等级提升到" .. data.result.lv .. "级!"
									elseif upFlag == 2 and data.result.lv >= upMaxLv then	str = str + "传功成功，由于英雄阶位限制，等级提升到" .. data.result.lv .. "级!"
									else 
										if data.result.lv < upMaxLv then 
											str = str .. "传功成功，目标英雄等级提升到" .. data.result.lv .. "级!"
										else
											str = str .. "传功成功，由于英雄阶位限制，等级提升到" .. data.result.lv .. "级!"
										end
									end
									KNMsg.getInstance():flashShow( str )
								end
								
								self.drugType = 1
								this.target = nil
								this.source = nil
								switchScene("byexp" , nil , tipFun)
							end})
			end

		end})
	this.layer:addChild(conveyingBtn:getLayer())
	
	
	
	this.baseLayer:addChild( this.layer )
	
	
	-- 显示公用层 底部公用导航以及顶部公用消息
	this.infoLayer = InfoLayer:new("byexp" , 0 , {title_text = PATH.."title_text.png"})
	this.baseLayer:addChild( this.infoLayer:getLayer() )
	
	return this.baseLayer
end

--刷新界面
function M:refresh()
	if self.acceptBtn then
		self.acceptBtn:removeFromParentAndCleanup( true )
	end
	self.acceptBtn = self:createHeroSeat( 1 ,  self.target )
	setAnchPos( self.acceptBtn , 42 , 349 )
	self.layer:addChild(self.acceptBtn)
	
	if self.impartBtn then
		self.impartBtn:removeFromParentAndCleanup( true )
	end
	self.impartBtn = self:createHeroSeat( 2 , self.source )
	setAnchPos( self.impartBtn , 256 , 349 )
	self.layer:addChild(self.impartBtn)
	
	self:refreshCost( 1 )
end
--刷新花费
function M:refreshCost( index )
	self.drugType = index
	
	
	if self.source then
		local costNum 
--		if  self.drugType == 2 then
--			costNum = "需要  高级传功丹  X" .. self.source.s_trans
--		else
--			costNum = "需要  普通传功丹  X" .. self.source.n_trans
--		end
		local cruData = tonumber(getConfig("generalexp")[ self.source.lv .. "" ])
		local drugConfig = getConfig("transmission")
		local curCost
		if  self.drugType == 2 then
			curCost = math.ceil( math.ceil( cruData * tonumber( drugConfig["s_discount"] ) ) / tonumber( drugConfig["s_use"] ) )
			costNum = "需要  高级传功丹  X" .. curCost
		else
			curCost = math.ceil( math.ceil( cruData * tonumber( drugConfig["n_discount"] ) ) / tonumber( drugConfig["n_use"] ) )
			costNum = "需要  普通传功丹  X" .. curCost
		end
		
		self.costText:setString( costNum )
		self.costText:getLabel():setVisible( true )
	else
		self.costText:getLabel():setVisible( false )
	end
end
--生成英雄位
function M:createHeroSeat( _type , _data )
	local type = _type --1接受者  2 源
	local data = _data
	local tempBtn
	--创建文字
	local function createText()
		local str = {"选" , "择" , "英" , "雄"}
		for i = 1 , #str do
			local tempText = display.strokeLabel(str[i] , 0 , 0 , 36 , ccc3( 0x2c , 0x00 , 0x00 ) , 2 , ccc3( 0x40 , 0x1d , 0x0c ) , { dimensions_width = 50 , dimensions_height = 50 , align = 1 } ) 
			setAnchPos( tempText , 40 + 52 * ( ( i - 1 ) % 2 ) , 129 - 60 * math.floor( ( i - 1 ) / 2 ) )
			tempBtn:getLayer():addChild( tempText )
		end
	end
	--生成参数
	local function createParams()
		local params = { scale = 1.02 ,frontScale = { 0.78 } ,  front = data and getImageByType(data.cid , "b") or nil}
		params.callback = function()
			local list
			list = SelectList:new("general" , self.layer , COMMONPATH .. "title/hero_text.png" ,
			{
				showTitle = true,
				y = 85,
				btn_opt = "ok.png",
				target = true,
				generalType = "byexp" .. type ,
				haveUsed = { self.source , self.target } , 
				optCallback=
					function()
						list:destroy()
						local curId = list:getCurItem():getId()
						for i,v in pairs(DATA_Bag:getTable("general")) do
							if v.id == curId then
								if _type == 2 then
									self.source = v
								else
									self.target = v
								end
								break
							end
						end
						self:refresh()
					end
			}
			)
			self.baseLayer:addChild(list:getLayer())
		end
		
		return params
	end
	
	tempBtn = KNBtn:new(PATH , {"text_bg.png"} , 0 , 0 , createParams() ) 
	
	if not data then
		createText()
	end
	return tempBtn:getLayer()
end

return M
