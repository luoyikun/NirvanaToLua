LuckWishingView = LuckWishingView or BaseClass(BaseView)

function LuckWishingView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/randomact/luckywishing_prefab", "LuckyWishing"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
		{"uis/views/randomact/luckywishing_prefab", "RepeatRechargeLeftDisplay"},
	}
	self.play_audio = true
	self.full_screen = false

	self.is_show = false
	self.show_display = nil
	self.title = nil
	self.fashion_role_model = nil
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LuckWishingView:LoadCallBack()
	self.node_list["Name"].text.text = Language.Title.LuckyWish
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnReardOnce"].button:AddClickListener(BindTool.Bind(self.OnBtnReardOnce, self))
	self.node_list["BtnReardSanShi"].button:AddClickListener(BindTool.Bind(self.OnBtnReardSanShi, self))
	self.node_list["ToggleCheckBox"].button:AddClickListener(BindTool.Bind(self.CheckBoxClick, self))
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.item_list = {}
	for i = 1, 10 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		table.insert(self.item_list, item)
	end
	self.item_center = ItemCell.New()
	self.item_center:SetInstanceParent(self.node_list["ItemCenter"])
	self.item_center:SetShowOrangeEffect(true)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
	self.node_list["ImgCheckBox"]:SetActive(LuckWishingData.Instance:GetIsShield())
end

function LuckWishingView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.item_center = nil
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.fight_text = nil

end

function LuckWishingView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_WISH) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	BaseView.Open(self)
end

function LuckWishingView:OpenCallBack()
	self:Flush()
	self:FlushModel()
end

function LuckWishingView:ShowIndexCallBack()
	self:FlushModel()
end

function LuckWishingView:OnBtnReardOnce()
	LuckWishingCtrl.Instance:SendAllInfoReq(RA_LUCKY_WISH_OPERA_TYPE.RA_LUCKY_WISH_OPERA_TYPE_WISH, 1)
	LuckWishingData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_1)
end

function LuckWishingView:OnBtnReardSanShi()
	local other_cfg = LuckWishingData.Instance:GetBigRewardShowData()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].lucky_wish_30_times_use_item)
	if item_num <= 0 and PlayerData.Instance:GetRoleVo().gold < other_cfg.consume_gold_30 then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	LuckWishingCtrl.Instance:SendAllInfoReq(RA_LUCKY_WISH_OPERA_TYPE.RA_LUCKY_WISH_OPERA_TYPE_WISH, 30)
	LuckWishingData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_30)
end

function LuckWishingView:CheckBoxClick()
	local is_shield = LuckWishingData.Instance:GetIsShield()
	LuckWishingData.Instance:SetIsShield(not is_shield)

	self.node_list["ImgCheckBox"]:SetActive(not is_shield)
end


function LuckWishingView:OnFlush()
	-- 活动剩余时间刷新
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	local lucky_info = LuckWishingData.Instance:GetLuckyInfo()
	local lucky_value = 0
	if lucky_info and next(lucky_info) then
		lucky_value = lucky_info.lucky_value
	end
	local other_cfg = LuckWishingData.Instance:GetBigRewardShowData()
	if other_cfg and next(other_cfg) then
		self.node_list["ImgProgressBG"].slider.value = lucky_value / other_cfg.lucky_max
		self.node_list["TxtHasRecharge"].text.text = lucky_value .. "/" .. other_cfg.lucky_max
		self.node_list["TextCostOne"].text.text = other_cfg.consume_gold_1 or 0
		self.node_list["TextCostSanShi"].text.text = other_cfg.consume_gold_30 or 0
	end

	-- 钥匙
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].lucky_wish_30_times_use_item)
	self.node_list["keyCostLayer"]:SetActive(item_num > 0)
	self.node_list["GoldCostLayer"]:SetActive(item_num <= 0)
	self.node_list["keyImgeRemind"]:SetActive(item_num > 0)
	self.node_list["KeyNumText"].text.text = "X" .. item_num

	-- 礼包展示
	local day_cfg = LuckWishingData.Instance:GetEveryDayRewardShowData()
	if day_cfg and next(day_cfg) then
		for i = 1, 10 do
			local data = day_cfg[i]
			if nil ~= data.item and data.item.item_id then
				self.item_list[i]:SetActive(true)
				self.item_list[i]:SetData({item_id = data.item.item_id, is_bind = 0})
			else
				self.item_list[i]:SetActive(false)
			end
		end
	end
end

function LuckWishingView:FlushNextTime()
	local time = LuckWishingData.Instance:GetActivitytimes()--ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_WISH)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	local time_str = TimeUtil.FormatSecond(time, 10)
	self.node_list["TxtActTime1"].text.text = string.format(Language.Activity.ActivityTime1, time_str) 

end

function LuckWishingView:FlushModel()
	local day_cfg = LuckWishingData.Instance:GetBigRewardShowData()
	local show_power = 0
	-- 形象展示
	if day_cfg and next(day_cfg) then
		self.item_center:SetActive(true)
		self.item_center:SetData({item_id = day_cfg.item.item_id})
		self.model:ChangeModelByItemId(day_cfg.item.item_id)
		show_power = ItemData.GetFightPower(day_cfg.item.item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(day_cfg.item.item_id)
		if item_cfg and next(item_cfg) then
			local name = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
			self.node_list["TextDesc1"].text.text = string.format(Language.Activity.LuckyWishDesc1, name)
			self.node_list["TextDesc2"].text.text = Language.Activity.LuckyWishDesc2
		end
	end

	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = show_power
	end
end


