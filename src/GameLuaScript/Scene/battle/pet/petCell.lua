--[[

	单个幻兽

]]--


local KNBar = requires(IMG_PATH,"GameLuaScript/Common/KNBar")
local KNBtn = requires( IMG_PATH , "GameLuaScript/Common/KNBtn" )
local infoLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroInfo")
local M = {}
function M:create( _data , _isSelf )
	local data = _data or {}
	local content = display.newLayer()
	local isDisabled = false	--是否禁用操作
	local petSkill = requires(IMG_PATH,"GameLuaScript/Scene/battle/pet/petSkill")

	

	local actionLayer = display.newLayer()
	local imagePath = IMG_PATH .. "image/scene/battle/pet/"
	
	if data.cid then
		--背景
		local bg = display.newSprite( imagePath .. "light.png" )
		content:addChild( bg )

		--幻兽背景效果
		local function petEffect()
			local action1 = transition.fadeIn( bg , {time = 1 } )
			local action2 = transition.fadeOut( bg , {time = 1 } )
			bg:runAction( transition.sequence( {action1 , action2 , CCCallFunc:create(petEffect)} ) )
		end
	
		petEffect()
	end
	


	if data.cid then
		local petBtn = KNBtn:new( IMG_PATH.."image/pet/" , { data.cid .. ".png" } , 0 , 0 , {
--		 	text = {"绝对伤害值：" .. data.absolute , 18 , ccc3( 0x2c , 0x00 , 0x00 ) , { x = -5 , y = _isSelf and 70 or -65 } , nil , 17 },
		 	callback = function()
		 		infoLayer:new( _data , 2 )
		 	end
		 }):getLayer()
		content:addChild( petBtn )
		setAnchPos(petBtn , -70 , -90 , 0.5 , 0.5 )
	end

----------------------------------------------------------------------------------------------------------
--
--	刷新界面数据
--
	local function refreshData()
		local data = DATA_Battle:get( )["report"]["prepare"]["p1_pet"]
	end

----------------------------------------------------------------------------------------------------------
--
--	技能按钮处理
--
	local skillBtns = {}
	local bars = {}		--怒气值进度条
	local isSelf = _data.pet_id ~= 0	--是否是自己一方宠物
	local foeScale = 0.6		--敌方技能图标缩放
	local startY = isSelf and 60 or 110
	local startX = isSelf and 55 or -260
	local spaceX = isSelf and 95 or 60
	--宠物技能	
	for i = 1 , 3 do
		local skillX , skillY =  startX - 30 + i * spaceX , startY - 105
		if data.skills ~= nil and data.cid then
			--生成默认技能位
			local curSkillData = data.skills["a" .. i ]
			local maskImage
			if curSkillData then
				skillBtns[i] = petSkill:create( curSkillData , { id = i , refreshFun = refreshData , isSelf = _isSelf , x = skillX , y = skillY })
				setAnchPos( skillBtns[i] , skillX , skillY )
				skillBtns[i]:setDisabled( false )
				content:addChild( skillBtns[i] )
				
				
				if not isSelf then
					skillBtns[i]:setScale( foeScale )
					skillBtns[i]:setPosition( skillX  , skillY )
				end 
				
				--maskImage = display.newSprite( imagePath .. "skill_fore.png" )
			else
				maskImage = display.newSprite( imagePath .. "skill_fore_dis.png" )
				maskImage:setPosition( skillX , skillY )
				content:addChild(maskImage)
				
				if not isSelf then
					maskImage:setScale( foeScale )
				end 
			end 

		else
			local maskImage = display.newSprite( imagePath .. "skill_fore_dis.png" )
			maskImage:setPosition( skillX , skillY )
			content:addChild(maskImage)
			if not isSelf then
				maskImage:setScale( foeScale )
			end 
		end	

	end
	local config = requires(IMG_PATH,"GameLuaScript/Config/Petskill")
	
	for i = 1 , 3 do
		data.skills = data.skills or {}	
		local curData = data.skills["p" .. i ]
		local attribBtn
		if curData and data.cid  then
			local attrib = config[ curData.cid .. ""]["department"]
			attribBtn = KNBtn:new( imagePath .. "passivity/" , {attrib .. ".png"} , 0 , 0 ):getLayer()
		else
			attribBtn = KNBtn:new( imagePath .. "passivity/" , {"kong.png"} , 0 , 0 ):getLayer()
		end

		if _isSelf then
			setAnchPos( attribBtn , -105 + 40 * i , -98 , 0.5 , 0.5 )
		else
			setAnchPos( attribBtn , -102 + 40 * i , 45 , 0.5 , 0.5 )
		end
		content:addChild(attribBtn)
	end


	--设置是否显示努气值
	function content:isVisibleSp( isShow )
		if #bars ~= 0 then
			for i = 1 , #data.skills do
				bars[i]:setVisible( isShow )
				skillBtns[i]:setVisible( isShow )
			end
--			skillLogo:setVisible( isShow )
		end
	end

	--禁用幻兽操作
	function content:setDisabled()
		isDisabled = true
	end


	--获取按钮组
	function content:getSkillBtns()
		return skillBtns
	end
	--获取宠物数据
	function content:getData()
		return data
	end


	return content
end

return M
