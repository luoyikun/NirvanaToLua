KaifuActivityGoldenPigCallView = KaifuActivityGoldenPigCallView or BaseClass(BaseRender)
--开服活动龙神召唤 
local MAX_CALL_BUTTON_NUM = 3

function KaifuActivityGoldenPigCallView:__init()
	self.call_award_list = {}
	self.join_award_list = {}
	self.next_timer = nil

	local button_list = {
		self.node_list["BtnJuniorCall"],
		self.node_list["BtnMiddleCall"],
		self.node_list["BtnSeniorCall"],
	}

	self.text_button_list = {
		self.node_list["TxtInBtnJunior"],
		self.node_list["TxtInBtnMiddle"],
		self.node_list["TxtInBtnSenior"],
	}

	self.text_call_num_list = {
		self.node_list["TxtJunior"],
		self.node_list["TxtMiddle"],
		self.node_list["TxtSenior"],
	}

	self.effect_node = {
		self.node_list["NodeJuniorEffect"],
		self.node_list["NodeMiddleEffect"],
		self.node_list["NodeSeniorEffect"],
	}
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	for i = 1, MAX_CALL_BUTTON_NUM do
		local call_award_item = ItemCell.New()
		call_award_item:SetInstanceParent(self.node_list["NodeCallReward" .. i])
		call_award_item:SetData(nil)

		local join_award_item = ItemCell.New()
		join_award_item:SetInstanceParent(self.node_list["NodeJoinRaward" .. i])
		join_award_item:SetData(nil)

		table.insert(self.call_award_list, call_award_item)
		table.insert(self.join_award_list, join_award_item)

		button_list[i].button:AddClickListener(BindTool.Bind(self.OnClickBtnCallItem, self, i))
	end
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OpenHelp,self))
	self.node_list["BtnAddGold"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi,self))
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["DisplayModel"].ui3d_display)

	self.name_list = {
		[0] = "junior",
		[1] = "medium",
		[2] = "senior",
	}
	ClickOnceRemindList[RemindName.LongShenZhaoHuan] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.LongShenZhaoHuan)
end

function KaifuActivityGoldenPigCallView:__delete()
	for k, v in pairs(self.call_award_list) do
		v:DeleteMe()
	end

	for k, v in pairs(self.join_award_list) do
		v:DeleteMe()
	end

	self.text_left_call_num = nil
	self.call_award_list = {}
	self.join_award_list = {}
	self.text_call_num_list = {}
	self.text_button_list = {}
	self.effect_node = {}

	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	self.name_list = nil
	self.fight_text = nil
end

function KaifuActivityGoldenPigCallView:OnFlush()
	local left_num_info = KaifuActivityData.Instance:GetGoldenPigCallInfo() or {}
	self.node_list["TxtCurNum"].text.text = CommonDataManager.ConverMoney(left_num_info.current_chongzhi or 0)
    --每种召唤需要的积分显示
	local basic_cfg = KaifuActivityData.Instance:GetGoldenPigBasisCfg() or {}

	for i = 1, MAX_CALL_BUTTON_NUM do
		local call_name = self.name_list[i-1] .. "_summon_consume"
		if basic_cfg[1] ~= nil then
			self.text_call_num_list[i].text.text =string.format(Language.Activity.CallPoint, basic_cfg[1][call_name])  
		end
	end

	local text_left_call_num_info = left_num_info.summon_credit or 0
	local need_diamond_num_info =  basic_cfg[1]~= nil and basic_cfg[1].gold_consume or 0

	local color = text_left_call_num_info > 0 and "#67ff5f" or TEXT_COLOR.RED
	local text_left_call_num_info = ToColorStr(text_left_call_num_info, color)

	self.node_list["ZhaoHuanText"].text.text = text_left_call_num_info
	local str = string.format(Language.Activity.DragonGodCall, need_diamond_num_info)

	RichTextUtil.ParseRichText(self.node_list["TxtLeftCallNum"].rich_text, str, 22)

	--召唤奖励和参与奖励图片显示
	local item_img_list = KaifuActivityData.Instance:GetCurCallCfg()

	if nil == item_img_list then return end

	for i, v in ipairs(item_img_list) do
		local call_table = v.summon_reward
		self.call_award_list[i]:SetData(call_table)
		self.call_award_list[i]:IsDestoryActivityEffect(false)
		self.call_award_list[i]:SetActivityEffect()
		local join_table = v.joiner_reward
		self.join_award_list[i]:SetData(join_table)
		if i == MAX_CALL_BUTTON_NUM then
			self.join_award_list[i]:SetActivityEffect()
		end
		
	end

	if self.next_timer == nil then
		self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	end
	
	self:ChangeRoleModel(item_img_list[1])
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = item_img_list[1].power or 0
	end
	self.node_list["TxtModelName"].text.text = item_img_list[1].model_name or 0
	--Boss是否出现，出现显示前往击杀，未出现显示XX召唤  0不存在,1存在
	local boss_state_info = KaifuActivityData.Instance:GetGoldenPigCallBossInfo()
	for i = 1, MAX_CALL_BUTTON_NUM do
		self.text_button_list[i].text.text = Language.Activity.BossCallNameList[i]
		self.effect_node[i]:SetActive(false)
	end

	if nil ~= boss_state_info then
		for i, v in ipairs(boss_state_info) do
			if v == 1 then
				self.text_button_list[i].text.text = Language.Activity.GoFindBoss
				local level = GameVoManager.Instance:GetMainRoleVo().level
				if level >= 170 then
					--等级超过170级出现特效
					self.effect_node[i]:SetActive(true)
				end
			end
		end
	end
end

function KaifuActivityGoldenPigCallView:FlushNextTime()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG
	local time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end

	self.node_list["TxtRestTime"].text.text = time_str

end

function KaifuActivityGoldenPigCallView:OnClickBtnCallItem(index)
	local boss_state_info = KaifuActivityData.Instance:GetGoldenPigCallBossInfo()
	if boss_state_info ~= nil and boss_state_info[index] and boss_state_info[index] == 1 then
		KaifuActivityCtrl.Instance:CloseKaiFuView()
		local golden_cfg = KaifuActivityData.Instance:GetGoldenCallPositionCfg(index - 1)
		if golden_cfg ~= nil then
			MapLocalView:FlyToPos(golden_cfg.scene_id, golden_cfg.pos_x, golden_cfg.pos_y)
		end
		return
	end

	
	local callindex = index - 1
	local left_num_info = KaifuActivityData.Instance:GetGoldenPigCallInfo()
	local left_call_num = left_num_info and left_num_info.summon_credit or 0
	local basic_cfg = KaifuActivityData.Instance:GetGoldenPigBasisCfg() or {}
	local need_call_num = basic_cfg[1] and basic_cfg[1][self.name_list[callindex] .. "_summon_consume"] or 0
	need_call_num = need_call_num or 0
	if left_call_num < need_call_num then
		TipsCtrl.Instance:ShowLackJiFenView()
		return
	end

	KaifuActivityCtrl.Instance:SendGoldenPigCallInfoReq(GOLDEN_PIG_OPERATE_TYPE.GOLDEN_PIG_OPERATE_TYPE_SUMMON, callindex)
	return
end

function KaifuActivityGoldenPigCallView:OpenHelp()
	local tips_id = 198
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--模型显示
function  KaifuActivityGoldenPigCallView:ChangeRoleModel(cur_cfg)
	if nil == cur_cfg or nil == cur_cfg.path then
		return
	end
	local show_model = cur_cfg.show_model
	local bundle = cur_cfg.path
	local asset = cur_cfg.show_item

	if show_model == DISPLAY_TYPE.HALO then
		local main_role = Scene.Instance:GetMainRole()
		self.model_view:SetRoleResid(main_role:GetRoleResId())
		self.model_view:SetHaloResid(asset)
	elseif show_model == DISPLAY_TYPE.XIAN_NV then
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetTrigger("show_idle_1")
	elseif show_model == DISPLAY_TYPE.MOUNT then
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetTrigger(ANIMATOR_PARAM.REST)
	elseif show_model == DISPLAY_TYPE.WING then
		local main_role = Scene.Instance:GetMainRole()
		self.model_view:SetRoleResid(main_role:GetRoleResId())
		self.model_view:SetWingResid(asset)
	elseif show_model == DISPLAY_TYPE.WEAPON then
		self.model_view:SetMainAsset(bundle, asset)
	elseif show_model == DISPLAY_TYPE.GATHER then
		self.model_view:SetMainAsset(bundle, asset)
	elseif show_model == DISPLAY_TYPE.ZHIBAO then
		self.model_view:SetMainAsset(bundle .. "_prefab", asset)
	else
		local rotation = Vector3(0, 0, 0)
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetRotation(rotation)
	end
end

function KaifuActivityGoldenPigCallView:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end