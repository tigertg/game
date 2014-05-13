--[[

通用数据存储

]]

--[[包含所有 DATA]]
local _datas = {
	"Session",
	"User",
	"Chat",
	"Account",
	"General",
	"Formation",
	"Battle",
	"Power",
	"Energy",
	"Mission",
	"Instance",
	"Wash",
	"Bag",
	"Pet",
	"Equip",
	-- "UpdataData",
	"Hatch",
	"Shop",
	"RoleSkillEquip",
	"Result",
	"PetSkillDress",
	"Martial",
	"PetSkillDress",
	"Pulse",
	"Uplevel",
	"StoneList",
	"ExpConfig",
	"Uplevel",
	"IdType",
	"Rank",
	"Info",
	"Olgift",
	"Guide",
	"OtherPlay",
	"Incubation",
	"pulseTisp",
	"Activity",
	"Notice",
	"Gang",
	"Vip",
	"Friend"
}

for i = 1 , #_datas do
	requires(IMG_PATH , "GameLuaScript/Data/" .. _datas[i])
end


local M = {}

--[[初始化]]
function M.init()
	for i = 1 , #_datas do
		requires(IMG_PATH , "GameLuaScript/Data/" .. _datas[i]):init()
	end
end

--[[处理公用数据]]
function M.saveCommonData( data )
	local result = data["result"]
	if type(result) ~= "table" then return false end
	--dump(result["_G_general_stage_conf"])
	-- 存储数据
	if isset(result , "_G_userinfo")           then DATA_User:set( result["_G_userinfo"] )                                end
	if isset(result , "_G_account")            then DATA_Account:set( result["_G_account"] )                              end
	if isset(result , "_G_power")              then DATA_Power:set( result["_G_power"] )                                  end
	if isset(result , "_G_energy")             then DATA_Energy:set( result["_G_energy"] )                                end
	if isset(result , "_G_formation")          then DATA_Formation:set(result["_G_formation"])                            end
	if isset(result , "_G_formation_conf")     then DATA_Formation:setConf(result["_G_formation_conf"])                   end
	if isset(result , "_G_bag_equip")          then DATA_Bag:set("equip",result["_G_bag_equip"])                          end
	if isset(result , "_G_bag_skill")          then DATA_Bag:set("skill",result["_G_bag_skill"])                          end
	if isset(result , "_G_bag_pet")            then DATA_Bag:set("pet",result["_G_bag_pet"])                              end
	if isset(result , "_G_bag_prop")           then DATA_Bag:set("prop",result["_G_bag_prop"])                            end
	if isset(result , "_G_bag_general")        then DATA_Bag:set("general",result["_G_bag_general"])                      end
	if isset(result , "_G_pet_on")             then DATA_Pet:setFighting(result["_G_pet_on"])                             end
	if isset(result , "_G_general_dress")      then DATA_ROLE_SKILL_EQUIP:set(result["_G_general_dress"])                 end
	if isset(result , "_G_pet_dress")          then DATA_PetSkillDress:set(result["_G_pet_dress"])                        end
	if isset(result , "_G_martial")            then DATA_Martial:set(result["_G_martial"])                                end
	if isset(result , "_U_bag")                then updateBagInfo("_U_bag",result["_U_bag"])                              end
	if isset(result , "_D_bag")                then updateBagInfo("_D_bag",result["_D_bag"])                              end
	if isset(result , "_G_id_type")            then DATA_IDTYPE:set(result["_G_id_type"])                     				end
	if isset(result , "_G_ranking_level")      then DATA_Rank:setKey("level",result["_G_ranking_level"]) end
	if isset(result , "_G_ranking_athletics")  then DATA_Rank:setKey("athletics",result["_G_ranking_athletics"]) end
	if isset(result , "_G_ranking_ability")    then DATA_Rank:setKey("ability",result["_G_ranking_ability"]) end
	if isset(result , "_G_message_talk")       then DATA_Info:set_type("_G_message_talk",result["_G_message_talk"]) end
	if isset(result , "_G_message_system")     then DATA_Info:set_type("_G_message_system",result["_G_message_system"]) end
	if isset(result , "_G_message_battle")     then DATA_Info:set_type("_G_message_battle",result["_G_message_battle"]) end
	if isset(result , "_G_message_broadcast")  then DATA_Info:set_type("_G_message_broadcast",result["_G_message_broadcast"]) end
	if isset(result , "_G_olgift")             then DATA_Olgift:set_type("olgift" , result["_G_olgift"] ) end
	if isset(result , "_G_fame")               then DATA_User:set_fame( result["_G_fame"] ) end
	if isset(result , "_G_wash_max_percent")   then DATA_User:set_percent( result["_G_wash_max_percent"] ) end
	if isset(result , "_G_mission_cur")        then DATA_Guide:setStep( result["_G_mission_cur"] ) end
	if isset(result , "_G_hatch_fee")          then DATA_Incubation:set( result["_G_hatch_fee"] ) end
	if isset(result , "_G_pulse_conf")         then DATA_PulseTisp:set( result["_G_pulse_conf"] ) end
	if isset(result , "_G_skillexpback")       then DATA_Bag:set_skillexp(result["_G_skillexpback"]) end
	if isset(result , "_T_updatetip")      	   then DATA_Notice:set(result["_T_updatetip"]) end
	if isset(result , "_G_loginaward_tip")     then DATA_Notice:setGetNum( result["_G_loginaward_tip"] ) end	--设置当前可领取奖励个数
	if isset(result , "_G_msgcount")      	   then DATA_Chat:initNum(result["_G_msgcount"]) end
	if isset(result , "_G_viplv")			   then DATA_Vip:set_type( "viplv" , result["_G_viplv"] ) end		--只有一个vip等级
	if isset(result , "_G_vipinfo")			   then DATA_Vip:set_type( "vipinfo" , result["_G_vipinfo"] ) end		--只有一个vip等级

	return true
end


return M
