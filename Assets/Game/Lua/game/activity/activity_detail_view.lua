ActivityDetailView = ActivityDetailView or BaseClass(BaseView)

function ActivityDetailView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/activityview_prefab", "ActivityDetailContent"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.act_id = 0
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ActivityDetailView:__delete()

end

function ActivityDetailView:ReleaseCallBack()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	if self.tower_model ~= nil then
		self.tower_model:DeleteMe()
		self.tower_model = nil
	end
	self.fight_text = nil
end

function ActivityDetailView:LoadCallBack()
	self.tower_model = RoleModel.New()
	self.tower_model:SetDisplay(self.node_list["Display"].ui3d_display)
	--获取组件
	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetShowOrangeEffect(true)
		item:SetData(nil)
		item:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		table.insert(self.item_list, item)
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtXiuLuoZhanLi"])
	--绑定事件
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnEnterAct"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnMingHun"].button:AddClickListener(BindTool.Bind(self.MinghunClick, self))
	self.node_list["BtnShowBtn2"].button:AddClickListener(BindTool.Bind(self.ClickBtn2, self))
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.ClickDuiHuan, self))
	self.node_list["BtnGouYuExchange"].button:AddClickListener(BindTool.Bind(self.ClickRongYu, self))
	self.node_list["BtnRiZhi"].button:AddClickListener(BindTool.Bind(self.ClickRiZhi, self))
	self.node_list["BtnRongyu"].button:AddClickListener(BindTool.Bind(self.ClickRongYu, self))
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickStart, self))
	self.node_list["BtnHuHuan"].button:AddClickListener(BindTool.Bind(self.ClickHuHuan, self))
	self.node_list["ImgFish"].button:AddClickListener(BindTool.Bind(self.ClickTitle, self))
	self.node_list["BtnSanJieBaZhu"].button:AddClickListener(BindTool.Bind(self.ClickSanJieBaZhu, self))
	self.node_list["BigBtn"].button:AddClickListener(BindTool.Bind(self.ClickCrystalBig, self))
	self.node_list["SmallBtn"].button:AddClickListener(BindTool.Bind(self.ClickCrystalSmall, self))
	

	for i = 1, 3 do
		self.node_list["ImgTitle" .. i].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, i))
		self.node_list["ImgYZDDTitle" .. i].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, i))
		self.node_list["TuanZhanTitle" .. i].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, i))
	end
	
	ActivityCtrl.Instance:SendQunxianLuandouFirstRankInfo()
	self:OnFlush()
end

function ActivityDetailView:OpenCallBack()
	if self.act_id == ACTIVITY_TYPE.GUILD_BONFIRE then
			-- -- 仙盟运镖
		if not ActivityData.Instance:GetActivityIsOpen(self.act_id) then
			self:SetGuildYunBiaoText()
		elseif not GuildCtrl.Instance.has_yunbiao then
			self:SetGuildYunBiaoText()
		else
			local post = GuildData.Instance:GetGuildPost()
			local status = GuildCtrl.Instance.has_yunbiao and true or false
			local flag = post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG
			local index = flag and true or false
			ActivityCtrl.Instance:ShowGuildYunBiaoButton(index, status)
		end
	else
		self:SetGuildYunBiaoText(-1, -1)
	end
	self:ReqJingHuaInfo()
end

function ActivityDetailView:ItemClick(index)
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if nil == act_info or nil == act_info["reward_item" .. index] then
		return
	end
	
	local item_cfg, _ = ItemData.Instance:GetItemConfig(act_info["reward_item" .. index].item_id)

	local item_callback = function ()
		if self.item_list[index] then
			self.item_list[index]:ShowHighLight(false)
		end
	end
	if nil ~= item_cfg then
		if self.item_list[index] then
			self.item_list[index]:ShowHighLight(true)
		end
		TipsCtrl.Instance:OpenItem(act_info["reward_item" .. index],nil ,nil, item_callback)
	end
end

function ActivityDetailView:CloseWindow()
	self:Close()
end

function ActivityDetailView:MinghunClick()
	ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_soul)
end

function ActivityDetailView:ClickDuiHuan()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_shengwang)
end

function ActivityDetailView:ClickRongYu()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_rongyao)
end

function ActivityDetailView:ClickCrystalBig()
	local info = ActivityData.Instance:GetActivityStatuByType(self.act_id)
	if self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then 						--精华护送
			--前往采集物
		if info.status == ACTIVITY_STATUS.OPEN then
			JingHuaHuSongCtrl.Instance:GetIntoCrossShuiJing(JingHuaHuSongData.JingHuaType.Big)
		elseif info.status == ACTIVITY_STATUS.STANDY then
			CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.JINGHUA_HUSONG)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		end
	end
end
function ActivityDetailView:ClickCrystalSmall()

	if self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then 						--精华护送
		--前往采集物
		JingHuaHuSongCtrl.Instance:GetIntoCrossShuiJing(JingHuaHuSongData.JingHuaType.Small)
	end
end



function ActivityDetailView:ClickRiZhi()
	TipsCtrl.Instance:ShowKFRecordView()
end

-- 打开三界霸主展示界面
function ActivityDetailView:ClickSanJieBaZhu()
	ViewManager.Instance:Open(ViewName.BeherrscherShowView)
end

function ActivityDetailView:ClickTitle(index)
	local title_cfg = {}
	if self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
		title_cfg = ActivityData.Instance:GetXianMoItemCfg()
		if title_cfg and title_cfg[index] then
			local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.CHAOSWAR then
		title_cfg = YiZhanDaoDiData.Instance:GetTitleCfg()
		if title_cfg and title_cfg[index] then
			local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.LUANDOUBATTLE or self.act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE then
		title_cfg = LuanDouBattleData.Instance:GetTitleCfg()
		if title_cfg and title_cfg[index] then
			local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.KF_TUANZHAN or self.act_id == ACTIVITY_TYPE.NIGHT_FIGHT_FB then
		local item_id = 0
		local other_cfg = KuaFuTuanZhanData.Instance:GetNightFightOtherCfg()
		for i = 1, 3 do
			if i == index then
				item_id = other_cfg.title_first_good
			elseif i == index then
				item_id = other_cfg.title_second_good
			elseif i == index then
				item_id = other_cfg.title_third_good
			end
		end
		if item_id > 0 then
			local data = {item_id = item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING then
		title_cfg = CrossFishingData.Instance:GetFishingOtherCfg()
		if title_cfg then
			local data = {item_id = title_cfg.rank_title_item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end

	if self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then
		title_cfg = KuaFuXiuLuoTowerData.Instance:GetTitleCfg()
		if title_cfg and title_cfg[index] then
			local data = {item_id = title_cfg[index].item_id, is_bind = 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
		end
	end
end


function ActivityDetailView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function ActivityDetailView:ClickBtn2()
	-- if self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then
	-- 	if not ActivityData.Instance:GetActivityIsOpen(self.act_id) then
	-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
	-- 	else
	-- 		ViewManager.Instance:Open(ViewName.FuXiuLuoTowerBuffView)
	-- 	end
	if self.act_id == ACTIVITY_TYPE.ZHUAGUI then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local have_team = ScoietyData.Instance:GetTeamState()
		local is_leader = ScoietyData.Instance:IsLeaderById(main_role_id)

		if have_team then
			if is_leader then
				local team_index = ScoietyData.Instance:GetTeamIndex()
				local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
				local invite_str = string.format(Language.Society.ZhuaGuiTeamInvite, team_index, act_info.min_level or 0, "")
				ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, invite_str, CHAT_CONTENT_TYPE.TEXT)
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.WorldInvite)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.DontInviety)
				return
			end
		else
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 1
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
			ActivityData.Instance:SetSendZhuaGuiInvite(true)
		end
		return
	elseif self.act_id == ACTIVITY_TYPE.KF_TUANZHAN or self.act_id == ACTIVITY_TYPE.NIGHT_FIGHT_FB then
		ViewManager.Instance:Open(ViewName.KuaFuTuanZhanRewardView)
	-- elseif self.act_id == ACTIVITY_TYPE.GUILD_BONFIRE then
	-- 	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	-- 	if guild_id < 1 then
	-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
	-- 		return
	-- 	end
	-- 	local post = GuildData.Instance:GetGuildPost()
	-- 	local dec = ""
	-- 	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
	-- 		dec = Language.Guild.GuildHuSongStart
	-- 	else
	-- 		dec = Language.Guild.CallGuildHuSong --.. "{point;".. "NPC名字" .. ";" .. 305 .. ";" .. 158 .. ";" .. 103 .. ";" .. 0 .. "}"
	-- 	end
	-- 	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
	-- 	self:Close()
	-- 	ViewManager.Instance:Open(ViewName.ChatGuild)
	end
end

function ActivityDetailView:ClickStart()
	if self.status then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		GuildCtrl.Instance:SendGuildYunBiaoReq(BIAOCHE_OPERA_TYPE.BIAOCHE_OPERA_TYPE_BIAOCHE_POS, guild_id)
		self:Close()
		return
	end

	if GuildDataConst.GUILDVO.is_today_biaoche_start == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.HasOpenGuildYunBiao)
		self:Close()
		return
	end
	local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
	if guild_yunbiao_cfg then
		local scene_id = guild_yunbiao_cfg.biaoche_scene_id
		local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
		local name = scene_cfg and scene_cfg.name or ""
		if Scene.Instance:GetSceneId() ~= scene_id then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.GuildYunNotInScene, name))
			return
		end
	end
	local tips = Language.Guild.IsOpenGuildYunBiao
	local ok_callback = function()
		local main_role = Scene.Instance:GetMainRole()
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
		if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_GUILD then
			MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
		end
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		GuildCtrl.Instance:SendGuildYunBiaoReq(BIAOCHE_OPERA_TYPE.BIAOCHE_OPERA_TYPE_START, guild_id)
	end

	local info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.GUILD_BONFIRE)
	local end_time = 0
	if info.status == ACTIVITY_STATUS.STANDY then
		end_time = (info.next_time or 0) - TimeCtrl.Instance:GetServerTime()
	end
	TipsCtrl.Instance:ShowCommonAutoView("", tips, ok_callback, nil, nil, nil, nil, nil, nil, nil, nil, end_time)
	self:Close()
end

function ActivityDetailView:ClickHuHuan()
	if self.status then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		GuildCtrl.Instance:SendGuildYunBiaoReq(BIAOCHE_OPERA_TYPE.BIAOCHE_OPERA_TYPE_BIAOCHE_POS, guild_id)
		self:Close()
		return
	end
	if GuildDataConst.GUILDVO.is_today_biaoche_start == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.HasOpenGuildYunBiao)
		self:Close()
		return
	end
	local dec = Language.Guild.CallGuildHuSong
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
	self:Close()
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

function ActivityDetailView:ClickEnter()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end

	if GameVoManager.Instance:GetMainRoleVo().level < act_info.min_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.JoinEventActLevelLimit, act_info.min_level))
		return
	end
	local scene_id= Scene.Instance:GetSceneId()
	---[[客户端自定义活动
	if self.act_id == ACTIVITY_TYPE.ZHUAGUI then 		-- 秘境降魔
		if scene_id == 106 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongYiZai)
		else
			GuajiCtrl.Instance:FlyToScene(106)
		end
		self:CloseWindow()
		ViewManager.Instance:Close(ViewName.Activity)
		return
	elseif self.act_id == ACTIVITY_TYPE.GUILD_MONEYTREE then
		local guild_id = GuildData.Instance.guild_id
		if guild_id and guild_id > 0 then
			GuildCtrl.Instance:SendGuildBackToStationReq(guild_id)
			self:Close()
		end
		return
	end
	--]]
	if not ActivityData.Instance:GetActivityIsOpen(self.act_id) and not ActivityData.Instance:GetActivityIsReady(self.act_id) then
		if self.act_id ~= ACTIVITY_TYPE.HUSONG then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
			return
		end
	end

	if ACTIVITY_ENTER_LIMIT_LIST[self.act_id] then
		if not ActivityData.Instance:IsAchieveLevelInLimintConfigById(self.act_id) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
			return
		end
	end

	if self.act_id == DaFuHaoDataActivityId.ID then								-- 大富豪
		 if ActivityData.Instance:GetActivityStatuByType(self.act_id) == nil or
			ActivityData.Instance:GetActivityStatuByType(self.act_id).status ~= ACTIVITY_STATUS.OPEN then
			TipsCtrl.Instance:ShowSystemMsg(Language.Guild.GUILDJIUHUINOOPEN)
			return
		end
		local cfg = DaFuHaoData.Instance:GetDaFuHaoOtherCfg()
		if nil ~= cfg then
			ActivityCtrl.Instance:SendActivityEnterReq(DaFuHaoDataActivityId.ID)
			DaFuHaoCtrl.Instance:SendGetGatherInfoReq()
		end
	elseif self.act_id == ACTIVITY_TYPE.KF_HOT_SPRING or  -- 泳池派对
			self.act_id == ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT or --月黑风高
			self.act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING or --钓鱼
			self.act_id == ACTIVITY_TYPE.KF_TUANZHAN or -- 跨服夜战
			self.act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE then -- 跨服乱斗战场 
			CrossServerCtrl.Instance:SendCrossStartReq(self.act_id)
	elseif self.act_id == ACTIVITY_TYPE.NIGHT_FIGHT_FB then 	-- 夜战王城
		local state_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.NIGHT_FIGHT_FB)
		if state_info ~= nil and state_info.status == 2 then
			KuaFuTuanZhanData.Instance:SetIsCrossServerState(0)
			KuaFuTuanZhanCtrl.Instance:SendNightFightEnterReq(NIGHT_FIGHT_OPERA_TYPE.NIGHT_FIGHT_OPERA_TYPE_ENTER)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Activity.HuoDongWeiKaiQi)
		end
	elseif self.act_id == ACTIVITY_TYPE.HUSONG then									-- 运镖(不是仙盟运镖，不知道是个啥东西)
		ViewManager.Instance:CloseAll()
		YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
		return
	elseif self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then									-- 修罗塔
		KuaFuXiuLuoTowerCtrl.Instance:SendEnterXiuLuoTowerFuBen()
	elseif self.act_id == ACTIVITY_TYPE.GUILD_BOSS then
		GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
	elseif self.act_id == ACTIVITY_TYPE.KF_FARMHUNTING then
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_FARMHUNTING)
	elseif self.act_id == ACTIVITY_TYPE.GUILD_BONFIRE then 				--仙盟运镖
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if guild_id <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
			return
		end
		local post = GuildData.Instance:GetGuildPost()
		local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
		if guild_yunbiao_cfg then
			local npc_cfg_id = guild_yunbiao_cfg.accept_npc_id
			MoveCache.end_type = MoveEndType.NpcTask
			MoveCache.param1 = npc_cfg_id
			GuajiCache.target_obj_id = npc_cfg_id
			MoveCache.target_obj = Scene.Instance:GetNpcByNpcId(npc_cfg_id) or nil
			local scene_id = guild_yunbiao_cfg.biaoche_scene_id
			local x, y = guild_yunbiao_cfg.accept_npc_x, guild_yunbiao_cfg.accept_npc_y
			local func = function()
				local status = GuildCtrl.Instance.has_yunbiao and true or false
				local flag = post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG
				local index = flag and true or false
				ActivityCtrl.Instance:ShowGuildYunBiaoButton(index, status)
			end
			if VipPower.Instance:GetParam(VipPowerId.scene_fly) > 0 and MoveCache.cant_fly == false then
				local SceneKey = 0 --这里默认去1线
				GuajiCtrl.Instance:FlyToScenePos(scene_id, x, y, false, SceneKey)
				ViewManager.Instance:CloseAll()
				local scene_logic = Scene.Instance:GetSceneLogic()
				if BossData.IsBossScene() or not scene_logic or scene_logic:GetSceneType() ~= SceneType.Common then
					return
				end
				func()
			else
				local SceneKey = 0 --这里默认去1线
				GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 1, 1, false, SceneKey)
				ViewManager.Instance:CloseAll()
				GuajiCtrl.Instance:SetArriveCallBack(func)
			end
			return
		end
	elseif self.act_id == ACTIVITY_TYPE.GUILD_ANSWER then						--仙盟答题		
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if guild_id < 1 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
			return
		end
		GuildCtrl.Instance:SendGuildQuestionEnterReq()
	elseif self.act_id == ACTIVITY_TYPE.GUILD_SHILIAN then						--仙盟试炼		
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if guild_id < 1 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
			return
		end
		local finish_timestamp = GuildMijingData.Instance:GetGuildFbStatus()
		if finish_timestamp == 0 then
			GuildMijingCtrl.SendGuildFbStartReq()
		end
		GuildMijingCtrl.SendGuildFbEnterReq()
	elseif self.act_id == ACTIVITY_TYPE.LUANDOUBATTLE then 						-- 乱斗战场
		LuanDouBattleData.Instance:SetIsCrossServerState(0)
		LuanDouBattleCtrl.Instance:SendMessBattleEnterReq()
	else
		local index = 0
		if self.act_id == ACTIVITY_TYPE.CLASH_TERRITORY and ClashTerritoryData.Instance:GetTerritoryRankById() then
			local rank = ClashTerritoryData.Instance:GetTerritoryRankById()
			index = math.max(math.ceil(rank / 2) - 1, 0)
		end
		ActivityCtrl.Instance:SendActivityEnterReq(self.act_id, index)
	end

	if self.act_id == ACTIVITY_TYPE.KF_HOT_SPRING then
		return
	end
	ViewManager.Instance:CloseAll()
end

--记录活动id
function ActivityDetailView:SetActivityId(act_id)
	self.act_id = act_id
end

--活动时间
function ActivityDetailView:SetTitleTime(act_info)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	local server_time_str = os.date("%H:%M", server_time)
	if now_weekday == 0 then now_weekday = 7 end
	local time_str = Language.Activity.YiJieShu

	if ActivityData.Instance:GetActivityIsOpen(act_info.act_id) then
		time_str = Language.Activity.KaiQiZhong
	elseif ActivityData.Instance:GetActivityIsReady(act_info.act_id) then
		time_str = Language.Activity.ZhunBeiZhong
	elseif act_info.is_allday == 1 then
		time_str = Language.Activity.AllDay
	else
		for _, v in ipairs(self.open_day_list) do
			if tonumber(v) == now_weekday then
				local open_time_tbl = Split(act_info.open_time, "|")
				local open_time_str = open_time_tbl[1]
				local end_time_tbl = Split(act_info.end_time, "|")
				local though_time = true
				for k2, v2 in ipairs(end_time_tbl) do
					if v2 > server_time_str then
						though_time = false
						open_time_str = open_time_tbl[k2]
						break
					end
				end
				if though_time then
					time_str = Language.Activity.YiJieShuDes
				else
					time_str = string.format("%s  %s", open_time_str, Language.Common.Open)
				end
				break
			end
		end
	end
	self.node_list["TxtTitleTime"].text.text = time_str
end


-- function ActivityDetailView:GetChineseWeek(act_info)
-- 	local open_time_tbl = Split(act_info.open_time, "|")
-- 	local end_time_tbl = Split(act_info.end_time, "|")

-- 	local time_des = ""

-- 	if #self.open_day_list >= 7 then
-- 		if #open_time_tbl > 1 then
-- 			local time_str = ""
-- 			for i = 1, #open_time_tbl do
-- 				if i == 1 then
-- 					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
-- 				else
-- 					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
-- 				end
-- 			end
-- 			time_des = string.format("%s %s", Language.Activity.EveryDay, time_str)
-- 		else
-- 			time_des = string.format("%s %s-%s", Language.Activity.EveryDay, act_info.open_time, act_info.end_time)
-- 		end
-- 	else
-- 		local week_str = ""
-- 		for k, v in ipairs(self.open_day_list) do
-- 			local day = tonumber(v)
-- 			if k == 1 then
-- 				week_str = string.format("%s%s", Language.Activity.WeekDay, Language.Common.DayToChs[day])
-- 			else
-- 				week_str = string.format("%s、%s", week_str, Language.Common.DayToChs[day])
-- 			end
-- 		end
-- 		if #open_time_tbl > 1 then
-- 			local time_str = ""
-- 			for i = 1, #open_time_tbl do
-- 				if i == 1 then
-- 					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
-- 				else
-- 					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
-- 				end
-- 			end
-- 			time_des = string.format("%s %s", week_str, time_str)
-- 		else
-- 			time_des = string.format("%s %s-%s", week_str, act_info.open_time, act_info.end_time)
-- 		end
-- 	end
-- 	return time_des
-- end

--描述
function ActivityDetailView:SetExplain(act_info)
	local min_level = tonumber(act_info.min_level)
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(min_level)
	-- local level_str = string.format(Language.Common.ZhuanShneng, lv, zhuan)
	local level_str = PlayerData.GetLevelString(min_level)
	local time_des = ""

	local str =  ActivityData.Instance:GetChineseWeek(act_info) or ""
	time_des = ActivityData.Instance:GetLimintOpenDayTextByActId(self.act_id, act_info, str)

	local detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)
	if self.act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
		local guild_id = PlayerData.Instance.role_vo.guild_id or 0
		local match_name = ClashTerritoryData.Instance:GetTerritoryWarMatch(guild_id)
		detailexplain = string.format(Language.Activity.TerritoryWarExplain, level_str, time_des, match_name)
	end
	self.node_list["TxtExplain"].text.text = detailexplain
end

--设置是否显示奖励
function ActivityDetailView:SetRewardState(act_info)
	if nil ~= act_info.reward_item1 then
		self.node_list["NodeType1"]:SetActive(false)
		self.node_list["NodeType2"]:SetActive(true)
		local tab_list = Split(act_info.item_label, ":")
		for k, v in ipairs(self.item_list) do
			if tab_list[k] then
				tab_list[k] = tonumber(tab_list[k])
			end
			if act_info["reward_item" .. k] and next(act_info["reward_item" .. k]) and act_info["reward_item" .. k].item_id ~= 0 then
				v.root_node:SetActive(true)
				v:SetShowVitualOrangeEffect(true)
				v:SetData(act_info["reward_item" .. k])
				if tab_list[k]then
					v:SetShowZhuanShu(tab_list[k] == 1)
				end
			else
				v:SetInteractable(false)
				v.root_node:SetActive(false)
			end
		end
	else
		self.node_list["NodeType1"]:SetActive(true)
		self.node_list["NodeType2"]:SetActive(false)
	end
end

function ActivityDetailView:SetYiZhanDaoDiInfo()
	local first_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiLastFirstInfo()
	local first_name = ""
	if nil == first_info.uid or first_info.uid <= 0 then
		first_name = Language.Competition.NoRank
	else
		first_name = first_info.game_name or ""
	end
	self.node_list["TxtYizhandaodi"].text.text = string.format(Language.Activity.Activity_datail_YiZhanDaoDi,first_name) 
	self.node_list["ImgYiZhanDaoDi"]:SetActive(self.act_id == ACTIVITY_TYPE.CHAOSWAR)
end

function ActivityDetailView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	self:SetYiZhanDaoDiInfo()

	self.open_day_list = Split(act_info.open_day, ":")

	self:SetTitleTime(act_info)
	self:SetRewardState(act_info)
	self:SetExplain(act_info)
	self.node_list["BtnMingHun"]:SetActive(false)
	self.node_list["ImgZhuaGuiNum"]:SetActive(false)
	self.node_list["ImgHunliNum"]:SetActive(false)
	self.node_list["TuanZhanPlane"]:SetActive(false)
	self.node_list["BtnShowBtn2"]:SetActive(self.act_id == ACTIVITY_TYPE.ZHUAGUI)
	--or self.act_id == ACTIVITY_TYPE.GUILD_BONFIRE)
	-- if self.act_id == ACTIVITY_TYPE.GUILD_BONFIRE then
	-- 	local flag = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE) 
	-- 	UI:SetButtonEnabled(self.node_list["BtnShowBtn2"], flag)
	-- end
	--按钮文字
	local btn_str = Language.Common.EnterScene
	if self.act_id == ACTIVITY_TYPE.ZHUAGUI then
		btn_str = Language.Activity.GoToZhuaGui
		self.node_list["BtnMingHun"]:SetActive(true)
		self.node_list["ImgZhuaGuiNum"]:SetActive(true)
		self.node_list["ImgHunliNum"]:SetActive(true)
		self.node_list["TxtShowBtn2"].text.text = Language.Society.WorldInviety
		local zhuagui_info = ZhuaGuiData.Instance:GetCurDayZhuaGuiInfo()
		self.node_list["TxtZhuaGuiNum"].text.text = string.format(Language.Activity.Activity_datail_zhuagui_num,zhuagui_info.zhuagui_day_catch_count)
		self.node_list["TxtHunliNum"].text.text = string.format(Language.Activity.Activity_datail_hunli_num,zhuagui_info.zhuagui_day_gethunli)
	elseif self.act_id == ACTIVITY_TYPE.GUILD_BONFIRE then
		self.node_list["TxtShowBtn2"].text.text = Language.Activity.GuildCall
		btn_str = Language.Common.QianWang
	elseif self.act_id == ACTIVITY_TYPE.HUSONG then
		btn_str = Language.Common.QianWang
	elseif self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then
		self.node_list["TxtShowBtn2"].text.text = Language.Activity.BuyBuff
	elseif self.act_id == ACTIVITY_TYPE.KF_TUANZHAN then
		-- self.node_list["TxtShowBtn2"].text.text = Language.Activity.BtnRankReward 
	end
	self.node_list["TxtBtnEnterAct"].text.text = btn_str
	self:SetTitleName(act_info.act_name)
	--设置活动底图
	local bundle, asset = ResPath.GetActivityBg(self.act_id)
	self.node_list["RawImgBG"].raw_image:LoadSprite(bundle, asset)

	self:SetLuanDouBattlePlane()
	-- 仙魔战场
	self:SetXianMoPlane()

	--水晶幻境面板
	self:SetShuijingPlane()

	--兑换声望
	self:SetExchangeShengWang()

	--跨服修罗塔
	self:SetKFXiuLuoTower()

	--跨服珍宝秘境
	self:SetKFZhenBaoMiJingTower()

	--跨服五行熔炉(之后改名怪物猎人)
	self:SetMonsterHunterPlane()

	--怒斩九霄
	self:SetTuanZhanPlane()

	--乱斗战场
	self:SetLuanDouZhanChangPlane()

	--跨服钓鱼
	self:SetKFFish()

	--一战封神
	self:SetYiZhanDaoDiPanel()

	-- 三界霸主风采展示按钮
	self:SetSanJieBaZhuBtn()
	-- 水晶护送
	self:SetShuiJinHuSonBtn()
	self:SetJingHuaData()
end

function ActivityDetailView:SetKFFish()
	if self.act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING then
		self.node_list["PlaneFish"]:SetActive(true)
		local cfg = ActivityData.Instance:GetClockActivityByID(self.act_id)
		if cfg and cfg.title_id then
			local bundle, asset = ResPath.GetTitleIcon(cfg.title_id)
			self.node_list["ImgFish"].image:LoadSprite(bundle, asset, function()
				self.node_list["ImgFish"].image:SetNativeSize()
			end)
			self:LoadTitleEff(self.node_list["ImgFish"], cfg.title_id, true)
		end
	else
		self.node_list["PlaneFish"]:SetActive(false)
	end
end
--处理活动系统面板标题字间距问题
function ActivityDetailView:SetTitleName(name)
	self.node_list["TitleText"].text.text = name
-- 	local number = string.utf8len(name)
-- 	if number == 2 then
-- 		self.node_list["TitleText"].text.lineSpacing = 1.5
-- 	elseif number == 3 then
-- 		self.node_list["TitleText"].text.lineSpacing = 1.3
-- 	elseif number == 4 then
-- 		self.node_list["TitleText"].text.lineSpacing = 1.1
-- 	elseif number == 5 then
-- 		self.node_list["TitleText"].text.lineSpacing = 0

-- 	end
end

function ActivityDetailView:SetLuanDouBattlePlane()
	if self.act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE or self.act_id == ACTIVITY_TYPE.LUANDOUBATTLE then
		self.node_list["LuanDouPlane"]:SetActive(true)
		local score_type = EXCHANGE_PRICE_TYPE.RONGYAO
		local nume = CommonDataManager.ConverMoney(ExchangeData.Instance:GetCurrentScore(score_type))
		self.node_list["TxtExchangeRY"].text.text = string.format(Language.Activity.RongYao, nume or 0)
	else
		self.node_list["LuanDouPlane"]:SetActive(false)
	end
end

function ActivityDetailView:SetXianMoPlane()
	local title_cfg = ElementBattleData.Instance:GetTitleCfg()
	for i = 1, 3 do
		if self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
			self.node_list["XianMoPlane"]:SetActive(true)
			local res_id = title_cfg[i].title_id
			local bundle, asset = ResPath.GetTitleIcon(res_id)
			self.node_list["ImgTitle" .. i].image:LoadSprite(bundle, asset)
			self:LoadTitleEff(self.node_list["ImgTitle" .. i], res_id, true)
			self.node_list["TxtZhenYing" .. i].text.text = Language.Activity.XianMoZhenYing[i]
		else
			self.node_list["XianMoPlane"]:SetActive(false)
			self.node_list["TxtZhenYing" .. i].text.text = Language.Activity.XianMoZhenYing[4]
		end
		local first_info = ActivityData.Instance:GetQunxianLuandouFirstRankInfo()
		if first_info == nil or first_info[i] == nil or "" == first_info[i] then
			self.node_list["TxtName" .. i].text.text = Language.Competition.NoRank
		else
			self.node_list["TxtName" .. i].text.text = Language.Activity.LastGame .. ToColorStr(first_info[i],TEXT_COLOR.GREEN_4) 
		end
	end
end

function ActivityDetailView:SetMonsterHunterPlane()
	if self.act_id == ACTIVITY_TYPE.KF_FARMHUNTING then
		-- self.node_list["MonsterHunter"]:SetActive(true)
		-- local title_id = FarmHuntingData.Instance:GetFarmHuntingTitleId() or 3001
		-- local bundle, name = "uis/icons/title/3000_atlas", "Title_" .. title_id
		-- self.node_list["HunterTitle"].image:LoadSprite(bundle, name)
		-- self:LoadTitleEff(self.node_list["HunterTitle"], title_id, true)
	else
		self.node_list["MonsterHunter"]:SetActive(false)
	end
end

function ActivityDetailView:SetTuanZhanPlane()
	if self.act_id == ACTIVITY_TYPE.KF_TUANZHAN or self.act_id == ACTIVITY_TYPE.NIGHT_FIGHT_FB then
		local title_id = 0
		local other_cfg = KuaFuTuanZhanData.Instance:GetNightFightOtherCfg()
		self.node_list["TuanZhanPlane"]:SetActive(true)
		for i = 1, 3 do
			if i == 1 then
				title_id = other_cfg.title_first
			elseif i == 2 then
				title_id = other_cfg.title_second
			else
				title_id = other_cfg.title_third
			end
			local bundle, name = "uis/icons/title/3000_atlas", "Title_" .. title_id
			self.node_list["TuanZhanTitle" .. i].image:LoadSprite(bundle, name, function()
				self.node_list["TuanZhanTitle" .. i].image:SetNativeSize()
			end)
			self:LoadTitleEff(self.node_list["TuanZhanTitle" .. i], title_id, true)
		end
	end
end

function ActivityDetailView:SetLuanDouZhanChangPlane()
	if self.act_id == ACTIVITY_TYPE.LUANDOUBATTLE or self.act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE then
		self.node_list["TuanZhanPlane"]:SetActive(true)
		local title_cfg = LuanDouBattleData.Instance:GetTitleCfg()
		for i = 1,3 do
			local res_id = Split(title_cfg[i].title_show, ",")
			local bundle, asset = res_id[1], res_id[2]
			self.node_list["TuanZhanTitle" .. i].image:LoadSprite(bundle, asset, function()
				self.node_list["TuanZhanTitle" .. i].image:SetNativeSize()
			end)
			self:LoadTitleEff(self.node_list["TuanZhanTitle" .. i], title_cfg[i].title_id, true)
		end
	end
end



function ActivityDetailView:SetShuijingPlane()
	if self.act_id == ACTIVITY_TYPE.SHUIJING then
		self.node_list["ShuiJingPlane"]:SetActive(true)
		local bigshuijing_cfg = CrossCrystalData.Instance:GetMaxBigShuiJingInfoList()
		if bigshuijing_cfg[1] then
			local bind_gold = tonumber(bigshuijing_cfg[1].bind_gold)
			local mojing = tonumber(bigshuijing_cfg[1].mojing)
			local shengwang = tonumber(bigshuijing_cfg[1].shengwang) 
			self.node_list["TxtShengWang"].text.text = "+" .. shengwang
			self.node_list["TxtMoJing"].text.text = "+" .. mojing
			self.node_list["TxtYuanBao"].text.text = "+" .. bind_gold
		end
	else
		self.node_list["ShuiJingPlane"]:SetActive(false)
	end
end

function ActivityDetailView:SetExchangeShengWang()
	if self.act_id == ACTIVITY_TYPE.SHUIJING or self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU or self.act_id == ACTIVITY_TYPE.CHAOSWAR then
		self.node_list["BtnExchange"]:SetActive(true)
	else
		self.node_list["BtnExchange"]:SetActive(false)
	end
	local score_type = EXCHANGE_PRICE_TYPE.SHENGWANG
	local nume = CommonDataManager.ConverMoney(ExchangeData.Instance:GetCurrentScore(score_type))
	self.node_list["TxtExchangeSW"].text.text = Language.Activity.ShengWang .. nume
end

function ActivityDetailView:SetKFXiuLuoTower()
	local is_show  = self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER
	local cfg = KuaFuXiuLuoTowerData.Instance:GetItemID()
	local show_id = cfg.model_show or 0
	local zhanli = cfg.fight_show or 0
	local show_list = Split(show_id, ",")
	local bundle, asset = show_list[1], show_list[2]

	self.node_list["Display"]:SetActive(is_show)
	self.node_list["BtnRiZhi"]:SetActive(is_show)
	self.node_list["BtnGouYuExchange"]:SetActive(is_show)
	self.node_list["XiuLuoZhanLiNode"]:SetActive(is_show)
	self.node_list["TxtGouYuExchange"]:SetActive(is_show)
	if is_show then
		self.node_list["TuanZhanPlane"]:SetActive(true)
		self.tower_model:SetMainAsset(bundle, asset, function()
			self.tower_model:SetLocalPosition(Vector3(0, 0.4, 0))
			self.tower_model:SetRotation(Vector3(0, 40, 0))
		end)

		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = zhanli
		end
		if self.node_list["BtnGouYuExchange"] then
			local score_type = EXCHANGE_PRICE_TYPE.RONGYAO
			local num = CommonDataManager.ConverMoney(ExchangeData.Instance:GetCurrentScore(score_type))
			self.node_list["TxtGouYuExchange"].text.text = string.format(Language.XiuLuo.RongYao, num)
		end
		local title_cfg = KuaFuXiuLuoTowerData.Instance:GetTitleCfg()
		if title_cfg then
			for i = 1,3 do
				local res_id = Split(title_cfg[i].title_show, ",")
				local bundle, asset = res_id[1], res_id[2]
				self.node_list["TuanZhanTitle" .. i].image:LoadSprite(bundle, asset, function()
					self.node_list["TuanZhanTitle" .. i].image:SetNativeSize()
				end)
				self:LoadTitleEff(self.node_list["TuanZhanTitle" .. i], title_cfg[i].title_id, true)
			end
		end
	end
end

function ActivityDetailView:SetKFZhenBaoMiJingTower()
	local is_show = self.act_id == ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT
	self.node_list["LeftBg"]:SetActive(is_show)
	self.node_list["LeftTitle"]:SetActive(is_show)
	if is_show then
		local data = ActivityData.Instance:GetClockActivityByID(self.act_id)
		self.node_list["LeftTitleImage"].image:LoadSprite(ResPath.GetTitleIcon(data.title_id))
		self:LoadTitleEff(self.node_list["LeftTitleImage"], data.title_id, true)
	end
end

function ActivityDetailView:SetYiZhanDaoDiPanel()
	if self.act_id == ACTIVITY_TYPE.CHAOSWAR then
		self.node_list["YiZhanDaoDiPlane"]:SetActive(true)
		local title_cfg = YiZhanDaoDiData.Instance:GetTitleCfg()
		for i = 1,3 do
			local res_id = Split(title_cfg[i].title_show, ",")
			local bundle, asset = res_id[1], res_id[2]
			self.node_list["ImgYZDDTitle" .. i].image:LoadSprite(bundle, asset, function()
				self.node_list["ImgYZDDTitle" .. i].image:SetNativeSize()
			end)
			self:LoadTitleEff(self.node_list["ImgYZDDTitle" .. i], title_cfg[i].title_id, true)
		end
	else
		self.node_list["YiZhanDaoDiPlane"]:SetActive(false)
	end
end

--设置水晶护送按钮
function ActivityDetailView:SetShuiJinHuSonBtn()
	self.node_list["BtnEnterAct"]:SetActive(true)
	self.node_list["ShuiJiHuiSon"]:SetActive(false)
	self.node_list["LingshiBtn"]:SetActive(false)
	local info = ActivityData.Instance:GetActivityStatuByType(self.act_id)
	if self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then
		if info.status == ACTIVITY_STATUS.OPEN then
			self.node_list["LingshiBtn"]:SetActive(true)
			self.node_list["ShuiJiHuiSon"]:SetActive(true)
			self.node_list["BtnEnterAct"]:SetActive(false)
			self.node_list["SmallBtn"]:SetActive(true)
			self.node_list["BtnCrystaltxt"].text.text = Language.Activity.BigCrystal
		else
			self.node_list["BtnEnterAct"]:SetActive(false)
			self.node_list["SmallBtn"]:SetActive(false)
			self.node_list["LingshiBtn"]:SetActive(true)
			self.node_list["BtnCrystaltxt"].text.text = Language.Activity.JoinActCrystal
		end
	end

end


-- 设置三界面霸主按钮
function ActivityDetailView:SetSanJieBaZhuBtn()
	self.node_list["BtnSanJieBaZhu"]:SetActive(false)
	if self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
		self.node_list["BtnSanJieBaZhu"]:SetActive(true)
	end
end

function ActivityDetailView:LoadTitleEff(parent, title_id, is_active, call_back)
	local title_cfg = TitleData.Instance:GetTitleCfg(title_id)
	if title_cfg and title_cfg.is_zhengui then
		self.title_effect_loader = self.title_effect_loader or {}
		if self.title_effect_loader[parent] then
			self.title_effect_loader[parent]:SetActive(is_active)
			return
		end

		local asset_bundle, asset_name = ResPath.GetTitleEffect("UI_title_eff_" .. title_cfg.is_zhengui)
		local async_loader = self.title_effect_loader[parent] or AllocAsyncLoader(self, "title_effect_loader_" .. title_id)
		async_loader:Load(asset_bundle, asset_name, function(obj)
			obj.transform:SetParent(parent.transform, false)
			obj:SetActive(is_active)
		end)
		self.title_effect_loader[parent] = async_loader
	end
end

function ActivityDetailView:SetGuildYunBiaoText(index, status)
	if nil == index or nil == status then
		return
	end
	if self.act_id == ACTIVITY_TYPE.GUILD_BONFIRE then
		self.status = status
		self.node_list["BtnEnterAct"]:SetActive(false)
		self.node_list["BtnStart"]:SetActive(index)	-- 盟主或副盟主
		self.node_list["BtnHuHuan"]:SetActive(not index)	-- 成员
		if status then
			self.node_list["TxtStart"].text.text = Language.Guild.Follow
			self.node_list["TxtHuHuan"].text.text = Language.Guild.Follow
		else
			self.node_list["TxtStart"].text.text = Language.Guild.GuildStart
			self.node_list["TxtHuHuan"].text.text = Language.Guild.GuildHuHuan
		end
	else
		self.node_list["BtnEnterAct"]:SetActive(true)
		self.node_list["BtnStart"]:SetActive(false)
		self.node_list["BtnHuHuan"]:SetActive(false)
	end
end

function ActivityDetailView:SetJingHuaData()
	if self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then
		self.node_list["LshsTips"]:SetActive(true)
		local sj_num = JingHuaHuSongData.Instance:GetBigCrystalNum()
		local color = sj_num > 0 and "#89F201" or "#F9463B"
		self.node_list["LshsTips"].text.text = string.format(Language.CrossCrystal.BigCrystalTips, color,sj_num) 
	else
		self.node_list["LshsTips"]:SetActive(false)
	end
end

function ActivityDetailView:ReqJingHuaInfo()
	if self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then
		JingHuaHuSongCtrl.Instance:SendGetCrystalInfoReq()
	end
end
