--[[

首页场景

]]


collectgarbage("setpause" , 100)
collectgarbage("setstepmul" , 5000)


-- [[ 包含各种 Layer ]]
local logicLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local bgLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/bgLayer")
local intoLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/intoAnimation")
local skipLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/skipLayer")
local M = {}
local bg
function M:create( param )
	local scene = display.newScene("battle")
	if type( param ) ~= "table" then param = {} end
	-- 战斗ID
	--[[
	local report_id = DATA_Battle:get("report_id")
	local win = DATA_Battle:get("win")
	]]
	
	audio.preloadSound(IMG_PATH .. "sound/atk.mp3")
	audio.preloadSound(IMG_PATH .. "sound/atk_skill.mp3")
	
	audio.preloadMusic(IMG_PATH .. "sound/battle_bg.mp3")
	
	audio.preloadMusic(IMG_PATH .. "sound/lose.mp3")
	audio.preloadMusic(IMG_PATH .. "sound/win.mp3")
	
	
	SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
	audio.playMusic( IMG_PATH .. "sound/battle_bg.mp3" , true )

	---------------插入layer---------------------
	bg = bgLayer:create()
	scene:addChild( bg )	-- 背景

	
	-- 战斗逻辑层 创建
	local function createLogic()
		scene:addChild( logicLayer:create( param ) )
	end
	--创建跳过按钮层
	local skip  =  skipLayer:create( param.battleType )
	
	--进场动画控制
	createLogic()
--	if param.intoAnimation then
--		scene:addChild( intoLayer:create( { showInfo = param.showInfo , animationOverCallFun = createLogic } ) )
--	else
--		createLogic()
--	end
	---------------------------------------------

	
	scene:addChild( skip )
	
	return scene
end
--四星五星技能控制层
function M:skillHide( isShow )
	bg:setVisible( isShow )
end
return M
