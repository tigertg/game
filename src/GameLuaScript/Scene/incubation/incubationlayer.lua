--[[

	孵化层

]]--
local PATH = IMG_PATH.."image/scene/incubation/"
local PROPPATH = IMG_PATH.."image/prop/"
local NORMAL , CHOOSE , COOKING  = 1 , 2 , 3
local card_mask
local KNCardpopup = requires(IMG_PATH,"GameLuaScript/Common/KNCardpopup")
--[[英雄模块，首页点击英雄图标进入]]
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local HatchLayer = {
	baseLayer ,
	layer ,
	eggs , 
	scroll ,
	goldText,
	silverText,
}
function HatchLayer:new( x , y , params )
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	this.state = NORMAL		--当前状态
	this.eggBtn = {}		--宠物蛋按钮
	this.hatchSeat = nil	--孵化位
	this.curEggType = 0 	--当前孵化级别
	this.isAction = false	--收取一个宠物后，是否做动画自动添加一个新的幻兽蛋到孵化位
	if not params then params = {} end
	
	this.baseLayer = display.newLayer()
	this.layer = display.newLayer()
	
	local bg = display.newSprite( COMMONPATH .. "mid_bg.png" )
	--背景纹理
	local topBg = display.newSprite(PATH.."bg.png")
	--幻兽之卵标题
	local petEggTitle = display.newSprite(PATH.."pet_egg.png")
	--孵化栏
	local hatchTitle2 = display.newSprite(PATH.."hatch_title2.png")
	--动画图片
	local effSp = display.newSprite(PATH .. "eff.png")
	--点击幻兽蛋进入孵化位
	local setTip = display.strokeLabel("点击幻兽蛋进入孵化位" , display.cx - 150 , 490 , 18 , ccc3( 0xf8 , 0xd2 , 0x5c ) , nil , nil , { dimensions_width = 300 , dimensions_height = 70 , align = 1 } ) 
	local getTip = display.strokeLabel( "黄金孵化，有更高概率孵出高星级幻兽"  , 104 , 132 , 16 , ccc3( 0xff , 0xf1 , 0xb7 ) )
	this.hatchTip = display.strokeLabel( ""  , 104 , 236 , 18 , ccc3( 0xff , 0xf1 , 0xb7 ) )
	
	setAnchPos( bg , 0 , 86 )
	setAnchPos(topBg , display.cx  , 118 , 0.5 , 0 )
	setAnchPos(petEggTitle , display.cx  , 700 , 0.5 )
	setAnchPos(hatchTitle2 , display.cx  , 485 , 0.5)
	setAnchPos( effSp , display.cx , 372 , 0.5 , 0.5)
	
	this.layer:addChild(bg)
	this.layer:addChild(topBg)
	this.layer:addChild(petEggTitle)
	this.layer:addChild(setTip)
	
	this.layer:addChild(getTip)
	this.layer:addChild(this.hatchTip)
	this.layer:addChild( effSp )
	this.layer:addChild(hatchTitle2)
	
	
	local rotationFun
	local function rotation( angle )
		transition.rotateTo( effSp , {
			time = 10 ,
			angle = -angle ,
			onComplete = function()
				angle = angle == 180 and 360 or 180
				rotationFun(angle)
			end
		})
	end
	
	
	--孵化请求
	local function askFun( _type )
		if _type == 2 and tonumber( DATA_Account:get("gold")) < tonumber( this.goldText:getString() ) then
			KNMsg:getInstance():flashShow("黄金不足，通过充值可以获得黄金")
			return
		end

		if _type == 1 and tonumber( DATA_Account:get("silver")) < tonumber( this.silverText:getString() ) then
			KNMsg:getInstance():flashShow("银两不足")
			return
		end

		if isBagFull() then
			return false
		end

		rotationFun = rotation( 180 )

		HTTP:call("pet", "hatch", { type = _type ,  id = DATA_Bag:getEgg( this.curEggType + 2 ) },{
			success_callback = function( _data)
				this:refreshSeat()

				transition.stopTarget(effSp)
				
				local function dropBagBackFun()
					if DATA_Bag:getEggCount( this.curEggType ) > 0 then
						this.isAction = true
						this:createMachine( this.curEggType )
					else
						this.state = NORMAL
					end 
				end
				
				
				if _data.awards.drop then
					local cids = {}
					for key , v in pairs(_data.awards.drop) do
						cids[#cids + 1] = v
					end
					this:playGetCards(cids , { backFun = dropBagBackFun } )
				end
			end
		})
	end
	--黄金孵化
	this.goldHatchBtn  = KNBtn:new( COMMONPATH , { "btn_bg_red.png"  , "btn_bg_red_pre.png" , "btn_bg_red2.png" },
									 display.cx - 174 , 
									 180 , 
									 {
									 	scale = true , 
									 	front = PATH .. "gold.png" , 
									 	callback = function()
									 		askFun(2)
									 	end
									 } )
	this.layer:addChild( this.goldHatchBtn:getLayer() )
	--银两孵化
	this.silverHatchBtn  = KNBtn:new( COMMONPATH , { "btn_bg_red.png"  , "btn_bg_red_pre.png" , "btn_bg_red2.png"},
									 display.cx + 30 , 
									 180 , 
									 {
									 	scale = true , 
									 	front = PATH .. "silver.png" , 
									 	callback = 
									 	function()
									 		askFun(1)
									 	end
									 } )
	this.layer:addChild( this.silverHatchBtn:getLayer() )
	
	this.gold = display.newSprite( COMMONPATH .. "gold.png" )
	this.silver = display.newSprite( COMMONPATH .. "silver.png" )
	this.goldText = display.strokeLabel( "" , 120, 158, 18, ccc3( 0xff , 0xf1 , 0xb7 ))
	this.silverText = display.strokeLabel( "" , 325, 158, 18, ccc3( 0xff , 0xf1 , 0xb7 ))
	
	setAnchPos( this.gold , 100 , 167 , 0.5 , 0.5 )
	setAnchPos( this.silver , 305 , 167 , 0.5 , 0.5 )
	this.gold:setVisible(false)
	this.silver:setVisible(false)
	
	this.layer:addChild( this.gold )
	this.layer:addChild( this.silver )
	this.layer:addChild( this.goldText )
	this.layer:addChild( this.silverText )
	
	--生成宠物蛋
	for i = 1 , 3 do
		this:createMachine( i )
	end
	
	this:refreshSeat()
	


	
	-- 显示公用层 底部公用导航以及顶部公用消息
	this.infoLayer = InfoLayer:new("hatch" , 0 , {title_text = PATH.."title_text.png" , closeCallback =function() switchScene("pet") end })
	this.layer:addChild( this.infoLayer:getLayer() )

	return this
end
--刷新数据
function HatchLayer:refreshSeat( index )
	local tempTable
	if not index then
		tempTable = { text = { "孵化位" , 18 , ccc3( 0x72 , 0xc6 , 0xe5 ) , { x = 0 , y = 10} } , callback = function()end ,  front = nil , other = { PATH .. "free.png" , 19 , 4 } }
		
		self.goldText:setString("")
		self.silverText:setString("")
		self.gold:setVisible(false)
		self.silver:setVisible(false)
		
		self.hatchTip:setString( "" )
		
		local tempDelayAction = CCArray:create()
		tempDelayAction:addObject( CCDelayTime:create(0.5) )
		tempDelayAction:addObject( CCCallFunc:create(function()
												 		self.goldHatchBtn:setEnable(false)
														self.silverHatchBtn:setEnable(false)
													end) )
		self.gold:runAction(CCSequence:create( tempDelayAction ))
		

		
	else
		if self.state == NORMAL then
			self.curEggType = 0
			
			tempTable = { text = { "孵化位" , 18 , ccc3( 0x72 , 0xc6 , 0xe5 ) , { x = 0 , y = 10} } , callback = function()end ,  front = nil , other = { PATH .. "free.png" , 19 , 4 } }
			self.goldHatchBtn:setEnable(false)
			self.silverHatchBtn:setEnable(false)
			
			self.goldText:setString("")
			self.silverText:setString("")
			self.gold:setVisible(false)
			self.silver:setVisible(false)
			
			self.hatchTip:setString( "" )
			
		elseif self.state == CHOOSE then
		
			self.curEggType = index
			
			tempTable = { text = nil ,
							scale = true , 
							front =  PROPPATH .. "s_600" .. index .. ".png" ,
							frontScale = { 1 , nil , 10 } ,
							other = { PATH .. "egg_title" .. index .. ".png" , 8 , 6 } ,
							callback = 
							function()
								self.state = NORMAL
								self:refreshSeat( index )
								self:createMachine( index )
							end , 
						}
			self.goldHatchBtn:setEnable(true)
			self.silverHatchBtn:setEnable(true)
			self.gold:setVisible(true)
			self.silver:setVisible(true)
			
			local cost = DATA_Incubation:get()
			local lv = index + 2
			self.goldText:setString( cost.gold[ lv .. "" ])
			self.silverText:setString( cost.silver[ lv .. "" ] )
			local tipTable = {
								["1"] = "初级幻兽蛋：可孵出1-2星幻兽" ,
								["2"] = "中级幻兽蛋：可孵出1-3星幻兽" ,
								["3"] = "高级幻兽蛋：可孵出1-4星幻兽" ,
								}
			self.hatchTip:setString( tipTable[ index .. "" ])
		elseif self.state == COOKING then
			
		end	
	end
	
	
	if self.hatchSeat then
		self.hatchSeat:removeFromParentAndCleanup( true )
	end
	--孵化位
	self.hatchSeat  = KNBtn:new( PATH , { "hatch_seat.png"  },
									 display.cx - 50 , 
									 308 , 
									 tempTable):getLayer()
	self.layer:addChild( self.hatchSeat )
	
end

--生成宠物蛋
function HatchLayer:createMachine( index )
	local eggNum = 	self.state == CHOOSE and  DATA_Bag:getEggCount( index ) - 1 or DATA_Bag:getEggCount( index )
	local tempData =  { 
						text = { eggNum > 99 and "99" or  eggNum , 18 , ccc3( 0xff , 0xff , 0xff ) , { x = 36 , y = -26} , nil , 17 } , 
						scale = true , 
						front = ( eggNum > 0 and PROPPATH .. "s_600"  or PATH .. "g_600" ) .. index .. ".png" , 
						other = { { PATH .. "egg_num_bg.png" , 65 , 4 } , {PATH .. "egg_title".. index .. ".png" , nil , -30 } } ,
						callback = function()
							
							if self.curEggType == 0 then
								self.isAction = true
								self.state = CHOOSE
								self:createMachine( index )
							else
								self.state = NORMAL
								self:createMachine( self.curEggType )
								
								self.isAction = true
								self.state = CHOOSE
								self:createMachine( index )
							end
						end ,
					}
					
	if self.eggBtn[index] then
		self.eggBtn[index]:getLayer():removeFromParentAndCleanup( true )
	end
	
	self.eggBtn[index] = KNBtn:new( IMG_PATH .. "image/scene/fb/" , { "item_bg.png"  },
									 60 + ( index - 1 ) * 136 , 
									 610 , 
									 tempData)
	self.eggBtn[index]:setEnable( eggNum > 0 )
	
	if eggNum > 99 then
		self.eggBtn[index]:getLayer():addChild( display.strokeLabel( "+", 86, 10, 16, ccc3( 0xff , 0xff , 0xff )))
	end
	
	self.layer:addChild( self.eggBtn[index]:getLayer() )

	if index == 1 and KNGuide:getStep() == 404 then
		KNGuide:show( self.eggBtn[index]:getLayer() , {
			callback = function()
				KNGuide:show( self.silverHatchBtn:getLayer() , {
					remove = true
				})
			end
		})
	end
	
	if self.isAction then
		self.isAction = false
		
		tempData.callback = nil
		tempData.text = nil
		tempData.other = nil
		--强制转换成正常宠物蛋	
		tempData.front = PROPPATH .. "s_600" .. index .. ".png" 
		
		local actionSp = KNBtn:new( IMG_PATH .. "image/scene/fb/" , { "item_bg.png"  },
									 60 + ( index - 1 ) * 136 , 
									 610 , 
									 tempData):getLayer()
									 
		self.layer:addChild( actionSp , 1)
		transition.moveTo( actionSp , {
			time = 0.5 , 
			x = display.cx - 41 , 
			y = display.cy - 96 ,
			onComplete =
			function()
			 	actionSp:removeFromParentAndCleanup( true )
			 	self:refreshSeat( index )
			end
		})
										
	end
	
end




function HatchLayer:getLayer()
	return self.layer
end
--------------------------------------------------------------------------------------------------
--
--
--[[播放卡牌获得动画]]
--
--
function HatchLayer:playGetCards(cids , params )
	local scene = display.getRunningScene()

	local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
	card_mask = KNMask:new({priority = -133})
	scene:addChild(card_mask:getLayer() , 100)

	local callback
	callback = function(index)
		local next_index = index + 1
		if cids[next_index] then
			self:playOneCard(cids[next_index] , next_index , callback)
		else
			-- scene:removeChild(card_mask , true)
			card_mask:remove()
			if params.backFun then params.backFun() end
		end
	end
	
	self:playOneCard(cids[1] , 1 , callback)
end

function HatchLayer:playOneCard(cid , index , callback)
	local scene = display.getRunningScene()
	local baseX = 42
	local baseY = 256

	local card_x = baseX + 49 + (index - 1) * 74
	local card_y = baseY - 153


	local tempPath = getImageByType(cid , "s")
	local btn = KNBtn:new( IMG_PATH .. "image/scene/common/" , { "skill_frame1.png" },
		card_x ,
		card_y ,
		{
			scale = true ,
			front = tempPath,
			priority = -132,
			callback = function()
				self:popOneCard(cid , index , function()
					-- scene:removeChild(card_mask , true)
					card_mask:remove()
				end)
			end
		})

	local handle
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		award_handle = nil

		self:popOneCard(cid , index , callback)
	end , 0.22 , false)
end

function HatchLayer:popOneCard(cid , index , callback)
	local baseX = 42
	local baseY = 256
	local card_x = baseX + 49 + (index - 1) * 74
	local card_y = baseY - 153





	local card_popup = KNCardpopup:new(cid , function()
		callback(index)
	end , {
		init_x = card_x - 160,
		init_y = card_y - 211,
		end_x = card_x - 170,
		end_y = card_y - 500,
	})


	card_mask:getLayer():addChild( card_popup:play() )
end

return HatchLayer