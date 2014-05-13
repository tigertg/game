--[[

		替补英雄

]]--
local M = {}
local backHeros = { length = 0  , click_times = 0 , isHire = false }		--存放替补英雄
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
--[[获取对象]]
function M:get( group ,  index , instantIndex )
	if index == "replace" then
		local dieNum = backHeros[group].dieNum or 0
		for i = dieNum , 4 do
			index = i + instantIndex
			if backHeros[group][ index ] ~= nil then
				return  backHeros[group][ index ]
			end
		end
		return nil
	else
		index = tonumber( index )
		if backHeros[group] == nil or backHeros[group][index] == nil then return nil end
	end
	return backHeros[group][index]
end

--[[数据初始化 清空所有数据]]
function M:init( first )
	if first then backHeros = { length = 0  , click_times = 0 , isHire = false } end
	local temp_heros = {}
	for i = 1 , 2 do			-- 两方
		temp_heros[i] = {}
		for j = 0 , 3 do		-- 上阵4人
			if backHeros[i] ~= nil and backHeros[i][j] ~= nil then
				backHeros[i][j]:removeFromParentAndCleanup(true)
				backHeros[i][j] = nil
			end
			--初始化每组人员人数
			temp_heros[i][j] = nil
		end
	end

	backHeros = temp_heros
	backHeros.length = 0
	backHeros.click_times = 0
	backHeros.isHire = false
end
--返回对应组 替补英雄个数
function M:getBackHeroNum( _group )
	return backHeros[_group].length
end
--[[清空单个数据]]
function M:clear( group , index )
	index = tonumber( index )
	backHeros[group][index]:removeFromParentAndCleanup( true )
	
	backHeros[group][index] = nil
	--记录双方死亡人数
	if backHeros[group].dieNum then
		backHeros[group].dieNum = backHeros[group].dieNum + 1
	else
		backHeros[group].dieNum = 1
	end
	
	for i = 0 , 3 do
		if backHeros[group][i] ~= nil and type( backHeros[group][i] ) ~= "number" then
			local tempIndex = i - 1 - backHeros[group].dieNum
			transition.moveTo( backHeros[group][i] ,{ easing = "ELASTICIN" , delay = 0.2 * i , time = 0.3 , x = (group == 1 and ( 260 + tempIndex * 70 ) ) or ( 90 + tempIndex * 70 ) })
		end
	end

	--总替补人数减一
	backHeros.length = backHeros.length - 1
	if backHeros.length < 0 then
		backHeros.length = 0
	end
	--本组人员数减1
	backHeros[group].length = backHeros[group].length - 1
	if backHeros[group].length < 0 then
		backHeros[group].length = 0
	end
	return true
end

--生成复活对像
function M:initGroup( _group  )
	local group = _group
	for j = 0 , 3 do		-- 上阵4人
		if backHeros[group] ~= nil and backHeros[group][j] ~= nil then
			backHeros[group][j]:removeFromParentAndCleanup(true)
			backHeros[group][j] = nil
		end		
	end
	
	backHeros[group].dieNum = 0
	backHeros[group].length = 0
	
end
--是否显示换位按钮
function M:showDisseat( isShow , target )
	if backHeros.hit then
		backHeros.hit = false 
		return 
	end
	
	local length = 0
	for key , v in pairs( backHeros[1] ) do
		if type(v) ~= "number" then
			length = length + 1 
			v.disseatBtn:showBtn( isShow )
		end
	end
	
	if target then
		backHeros.replaceId = target
		backHeros[1][ target ].disseatBtn:showBtn( not isShow )
		backHeros.hit = true
		--单个武将不做处理
		if length > 1 then
			logic:pause( "showDisseat" )
		end
	else
		logic:resume( "showDisseat" )
	end
end

function M.new( data , param )
	if type( param ) ~= "table" then param = {} end
--	--替补人员总长度
	backHeros.length = backHeros.length + 1;
	
	local _data = data
	local hero_group = _data["_group"]
	local hero_index = _data["_index"]
	
	local isEnabled = false		--默认不响应点击操作
	local imagePath = IMG_PATH .. "image/scene/battle/"
	local cid = data.cid or data.npc_id
	

	local function backFun()
--		isEnabled = false
		if not isEnabled then
			return
		end
		M:showDisseat( true , hero_index )
	end
	local backHero = KNBtn:new(imagePath , { "backFrame.png" }  , 0 , 0 , { front = getImageByType(cid , "s") , frontScale = {1 , 0 , 3 } , callback = backFun}):getLayer()
	local frameSize = backHero:getContentSize()
----------------------------------------------------------------------------------------------------------------
--
-- 换位
--
	--请求换位
	local function askDisseat()
		logic:resume( "showDisseat" )
		logic:pause("socket")
		local battle_call_data = {
			report_id = DATA_Battle:get("report_id"),
			turn = logic:getActionTurn(),
			step = logic:getActionStep() - 1,		-- 因为lua里，step是从1开始的，后台step是从0开始的，所以要-1
			set_back = backHeros.replaceId..","..hero_index
		}
		SOCKET:getInstance("battle"):call(DATA_Battle:getMod() , DATA_Battle:getAct() .. "_process" , "process" , battle_call_data , {
			error_callback = function(err)
				KNMsg.getInstance():flashShow("[" .. err.code .. "]" .. err.msg)	-- 弹出错误文字提示
				logic:resume("socket")
			end,
			success_callback = param.refreshFun
		})

	end
	--换位按钮
	backHero.disseatBtn = KNBtn:new(IMG_PATH.."image/buttonUI/battle", {"disseat.png"} , 0 ,  frameSize.height - 8 , { scale = true })
--	backHero.disseatBtn = KNBtn:new(IMG_PATH.."image/buttonUI/battle", {"disseat.png"} , 0 ,  frameSize.height - 8 , { scale = true , callback = askDisseat})
	backHero:addChild(backHero.disseatBtn:getLayer())
	backHero.disseatBtn:showBtn( false )	--默认隐藏

	-- 存储数据
	if backHeros[hero_group] == nil then backHeros[hero_group] = {} end
	backHeros[hero_group][hero_index] = backHero
	--记录每一组替补人数
	if backHeros[hero_group].length == nil then 
		backHeros[hero_group].length = 1
	else
		backHeros[hero_group].length = backHeros[hero_group].length + 1
	end
	backHeros.replaceId = -1		--存放换位的第一个点击对像ID,默认存放无效数据
--------------------------------------------------------------------------------------------------------------------------
--
--	对外操作接口
--
	
--	local old_setPosition = backHero.setPosition
--	function backHero:setPosition(x , y)
--		old_setPosition(backHero , x , y)
--	end

	function backHero:getDieNum( group )
		return backHeros[group].dieNum or 0
	end
	
	--获取卡牌大小
	function backHero:getBackSize()
		return frameSize
	end
	--[[设置英雄数据]]
	function backHero:setData( key , value )
		_data[key] = value
	end

	--[[获取英雄数据]]
	function backHero:getData( key )
		if key ~= nil then return _data[key] end
		return _data
	end

	--是否响应点击操作
	function backHero:setEnabled( flag )
		isEnabled = flag
		isEnabled = false	--屏蔽换位按钮
	end
	--[[获取卡牌的位置和尺寸]]
	function backHero:getPositionAndSize()
		local hero_x , hero_y = backHero:getPosition()
		local hero_width = frameSize.width
		local hero_height = frameSize.height

		return {
			_x = hero_x,
			_y = hero_y,
			_cx = hero_x + hero_width / 2,
			_cy = hero_y + hero_height / 2,
			_width = hero_width,
			_height = hero_height,
		}
	end
	return backHeros[hero_group][hero_index]
end

return M
