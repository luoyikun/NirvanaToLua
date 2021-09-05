GuildBossView = GuildBossView or BaseClass(BaseView)

local boss_id = {
	[203] = {Vector3(1, 1, 1), Vector3(0, -0.7, 0)},
	[204] = {Vector3(0.7, 0.7, 0.7), Vector3(0, 0, 0)},
	[205] = {Vector3(1, 1, 1), Vector3(0, -0.3, 0)},
	[207] = {Vector3(1, 1, 1), Vector3(0, -0.3, 0)},
	[208] = {Vector3(0.8, 0.8, 0.8), Vector3(0, 0, 0)},
	[209] = {Vector3(0.7, 0.7, 0.7), Vector3(0, 0, 0)},

}
function GuildBossView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/guildview_prefab", "GuildBossView"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GuildBossView:__delete()

end

function GuildBossView:LoadCallBack()
	self.item_cells = {}
	for i = 1, 6 do
		self.item_cells[i] = {}
		self.item_cells[i].obj = self.node_list["ItemCell" .. i]
		self.item_cells[i].cell = ItemCell.New()
		self.item_cells[i].cell:SetInstanceParent(self.item_cells[i].obj)
	end

	self.node_list["BtnNormalSummon"].button:AddClickListener(BindTool.Bind(self.Call, self))
	self.node_list["BtnSpecialSummon"].button:AddClickListener(BindTool.Bind(self.SurperCall, self))
	self.node_list["ButtonFeed"].button:AddClickListener(BindTool.Bind(self.Feed, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["TitleText"].text.text = Language.Title.LingShou

	self.last_boss_resid = 0
	self.last_boss_resid2 = 0
	self.MaxLevel = false
	self.HasCalled = false

	local event_trigger = self.node_list["RotateEventTrigger1"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragNormal, self))

	local event_trigger = self.node_list["RotateEventTrigger2"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSpecial, self))

	local config = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GUILD_BOSS)
	if config then
		local str = Language.Common.Week
		local time = ""
		local open_day_list = Split(config.open_day, ":")
		if open_day_list then
			for i = 1, #open_day_list do
				local day = tonumber(open_day_list[i])
				day = Language.Common.DayToChs[day]
				str = str .. day
				if i ~= #open_day_list then
					str = str .. "、"
				end
			end
			str = str
			time = config.open_time .. "-" .. config.end_time
		end

		self.node_list["ActivityTime"].text.text = string.format(Language.Guild.BossTime, str, time)
	end
end

function GuildBossView:FlushRewardIcon(index, item)
	local feed_id = GuildData.Instance:GetBossFeedItemId()
	if item then
		if self.item_cells[index].cell then
			self.item_cells[index].cell:SetData(item)
		end
	end
end

function GuildBossView:OnRoleDragNormal(data)
	if self.boss_model then
		self.boss_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function GuildBossView:OnRoleDragSpecial(data)
	if self.boss_model2 then
		self.boss_model2:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function GuildBossView:ReleaseCallBack()
	if self.boss_model then
		self.boss_model:DeleteMe()
		self.boss_model = nil
	end
	if self.boss_model2 then
		self.boss_model2:DeleteMe()
		self.boss_model2 = nil
	end
	self.last_boss_resid = 0
	self.last_boss_resid2 = 0

	for k,v in pairs(self.item_cells) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cells = {}

	-- 清理变量和对象
	self.boss_display = nil
	self.boss_display2 = nil

end

function GuildBossView:OpenCallBack()
	GuildCtrl.Instance:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ)
	self:Flush()
end

function GuildBossView:OnFlush()
	local feed_id = GuildData.Instance:GetBossFeedItemId()
	local number = 0
	if feed_id then
		number = ItemData.Instance:GetItemNumInBagById(feed_id)

		self.node_list["FeedCount"].text.text = string.format(Language.Guild.HasShouLingDan, number)
	end

	local boss_info = GuildData.Instance:GetBossInfo()
	if boss_info then
		local boss_super_call_name = boss_info.boss_super_call_name
		if boss_super_call_name == nil or boss_super_call_name == "" then
			boss_super_call_name = Language.Common.ZanWu
		end

		self.node_list["PlayerName"].text.text = boss_super_call_name
		if boss_info.boss_normal_call_count > 0 then
			self.HasCalled = true
			UI:SetButtonEnabled(self.node_list["BtnNormalSummon"], false)
			self.node_list["TextSummon"].text.text = Language.Guild.CallEndTxt
			UI:SetButtonEnabled(self.node_list["ButtonFeed"], (not self.MaxLevel) and false)
		else
			self.HasCalled = false
			UI:SetButtonEnabled(self.node_list["BtnNormalSummon"], true)
			self.node_list["TextSummon"].text.text = Language.Guild.CallTxt
			UI:SetButtonEnabled(self.node_list["ButtonFeed"], (not self.MaxLevel) and true)
		end
		if boss_info.boss_super_call_count > 0 then

			UI:SetButtonEnabled(self.node_list["BtnSpecialSummon"], false)
			self.node_list["TextSummon2"].text.text = Language.Guild.CallEndTxt

		else

			UI:SetButtonEnabled(self.node_list["BtnSpecialSummon"], true)
			self.node_list["TextSummon2"].text.text = Language.Guild.SurperCallTxt


		end
		local boss_config = GuildData.Instance:GetGuildActiveConfig()
		if boss_config then
			local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list

			self.node_list["TextCost"].text.text = boss_config.other[1].boss_super_call_gold
			boss_config = boss_config.boss_cfg
			-- local next_config = boss_config[boss_info.boss_level + 2]		
			local config = boss_config[boss_info.boss_level]

			if monster_cfg then
				local temp_config = monster_cfg[config.boss_id]
				if temp_config then
					local superbossname = temp_config.name
					local supername = Split(temp_config.name, "·")
					local name = supername[2]

					self.node_list["ButtonText"].text.text = string.format(Language.Guild.NormalBoss, CommonDataManager.GetDaXie(boss_info.boss_level), name)
				end	
			end
			-- self.node_list["ButtonText"].text.text = string.format(Language.Guild.NormalBoss, CommonDataManager.GetDaXie(boss_info.boss_level))
			self.node_list["RedPointFeed"]:SetActive(false)
			local next_config = boss_config[boss_info.boss_level + 2]
			if next_config then
				if number > 0 and boss_info.boss_normal_call_count <= 0 then
					self.node_list["RedPointFeed"]:SetActive(true)
				end
				self.MaxLevel = false
				self.node_list["ExpBar"]:SetActive(not false)
				self.node_list["TextExp"]:SetActive(not false)
				UI:SetButtonEnabled(self.node_list["ButtonFeed"], true and (not self.HasCalled))
				self.node_list["TextMaxLevel"]:SetActive(false)
			else
				self.MaxLevel = true
				self.node_list["ExpBar"]:SetActive(not true)
				self.node_list["TextExp"]:SetActive(not true)
				UI:SetButtonEnabled(self.node_list["ButtonFeed"], false and (not self.HasCalled))
				self.node_list["TextMaxLevel"]:SetActive(true)
			end

			
			-- self.node_list["TextNextLevl"].text.text = string.format(Language.Guild.SurperBoss, CommonDataManager.GetDaXie(boss_info.boss_level + 1))
			-- local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
			-- local config = boss_config[boss_info.boss_level]
			local config2 = boss_config[boss_info.boss_level + 1]
			if monster_cfg and config2 then
				local temp_config = monster_cfg[config2.boss_id]
				if temp_config then
					local superbossname = temp_config.name
					local supername = Split(temp_config.name, "·")
					local name = supername[2]
					self.node_list["TextNextLevl"].text.text = string.format(Language.Guild.SurperBoss, CommonDataManager.GetDaXie(boss_info.boss_level + 1), name)
				end
				
			end

			if config then
				if monster_cfg then
					local temp_config = monster_cfg[config.boss_id]
					if temp_config then
						self:FlushBossModel(temp_config)
					end
				end
				self.node_list["TextExp"].text.text = boss_info.boss_exp .. "/" .. config.uplevel_exp
				local value = boss_info.boss_exp / config.uplevel_exp
				value = value > 1 and 1 or value
				
				self.node_list["ExpBar"].slider.value = value
				self:FlushRewardIcon(6, config.normal_item_reward)
				self:FlushRewardIcon(5, {item_id = ResPath.CurrencyToIconId.bind_diamond, num = 1})
				
			end
			-- local config2 = boss_config[boss_info.boss_level + 1]
			if config2 then
				if monster_cfg then
					local temp_config = monster_cfg[config2.boss_id]
					if temp_config then
						self:FlushSurperBossModel(temp_config)
					end
				end
				for i = 3, 4 do
					self.item_cells[i].obj:SetActive(false)
				end
				self.item_cells[1].cell:SetData({item_id = ResPath.CurrencyToIconId.bind_diamond, num = 1})
				local reward = config2.super_call_item_reward
				if reward then
					if self.item_cells[2].cell then
						self.item_cells[2].cell:SetData(reward)
					end
				end
			end
		end
	end
end

function GuildBossView:FlushBossModel(boss_data)
	if not self.boss_model then
		self.boss_model = RoleModel.New()
	end
	if self.last_boss_resid ~= boss_data.resid then
		self.boss_model:SetDisplay(self.node_list["BossDisplay"].ui3d_display)
		local bundle, asset = ResPath.GetMonsterModel(boss_data.resid)
		
		if boss_id[boss_data.id] then
			local v = boss_id[boss_data.id]
			local fun = function()
				self.boss_model:SetScale(v[1])
				self.boss_model:SetLocalPosition(v[2])
			end
			self.boss_model:SetMainAsset(bundle, asset, fun)
		else
			self.boss_model:SetMainAsset(bundle, asset)
		end
		self.last_boss_resid = boss_data.resid
	end
end

function GuildBossView:FlushSurperBossModel(boss_data)

	if not self.boss_model2 then
		self.boss_model2 = RoleModel.New()
	end
	if self.last_boss_resid2 ~= boss_data.resid then
		self.boss_model2:SetDisplay(self.node_list["BossDisplay2"].ui3d_display)
		local bundle, asset = ResPath.GetMonsterModel(boss_data.resid)
		if boss_id[boss_data.id] then
			local v = boss_id[boss_data.id]
			local fun = function()
				self.boss_model2:SetScale(v[1])
				self.boss_model2:SetLocalPosition(v[2])
			end
			self.boss_model2:SetMainAsset(bundle, asset, fun)
		else
			self.boss_model2:SetMainAsset(bundle, asset)
		end
		self.last_boss_resid2 = boss_data.resid
	end
end

function GuildBossView:Call()
	local flag = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BOSS)
	if flag then
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			if scene_logic:GetSceneType() ~= SceneType.GuildStation then
				GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AutoReturn)
				return
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GUILDJIUHUINOOPEN)
		return
	end
	local post = GuildData.Instance:GetGuildPost()
	if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
		return
	else
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			if scene_logic:GetSceneType() ~= SceneType.GuildStation then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotInGuildStation)
				return
			end
		end
	end

	local boss_info = GuildData.Instance:GetBossInfo()
	if boss_info then
		local describe = Language.Guild.CallBoss
		local yes_func = function() GuildCtrl.Instance:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_CALL)
		GuildCtrl.Instance:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ) end

		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function GuildBossView:SurperCall()
	local flag = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BOSS)
	if flag then
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			if scene_logic:GetSceneType() ~= SceneType.GuildStation then
				GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AutoReturn)
				return
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GUILDJIUHUINOOPEN)
		return
	end
	local boss_info = GuildData.Instance:GetBossInfo()
	if boss_info then
		local describe = string.format(Language.Guild.SurperCallBoss, ToColorStr("100", COLOR.YELLOW))
		local yes_func = function() GuildCtrl.Instance:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_CALL, 1)
		GuildCtrl.Instance:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ) end

		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function GuildBossView:Feed()
	local feed_id = GuildData.Instance:GetBossFeedItemId()
	if feed_id then
		local number = ItemData.Instance:GetItemNumInBagById(feed_id)
		if number < 1 then
			TipsCtrl.Instance:ShowItemGetWayView(feed_id)
			return
		end
	end
	GuildCtrl.Instance:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_UPLEVEL)
end

function GuildBossView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(61)
end

function GuildBossView:OnClickClose()
	self:Close()
end