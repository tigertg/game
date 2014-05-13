-- for CCLuaEngine
function __G__TRACKBACK__(errorMessage)
    CCLuaLog("----------------------------------------")
    CCLuaLog("LUA ERROR: "..tostring(errorMessage).."\n")
    CCLuaLog(debug.traceback("", 2))
    CCLuaLog("----------------------------------------")
end



-- 简单配置
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2
DEBUG_MEM_USAGE = 10	-- 显示内存使用
msg = ""
xpcall(function()
	-- 设置图片质量
	local cclog = function(...)
        print(string.format(...))
    end
    
    
	requires(IMG_PATH , "GameLuaScript/Config/base") 			-- 配置文件
	requires(IMG_PATH , "GameLuaScript/Config/conf") 			-- 配置文件

	requires(IMG_PATH , "GameLuaScript/Common/CommonFunction")

	-- 引入框架
	requires(IMG_PATH , "framework/init")
	requires(IMG_PATH , "framework/client/init")
	requires(IMG_PATH , "GameLuaScript/Config/channel")			-- 渠道号(一定要放在框架引入后面)


	-- 游戏入口 - 后续可以去掉很多
	requires(IMG_PATH , "GameLuaScript/Data/Session")
	requires(IMG_PATH , "GameLuaScript/Network/http")
	requires(IMG_PATH , "GameLuaScript/Network/socket")
	

	requires(IMG_PATH , "GameLuaScript/Common/CommonFunction")
	requires(IMG_PATH , "GameLuaScript/SwitchScene")


	-- 常用组件
	requires(IMG_PATH , "GameLuaScript/Common/KNButton")
	requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
	requires(IMG_PATH , "GameLuaScript/Common/KNMsg")
	requires(IMG_PATH , "GameLuaScript/Common/KNScrollView")

	-- 全局引导
	requires(IMG_PATH , "GameLuaScript/Common/KNGuide")
	--全局时钟
	requires(IMG_PATH , "GameLuaScript/Common/KNClock"):new()

	requires(IMG_PATH , "GameLuaScript/Common/KNFileManager")

	----------------
	-- 创建登录场景
	switchScene("login" , nil , function()
		if ERROR_CODE ~= nil and ERROR_CODE ~= 0 and ERROR_MSG ~= nil and ERROR_MSG ~= "" then
			KNMsg.getInstance():flashShow(ERROR_MSG)

			ERROR_MSG = ""
			ERROR_CODE = 0
		end
	end)

end, __G__TRACKBACK__)
