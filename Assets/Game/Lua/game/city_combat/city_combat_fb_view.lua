CityCombatFBView = CityCombatFBView or BaseClass(BaseView)

function CityCombatFBView:__init()
	self.ui_config = {{"uis/views/citycombatview_prefab", "CityCombatFBView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.active_close = false
	self.fight_info_view = true
	self.auto_guaji = false
end

function CityCombatFBView:ReleaseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)

	GlobalEventSystem:UnBind(self.enter_fight)
	GlobalEventSystem:UnBind(self.exit_fight)

	if self.buttons then
		self.buttons:DeleteMe()
		self.buttons = nil
	end

	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.main_role_revive then
		GlobalEventSystem:UnBind(self.main_role_revive)
		self.main_role_revive = nil
	end
	if self.move_by_click then
		GlobalEventSystem:UnBind(self.move_by_click)
		self.move_by_click = nil
	end
	if self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.rank_data = {}

	for k,v in pairs(self.rank_list) do
		v:DeleteMe()
	end
	self.rank_list = {}

	self:RemoveCountDown()
	self:RemoveDelayTime()

	if nil ~= self.bai_ye_cd then
		CountDown.Instance:RemoveCountDown(self.bai_ye_cd)
		self.bai_ye_cd = nil
	end

	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end
	
end

function CityCombatFBView:PoChengReset()
	if not self:IsLoaded() then
		return
	end
	self.node_list["PanelTimer"]:SetActive(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	local function diff_time_func(elapse_time, total_time)
		local left_time = math.ceil(total_time - elapse_time)
		if elapse_time >= total_time then
			self.node_list["PanelTimer"]:SetActive(false)
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
			self:RemoveCountDown()
		end
		self.node_list["TxtTimer"].text.text = left_time
	end
	diff_time_func(0, 3)
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(
		3, 1, diff_time_func)
end

function CityCombatFBView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if nil ~= self.down_time_dis then
		CountDown.Instance:RemoveCountDown(self.down_time_dis)
		self.down_time_dis = nil
	end
end

function CityCombatFBView:LoadCallBack()
	self.node_list["TaskButton"].toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self))
	self.node_list["BtnGuildShow"].button:AddClickListener(BindTool.Bind(self.OnClickGuildShowView, self))
	self.node_list["BaiYeShow"]:SetActive(false)
	self.node_list["BtnBaiYe"].button:AddClickListener(BindTool.Bind(self.OnClickBaiYe, self))
	self.is_show_remind_bai_ye = true
	self.is_first = true

	self.rank_list = {}
	local list_delegate = self.node_list["RankLayoutList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local list_delegateone = self.node_list["RankLayoutList1"].list_simple_delegate
	list_delegateone.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegateone.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.item_list = {}
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
		self.item_list[i].root_node.transform:SetLocalScale(0.8, 0.8, 0.8)
		self.item_list[i]:SetData(nil)
	end

	self.node_list["TxtName"].text.text = ""
	self.node_list["TxtCurrTime"].text.text = ""
	self.node_list["PanelTimer"]:SetActive(false)
	self.select_rank = 1
	self.have_def_guild = false
	self.is_show_remind_bai_ye = true 
	self:Flush()
	self:FlushDefGuildTime()

	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
	self.enter_fight = GlobalEventSystem:Bind(ObjectEventType.ENTER_FIGHT, BindTool.Bind(self.FightStateChange, self, true))
	self.exit_fight = GlobalEventSystem:Bind(ObjectEventType.EXIT_FIGHT, BindTool.Bind(self.FightStateChange, self, false))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.main_role_revive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind(self.MainRoleRevive, self))
	self.move_by_click = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK, BindTool.Bind(self.OnMoveByClick, self))
	self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.OnGuajiTypeChange, self))

	self.auto_guaji = GuajiCache.guaji_type == GuajiType.Auto
end

function CityCombatFBView:GetNumberOfCells()
	return #self.rank_data
end

-- 打开仙盟输出展示面板
function CityCombatFBView:OnClickGuildShowView()
	GuildCtrl.Instance:OpenGuildShowView(ACTIVITY_TYPE.GONGCHENGZHAN)
end

function CityCombatFBView:FlushDiaoXiangHp()
	local hp = CityCombatData.Instance:GetDiaoXiangHp() or 0
	if self.node_list and self.node_list["HP"] then
		local num = math.floor(hp * 10000) / 100 or 0
		self.node_list["HP"].text.text = num .. "%"
	end
end

-- 拜谒按钮监听
function CityCombatFBView:OnClickBaiYe()
	GuajiCtrl.Instance:StopGuaji()
	GuajiType.IsManualState = false

	-- 寻路，发送拜谒请求
	self.is_show_remind_bai_ye = false
	local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.GONGCHENGZHAN)
	local pos_x = bai_ye_cfg.worship_pos_x
	local pos_y = bai_ye_cfg.worship_pos_y
	if bai_ye_cfg then
		local main_role = Scene.Instance:GetMainRole()
		local main_pos_x, main_pos_y = main_role:GetLogicPos()
		local distance = GameMath.GetDistance(main_pos_x, main_pos_y, pos_x, pos_y, false)	
		if distance <= 10 * 10 then
			CityCombatCtrl.Instance:SendBaiYeReq()
		else
			MoveCache.end_type = MoveEndType.BAIYE
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos_x + math.floor(math.random(-8, 8)), pos_y + math.floor(math.random(-8, 8)), 0, 0)
		end
	 end
end

-- 设置拜谒计时器
function CityCombatFBView:SetBaiYeDownTime()
	local complere_fun = function()
		FuBenCtrl.Instance:SendExitFBReq()
		if nil ~= self.down_time_dis then
			CountDown.Instance:RemoveCountDown(self.down_time_dis)
			self.down_time_dis = nil
		end
	end

	if nil == self.down_time_dis then
		local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.GONGCHENGZHAN)
		local remaining_time = bai_ye_cfg.worship_time
		self.down_time_dis = CountDown.Instance:AddCountDown(remaining_time, 1, function(elapse_time, total_time)
			local remaining_time = math.floor(total_time - elapse_time)
			self.node_list["TextDownTime"].text.text = TimeUtil.FormatSecond(remaining_time, 2)
			if remaining_time <= 0 then
				FuBenCtrl.Instance:SendExitFBReq()
			end
		end, complere_fun)
	end
end

-- 设置拜谒气泡提示框倒计时
function CityCombatFBView:SetRemindBubbleActive()
	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end

	self.remind_bubble_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		if self.node_list["RemindBaiYe"] then
			self.node_list["RemindBaiYe"]:SetActive(false)
		end
	end, 5)
end

function CityCombatFBView:GetIsBaiYe()
	return nil ~= self.down_time_dis
end

-- 刷新拜谒按钮CD
function CityCombatFBView:UpdateBaiYeBtnCD(bai_ye_info, bai_ye_cfg)
	self.node_list["CDText"].text.text = ""
	self.node_list["CDMask"].image.fillAmount = 0

	local complere_fun = function()
		self.node_list["CDText"].text.text = ""
		self.node_list["CDMask"].image.fillAmount = 0
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

function CityCombatFBView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	if nil == self.rank_list[cell] then
		self.rank_list[cell] = CityCombatRankCell.New(cell.gameObject)
		self.rank_list[cell].parent_view = self
	end
	if nil ~= self.rank_data[data_index] then
		local cell_data = self.rank_data[data_index]
		cell_data.data_index = data_index
		self.rank_list[cell]:SetData(cell_data)
	end
end

function CityCombatFBView:FightStateChange(is_fight)
	-- self.buttons.node_list["BtnResZone"]:SetActive(is_fight)
	-- self.buttons.node_list["ImgZiYuan"]:SetActive(is_fight)
end

function CityCombatFBView:FlushDefGuildTime()
	if not self:IsLoaded() then
		return
	end
	local def_guild_data = CityCombatData.Instance:GetGlobalInfo()
	if def_guild_data == nil or def_guild_data.shou_guild_name == nil or def_guild_data.shou_guild_name == "" then
		self.node_list["TxtName"].text.text = Language.Common.No
		self.node_list["TxtCurrTime"].text.text = ""
		self.have_def_guild = false
		return
	end
	self.node_list["TxtName"].text.text = def_guild_data.shou_guild_name
	self.time_count = def_guild_data.cu_def_guild_time
	self.have_def_guild = true
end

function CityCombatFBView:Timer()
	if self.have_def_guild then
		self.time_count = self.time_count + 1
		local time_count = TimeUtil.FormatSecond(self.time_count, 2)
		if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENGZHAN) then
			time_count = 0
		end
		self.node_list["TxtCurrTime"].text.text = string.format(Language.CityCombat.DefenseTime, ToColorStr(time_count, TEXT_COLOR.GREEN))
		CityCombatData.Instance:ReSetRank(self.time_count)
	end
	self:FlushRank()
end

function CityCombatFBView:NumberForShort(num)
	local text = ""
	if num < 10000 then
		text = num
	else
		text = math.floor(num / 10000) .. Language.Common.Wan
	end
	return text
end

function CityCombatFBView:FlushItemList()
	local next_zhangong_reward = CityCombatData.Instance:GetNextZhanGongReward()
	--奖励
	for k, v in ipairs(self.item_list) do
		local index = k - 1
		local reward_list = next_zhangong_reward["reward_item"] or {}
		local reward = reward_list[index]
		if reward then
			v:SetActive(true)
			v:SetData(reward)
		else
			if next_zhangong_reward.sheng_wang and next_zhangong_reward.sheng_wang > 0 then
				v:SetActive(true)
				local data = {}
				data.item_id = ResPath.CurrencyToIconId["honor"]
				data.num = next_zhangong_reward.sheng_wang
				v:SetData(data)
			else
				v:SetActive(false)
			end
		end
	end
end

function CityCombatFBView:OnFlush(param_t)
	if not self:IsLoaded() then
		return
	end

	for k, v in pairs(param_t) do
		if k == "mvp_name" then
			local name_str = GuildData.Instance:GetGuildMvpInfo()
			self.node_list["MvpName"].text.text = name_str or Language.GuildShowView.XuWieYiDai
		elseif k == "bai_ye" then
			local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.GONGCHENGZHAN)
			if nil ~= activity_info and ACTIVITY_STATUS.CLOSE == activity_info.status then
				local fu_ben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
				fu_ben_icon_view:SetDownTimeActive(false)
				self.node_list["BaiYeShow"]:SetActive(true)
				if self.is_first then
					if self.buttons then
						self.buttons:DeleteMe()
						self.buttons = nil
					end
					MainUICtrl.Instance:ShowActivitySkill(false)
					self.is_first = false
				end
				local is_poqiang = CityCombatData.Instance:GetIsPoQiang()
				if is_poqiang <= 0 then
					local scene_logic = Scene.Instance:GetSceneLogic()
					if scene_logic then
						scene_logic:SetBlock(false)
						Scene.Instance:CreateDoorList()
					end
				end
				local bai_ye_info = CityCombatData.Instance:GetBaiYeInfo()
				local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.GONGCHENGZHAN)
				self.node_list["TextCount"].text.text = string.format(Language.CityCombat.ShengYuCount, bai_ye_cfg.worship_click_times)
				if bai_ye_info and next(bai_ye_info) and bai_ye_cfg then
					self.node_list["TextCount"].text.text = string.format(Language.CityCombat.ShengYuCount, bai_ye_cfg.worship_click_times - bai_ye_info.worship_times)
					self.node_list["RemindBaiYe"]:SetActive(self.is_show_remind_bai_ye)
					self:UpdateBaiYeBtnCD(bai_ye_info, bai_ye_cfg)
				end
			end
		end
	end

	--战功
	local self_info = CityCombatData.Instance:GetSelfInfo()
	local next_zhangong_reward = CityCombatData.Instance:GetNextZhanGongReward()
	local text = ""
	local self_zhangong_text = self:NumberForShort(self_info.zhangong)
	local next_reward_text = next_zhangong_reward.zhangong

	if self.now_max_zhangong ~= next_reward_text then
		self.now_max_zhangong = next_reward_text
		self:FlushItemList()
	end
	-- local max_zhanggong = CityCombatData.Instance:GetMaxZhanGong()
	-- local flag = tonumber(self_info.zhangong) >= tonumber(max_zhanggong)
	-- self.node_list["HasGet"]:SetActive(flag)

	if self_info.zhangong > next_zhangong_reward.zhangong then
		text = ToColorStr(self_zhangong_text .. " / " .. next_reward_text, TEXT_COLOR.GREEN_4)
	else
		text = ToColorStr(self_zhangong_text, TEXT_COLOR.RED_4) .. ToColorStr(" / " .. next_reward_text, TEXT_COLOR.GREEN_4)
	end
	self.node_list["TxtRewardCount"].text.text = string.format(Language.Activity.CityCombatScoreRew, text)
	--排名
	self:FlushRank()

	if self.buttons then
		self.buttons:Flush()
	end

end

function CityCombatFBView:FlushRank()
	if self.select_rank == 1 then
		self.rank_data = CityCombatData.Instance:GetTimeRankList()
		self.node_list["RankLayoutList"]:SetActive(false)
		self.node_list["RankLayoutList1"]:SetActive(true)
		self.node_list["ItemList"]:SetActive(false)
		self.node_list["HasGet"]:SetActive(false)
		self.node_list["TxtRewardCount"]:SetActive(false)
		self.node_list["HeadLine"]:SetActive(false)
		self.node_list["HeadLine1"]:SetActive(true)
		self.node_list["Xmranktext"]:SetActive(true)
	else
		self.rank_data = CityCombatData.Instance:GetZhanGongRankList()
		self.node_list["RankLayoutList1"]:SetActive(false)
		self.node_list["RankLayoutList"]:SetActive(true)
		self.node_list["ItemList"]:SetActive(true)
		local self_info = CityCombatData.Instance:GetSelfInfo()
		local max_zhanggong = CityCombatData.Instance:GetMaxZhanGong()
		local flag = tonumber(self_info.zhangong) >= tonumber(max_zhanggong)
		self.node_list["HasGet"]:SetActive(flag)
		self.node_list["TxtRewardCount"]:SetActive(true)
		self.node_list["HeadLine1"]:SetActive(false)
		self.node_list["HeadLine"]:SetActive(true)
		self.node_list["Xmranktext"]:SetActive(false)
	end

	local my_guildrank = CityCombatData.Instance:GetMyGuildRank()
	if self.select_rank == 1 then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id or 0
		if CityCombatData.Instance:IsMyGuildInList(guild_id) then
			self.node_list["Xmranktext"].text.text = string.format(Language.CityCombat.MyRankName, my_guildrank)
		else
			self.node_list["Xmranktext"].text.text = string.format(Language.CityCombat.MyRankName, Language.Common.NoRank)
		end
	end
	if self.node_list["RankLayoutList"].scroller.isActiveAndEnabled then
		self.node_list["RankLayoutList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
		if self.node_list["RankLayoutList1"].scroller.isActiveAndEnabled then
		self.node_list["RankLayoutList1"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	for i = 1, #self.rank_list do
		self.rank_list[i]:SetActive(self.rank_data[i] ~= nil)
	end
end

function CityCombatFBView:OpenCallBack()
	self.now_max_zhangong = 0

	local loader = AllocAsyncLoader(self, "skill_button_loader")
	loader:Load("uis/views/citycombatview_prefab", "CityCombatSkills", function (obj)
		if IsNil(obj) then
			return
		end

		MainUICtrl.Instance:ShowActivitySkill(obj)
		if nil == self.buttons then
			self.buttons = CityCombatSkillRender.New(obj)
			-- self.buttons:AddClickListener(BindTool.Bind(self.CutFlag, self))
			self.buttons:Flush()
		end
	end)
end

function CityCombatFBView:CloseCallBack()
	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.buttons then
		self.buttons:DeleteMe()
		self.buttons = nil
	end
	self:RemoveCountDown()
end

function CityCombatFBView:OnMainUIModeListChange(is_show)
	self.node_list["Ani"]:SetActive(is_show)
end

function CityCombatFBView:ToggleChange(is_on)
	if is_on then
		self.select_rank = 1
	else
		self.select_rank = 2
	end
	self:FlushRank()
end

-- --寻路至资源区
-- function CityCombatFBView:ToResourceZone()
-- 	CityCombatCtrl.Instance:QuickChangePlace(CITY_COMBAT_MOVE_TYPE.ZHIYUAN_PLACE)
-- end

--寻路至砍旗
-- function CityCombatFBView:CutFlag()
-- 	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
-- end

function CityCombatFBView:OnMoveByClick()
	self.auto_guaji = false
end

function CityCombatFBView:MainRoleRevive()
	if self.auto_guaji then
		self:RemoveDelayTime()
		-- 延迟是因为主角复活后有可能坐标还没有reset
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto) end, 0.5)
	end
end

function CityCombatFBView:OnGuajiTypeChange(guaji_type)
	if guaji_type == GuajiType.Auto then
		self.auto_guaji = true
	end
end

function CityCombatFBView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

----------------------------------------------------------------------------
-- 场景技能按钮
----------------------------------------------------------------------------

CityCombatSkillRender = CityCombatSkillRender or BaseClass(BaseRender)
function CityCombatSkillRender:__init()
	self.time_last = 0
end

function CityCombatSkillRender:LoadCallBack()
	self.node_list["BtnFlag"].button:AddClickListener(BindTool.Bind(self.CutFlag, self))
	-- self.node_list["ButtonEXSkill"]:SetActive(false)
	-- self.node_list["ButtonEXSkill"].button:AddClickListener(BindTool.Bind(self.EXSkill, self))
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSkillCD, self), 0.1)
end

function CityCombatSkillRender:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function CityCombatSkillRender:EXSkill()
	-- local index = 1
	-- local cfg = FuBenData.Instance:GetArmorDefendSkillCfg(index)
	-- if nil == cfg then
	-- 	return
	-- end
	local skill_data = CityCombatData.Instance:GetChengZhuSkillid()
	-- local time_list = FuBenData.Instance:GetArmorPerformTimeList()
	-- local time = time_list and (time_list[2] - TimeCtrl.Instance:GetServerTime()) or 0
	local time = TimeCtrl.Instance:GetServerTime() - self.time_last 
	if time < skill_data[1].cd_s then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillCD)
		return
	end

	local target_obj = GuajiCtrl.Instance:SelectAtkTarget(false)
	if nil == target_obj then
		SysMsgCtrl.Instance:ErrorRemind(Language.Dungeon.TowerEnergyNotTarget)
		return
	end
	self.select_obj = target_obj
	local target_x, target_y = target_obj:GetLogicPos()

	if not GuajiCtrl.CheckRange(target_x, target_y, 10) then
		-- TipsCtrl.Instance:ShowSystemMsg(Language.Role.AttackDistanceFar)
		local scene_id = Scene.Instance:GetSceneId()
		MoveCache.end_type = MoveEndType.UseAoeSkill
		GuajiCtrl.Instance:MoveToPos(scene_id, target_x, target_y, 9, 0)
		return
	end
	self:SedUseSkill()
end

function CityCombatSkillRender:SedUseSkill()
	self.time_last = TimeCtrl.Instance:GetServerTime()
	local main_role = Scene.Instance:GetMainRole()
	local main_role_x, main_role_y = main_role:GetLogicPos()
	local target_x, target_y = self.select_obj:GetLogicPos()
	FightCtrl.SendPerformSkillReq(0, 0, target_x, target_y, self.select_obj:GetObjId(), true, main_role_x, main_role_y)
	self:PlaySkillAnim(self.select_obj)
end

function CityCombatSkillRender:PlaySkillAnim(target_obj)
	if self.select_obj == nil then return end
	local pos = self.select_obj:GetLuaPosition()
	local bundle_name, asset_name = ResPath.GetMiscEffect("tongyong_JN_zhendi")
	EffectManager.Instance:PlayControlEffect(self, bundle_name, asset_name, Vector3(pos.x, pos.y + 1, pos.z), nil)
		-- 播放动作
	local main_role = Scene.Instance:GetMainRole()
	if nil ~= main_role.draw_obj then
		local main_part = main_role.draw_obj:GetPart(SceneObjPart.Main)
		if nil ~= main_part then
			main_part:SetTrigger("attack17")
		end
	end
end

function CityCombatSkillRender:UpdateSkillCD()
	local skill_data = CityCombatData.Instance:GetChengZhuSkillid()
	-- local skill_cfg = FuBenData.Instance:GetArmorDefendSkillCfg()
	-- local time_list = FuBenData.Instance:GetArmorPerformTimeList()
	-- self.time_last = 0
	if skill_data[1] and self.time_last then
		local time = TimeCtrl.Instance:GetServerTime() - self.time_last
		if time < skill_data[1].cd_s then
			self.node_list["CDText"]:SetActive(true)
			self.node_list["CDText"].text.text = math.ceil(skill_data[1].cd_s - time)
			if skill_data[1].cd_s > 0 then
				self.node_list["CDMask"]:SetActive(true)
				self.node_list["CDMask"]:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = (skill_data[1].cd_s - time) / skill_data[1].cd_s
			end
		else
			self.node_list["CDText"].text.text = 0
			self.node_list["CDText"]:SetActive(false)
			self.node_list["CDMask"]:SetActive(false)
		end	
	end
end

function CityCombatSkillRender:CutFlag()
	local is_atk_side = CityCombatData.Instance:GetIsAtkSide()
	local is_destroy = CityCombatData.Instance:GetwallIsDestroy()
	local monster = CityCombatData.Instance:GetFlagInfo()
	if not is_destroy then
		monster = CityCombatData.Instance:GetWallInfo()
	end
	if is_atk_side or is_destroy then
		if monster and monster.id and monster.id > 0 then
			MoveCache.param_1 = monster.id
			GuajiCache.monster_id = monster.id
			MoveCache.end_type = MoveEndType.FightByMonsterId
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), monster.x, monster.y, 2, 0)
		else
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
	else
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	end
end

function CityCombatSkillRender:OnFlush()
	local is_atk_side = CityCombatData.Instance:GetIsAtkSide()
	local is_destroy = CityCombatData.Instance:GetwallIsDestroy()

	self.node_list["TxtKanQi"]:SetActive(is_atk_side and is_destroy)
	self.node_list["TxtKanMen"]:SetActive(is_atk_side and not is_destroy)
	self.node_list["TxtShouQI"]:SetActive(not is_atk_side and is_destroy)
	self.node_list["TxtShouMen"]:SetActive(not is_atk_side and not is_destroy)

	if CityCombatData.Instance:GetIsAtkSide() then
		self.node_list["ImgSkill"].image:LoadSprite(ResPath.GetRoleSkillIcon("4001"))
	else
		self.node_list["ImgSkill"].image:LoadSprite(ResPath.GetRoleSkillIcon("4002"))
	end
end

----------------------------------------------------------------------------
--CityCombatRankCell 		排名格子
----------------------------------------------------------------------------
CityCombatRankCell = CityCombatRankCell or BaseClass(BaseCell)
function CityCombatRankCell:__init()
	self.parent_view = parent
end

function CityCombatRankCell:__delete()
	self.parent_view = nil
end

function CityCombatRankCell:OnFlush()
	if nil == self.data then return end
	if self.data.data_index <= 3 then
		self.node_list["TxtRank"]:SetActive(false)
		self.node_list["ImageRank"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(self.data.data_index)
		self.node_list["ImageRank"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["ImageRank"]:SetActive(false)
	end
	self.node_list["TxtRank"].text.text = self.data.data_index
	self.node_list["TxtName"].text.text = self.data.name
	local value = self.data.value
	if self.parent_view.select_rank == 1 then
		value = TimeUtil.FormatSecond(self.data.value, 2)
	end

	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENGZHAN) then
		value = 0
	end
	self.node_list["TxtTime"].text.text = value
	-- self.node_list["ImgMask"]:SetActive(self.data.is_self)
end
