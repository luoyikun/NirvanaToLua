
-- 客户端命令
ClientCmdCtrl = ClientCmdCtrl or BaseClass(BaseController)

function ClientCmdCtrl:__init()
	if ClientCmdCtrl.Instance then
		print_error("[ClientCmdCtrl] Attempt to create singleton twice!")
		return
	end
	ClientCmdCtrl.Instance = self

	self.cmd_info_list = {}

	self.block_gameobj = nil
	self.block_info = {}
	self.is_show_pos = false
	self.is_shield_follow = false

	self:InitConsoleCmd()
end

function ClientCmdCtrl:__delete()
	ClientCmdCtrl.Instance = nil
end

function ClientCmdCtrl:Cmd(text)
	if nil == text or "" == text then
		return
	end

	local params = Split(text, " ")
	if nil == next(params) then
		return
	end

	local name = params[1]

	local cmd_info = self.cmd_info_list[name]
	if nil ~= cmd_info then
		table.remove(params, 1)
		cmd_info.func(params)
	end
end

function ClientCmdCtrl:RegCmdFunc(name, help, callback_func)
	self.cmd_info_list[name] = {desc = help, func = callback_func}
end

-- 初始化命令
function ClientCmdCtrl:InitConsoleCmd()
	self:RegCmdFunc("disconnect", "disconnect game server", BindTool.Bind1(self.OnDisconnect, self))
	self:RegCmdFunc("error", "error test", BindTool.Bind1(self.OnErrorTest, self))
	self:RegCmdFunc("block", "show block", BindTool.Bind1(self.OnBlock, self))
	self:RegCmdFunc("posblock", "show pos block", BindTool.Bind1(self.OnPosBlock, self))
	self:RegCmdFunc("show", "show info[pos]", BindTool.Bind1(self.OnShow, self))
	self:RegCmdFunc("exec", "execute lua", BindTool.Bind1(self.OnExecute, self))
	self:RegCmdFunc("test", "test", BindTool.Bind1(self.OnTest, self))
	self:RegCmdFunc("guide", "force guide", BindTool.Bind1(self.Guide, self))
	self:RegCmdFunc("gmlist", "gmlist [cmd_list_level]", BindTool.Bind1(self.GmCmdList, self))
	self:RegCmdFunc("pos", "show role pos [on/off]", BindTool.Bind1(self.ShowRolePos, self))
	self:RegCmdFunc("fly", "show role fly [on/off]", BindTool.Bind1(self.ShowRoleFly, self))
	self:RegCmdFunc("mem", "mem [on/off]", BindTool.Bind1(self.CalcMem, self))
	self:RegCmdFunc("clearmem", "clearmem", BindTool.Bind1(self.ClearMem, self))
	self:RegCmdFunc("camera", "name", BindTool.Bind1(self.MoveCamera, self))
	self:RegCmdFunc("lock", "name", BindTool.Bind1(self.OnLock, self))
	self:RegCmdFunc("count", "count", BindTool.Bind1(self.OnCount, self))
	self:RegCmdFunc("openview", "openview", BindTool.Bind1(self.OpenView, self))
	self:RegCmdFunc("openday", "openday", BindTool.Bind1(self.OpenDay, self))
	self:RegCmdFunc("npcdis", "npcdis [npc_id]", BindTool.Bind1(self.NpcDis, self))
	self:RegCmdFunc("addchat", "addchat [chat_num]", BindTool.Bind1(self.AddChat, self))
	self:RegCmdFunc("addsystem", "addsystem [num]", BindTool.Bind1(self.AddSystemMsg, self))
	self:RegCmdFunc("addsystem2", "addsystem [num]", BindTool.Bind1(self.AddSystemMsg2, self))
	self:RegCmdFunc("log", "log", BindTool.Bind1(self.OutputLog, self))
	self:RegCmdFunc("leak", "log", BindTool.Bind1(self.CheckLeak, self))
	self:RegCmdFunc("equipid", "equipid", BindTool.Bind1(self.OnEquipId, self))
	self:RegCmdFunc("assetpathmap", "assetpathmap", BindTool.Bind1(self.OutputAssetPathMap, self))
	self:RegCmdFunc("fightcamera", "open [on/off]", BindTool.Bind1(self.OnFightStateCamera, self))
	self:RegCmdFunc("fps", "open [on/off]", BindTool.Bind1(self.OnFps, self))
	self:RegCmdFunc("follow", "open [on/off]", BindTool.Bind1(self.OnFollow, self))
	self:RegCmdFunc("audit_task", "audit_task", BindTool.Bind1(self.OnAuditTask, self))
	self:RegCmdFunc("audit_use_skill", "audit_use_skill", BindTool.Bind1(self.OnAuditUseSkill, self))
end

function ClientCmdCtrl:OnAuditTask(params)
	if params[1] then
		local task_id = tonumber(params[1]) or 0
		local task_status = TaskData.Instance:GetTaskStatus(task_id)
		local progress_num 
		local task_info = TaskData.Instance:GetTaskInfo(task_id)
		if task_info then
			progress_num = task_info.progress_num
		end
		local task_data = MainUIViewTask.TaskCellInfo(task_id, task_status, progress_num)
		MainUICtrl.Instance:FlushView("audit_task", {task_data})
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.NotUseOperate)
	end
end

function ClientCmdCtrl:OnAuditUseSkill(params)
	if params[1] then
		local skill_index = tonumber(params[1]) or 0
		MainUICtrl.Instance:FlushView("audit_use_skill", {skill_index})
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Task.NotUseOperate)
	end
end


function ClientCmdCtrl:OnDisconnect(params)
	GameNet.Instance:DisconnectGameServer()
end

function ClientCmdCtrl:OnErrorTest(params)
	a.b = 0
end

function ClientCmdCtrl:Guide(params)
	FunctionGuide.Instance:TriggerGuideById(params[1])
end

function ClientCmdCtrl:OnBlock(params)
	if params[1] == "off" then
		if nil ~= self.block_gameobj then
			ResMgr:Destroy(self.block_gameobj)
			self.block_gameobj = nil
		end
	else
		if nil ~= self.block_gameobj then
			ResMgr:Destroy(self.block_gameobj)
		end

		self.block_gameobj = GameObject.New()

		for y = 0, GridFindWay.Height - 1 do
			local begin_i, end_i = -1, -1
			local is_block = true
			for x = 0, GridFindWay.Width - 1 do
				is_block = GridFindWay:IsBlock(x, y)
				if is_block then
					if begin_i < 0 then begin_i = x end
					end_i = x
				end

				if begin_i >= 0 and end_i >= begin_i and (x == GridFindWay.Width - 1 or not is_block) then
					local pos_x, pos_y = GameMapHelper.LogicToWorld(begin_i + (end_i - begin_i) / 2, y)
					local scale_x = (end_i - begin_i + 1) / 2

					local obj = GameObject.CreatePrimitive(UnityEngine.PrimitiveType.Cube)
					local obj_transform = obj.transform
					obj_transform:SetParent(self.block_gameobj.transform)
					obj_transform:SetPosition(pos_x, -3, pos_y)
					obj_transform:SetLocalScale(scale_x, 8, 0.5)
					begin_i = -1
				end
			end
		end
	end
end

function ClientCmdCtrl:OnPosBlock(params)
	if params[5] and "" ~= params[5] then
		ResMgr:Destroy(self.block_gameobj)
		self.block_gameobj = nil
		for k,v in pairs(self.block_info) do
			AStarFindWay:RevertBlockInfo(v[1], v[2])
		end
		self.block_info = {}
		return
	end
	if not self.block_gameobj then
		self.block_gameobj = GameObject.New()
	end

	-- local start_pos_x, start_pos_y = 543, 167
	-- local end_pos_x, end_pos_y = 560, 163
	local cube_height = 0
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		cube_height = main_role:GetRoot().transform.position.y
	end

	local start_pos_x = params[1]
	local start_pos_y = params[2]
	local end_pos_x = params[3]
	local end_pos_y = params[4]

	local i_min, i_max = math.min(start_pos_x, end_pos_x), math.max(start_pos_x, end_pos_x)
	local j_min, j_max = math.min(end_pos_y, start_pos_y), math.max(end_pos_y, start_pos_y)

	for i = i_min, i_max do
		for j = j_min, j_max do
			local obj = GameObject.CreatePrimitive(UnityEngine.PrimitiveType.Cube)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.block_gameobj.transform)
			local w_pos_x, w_pos_y = GameMapHelper.LogicToWorld(i, j)
			obj_transform:SetPosition(w_pos_x, cube_height, w_pos_y)
			AStarFindWay:SetBlockInfo(i, j)
			table.insert(self.block_info, {i, j})
			obj_transform:SetLocalScale(1, 40, 1)
		end
	end


	-- width, height = 29, 2
	-- pos_x, pos_y = 250, 351
	-- w_pos_x, w_pos_y = GameMapHelper.LogicToWorld(pos_x, pos_y)
	-- for i = 1, width do
	-- 	for j = 1, height do
	-- 		local obj = GameObject.CreatePrimitive(UnityEngine.PrimitiveType.Cube)
	-- 		local obj_transform = obj.transform
	-- 		obj_transform:SetParent(self.block_gameobj.transform)
	-- 		obj_transform:SetPosition(w_pos_x + i, 330, w_pos_y + j)
	-- 		obj_transform:SetLocalScale(1, 40, 1)
	-- 	end
	-- end
	
	-- local x, y = main_role:GetLogicPos()
	-- if GameMath.IsInRect(x, y, pos_x, pos_y, width, height) then
	-- 	if on_off then
	-- 		for k, v in pairs(self.block_shield_area) do
	-- 			AStarFindWay:SetBlockInfo(v.x, v.y, 2)
	-- 		end
	-- 	else
	-- 		if nil ~= self.block_gameobj then
	-- 			ResMgr:Destroy(self.block_gameobj)
	-- 			self.block_gameobj = nil
	-- 		end
	-- 		-- AStarFindWay:RevertBlockInfo(v.x, v.y)
	-- 	end
	-- end
end

function ClientCmdCtrl:OnShow(params)
	if "pos" == params[1] then
		for k,v in pairs(Scene.Instance:GetObjList()) do
			print_log("====", v:GetName(), v:GetLogicPos())
		end
	end
end

function ClientCmdCtrl:OnExecute(fd, str)
	_G.package.loaded["game.clientcmd.client_cmd_script"] = nil
	require("game.clientcmd.client_cmd_script")
end

function ClientCmdCtrl:OnTest(params)
	print_log("test:", Join(params, " "))
	if params and params[1] == "budget" then
		RenderBudget.Instance:SetBudget(tonumber(params[2]))
	end
	if params and params[1] == "fps" then
		SettingData.Instance:FpsCallBack(tonumber(params[2]))
	end
	for k,v in pairs(params) do
		if v == "mijing" then
			GuildMijingCtrl.SendGuildFbStartReq()
		elseif v == "entermijing" then
			GuildMijingCtrl.SendGuildFbEnterReq()
		elseif v =="gh" then
			GuildBonfireCtrl.SendGuildBonfireStartReq()
		elseif v =="gh2" then
			GuildBonfireCtrl.SendGuildBonfireGotoReq()
		elseif v == "story1" then
			FuBenCtrl.Instance:SendEnterFBReq(5, 1)
		elseif v == "story2" then
			FuBenCtrl.Instance:SendEnterFBReq(5, 2)
		elseif v == "story3" then
			FuBenCtrl.Instance:SendEnterFBReq(5, 3)
		elseif v == "guide1" then	-- 运镖引导
			FuBenCtrl.Instance:SendEnterFBReq(21, 710)
		elseif v == "guide2" then 	-- 攻城战
			FuBenCtrl.Instance:SendEnterFBReq(21, 740)
		elseif v == "guide3" then	-- 抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 770)
		elseif v == "guide4" then	-- 被抢BOSS
			FuBenCtrl.Instance:SendEnterFBReq(21, 900)
		elseif v == "guide5" then	-- 水晶幻境
			FuBenCtrl.Instance:SendEnterFBReq(21, 820)
		elseif v == "p" then	-- 水晶幻境
			ViewManager.Instance:Open(ViewName.Player)
		elseif v == "daily1" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4601)
		elseif v == "daily2" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4602)
		elseif v == "daily3" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4603)
		elseif v == "daily4" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4604)
		elseif v == "daily5" then	-- 日常任务副本
			FuBenCtrl.Instance:SendEnterFBReq(24, 4605)
		end
	end


end

-- GM命令List表
local gm_list = {};

-- 成为低级菜鸟命令
local dijicainiao_gm_list =
{
	{"changegongji", "1435"},
	{"changemaxhp", "30249"},
	{"changefangyu", "690"},
	{"changemingzhong", "551"},
	{"changeshanbi", "327"},
	{"changebaoji", "1321"},
	{"changejianren", "2647"},
	{"setrolelevel", "40"},
	{"jumptotrunk", "840"},
	{"setrolelevel", "40"}

}
gm_list["1"] = dijicainiao_gm_list;

-- 成为高级菜鸟命令
local gaojicainiao_gm_list =
{
	{"changegongji", "2061"},
	{"changemaxhp", "43000"},
	{"changefangyu", "1082"},
	{"changemingzhong", "870"},
	{"changeshanbi", "517"},
	{"changebaoji", "1850"},
	{"changejianren", "3772"},
	{"setrolelevel", "42"},
	{"jumptotrunk", "890"},
	{"setrolelevel", "42"}
}
gm_list["2"] = gaojicainiao_gm_list;

-- 成为低级高手命令
local dijigaoshou_gm_list =
{
	{"changegongji", "4123"},
	{"changemaxhp", "86121"},
	{"changefangyu", "2623"},
	{"changemingzhong", "2001"},
	{"changeshanbi", "1196"},
	{"changebaoji", "3159"},
	{"changejianren", "7264"},
	{"setrolelevel", "55"},
	{"jumptotrunk", "1230"},
	{"setrolelevel", "55"}
}
gm_list["3"] = dijigaoshou_gm_list;

-- 成为高级级高手命令
local gaojigaoshou_gm_list =
{
	{"addchongzhi", "999999"},
	{"setrolelevel", "998"},
	{"jumptotrunk", "3300"},
}
gm_list["4"] = gaojigaoshou_gm_list;

-- 成为高级级高手命令
local wudi_gm_list =
{
	{"changegongji", "99999999"},
	{"changemaxhp", "99999999"},
	{"addchongzhi", "999999"},
	{"setrolelevel", "998"},
	{"jumptotrunk", "1880"},
}
gm_list["5"] = wudi_gm_list;

function ClientCmdCtrl:GmCmdList(params)
	for k,v in pairs(params) do
		if nil == gm_list[v] then
			return
		end

		for i, v1 in ipairs(gm_list[v]) do
			SysMsgCtrl.SendGmCommand(v1[1], v1[2])
		end
	end

end

function ClientCmdCtrl:ShowRolePos(params)
	local on_off = "on" == params[1] and true or false
	self.is_show_pos = on_off
end

function ClientCmdCtrl:ShowRoleFly(params)
	local on_off = "on" == params[1] and true or false
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		if on_off then
			main_role:StartFlyingUp()
		else
			main_role:StartFlyingDown()
		end
	end
end

local calc_mem_timer = nil
function ClientCmdCtrl:CalcMem(params)
	if "on" == params[1] then
		local t = {
			res_count = 0,  				-- 资源数
			res_pool_count = 0,				-- 资源池
			gameobj_cache_count = 0,		-- 池GO
			gameobj_pool_count = 0,			-- GO池数
			gameobj_count = 0,				-- GO数
			time_quest_count = 0,			---定时器个数
			itemlist_change_count = 0,		-- 物品监听数量1
			item_change_count = 0,			-- 物品监听数量2
			attr_listen_count = 0,			-- 属性监听数量
			event_count = 0,				-- 事件监听数量
			lua_obj_count = 0				-- lua对象数量
		}

		calc_mem_timer = GlobalTimerQuest:AddRunQuest(function()
			ResPoolMgr:GetPoolDebugInfo(t)
			ResMgr:GetDebugGameObjCount(t)
			GlobalTimerQuest:GetQuestCount(t)
			ItemData.Instance:GetDebugNotifyChangeCount(t)
			PlayerData.Instance:GetDeubgListenCount(t)
			GlobalEventSystem:GetDebugEventCount(t)
			BundleCache:GetBundleCount(t)
			GetDebugLuaObjCount(t)

			if not self.attr_text then
				local async_loader = AllocAsyncLoader(self, "AssertAttrContent")
				async_loader:SetIsUseObjPool(true)
				async_loader:Load("uis/views/commonwidgets_prefab", "AssertAttrContent", function(obj)
					if IsNil(obj) then
						async_loader:Destroy()
						return
					end

					local UIRoot = GameObject.Find("GameRoot/UILayer").transform
					if UIRoot then
						local obj_transform = obj.transform
						obj_transform:SetParent(UIRoot, false)
						obj_transform:SetAsLastSibling()
						self.attr_text = obj_transform:Find("AttrText").gameObject:GetComponent(typeof(UnityEngine.UI.Text))
					else
						async_loader:Destroy()
					end
				end)
			end

			local str_attr = "\n资源数量: " .. t.res_count .. "\n\n资源池: " .. t.res_pool_count .. "\n\nGO池: " .. t.gameobj_cache_count
				.. "\n\n池中GO数量: " .. t.gameobj_pool_count .. "\n\nGO数: " .. t.gameobj_count .. "\n\n定时器个数: " .. t.time_quest_count 
				.. "\n\nbunlde数量: " .. t.bundle_count .. "\n\n物品监听数量: " .. t.item_change_count .. "\n\n属性监听数量: " .. t.attr_listen_count
				.. "\n\n事件监听数量: " .. t.event_count .. "\n\nlua对象数量: " .. t.lua_obj_count
			if self.attr_text and self.attr_text.text then
				self.attr_text.text = str_attr
			end
		end, 0.5)
	elseif "off" == params[1] then
		if nil ~= calc_mem_timer then
			GlobalTimerQuest:CancelQuest(calc_mem_timer)
		end

		if self.attr_text then
			ResMgr:Destroy(self.attr_text.gameObject.transform.parent.gameObject)
			self.attr_text = nil
		end
	end
end

function ClientCmdCtrl:ClearMem()
	ResPoolMgr:Clear()
end

function ClientCmdCtrl:MoveCamera(params)
	Camera.Instance:MoveInName(params[1])
end

function ClientCmdCtrl:OnLock(params)
	SettingCtrl.Instance:GmOpenUnLockView()
end

function ClientCmdCtrl:OnCount(params)
	MainUICtrl.Instance:CreateMainCollectgarbageText()
end

function ClientCmdCtrl:OpenView(params)
	--local on_off = "on" == params[1] and true or false

	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:GetFollowUi():ChangeBubble(params[1], params[2])
	end
end

function ClientCmdCtrl:OpenDay(params)
	SysMsgCtrl.Instance:ErrorRemind("当前渠道:" .. GLOBAL_CONFIG.package_info.config.agent_id 
		.. "\n 当前开服天数:" .. TimeCtrl.Instance:GetCurOpenServerDay())
end

function ClientCmdCtrl:NpcDis(params)
	local npc_id = tonumber(params[1]) or 0
	if npc_id <= 0 then
		return
	end
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	if not npc_obj then
		print_error("can no find npc id:" .. npc_id)
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		local logic_x, logic_y = main_role:GetLogicPos()
		local dis = npc_obj:RoleDistance(logic_x, logic_y)
		print_error("npc distance role --- " .. dis)
	end
end

function ClientCmdCtrl:AddChat(params)
	if params[1] ~= nil and params[1] ~= "" then
		local num = tonumber(params[1])
		if num ~= nil and num > 0 then
			for i = 1, num do
				local chat = {}
				local role = GameVoManager.Instance:GetMainRoleVo()
				chat.from_uid = role.role_id								
				chat.username = role.name .. "->text" .. i
				chat.sex = 0
				chat.camp = 1
				chat.prof = 1
				chat.authority_type = 0
				chat.content_type = 0
				chat.tuhaojin_color = 0						
				chat.bigchatface_status = 0				
				chat.personalize_window_bubble_type = 0
				chat.avatar_key_big = 0
				chat.avatar_key_small = 0

				chat.personalize_window_avatar_type = 0

				chat.level = role.level
				chat.vip_level = 0
				chat.channel_type = CHANNEL_TYPE.WORLD
				chat.guild_signin_count = 0
				chat.is_msg_record = 0
				chat.use_head_frame = 0
				chat.msg_timestamp = TimeCtrl.Instance:GetServerTime()
				chat.msg_length = 0
				chat.content = "聊天测试----->" .. i

				ChatCtrl.Instance:OnChannelChat(chat)
			end
		end
	end
end

function ClientCmdCtrl:AddSystemMsg(params)
	if params[1] ~= nil and params[1] ~= "" then
		local num = tonumber(params[1])
		local msg_type = tonumber(params[2])
		if num ~= nil and num > 0 then
			for i = 1, num do
				local cmd = SCSystemMsg.New()
				cmd.send_time = 1540405388
				cmd.msg_type = msg_type or SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE
				cmd.msg_length = 157
				cmd.display_pos = 0
				cmd.color = 0

				cmd.content = string.format("{showpos;2} 惊闻一声天雷，{r;1051387;郎晓啸;3} 的坐骑成功进阶至{mount;41}，战斗力直线飙升，来顶礼膜拜吧%s！{openLink;4}", math.random(1, 1000000))
				ChatCtrl.Instance:OnSystemMsg(cmd)

				--cmd.msg_type = SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_WORLD
				ChatCtrl.Instance:OnSystemMsg(cmd)
			end
		end
	end
end

function ClientCmdCtrl:AddSystemMsg2(params)
	if params[1] ~= nil and params[1] ~= "" then
		local num = tonumber(params[1])
		if num ~= nil and num > 0 then
			for i = 1, num do
				local cmd = SCSystemMsg.New()
				cmd.send_time = 1540405388
				cmd.msg_type = SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE
				cmd.msg_length = 157
				cmd.display_pos = 0
				cmd.color = 0

				-- cmd.content = " 惊闻一声天雷的坐骑成功进阶至战斗力直线飙升"
				cmd.content = "恭喜{r;1065026;晏心怡;0}在战魂寻宝十次中获得{i;23361}{openLink;71}"
				ChatCtrl.Instance:OnSystemMsg(cmd)

				cmd.msg_type = SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_WORLD
				ChatCtrl.Instance:OnSystemMsg(cmd)
			end
		end
	end
end

function ClientCmdCtrl:OutputLog(params)
	ResUtil.OutputLog()
end

function ClientCmdCtrl:CheckLeak(params)
	-- ResPoolMgr:Clear()
	BundleCache:CheckAsetBundleLeak()
	BundleCache:CheckAsetBundleDetailLeak()
	ResPoolMgr:CheckLeak()
end

-- 功能做完会删掉
function ClientCmdCtrl:OnEquipId(params)
	if params[2] and tonumber(params[2]) <= 8 then
		if tonumber(params[1]) == 1 then
			local equip_collect_cfg = SuitCollectionData.Instance:GetOrangeCollectEquipCfg(tonumber(params[2]))
			local equip_id_tab = Split(equip_collect_cfg.equip_items, "|")
			for k, v in pairs(equip_id_tab) do
				SysMsgCtrl.SendGmCommand("additem", v .. " 1 1")
			end
		elseif tonumber(params[1]) == 2 then
			local equip_collect_cfg = SuitCollectionData.Instance:GetRedCollectEquipCfg(tonumber(params[2]))
			local equip_id_tab = Split(equip_collect_cfg.equip_items, "|")
			for k, v in pairs(equip_id_tab) do
				SysMsgCtrl.SendGmCommand("additem", v .. " 1 1")
			end
		end
	end
end

function ClientCmdCtrl:OutputAssetPathMap(params)
	EditorResourceMgr.OutputAssetPathMap()
end

function ClientCmdCtrl:OnFightStateCamera(params)
	local on_off = "on" == params[1] and true or false
	FIGHTSTATE_CAMERA = on_off
end

function ClientCmdCtrl:OnFps(params)
	local on_off = "on" == params[1] and true or false
	GameObject.Find("GameRoot/UILayer/FPSControl"):GetComponent(typeof(ShowFPS)).SetSwich(on_off)
end

function ClientCmdCtrl:OnFollow(params)
	local on_off = "on" == params[1] and true or false

	self.is_shield_follow = on_off
	SceneData.Instance:IsShieldRoleFollowAndShadow(self.is_shield_follow)

	local role_list = Scene.Instance:GetRoleList()
	for k ,v in pairs(role_list) do
		v.is_shield_role_shadow = self.is_shield_follow
		v:UpdateShadowByQuality()

		local follow_ui = v:GetFollowUi()
		if follow_ui then
			if self.is_shield_follow then
				follow_ui:Hide()
			else
				follow_ui:Show()
			end
		end
	end
end