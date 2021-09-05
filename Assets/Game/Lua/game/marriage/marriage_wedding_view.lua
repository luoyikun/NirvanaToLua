MarriageWeddingView = MarriageWeddingView or BaseClass(BaseView)

local YanHuiType = {
	Normal = 1,			--普通婚宴
	Special = 2			--豪华婚宴
}

function MarriageWeddingView:__init()
self.ui_config = {
		{"uis/views/marriageview_prefab", "HunYanContent"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true
end

function MarriageWeddingView:__delete()

end

function MarriageWeddingView:LoadCallBack()
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.HoldWeddingClick, self))
	self.node_list["Toggle1"].toggle:AddClickListener(BindTool.Bind(self.UseNomralWeddingChange, self))
	self.node_list["Toggle2"].toggle:AddClickListener(BindTool.Bind(self.UseSpecialDiamondChange, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.HelpClick, self))
	self.node_list["ButtonInvite"].button:AddClickListener(BindTool.Bind(self.OnClickInvite, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.is_use_bind_diamond = 1

	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell"..i])
	end
	self:Flush()
end
function MarriageWeddingView:OpenCallBack()

end

function MarriageWeddingView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function MarriageWeddingView:HelpClick()
	local tips_id = 70 -- 结婚帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MarriageWeddingView:Flush()
	local role_msg_info = MarriageData.Instance:GetYuYueRoleInfo()
	local is_holding_weeding = MarriageData.Instance:GetIsHoldingWeeding()

	for i=1,4 do
		self.node_list["ItemCell" .. i]:SetActive(false)
	end
	self.node_list["Toggle1"].toggle.interactable = not is_holding_weeding
	self.node_list["Toggle2"].toggle.interactable = not is_holding_weeding
	-- for i = 1, 2 do
	-- 	if self.node_list["Toggle" .. i].toggle.isOn then
	-- 		self.node_list["Toggle" .. i].transform:SetLocalScale(1.1, 1.1, 1.1)
	-- 		else
	-- 		self.node_list["Toggle" .. i].transform:SetLocalScale(1, 1, 1)
	-- 	end
	-- end
	if is_holding_weeding then
		local yanhui_type = MarriageData.Instance:GetYanHuiType()
		self.node_list["Toggle1"].toggle.isOn = (yanhui_type == 1)
		self.node_list["Toggle2"].toggle.isOn = (yanhui_type == 2)
	end
	if is_holding_weeding then
		self.node_list["TxtBton"].text.text = Language.Marriage.EnterDes
	else
		self.node_list["TxtBton"].text.text = Language.Marriage.Yuyue
	end

	local bind_cfg = MarriageData.Instance:GetWeddingCfgByType(YanHuiType.Normal) or {}
	local bind_reward_data = MarriageData.Instance:GetHunYanReward(true)
	local bind_item_num = bind_reward_data.num
	local item_id1 = bind_cfg.reward_item
	-- self.node_list["TxtUseBind"].text.text = string.format("*%s", bind_item_num)
	local bind_gold = bind_cfg.need_gold
	if bind_gold and bind_gold > 0 then
		self.node_list["TxtGold1"].text.text = bind_gold
	end

	-- self.item_cell_list[1]:SetData({item_id = bind_reward_data.item_id, num = bind_item_num})
	for i1 = 1, 2 do
		if item_id1[i1 - 1] then
			self.item_cell_list[i1]:SetData({item_id =  item_id1[i1 - 1].item_id, num = item_id1[i1 - 1].num})
			self.node_list["ItemCell" .. i1]:SetActive(true)
		end
	end
	local gold_cfg = MarriageData.Instance:GetWeddingCfgByType(YanHuiType.Special) or {}
	local reward_data = MarriageData.Instance:GetHunYanReward()
	local item_num = reward_data.num
	local item_id2 = gold_cfg.reward_item
	-- self.node_list["TxtUseNotBind"].text.text = string.format("*%s", item_num)
	local gold = gold_cfg.need_gold
	if gold and gold > 0 then
		self.node_list["TxtGold2"].text.text =  gold
	end
	self.item_cell_list[2]:SetData({item_id = reward_data.item_id, num = 0})
	for i2 = 3, 4 do
		if item_id2[i2 - 3] then
			self.item_cell_list[i2]:SetData({item_id = item_id2[i2 - 3].item_id, num = item_id2[i2 - 3].num})
			self.node_list["ItemCell" .. i2]:SetActive(true)
		end
	end
	local free_time = MarriageData.Instance:GetPutongHunyanTimes() < 1
	-- self.node_list["TxtFreeTimes"]:SetActive(free_time)
	self.node_list["TxtFreeTimes1"]:SetActive(not free_time)

	self.node_list["ButtonInvite"]:SetActive(role_msg_info.marry_state > 1)
	local seq = role_msg_info.param_ch4
	local str = ""
	if seq > 0 then
		str = MarriageData.Instance:GetShowTime(seq)
	end

	self.node_list["BtnGo"]:SetActive(role_msg_info.marry_state < 0 or seq < 0)
	self.node_list["MyTime"]:SetActive(role_msg_info.marry_state > 1)
	self.node_list["TimeDesc"]:SetActive(role_msg_info.marry_state > 1)
	self.node_list["MyTime"].text.text = str
	self.node_list["Hosted1"]:SetActive(seq < 0 and role_msg_info.marry_count <= 0)
	self.node_list["Hosted2"]:SetActive(seq < 0 and role_msg_info.marry_count <= 0)
end

function MarriageWeddingView:OnClickInvite()
	local info = MarriageData.Instance:GetYuYueRoleInfo()
	if info.marry_state > 0 then
		MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_GET_YUYUE_INFO)
		ViewManager.Instance:Open(ViewName.WeddingInviteView)	--邀请界面
	elseif info.marry_count > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NoYuYueHunYan)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NoWeddingCount)
	end
end

--前往月老
function MarriageWeddingView:GoToMarryNpc()
	local cfg = MarriageData.Instance:GetMarriageConditions()
	if nil == cfg then return end
	local npc_info = MarryMeData.Instance:GetNpcInfo(cfg.marry_npc_scene_id, cfg.marry_npc_id)
	if npc_info then
		MoveCache.end_type = MoveEndType.NpcTask
		MoveCache.param1 = cfg.qingyuannpc_id
		GuajiCtrl.Instance:MoveToPos(cfg.marry_npc_scene_id, npc_info.x, npc_info.y, 1, 1, false)
	end
	ViewManager.Instance:Close(ViewName.Marriage)
end

function MarriageWeddingView:DoHoldWedding(index, str1, str2)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local other_vo = ScoietyData.Instance:GetFriendInfoByName(main_vo.lover_name) or {}
	local cfg = MarriageData.Instance:GetWeddingCfgByType(index)
	local role_msg_info = MarriageData.Instance:GetYuYueRoleInfo()
	local cost = (cfg.need_coin > 0) and cfg.need_coin or cfg.need_gold
	if index == YanHuiType.Normal then
		if MarriageData.Instance:GetPutongHunyanTimes() < 1 then
			cost = 0
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NoWeddingCount)
			return
		end
	end
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	local had_money = (cfg.need_coin > 0) and mainrole_vo.bind_gold or mainrole_vo.gold
	if cost == 0 and index == YanHuiType.Normal then
		str1 = "WeedingTips"
	else
		str1 = "WeedingTips"
	end

	if had_money >= cost then
		if role_msg_info.marry_count <= 0 and role_msg_info.param_ch4 < 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NoWeddingCount)
			return
		else
			MarriageData.Instance:SetYanHuiType(self.is_use_bind_diamond)
			ViewManager.Instance:Open(ViewName.WeddingYuYueView)
			-- TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[3])
			self:Close()
		end
	else
		if index == YanHuiType.Normal then
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage[str2])
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
end

--开启宴会按下后
function MarriageWeddingView:HoldWeddingClick()
	local is_holding_weeding = MarriageData.Instance:GetIsHoldingWeeding()
	if is_holding_weeding then
		-- local fb_key = MarriageData.Instance:GetFuBenKey()
		MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_JOIN_HUNYAN, 1)
	else
		if self.is_use_bind_diamond == 1 then
			self:DoHoldWedding(YanHuiType.Normal, "WeedingTips", "NotEnoughBindDiamond")
		else
			self:DoHoldWedding(YanHuiType.Special, "WeedingTips", "NotEnoughDiamond")
		end
	end
end

function MarriageWeddingView:UseNomralWeddingChange(isOn)
	if isOn then
		self.is_use_bind_diamond = 1
	else
		self.is_use_bind_diamond = 2
	end
	self:Flush()
end

function MarriageWeddingView:UseSpecialDiamondChange(isOn)
	if isOn then
		self.is_use_bind_diamond = 2
	else
		self.is_use_bind_diamond = 1
	end
	self:Flush()
end