--跨服帮派战排行
KuafuTaskFollowView = KuafuTaskFollowView or BaseClass(BaseView)

local GuildFight_Flag_Num = 3
local RankItem_Num = 5

function KuafuTaskFollowView:__init()
	self.ui_config = {{"uis/views/kuafuliujie_prefab", "KuaFuBattleView"}}
	self.active_close = false
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配

	self.cur_task_monster_id = 0
	self.item_t = {}
end

function KuafuTaskFollowView:ReleaseCallBack()
	if self.flag_list then
		for k,v in pairs(self.flag_list) do
			v:DeleteMe()
		end
		self.flag_list = {}
	end
	if self.kuafu_guild_battle_time then
		CountDown.Instance:RemoveCountDown(self.kuafu_guild_battle_time)
	end
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end

	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end
	self.reward_obj = nil
end

function KuafuTaskFollowView:LoadCallBack()
	self.reward_obj = GuildBattleRewardRender.New(self.node_list["NodeRewardList"])
	self:InitFlagPanel()
	self:InitRankPanel()
	self.node_list["BattleImg"].button:AddClickListener(BindTool.Bind(self.ClickKuafuGuildBattle, self))
	self.node_list["BtnGuildShow"].button:AddClickListener(BindTool.Bind(self.OnClickGuildShowView, self))
	self.node_list["TaskParent"]:SetActive(true)
	self.node_list["GuildShow"]:SetActive(true)
	self.node_list["BaiYeShow"]:SetActive(false)
	self.node_list["BtnBaiYe"].button:AddClickListener(BindTool.Bind(self.OnClickBaiYe, self))
	self.is_show_remind_bai_ye = true


	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
end

function KuafuTaskFollowView:CloseCallBack()
	if self.bai_ye_cd then
		CountDown.Instance:RemoveCountDown(self.bai_ye_cd)
		self.bai_ye_cd = nil
	end
	
	if nil ~= self.down_time then
		CountDown.Instance:RemoveCountDown(self.down_time)
		self.down_time = nil
	end

	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end

end

function KuafuTaskFollowView:OpenCallBack()
	local time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.KF_GUILDBATTLE)
	if self.kuafu_guild_battle_time then
		CountDown.Instance:RemoveCountDown(self.kuafu_guild_battle_time)
		self.kuafu_guild_battle_time = nil
	end
	if next_time > TimeCtrl.Instance:GetServerTime() then
		self.kuafu_guild_battle_time = CountDown.Instance:AddCountDown(next_time- TimeCtrl.Instance:GetServerTime(), 1, BindTool.Bind1(self.UpdateOpenCountDownTime, self))
	else
		self.node_list["TimeTxt"].text.text = string.format(Language.XiuLuo.Time, "00:00:00")
	end
end

function KuafuTaskFollowView:OnMainUIModeListChange(is_show)
	self.node_list["NodeTrackAndMapInfo"]:SetActive(is_show)
	if is_show then
		self:Flush()
	end
end

function KuafuTaskFollowView:ClickKuafuGuildBattle()
	KuafuGuildBattleCtrl.Instance:OpenRecordPanle()
end

-- 打开仙盟输出展示面板
function KuafuTaskFollowView:OnClickGuildShowView()
	GuildCtrl.Instance:OpenGuildShowView(ACTIVITY_TYPE.KF_GUILDBATTLE)
end

function KuafuTaskFollowView:InitFlagPanel()
	self.flag_list = {}
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/kuafuliujie_prefab", "GuildFightFlagCell", nil, function(prefab)
		local count = 0
		for i = 1, GuildFight_Flag_Num do
			local obj = ResMgr:Instantiate(prefab)
			local info_cell = GuildBattleInfoRender.New(obj)
			info_cell:SetInstanceParent(self.node_list["NodeFlag"].transform)
			info_cell:SetIndex(i)
			info_cell:SetMotherView(self)
			self.flag_list[i] = info_cell
		end
		self:Flush()
	end)
end

function KuafuTaskFollowView:InitRankPanel()
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	-- self.rank_items = {}
	-- local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	-- res_async_loader:Load("uis/views/kuafuliujie_prefab", "RankItem", nil, function(prefab)
	-- 	for i = 1, RankItem_Num do
	-- 		local obj = ResMgr:Instantiate(prefab)
	-- 		local info_cell = GuildBattleRankRender.New(obj)
	-- 		info_cell:SetInstanceParent(self.node_list["NodeRankList"].transform)
	-- 		info_cell:SetIndex(i)
	-- 		self.rank_items[i] = info_cell
	-- 	end
		self:Flush()
	-- end)
end



function KuafuTaskFollowView:BagGetNumberOfCells()
	local data_list = KuafuGuildBattleData.Instance:GetRankInfo().rank_list
	return #data_list
end

function KuafuTaskFollowView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = GuildBattleRankRender.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	local data_list = KuafuGuildBattleData.Instance:GetRankInfo().rank_list or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
end


function KuafuTaskFollowView:UpdateOpenCountDownTime(elapse_time, total_time)
	if total_time - elapse_time > 0 then
		self.node_list["TimeTxt"].text.text = string.format(Language.XiuLuo.Time, TimeUtil.FormatSecond(total_time - elapse_time, 3))
	end
end

function KuafuTaskFollowView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "mvp_name" then
			local name_str = GuildData.Instance:GetGuildMvpInfo()
			self.node_list["MvpName"].text.text = name_str or Language.GuildShowView.XuWieYiDai
		elseif k == "bai_ye" then
			local fu_ben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
			fu_ben_icon_view:SetDownTimeActive(false)
			self.node_list["BaiYeShow"]:SetActive(true)
			self.node_list["GuildShow"]:SetActive(false)
			self.node_list["TaskParent"]:SetActive(false)
			local bai_ye_info = CityCombatData.Instance:GetBaiYeInfo()
			local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.KF_GUILDBATTLE)
			self.node_list["TextCount"].text.text = string.format(Language.CityCombat.ShengYuCount, bai_ye_cfg.worship_click_times)
			if bai_ye_info and next(bai_ye_info) and bai_ye_cfg then
				self.node_list["TextCount"].text.text = string.format(Language.CityCombat.ShengYuCount, bai_ye_cfg.worship_click_times - bai_ye_info.worship_times)
				self.node_list["RemindBaiYe"]:SetActive(self.is_show_remind_bai_ye)
				self:UpdateBaiYeBtnCD(bai_ye_info, bai_ye_cfg)
			end
		elseif k == "bai_ye_not_active" then
			self.node_list["BaiYeShow"]:SetActive(false)
		end
	end
	
	local rank_info = KuafuGuildBattleData.Instance:GetRankInfo()

	local notify_info = KuafuGuildBattleData.Instance:GetNotifyInfo()
	-- if rank_info and next(self.rank_items) then
	-- 	if nil ~= rank_info.rank_list then
	-- 		for i = 1, RankItem_Num do
	-- 			self.rank_items[i]:SetData(rank_info.rank_list[i])
	-- 		end
	-- 	end
	-- end
	local reward_item = KuafuGuildBattleData.Instance:GetScoreReward(notify_info.param_1)
	self.reward_obj:SetData(reward_item)
	if notify_info and notify_info.notify_type == SC_CROSS_GUILDBATTLE_INFO_TYPE.SC_CROSS_GUILDBATTLE_NOTIFY_TYPE_SCORE then
		if notify_info.param_1 >= reward_item.score  then
			self.node_list["TxtOwnScore"].text.text = string.format(Language.KuafuGuildBattle.KfOwnScore, notify_info.param_1, reward_item.score)
		else
			self.node_list["TxtOwnScore"].text.text = string.format(Language.KuafuGuildBattle.KfOwnScoreTwo, notify_info.param_1, reward_item.score)
		end
		
		local yilingwan_bool = KuafuGuildBattleData.Instance:GetMaxScoreReward(notify_info.param_1)
		self.node_list["GetShow"]:SetActive(yilingwan_bool)
	end

	if next(self.flag_list) and rank_info then
		if next(rank_info) then
			for i = 1, #rank_info.flag_list do
				self.flag_list[i]:SetData(rank_info.flag_list[i])
			end
		end
	end
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuafuTaskFollowView:GetCurTaskMonsterID()
	return self.cur_task_monster_id
end

function KuafuTaskFollowView:SetCurTaskMonsterID(index)
	self.cur_task_monster_id = index
end

function KuafuTaskFollowView:ResetCurTaskMonsterID()
	self.cur_task_monster_id = 0
end


-- 拜谒按钮监听
function KuafuTaskFollowView:OnClickBaiYe()
	GuajiCtrl.Instance:StopGuaji()
	GuajiType.IsManualState = false

	-- 寻路，发送拜谒请求
	self.is_show_remind_bai_ye = false
	local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.KF_GUILDBATTLE)
	local pos_x = bai_ye_cfg.worship_pos_x
	local pos_y = bai_ye_cfg.worship_pos_y
	local scene_id = KuafuGuildBattleData.Instance:GetSceneIdByIndex()
	if bai_ye_cfg and scene_id then
		local main_role = Scene.Instance:GetMainRole()
		local main_pos_x, main_pos_y = main_role:GetLogicPos()
		local distance = GameMath.GetDistance(main_pos_x, main_pos_y, pos_x, pos_y, false)		
		if Scene.Instance:GetSceneId() == scene_id and distance <= 10 * 10 then
			CityCombatCtrl.Instance:SendBaiYeReq()
		else
			local callback = function()
				MoveCache.end_type = MoveEndType.BAIYE
				GuajiCtrl.Instance:MoveToPos(scene_id, pos_x + math.floor(math.random(-8, 8)), pos_y + math.floor(math.random(-8, 8)))
			end
			callback()
			GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
		end
	 end
end

-- 设置拜谒计时器
function KuafuTaskFollowView:SetBaiYeDownTime()
	local complere_fun = function()
		if nil ~= self.down_time then
			CountDown.Instance:RemoveCountDown(self.down_time)
			self.down_time = nil
		end
	end
	
	if nil == self.down_time then
		local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.KF_GUILDBATTLE)
		local remaining_time = bai_ye_cfg.worship_time
		self.down_time = CountDown.Instance:AddCountDown(remaining_time, 1, function(elapse_time, total_time)
			if self.node_list and self.node_list["TextDownTime"] then
				local remaining_time = math.floor(total_time - elapse_time)
				self.node_list["TextDownTime"].text.text = TimeUtil.FormatSecond(remaining_time, 2)
			end
		end, complere_fun)
	end
end

-- 设置拜谒气泡提示框倒计时
function KuafuTaskFollowView:SetRemindBubbleActive()
	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end

	self.remind_bubble_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		if self.node_list and self.node_list["RemindBaiYe"] then
			self.node_list["RemindBaiYe"]:SetActive(false)
		end
	end, 5)
end

function KuafuTaskFollowView:GetIsBaiYe()
	return nil ~= self.down_time
end

-- 刷新拜谒按钮CD
function KuafuTaskFollowView:UpdateBaiYeBtnCD(bai_ye_info, bai_ye_cfg)
	self.node_list["CDText"].text.text = ""
	self.node_list["CDMask"].image.fillAmount = 0

	local complere_fun = function()
		if self.node_list and self.node_list["CDText"] and self.node_list["CDMask"] then
			self.node_list["CDText"].text.text = ""
			self.node_list["CDMask"].image.fillAmount = 0
		end
	end

	if bai_ye_info.next_worship_timestamp > 0 then
		if nil ~= self.bai_ye_cd then
			CountDown.Instance:RemoveCountDown(self.bai_ye_cd)
			self.bai_ye_cd = nil
		end
		
		local remaining_time = bai_ye_info.next_worship_timestamp - TimeCtrl.Instance:GetServerTime()
		self.bai_ye_cd = CountDown.Instance:AddCountDown(remaining_time, 0.05, function(elapse_time, total_time)
			local daiff_value = math.ceil(total_time - elapse_time)
			self.node_list["CDText"].text.text = daiff_value
			self.node_list["CDMask"].image.fillAmount = (total_time - elapse_time) / bai_ye_cfg.worship_click_cd
			if daiff_value <= 0 then
				self.node_list["CDText"].text.text = ""
				self.node_list["CDMask"].image.fillAmount = 0
			end
		end, complere_fun)
	end
end

----------------------------------------------BaseRender------------------------------------------------------------------------------
GuildBattleRankRender= GuildBattleRankRender or BaseClass(BaseRender)

function GuildBattleRankRender:__init()

end

function GuildBattleRankRender:__delete()
end

function GuildBattleRankRender:OnFlush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	end
	self.root_node:SetActive(true)
	self.node_list["TxtRank"].text.text = self.index
	self.node_list["TxtGuild"].text.text = self.data.guild_name
	self.node_list["TxtScore"].text.text = self.data.score
	self.node_list["TxtOwnNum"].text.text = self.data.own_num
	
	if self.index <= 3 then
		local bundle, asset = ResPath.GetRankIcon(self.index)
		self.node_list["TxtRank"]:SetActive(false)
		self.node_list["RankImage"]:SetActive(true)
		self.node_list["RankImage"].image:LoadSprite(bundle, asset)
	else
		self.node_list["RankImage"]:SetActive(false)
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["TxtRank"].text.text = index
	end
end

function GuildBattleRankRender:SetIndex(index)
	self.index = index
end

function GuildBattleRankRender:SetData(data)
	self.data = data
	self:Flush()
end

-----------奖励item------------
GuildBattleRewardRender= GuildBattleRewardRender or BaseClass(BaseRender)

local Max_Reward_Num = 3

function GuildBattleRewardRender:__init()
	self.item_cell = {}
	self.item_parent = {}
	for i = 1, Max_Reward_Num do
		self.item_parent[i] = self.node_list["item" .. i]
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self.item_parent[i])
	end
end

function GuildBattleRewardRender:__delete()
	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function GuildBattleRewardRender:SetData(data)
	-- local reward_data = ItemData.Instance:GetGiftItemList(data.reward_item.item_id)
	-- self.item_parent[1].gameObject:SetActive(false)
	-- if reward_data and next(reward_data)  then
	-- 	local data_2 = reward_data[1]
	-- 	self.item_cell[2]:SetData(data_2)
	-- 	self.item_parent[2].gameObject:SetActive(data_2 ~= nil)
	-- 	local data_3 = reward_data[2]
	-- 	self.item_cell[3]:SetData(data_3)
	-- 	self.item_parent[3].gameObject:SetActive(data_2 ~= nil)
	-- else
	-- 	local data_1 = {item_id = ResPath.CurrencyToIconId.kuafu_jifen, num = data.convert_credit}
	-- 	self.item_parent[2].gameObject:SetActive(true)
	-- 	self.item_cell[2]:SetData(data_1)
	-- 	self.item_parent[3].gameObject:SetActive(false)
	-- 	self.item_cell[1]:SetData(data.reward_item)
	-- 	self.item_parent[1].gameObject:SetActive(true)
	-- end
	for k ,v in ipairs(self.item_cell) do
		if data.reward_show[k-1] then
			v:SetData(data.reward_show[k-1])
			v:SetParentActive(true)
		else
			v:SetParentActive(false)
		end
	end

end

--------------------GuildBattleInfoRender----------------------------
GuildBattleInfoRender= GuildBattleInfoRender or BaseClass(BaseRender)

function GuildBattleInfoRender:__init()
	self.node_list["GuildFightFlagCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.now_guild_name = nil
	self.hp_index = 100
	self.save_monster_id = 0
end

function GuildBattleInfoRender:__delete()
	self.mother_view = nil
end

function GuildBattleInfoRender:SetMotherView(view)
	self.mother_view = view
end

function GuildBattleInfoRender:OnFlush()
	if nil == self.data then return end
	if self.data.max_hp <= 0 then
		self.data.max_hp = 100	--第一次开活动准备时间给个假的上线血量
		self.data.cur_hp = 100
	end
	local my_server_id = GameVoManager.Instance:GetMainRoleVo().server_id
	if self.data.plat_type ~= -1 and self.data.server_id ~= -1 then
		local guild_name = GameVoManager.Instance:GetMainRoleVo().guild_name
		if self.data.guild_name == guild_name then
			self.node_list["GuildNameTxt"].text.text = string.format(Language.KuafuGuildBattle.KfBattleOccupy, ToColorStr(self.data.guild_name, "#89F201FF"))
		else
			self.node_list["GuildNameTxt"].text.text = string.format(Language.KuafuGuildBattle.KfBattleOccupy, ToColorStr(self.data.guild_name, "#F9463BFF"))
		end
	else
		self.node_list["GuildNameTxt"].text.text = string.format(Language.KuafuGuildBattle.KfBattleOccupy, Language.KuafuGuildBattle.KfGuildNot)
	end

	self:CheckFlagState()

	local cur_hp_value = self.data.cur_hp / self.data.max_hp * 100

	self.node_list["NodeEffect"]:SetActive(false)
	-- 如果hp值发生变化,则
	if self.hp_index ~= cur_hp_value then
		self.hp_index = self.data.cur_hp / self.data.max_hp * 100
		self.node_list["NodeEffect"]:SetActive(true)
	end
	cur_hp_value = self.data.monster_id <= 0 and 1 or cur_hp_value
	self.node_list["ProgressImg"].slider.value = cur_hp_value


	if ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_GUILDBATTLE) then
		self.node_list["FlagRedImg"]:SetActive(self.index == 1)
		self.node_list["ImageImg"]:SetActive(self.index ~= 1)
		self.node_list["NameTxt"].text.text = self.index == 1 and Language.KuafuGuildBattle.Name1 or Language.KuafuGuildBattle.Name2
	end
end

function GuildBattleInfoRender:CheckFlagState()
	local flag_cfg = KuafuGuildBattleData.Instance:GetSceneFlagCfg(Scene.Instance:GetSceneId(), self.data.monster_id)
	local guild_name = GameVoManager.Instance:GetMainRoleVo().guild_name

	if flag_cfg then
		if self.data.guild_name == guild_name and self.data.server_id ~= -1 then
			self.node_list["IconImg"]:SetActive(false)
			self.node_list["IconImg2"]:SetActive(true)
			self.node_list["NameTxt"].text.text = ToColorStr(flag_cfg.flag_name,TEXT_COLOR.GREEN)
			self.node_list["FillImage"].image:LoadSprite("uis/views/kuafuliujie/images_atlas","progress_green")
			self:ChangeLine("green")
		elseif self.data.guild_name ~= guild_name and self.data.server_id ~= -1 then
			self.node_list["IconImg"]:SetActive(true)
			self.node_list["IconImg2"]:SetActive(false)
			self.node_list["NameTxt"].text.text = ToColorStr(flag_cfg.flag_name,TEXT_COLOR.YELLOW)
			self.node_list["FillImage"].image:LoadSprite("uis/views/kuafuliujie/images_atlas","progress_red")
			self:ChangeLine("red")
		else
			self.node_list["IconImg"]:SetActive(true)
			self.node_list["IconImg2"]:SetActive(false)
			self.node_list["NameTxt"].text.text = ToColorStr(flag_cfg.flag_name,TEXT_COLOR.YELLOW)
			self.node_list["FillImage"].image:LoadSprite("uis/views/kuafuliujie/images_atlas","progress_red")
			self:ChangeLine("red")
		end

		self.node_list["FlagRedImg"]:SetActive(flag_cfg.flag_type ~= 0)
		self.node_list["ImageImg"]:SetActive(not (flag_cfg.flag_type ~= 0))
	end
end

function GuildBattleInfoRender:ChangeLine(str)
	local value = self.data.cur_hp / self.data.max_hp
	if 0.5 < value and value < 0.75 then
		self.node_list["Line1"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
		self.node_list["Line2"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
		self.node_list["Line3"].image:LoadSprite(ResPath.GetKuaFuLiujieLine("grey"))
	elseif 0.25 < value and value < 0.5 then
		self.node_list["Line1"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
		self.node_list["Line2"].image:LoadSprite(ResPath.GetKuaFuLiujieLine("grey"))
		self.node_list["Line3"].image:LoadSprite(ResPath.GetKuaFuLiujieLine("grey"))
	elseif 0 < value and value < 0.25 then
		self.node_list["Line1"].image:LoadSprite(ResPath.GetKuaFuLiujieLine("grey"))
		self.node_list["Line2"].image:LoadSprite(ResPath.GetKuaFuLiujieLine("grey"))
		self.node_list["Line3"].image:LoadSprite(ResPath.GetKuaFuLiujieLine("grey"))
	elseif 0.75 < value and value < 1 then
		self.node_list["Line1"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
		self.node_list["Line2"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
		self.node_list["Line3"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
	elseif value == 1 then
		self.node_list["Line1"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
		self.node_list["Line2"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
		self.node_list["Line3"].image:LoadSprite(ResPath.GetKuaFuLiujieLine(str))
	end
end


function GuildBattleInfoRender:OnClick()
	local flag_cfg = KuafuGuildBattleData.Instance:GetSceneFlagCfg(Scene.Instance:GetSceneId(), self.data.monster_id)
	if nil ~= flag_cfg then
		self.root_node.toggle.isOn = true
		MoveCache.param_1 = self.data.monster_id
		GuajiCache.monster_id = self.data.monster_id
		MoveCache.end_type = MoveEndType.FightByMonsterId
		GuajiCtrl.Instance:MoveToPos(flag_cfg.scene_id,flag_cfg.monster_x, flag_cfg.monster_y, 10, 10)
	end
end


function GuildBattleInfoRender:SetData(data)
	self.data = data
	self:Flush()
end

function GuildBattleInfoRender:SetIndex(index)
	self.index = index
end
