--小助手
local M = {}

local PATH = IMG_PATH .. "image/scene/aide/"
local InfoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")
local KNTextField = requires(IMG_PATH,"GameLuaScript/Common/KNTextField")
function M:new( params )
	params = params or {}
	local curType = params.type
	local data = getConfig("help" , curType )
	
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	-- 基础层
	this.baseLayer = display.newLayer()
	this.viewLayer = display.newLayer()
	
	
	local bg = display.newSprite(SCENECOMMON.."bg.png")
	setAnchPos(bg)
	this.baseLayer:addChild(bg)
	
	local title = display.newSprite(COMMONPATH.."dark_bg.png")
	setAnchPos(title, 0, 425, 0, 0.5)
	this.baseLayer:addChild(title)
	
	this.viewLayer:addChild( display.strokeLabel( data.title , display.cx - 190 , 700 , 30 , ccc3( 0xd3 , 0x45 , 0xf9 ) , nil , nil , {
					dimensions_width = 380 ,
					dimensions_height = 40,
					align = 1
				}))
	
	
	
	local scroll = KNScrollView:new( 15 , 100 , 450 , 600 , 0 , false )
	local group = KNRadioGroup:new()
	for i = 1 , #data do
		local curData = data[i]
		local textLayer = display.newLayer()
		textLayer:addChild( display.strokeLabel( curData.title , 0 , 0 , 20 , ccc3( 0x6c , 0xe5 , 0x32 ) , nil , nil , {
					dimensions_width = 450 ,
					dimensions_height = 25,
					align = 0
				})  )
		textLayer:setContentSize( CCSizeMake( 450 , 25 ) )
		scroll:addChild( textLayer ,  textLayer )
				
		local tempItem = this:itemCell( { data = curData } )
		scroll:addChild( tempItem )
	end
	scroll:alignCenter()
	this.viewLayer:addChild(scroll:getLayer() )

	
	
	this.baseLayer:addChild(this.viewLayer , 1 )
	-- 显示公用层 底部公用导航以及顶部公用消息
	this.infoLayer = InfoLayer:new("aide", 0, { title_text = PATH .. curType ..  "_title.png" , closeCallback = params.backFun })
	this.baseLayer:addChild( this.infoLayer:getLayer() )	
	
	return this.baseLayer 
end

function M:itemCell( params )
	params = params or  {}
	local data = params.data
	
	local layer = display.newLayer()
	
	local function createItem( params )
		params = params or {}
		local titleStr = params.title		--文字标题
		local titleColor = params.titleColor or ccc3( 0x2e , 0xdb , 0xeb )	--标题文字颜色
		local titleSize = params.titleSize or 20	--标题文字大小
		
		local contextStr = params.content	--文字内容
		local contextColor = params.contextColor or ccc3( 0xff , 0xfb , 0xd4 )	--文字颜色
		local contextSize = params.contextSize or 20	--文字大小
		
		local btn = params.btn	--是否有按钮
		local tempY = 0
		local itemLayer = display.newLayer()
		

		
		--活动标题
		local itemTitleText = KNTextField:create( { str = titleStr , size = titleSize  , color = titleColor , width = 450 } )
		tempY = tempY - itemTitleText:getContentSize().height
		setAnchPos( itemTitleText ,  0 , tempY , 0 , 0 )
		itemLayer:addChild( itemTitleText )
		
		--活动内容
		local itemTitleText = KNTextField:create( { str = contextStr , size = contextSize  , color = contextColor , width = 450 } )
		tempY = tempY - itemTitleText:getContentSize().height - 10
		setAnchPos( itemTitleText ,  0 , tempY , 0 , 0)
		itemLayer:addChild( itemTitleText )
		
		local function goFun( btn )
			if btn == "mission" 		then
				DATA_Mission:setByKey("current","map_id",DATA_Mission:get("max","map_id"))
				DATA_Mission:setByKey("current","mission_id",DATA_Mission:get("max","mission_id"))
				HTTP:call("mission" , "get",{},{success_callback = function()
					switchScene("mission")
				end })
			elseif btn == "insequip" 	then
				local check_result = checkOpened("fb_equip")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				switchScene("fb" , { coming = "equip"})
			elseif btn == "inspet" 		then
				local check_result = checkOpened("fb_equip")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				switchScene("fb" , { coming = "pet"})
				
			elseif btn == "inshero" 	then
				local check_result = checkOpened("fb_equip")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				switchScene("fb" , { coming = "hero"})
			elseif btn == "insskill" 	then
				local check_result = checkOpened("fb_equip")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				switchScene("fb" , { coming = "skill"})
				
			elseif btn == "equippieces" then
				-- 判断等级开放
				local check_result = checkOpened("forge")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				switchScene("forge" , { index = 2})
				
			elseif btn == "animalsoul" 	then
				-- 判断等级开放
				local check_result = checkOpened("forge")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				switchScene("forge" , { index = 3 })
			elseif btn == "evolvepool" 	then	--净化池
							-- 判断等级开放
				local check_result = checkOpened("forge")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				switchScene("forge" , { index = 4 })
			elseif btn == "soul" 		then
				-- 判断等级开放
				local check_result = checkOpened("forge")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end
				switchScene("forge" , { index = 1 })
			elseif btn == "pet" 		then
				-- 判断等级开放
				local check_result = checkOpened("pet")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				switchScene("pet")
			elseif btn == "hero" 		then
				if DATA_General:haveGet() then
					DATA_Formation:set_index(1)
					switchScene("hero",{gid = DATA_Formation:getCur()})
				else
					HTTP:call("general" , "get",{},{success_callback =
						function()
							DATA_General:haveGet(true)
							DATA_Formation:set_index(1)
							switchScene("hero",{gid = DATA_Formation:getCur() })
						end
					})
				end
			elseif btn == "bag" 		then
				switchScene("bag")
			end
		end
		if btn then
			local btnElement = { 
							insequip 	= "insequip" , 	--藏宝楼
							mission		= "mission"  ,	--闯关
							inspet		= "inspet" 	 ,	--狩猎
							inshero		= "inshero"  ,	--山神庙
							insskill	= "insskill" ,	--如意阁
							equippieces	= "equippieces" , --铁匠铺
							animalsoul	= "animalsoul" ,--兽魂殿
							soul		= "soul" 	 ,	--聚义厅
							bag			= "bag" 	 ,	--背包 出售物品
			}
			tempY = tempY - 45 
			local getBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" ,"btn_bg_red_pre.png"} , display.cx - 97 , tempY ,
				{
					priority = -130,
					front = PATH .. "go_" .. btn .. ".png",
					callback = 
					function()
						goFun(btn)
					end
				}):getLayer()
			itemLayer:addChild( getBtn )
		end
		itemLayer:setContentSize( CCSizeMake( 450 , math.abs( tempY ) ) )
		return itemLayer		
	end
	local contentLayer = display.newLayer()
	local addY = 0
	
	for i = 1 , #data do
		local tempData = { title = i .. ". " .. data[i].title ,  content = "　　" .. data[i].content , btn = data[i].button  }
		local item = createItem( tempData )
		setAnchPos( item , 0 , addY )
		addY = addY - item:getContentSize().height - 10
		contentLayer:addChild( item )
	end
	
	setAnchPos( contentLayer ,  0 , math.abs( addY ) )
	layer:addChild(contentLayer)
	
	layer:setContentSize( CCSizeMake( 450 , math.abs( addY ) ) )
	return layer
end

return M