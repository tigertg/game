--[[
		升级提示
]]

local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local PATH = IMG_PATH .. "image/scene/upgrade/"
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")

local M = {}
function M:mainHero(_data , _params )
	
	audio.playSound(IMG_PATH .. "sound/upgrade.mp3")
	
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	local params = _params or {}
	
	local selfData = _data._T_lvup 
	local heroData = _data._T_hero_lvup
	
	--需求改变，现在只需要展示新功能开放，所以强制将以下两个数据转为空值
	selfData = nil
	heroData = nil
	
	
	this.baseLayer = display.newLayer()
	this.mask = KNMask:new({ item = this.baseLayer ,  opacity = 230 })
	local scene = display.getRunningScene()
	scene:addChild(this.mask:getLayer())
	
	--背景层
	local layerBg = display.newSprite( PATH .. "layer_bg.png")
	setAnchPos( layerBg , display.cx , display.cy , 0.5 , 0.5 )
	this.baseLayer:addChild(layerBg)
	
	if not selfData then
		if heroData then
			this:popHero( _data , _params )
		else
			this:popGuide( _data , _params )
		end
	else
		local layer = display.newLayer()
		this.baseLayer:addChild( layer )
		
		--背景
		local bg = display.newSprite( PATH .. "bg.png")
		setAnchPos( bg , display.cx + 4 , display.cy + 30 , 0.5 , 0.5 )
		layer:addChild(bg)
		
		--人物头像
		layer:addChild(KNBtn:new( COMMONPATH , { "sex" .. DATA_User:get("sex") .. ".jpg" } , display.cx - 100 , display.cy + 80 ,{ front = COMMONPATH .. "role_frame.png",
			callback = function()
			end}):getLayer())
--		layer:addChild( display.newSprite(IMG_PATH.."image/scene/common/navigation/level_bg.png" , display.cx - 100  , display.cy + 140) )
--		local level_label = display.strokeLabel(DATA_User:get("lv") - 1 , 0  , 0 , 18 , ccc3(179 , 58 , 0) )
--		setAnchPos(level_label , display.cx - 100 , display.cy + 130 , 0.5)
--		layer:addChild( level_label )
		
		--人物名字	
		layer:addChild( display.strokeLabel( DATA_User:get("name") ,  display.cx , display.cy + 100 , 20 ) )
		--当前等级
		local curLv = display.strokeLabel( 	"Lv " .. ( DATA_User:get("lv") - 1) .."  →" ,  display.cx - 80 , display.cy + 30 , 24 ) 
		layer:addChild( curLv )
		--升级后的等级	
		layer:addChild( display.strokeLabel( 	"Lv  " ,  display.cx + 20 , display.cy + 30 , 30 ) )	
		--新等级
		local newLv = display.strokeLabel( 	selfData.lv ,  display.cx + 60 , display.cy + 30 , 30 ,ccc3(0xff , 0x00 , 0x00 ) )
		layer:addChild( newLv )
		
		
		
		
		local function eff1Fun()
			local effFrames = display.newFramesWithImage( IMG_PATH.."image/scene/upgrade/eff.png" , 5 )
			local effSprite
			effSprite =display.playFrames( math.random( 100 , 400)  , math.random(100 , 300) , 
											effFrames ,
											0.2 , 
											{
												 onComplete =
												 function() 
													effSprite:removeFromParentAndCleanup( true ) 
												 end 
											 } )
			
			layer:addChild( effSprite )	
		end
		
		local function eff2Fun()
			local effFrames = display.newFramesWithImage( IMG_PATH.."image/scene/upgrade/eff.png" , 5 )
			local effSprite2
			effSprite2 =display.playFrames( math.random( 100 , 400)  , math.random(500 , 700) , 
											effFrames ,
											0.2 , 
											{
												 onComplete =
												 function() 
													effSprite2:removeFromParentAndCleanup( true ) 
												 end 
											 } )
			
			layer:addChild( effSprite2 )												
		end
		eff1Fun()
		local actions = CCArray:create()
		actions:addObject( CCDelayTime:create( 0.8 ) )
		actions:addObject( CCCallFunc:create( eff2Fun ) )
		bg:runAction( CCSequence:create( actions ) )
		
		
		
		--附加信息
		local tipInfo1 = display.strokeLabel( "你带领的英雄、幻兽、装备 " , display.cx - 100 , display.cy - 35 , 14 , nil , nil , nil , { dimensions_width = 200 , dimensions_height = 30 } ) 
		layer:addChild( tipInfo1 )
		local tipInfo2 = display.strokeLabel( "的等级上限提升到了       级 " , display.cx - 100 , display.cy - 55 , 14 , nil , nil , nil , { dimensions_width = 200 , dimensions_height = 30 } ) 
		layer:addChild( tipInfo2 )
		--策划需求不确定，屏蔽
--		local openElement = { 	["1"] = 1 , 
--								["3"] = 2 , 
--								["5"] = 3 , 
--								["8"] = 4 , 
--								["11"] = 5 , 
--								["14"] = 6 , 
--								["17"] = 7 , 
--								["20"] = 8 , 
--								}
--		if openElement[selfData.lv .. ""] then
--			local tipInfo2 = display.strokeLabel( "可以开放第" .. openElement[selfData.lv .. ""] .. "阵位了 " , display.cx - 100 , display.cy - 75 , 14 , nil , nil , nil , { dimensions_width = 200 , dimensions_height = 30 } ) 
--			layer:addChild( tipInfo2 )
--		end
		
		local othenInfo = display.strokeLabel( tostring( selfData.lv * 2 )  , display.cx + 37 , display.cy - 55 , 14 , ccc3( 0xff , 0x00 , 0x00 ) , nil , nil , { dimensions_width = 33 , dimensions_height = 30 } ) 
		layer:addChild( othenInfo )
		
		
		local okBtn = KNBtn:new(
					COMMONPATH ,
					{ "btn_bg_red.png" , "btn_bg_red_pre.png"} ,
					display.cx - 80 ,
					display.cy - 125 , 
					{
						scale = true ,
						priority = -130,
						front = COMMONPATH .. "confirm.png" , 
						callback = function()
							if heroData or getGuideInfo() then
								this:popHero( _data , _params )
								transition.moveTo(layer , { time = 1 , x = -display.width , easing = "ELASTICOUT"  , onComplete = function() layer:removeFromParentAndCleanup(true) end})
							else
								--没有英雄升级 没有新功能引导
								this.mask:remove()
								if params.backFun then params.backFun() end
								
							end
	
						end
					}
				)
		layer:addChild( okBtn:getLayer() )
	end
	
end

function M:popHero( _data , _params )
	
	audio.playSound(IMG_PATH .. "sound/upgrade.mp3")
	
	local params = _params or {}
	
	local selfData = _data._T_lvup 
	local heroData = _data._T_hero_lvup
	
	if not heroData then
		if getGuideInfo() then
			self:popGuide( _data , _params )
		end
	else
		local layer = display.newLayer()
		self.baseLayer:addChild(layer)
		
		--背景
		local bg = display.newSprite( PATH .. "bg.png")
		setAnchPos( bg , display.cx + 4 , display.cy + 30 , 0.5 , 0.5 )
		layer:addChild(bg)
		
		
		
		local function createCell( id , lvNum )
			local curData = DATA_Bag:get( "general" , id )
		
			local imageLayer = display.newLayer()
			
			--人物头像
			imageLayer:addChild(KNBtn:new( IMG_PATH.."image/scene/common/navigation/" , { "logo.png" } , 15 , 10 ,{ front = getImageByType(curData.cid , "s" ),
				callback = function()
				end}):getLayer())
--			imageLayer:addChild( display.newSprite(IMG_PATH.."image/scene/common/navigation/level_bg.png" , 18  , 70) )
--			local level_label = display.strokeLabel( curData.lv - 1 , 0  , 0 , 18 , ccc3(179 , 58 , 0) )
--			setAnchPos(level_label ,18 , 60 , 0.5)
--			imageLayer:addChild( level_label )
			
			--人物名字	
			imageLayer:addChild( display.strokeLabel( curData.name ,  90 , 51 , 20 ) )
			--当前等级
			local curLv = display.strokeLabel( 	"Lv " .. ( curData.lv - 1 ) .."  →" ,  90 , 15 , 20 ) 
			imageLayer:addChild( curLv )
			--升级后的等级	
			imageLayer:addChild( display.strokeLabel( 	"Lv  " ,  170 , 15 , 20 ) )	
			--新等级
			local newLv = display.strokeLabel( 	lvNum ,  195 , 15 , 20 ,ccc3(0xff , 0x00 , 0x00 ) )
			imageLayer:addChild( newLv )
			
			imageLayer:setContentSize( CCSize:new( 218 , 72 ) )
			return imageLayer
		end
		
		local frame = display.newSprite(PATH .. "hero_frame.png")
		setAnchPos(frame , display.cx , display.cy + 50 , 0.5 , 0.5  )
		layer:addChild( frame )
		
		local scroll = KNScrollView:new( 127 , 393 , 218 , 168 , 17 , false , 0 )
		for key , v in pairs(heroData) do
			scroll:addChild( createCell( key , v ) )
		end
		
		layer:addChild(scroll:getLayer())
		
		
		local mask
		local okBtn = KNBtn:new(
					COMMONPATH ,
					{ "btn_bg_red.png" , "btn_bg_red_pre.png"} ,
					display.cx - 80 ,
					display.cy - 115 , 
					{
						scale = true ,
						priority = -130,
						front = COMMONPATH .. "confirm.png" , 
						callback = function()
							if getGuideInfo() then
								self:popGuide( _data , _params )
								transition.moveTo(layer , { time = 1 , x = -display.width , easing = "ELASTICOUT"  , onComplete = function() layer:removeFromParentAndCleanup(true) end})
							else
								self.mask:remove()
								if params.backFun then params.backFun() end
							end
						end
					}
				)
		layer:addChild( okBtn:getLayer() )
		
		setAnchPos( layer , display.width , 0 )
		transition.moveTo(layer , {time = 1 , x = 0 , easing = "ELASTICOUT" })
	end
end
--功能开放
function M:popGuide( _data , _params )
	audio.playSound(IMG_PATH .. "sound/upgrade.mp3")
	local params = _params or {}

	local guideInfo = getGuideInfo()
	if not guideInfo then
		self.mask:remove()
		self.baseLayer:removeFromParentAndCleanup(true)
		if params.backFun then params.backFun() end
		return
	end
	local layer = display.newLayer()
	self.baseLayer:addChild(layer)
	
	--背景
	local bg = display.newSprite( PATH .. "bg.png")
	setAnchPos( bg , display.cx + 4 , display.cy + 30 , 0.5 , 0.5 )
	layer:addChild(bg)

	if not guideInfo.not_new then
		local new_open_title = display.newSprite( PATH .. "new_open_title.png")
		setAnchPos( new_open_title , display.cx + 4 , display.cy + 110 , 0.5 , 0.5 )
		layer:addChild(new_open_title)
	end

	

	--文字
	local text = display.strokeLabel( guideInfo["text"] , display.cx - 100 , display.cy - 42 , 18 , nil , nil , nil , {
		dimensions_width = 200,
		dimensions_height = 112,
		align = 0,
	}) 
	layer:addChild( text )


	-- 按钮
	local okBtn = KNBtn:new(
		COMMONPATH ,
		{ "btn_bg_red.png" , "btn_bg_red_pre.png"} ,
		display.cx - 80 ,
		display.cy - 125 , 
		{
			scale = true ,
			priority = -130,
			front = PATH .. "btn_name/" .. guideInfo["id"] .. ".png" , 
			callback = function()
				if guideInfo["guide_step"] then
					KNGuide:setStep( guideInfo["guide_step"] )

					switchScene("home")
				else
					self.mask:remove()
					self.baseLayer:removeFromParentAndCleanup(true)
					if params.backFun then params.backFun() end
				end
			end
		}
	)
	layer:addChild( okBtn:getLayer() )
	
	transition.moveTo(layer , {time = 1 , x = 0 , easing = "ELASTICOUT" })


	-- 设置数据
	DATA_Guide:setOld()
end

function M:show( _data )
	
end
return M
