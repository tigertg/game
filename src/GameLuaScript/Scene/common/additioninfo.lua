-- 加成详细界面
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local PATH = IMG_PATH .. "image/scene/detail/"
local M = {

}


function M:new( params )
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	params = params or {}
	local data = params.data or {}
	local mask , layer
	layer = display.newLayer()
	
	-- 背景
	layer:addChild( display.newSprite(PATH .. "addition_bg.png" , display.cx , 202 , 0.5 , 0 ) )
	local function basePopup( titlePath )
		local addX , addY = 0 , 0
		local bg = display.newSprite( IMG_PATH .. "image/scene/mission/title_bg.png")
		setAnchPos(bg, addX , addY)
		
		local title = display.newSprite( titlePath )
		setAnchPos(title, addX - 24 , addY )
		bg:addChild(title)
		return bg
	end
	local title =  basePopup(PATH .. "addition_title.png" )
	setAnchPos( title , display.cx + 37 , 655 + 30 , 0.5 , 0  )
	layer:addChild( title )
	--返回按钮
	local cancelBtn = KNBtn:new(COMMONPATH,{"back_img.png","back_img_press.png"} , 37 , 627 + 40 , {
		scale = true,
		priority = -133,	
		callback = function()
			mask:remove()
		end
	})
	layer:addChild(cancelBtn:getLayer())
	
	
--	原始属性  i
--	装备属性  e
--	装备附加  ea
--	组合      g
--	升阶      s
--	以上每一种都有四个: 例如  atk_s   def_s  agi_s  hp_s
	local keyElement = { { color = ccc3( 0xff , 0xfb , 0xd4 ) , key = "i"  } ,
					{ color = ccc3( 0x34 , 0x82 , 0x22 ) , 		key = "s"  } ,
					{ color = ccc3( 0x98 , 0x43 , 0x21 ) , 		key = "e"  } ,
					{ color = ccc3( 0x38 , 0x82 , 0xad ) , 		key = "ea"  } ,
					{ color = ccc3( 0xb7 , 0x34 , 0x94 ) , 		key = "g"  } ,
					{ color = ccc3( 0xbf , 0x00 , 0x00 ) , 		key = "total"  } ,
					}
					
	
	local vElement = { "atk" , "def" , "hp" , "agi"  }
	local totalElement = { atk = 0 ,  def = 0 , agi = 0 , hp = 0 }
	for i = 1 , #keyElement do
		local key = keyElement[i].key
		for j = 1 , #vElement do
			local v = vElement[j]
			local addX , addY = 139 + ( j - 1 ) * 75 , 575 - ( i - 1 ) * ( i == 6 and 47 or 48 )
			local curValue
			if key ~= "total" then
				curValue= data[ v .. "_" .. key ] or 0
				totalElement[ v .."" ] = totalElement[ v .."" ] + curValue
			else
				curValue = totalElement[ v .. "" ]
			end
			layer:addChild( display.strokeLabel( curValue , addX , addY , 20 , keyElement[i].color , nil , nil ,{
					dimensions_width = 75 ,
					dimensions_height = 25,
					align = 1
				}) )
		end	
	end
	
	
	local pulseElement = { 'crit','block','hit','dodge','ctatk','kill' }
	for i = 1 , #pulseElement do
		local addX , addY = 40 + ( i - 1 ) * 65 , 220
		local curValue = data[pulseElement[i] .. "" ] or 0
		layer:addChild( display.strokeLabel( curValue , addX , addY , 20 , ccc3( 0x2c , 0x00 , 0x00 ) , nil , nil ,{
				dimensions_width = 65 ,
				dimensions_height = 25,
				align = 1
			}) )
	end
	
	setAnchPos( layer , 0 , -display.height )
	transition.moveTo( layer , { delay = 0.5 , time = 0.5 , y = 0 , easing = "BACKOUT" })
	mask = KNMask:new( { opacity = 100 , item = layer , priority = -132 } )
	
	
	local curScene = display.getRunningScene()
	curScene:addChild( mask:getLayer()  )
	return this
end
return M