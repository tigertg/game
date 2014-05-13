-- 常用基本元素
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNClock = requires(IMG_PATH,"GameLuaScript/Common/KNClock")
local KNTextField = requires(IMG_PATH,"GameLuaScript/Common/KNTextField")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")

--标题
function createTitle( titlePath )
	local addX = 0
	local addY = 0
	
	local titleBg = display.newSprite( IMG_PATH .. "image/scene/mission/title_bg.png")
	setAnchPos(titleBg, addX , addY , 0.5 , 0.5 )
	
	local title = display.newSprite( titlePath )
	setAnchPos(title, titleBg:getContentSize().width/2 - title:getContentSize().width/2 - 24  , addY + titleBg:getContentSize().height/2 ,  0 , 0.5 )
	titleBg:addChild(title)
	
	return titleBg
end
--常用弹出界面
function baseMask( params )
	params = params or {}
	local isBackBtn = params.isShowBack or false--时否显示返回按钮
	local bgInfo = params.bgInfo or { path = COMMONPATH .. "tip_bg.png" ,  y = 336 }
	local titlePath = params.titlePath or nil	--是否有标题
	
	local mask
	local layer = display.newLayer()
	local bg = display.newSprite( bgInfo.path , display.cx , bgInfo.y , 0.5 , 0 )
	layer:addChild( bg )
	
	if titlePath then
		local titleSp = createTitle(titlePath)
		setAnchPos( titleSp , display.cx + 50 , bgInfo.y + bg:getContentSize().height + 10  , 0.5 , 0.5  )
		layer:addChild( titleSp ) 
	end
	
	if isBackBtn then
		--退出界面
		layer:addChild( KNBtn:new( COMMONPATH , { "back_img.png" , "back_img_press.png" } , 30 , 545 , {
								priority = -131 ,
								callback = function()
									mask:remove()
								end
								} ):getLayer() )
	end
	
	setAnchPos( layer , 0 , display.height , 0 , 0 )
	transition.moveTo( layer , { time = 0.5 , y = 0 , easing = "BACKOUT"})
	
	mask = KNMask:new({ item = layer , priority = -130 })
	local scene = display.getRunningScene()
	scene:addChild( mask:getLayer() )
	
	function layer:remove()
		mask:remove()
	end
	return layer
end


--奖励道具
function awardCell( awardData , params )
	params = params or {}
	local rejectElement = {
				silver = { name ="银两" ,  desc = "银两: 游戏中的普通货币"  , star = nil } , 
				gold = { name = "黄金" , desc = "黄金: 游戏中的充值货币"  , star = nil} , 
				task_tribute = { name = "帮威" , desc = "帮威:用于帮会商店购买宝石、装备"  , star = nil} , 
				task_exp = { name = "帮贡" , desc = "帮贡:用于帮会升级和帮会商店道具开启"  , star = nil} , 
				task_power = { name = "体力" , desc = "体力:用于闯关的消耗"  , star = nil} , 
				power = { name = "体力" , desc = "体力:用于闯关的消耗"  , star = nil} , 
				funds = { name = "资金" , desc = "资金:用于帮会升级和帮会商店道具开启"  , star = nil} , 
				chip1 = { name = "一星装备碎片" , desc = "一星装备碎片:用于打造二星装备"  , star = 1} , 
				chip2 = { name = "二星装备碎片" , desc = "二星装备碎片:用于打造三星装备"  , star = 2} , 
				chip3 = { name = "三星装备碎片" , desc = "三星装备碎片:用于打造四星装备"  , star = 3} , 
				chip4 = { name = "四星装备碎片" , desc = "四星装备碎片:用于打造五星装备"  , star = 4} , 
				soul1 = { name = "一星英雄将魂" , desc = "一星英雄将魂:用于合成二星英雄"  , star = 1} , 
				soul2 = { name = "二星英雄将魂" , desc = "二星英雄将魂:用于合成三星英雄"  , star = 2} , 
				soul3 = { name = "三星英雄将魂" , desc = "三星英雄将魂:用于合成四星英雄"  , star = 3} , 
				soul4 = { name = "四星英雄将魂" , desc = "四星英雄将魂:用于合成五星英雄"  , star = 4} , 
				animal1 = { name = "一星兽魂" , desc = "一星兽魂:用于合成三星幻兽"  , star = 1} , 
				animal2 = { name = "二星兽魂" , desc = "二星兽魂:用于合成三星幻兽"  , star = 2} , 
				animal3 = { name = "三星兽魂" , desc = "三星兽魂:用于合成四星幻兽"  , star = 3} , 
				animal4 = { name = "四星兽魂" , desc = "四星兽魂:用于合成五星幻兽"  , star = 4} , 
	 	}
	local function clickFun()
	 	--当点击图标按钮后先从全局数据中查找是否存在数据，若没有则请求网络，否则隐藏用户信息栏，显示详细界面
	 	if (not rejectElement[ awardData["cid"] .. "" ]) and awardData["cid"] ~= "体力" and awardData["cid"] ~= "扫荡令"  then
			local detail_type = getCidType(awardData["cid"])
			local data = getConfig( detail_type , awardData["cid"] )
			data["cid"] = awardData["cid"]
			data["lv"] = awardData["lv"]
			pushScene("detail" , {
				detail = detail_type,
				data = data,
			})
		else
			local str = ""
			if ( rejectElement[ awardData["cid"] .. "" ]) then str = rejectElement[ awardData["cid"] ].desc
			elseif awardData["cid"] == "power" then str = "每次喝酒可获".. awardData.num .. "点体力"
			elseif awardData["cid"] == "扫荡令" then str = "每次喝酒可获10个扫荡令"
			end
			KNMsg.getInstance():flashShow( str )
		end
	end
	if params.getClickFun then
		return clickFun
	end
	local textData = awardData.num and { {( tonumber( awardData.num ) < 10000 and tonumber( awardData.num ) or math.floor(tonumber( awardData.num )/10000) .. "万" ) , 14 , ccc3( 0xff , 0xff , 0xff ) , { x = 17 , y = -22 }  , nil , 17 } }or nil
	local otherData = awardData.num and { { IMG_PATH .. "image/scene/activity_new/num_bg.png" , 34 , 0 } } or nil
	
	if params.name then
		textData = textData or {}
		local nameStr
		if rejectElement[awardData.cid]  then
			nameStr = rejectElement[awardData.cid .. ""].name
		else
			nameStr = getConfig( getCidType( awardData.cid ) , awardData.cid , "name" )	
		end
		
		table.insert( textData, { nameStr , 14 , ccc3( 0x2c , 0x00 , 0x00 ) , { x = 0 , y = params.star and -70 or -50 } , nil , 17 } )
	end
	if params.star then
		local star
		if rejectElement[ awardData.cid .. "" ] then
			star = rejectElement[ awardData.cid .. "" ].star
		else
			star = getConfig( getCidType( awardData.cid ) ,  awardData.cid , "star" )
		end
		if star then
			otherData = otherData or {}
			for j = 1 , star do
				table.insert( otherData, { IMG_PATH .. "image/scene/home/star.png" ,  7 - star * 12 + j * 24  , -27 } )
			end
		end
	end
	
    local iconPath = getImageByType( awardData.cid , "s")
	local equipBtn = KNBtn:new( SCENECOMMON , 
								{ "skill_frame1.png" } ,
								 0 , 0 , 
								 { 
								 	parent = params.parent , 
								 	priority = -130,
								 	scale = true ,
								 	front = iconPath , 
								 	other = otherData , 
								 	text = textData ,
								 	callback = function()
										clickFun()
							 		 end
								 }):getLayer()
	return equipBtn
end
