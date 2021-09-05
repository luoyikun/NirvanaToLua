GoldMemberView = GoldMemberView or BaseClass(BaseView)

function GoldMemberView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelOne"},
		{"uis/views/goldmember_prefab", "GoldMemberView"},
	}
	self.full_screen = false
	self.play_audio = true
	self.def_index = 0
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GoldMemberView:BackOnClick()
	ViewManager.Instance:Close(ViewName.GoldMemberView)
end

function GoldMemberView:__delete()
	if self.vip_time_coundown then
	GlobalTimerQuest:CancelQuest(self.vip_time_coundown)
	self.vip_time_coundown = nil
	end
end

function GoldMemberView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.button_show = nil
	self.tiem_text = nil
	self.gold_text = nil
	self.button_text = nil
	self.title_icon = nil
	self.fp = nil
	self.isbind_image = nil
	self.show_shop_redpoint = nil
	self.show_time=nil
	self.fight_text = nil
end

function GoldMemberView:LoadCallBack()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Capability"])
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.BackOnClick, self))
	self.node_list["ButtonBuy"].button:AddClickListener(BindTool.Bind(self.RewardOnClick, self))
	self.node_list["IconShop"].button:AddClickListener(BindTool.Bind(self.ShopOnClick, self))
	self.node_list["Name"].text.text = Language.GoldMember.Title

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])

	self:Flush()

end

function GoldMemberView:OpenCallBack()

	self.node_list["RedPoint"]:SetActive(GoldMemberData.Instance:CheckScoreIsOk())
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("member_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.GoldMember)
	end
end

function GoldMemberView:CloseCallBack()

end

function GoldMemberView:OnFlush(param_list)
	local active_cfg = GoldMemberData.Instance:GetGoldCfg()[1]
	local vip_info = GoldMemberData.Instance:GetGoldVipInfo()

	if active_cfg then
		local bundle, asset = ResPath.GetTitleIcon(active_cfg.gold_vip_title_id)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = active_cfg.title_zhanli
		end
		local num = active_cfg.return_gold
		local is_bind = 1
		local item_id = ResPath.CurrencyToIconId["bind_diamond"]
		self.item_cell:SetActivityEffect()
		self.item_cell:SetData({item_id = item_id, num = num, is_bind = is_bind})
		self.node_list["GoldText"].text.text = active_cfg.need_gold
	end

	self.node_list["TimeText"].text.text = Language.GoldMember.Menber_vip_title
	local day = GoldMemberData.Instance:GetCanRewardDay()
	if day > 0 then
		self.node_list["TxtReward"].text.text = day .. Language.GoldMember.Menber_vip_reward
		self.node_list["TxtReward"]:SetActive(true)
		self.node_list["GoldText"]:SetActive(false)
		self.node_list["ButtonText"].text.text = Language.GoldMember.Member_btn_titile[2]
		self.node_list["ImgRedPoint"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["ButtonBuy"], false)
	else
		self.node_list["TxtReward"]:SetActive(false)
		if vip_info.can_fetch_return_reward == 1 then
			self.node_list["ButtonText"].text.text = Language.GoldMember.Member_btn_titile[2]
			self.node_list["ImgRedPoint"]:SetActive(true)
			self.node_list["GoldText"]:SetActive(false)
			UI:SetButtonEnabled(self.node_list["ButtonBuy"], true)
		else
			self.node_list["ImgRedPoint"]:SetActive(false)
			if self.node_list["GoldText"].gameObject.activeSelf == true then
				self.node_list["ButtonText"].text.text = Language.GoldMember.Member_btn_titile[3]
				UI:SetButtonEnabled(self.node_list["ButtonBuy"], true)
			else
				self.node_list["ButtonText"].text.text = Language.GoldMember.Member_btn_titile[1]
				UI:SetButtonEnabled(self.node_list["ButtonBuy"], false)
			end
		end
	end
	self.node_list["RedPoint"]:SetActive(GoldMemberData.Instance:CheckScoreIsOk())
end


--关闭黄金会员面板
function GoldMemberView:BackOnClick()
	ViewManager.Instance:Close(ViewName.GoldMemberView)
end

function GoldMemberView:RewardOnClick()
	local gold_vip_info = GoldMemberData.Instance:GetGoldVipInfo()
	local active_cfg = GoldMemberData.Instance:GetGoldCfg()[1]
	if PlayerData.Instance.role_vo.level < GoldMemberData.Instance:GetActivitionLevel() then
		SysMsgCtrl.Instance:ErrorRemind(Language.GoldMember.Member_shop_level)
	return
	end

	if gold_vip_info.can_fetch_return_reward == 1 then
		GoldMemberCtrl.Instance:SendGoldVipOperaReq(GOLD_VIP_OPERA_TYPE.OPERA_TYPE_FETCH_RETURN_REWARD)
	return
	end

	local function ok_callback()
		GoldMemberCtrl.Instance:SendGoldVipOperaReq(GOLD_VIP_OPERA_TYPE.OPERA_TYPE_ACTIVE)
	end
	local des = string.format(Language.Common.CostGoldBuyTip, active_cfg.need_gold)
		TipsCtrl.Instance:ShowCommonAutoView("gold_vip", des, ok_callback)
end

function GoldMemberView:ShopOnClick()

		ViewManager.Instance:Open(ViewName.GoldMemberShop)
end
