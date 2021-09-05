ImmortalTipsView = ImmortalTipsView or BaseClass(BaseView)

function ImmortalTipsView:__init()
	self.ui_config = {
		{"uis/views/immortalcardview_prefab", "ImmortalTips"},
	}

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.type = 0
end
 
function ImmortalTipsView:SetCardType(card_type)
	if nil ~= card_type then
		self.type = card_type
	end
end

function ImmortalTipsView:__delete()

end

function ImmortalTipsView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ImmortalTipsView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	-- self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OpenGetWayView,self))


	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
end

function ImmortalTipsView:OpenCallBack()
	self:SetRewardDes(self.type)

	-- if self.time_quest == nil then
		-- self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetTime, self, self.type), 1)
		-- self:SetTime(self.type)
	-- end
end

function ImmortalTipsView:SetTime(type)
	local time = ImmortalData.Instance:GetTimesByType(type)
	local forever_flag = ImmortalData.Instance:CheckActivateByName(type)

	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	-- if forever_flag then
	-- 	self.node_list["TxtTime"].text.text = Language.XianZunCard.UnlimitedTime
	-- else
	-- 	self.node_list["TxtTime"].text.text = string.format(Language.XianZunCard.CardTime, TimeUtil.FormatSecond(time, 10))
	-- end
	if time > 0 then
		self.node_list["TxtTime"].text.text = string.format(Language.XianZunCard.CardTime, TimeUtil.FormatSecond(time, 10))
	else
		self.node_list["TxtTime"].text.text = string.format(Language.XianZunCard.CardTime, TimeUtil.FormatSecond(time, 10))
	end
end


function ImmortalTipsView:SetDes(index)
	local desc_text = ImmortalData.Instance:GetCardDescCfg()
end

function ImmortalTipsView:SetRewardDes(index)
	-- self.node_list["BtnStart"]:SetActive(index ~= 1)
	
	local bundle1, name1 = ResPath.GetCardWayImage(index)
	self.node_list["ImgGetWay"].image:LoadSprite(bundle1, name1)
	local bundle2, name2 = ResPath.GetCardTitleImage(index)
	self.node_list["TitleShow"].image:LoadSprite(bundle2, name2)
	local is_activity = ImmortalData.Instance:GetForeverActivityIsOpen()
	local card_desc = ImmortalData.Instance:GetCardDescCfg(index-1) or ""
	if card_desc then
		local str_text = card_desc.privilege_description
		if is_activity then
			str_text = card_desc.privilege_description .. "\n\n" .. card_desc.privilege_description1
		end
		self.node_list["TextDes"].text.text = str_text
		-- for i = 1, 5 do
		-- 	self.node_list["Desc" .. i].text.text = card_desc["desc" .. i]
		-- end
	end

	local cfg = ImmortalData.Instance:GetImmortalCfg()[index]
	if cfg == nil or next(cfg) == nil then return end

	local title_id = cfg.title_id
	local item_id = cfg.first_active_reward.item_id
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		self.node_list["IsTitle"]:SetActive(item_cfg.use_type ~= GameEnum.ITEM_OPEN_TITLE)
		self.node_list["ImgShow"]:SetActive(item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE)
		if item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE and title_id > 0 then
			local bundle, name = ResPath.GetCardShowImage(index)
			self.node_list["ImgShow"].image:LoadSprite(bundle, name)
			TitleData.Instance:LoadTitleEff(self.node_list["TitleEffect"], title_id, true)
		else
			-- 智霖要求特殊处理写死ID，进行放大模型
			if item_id == 22515 then
				self.node_list["Display"].rect.localPosition = Vector3(0, 80, 200)
			else
				self.node_list["Display"].rect.localPosition = Vector3(0, 0, 0)
			end
			self.model:ClearModel()
			self.model:ChangeModelByItemId(item_id)
		end
	end
end

function ImmortalTipsView:OpenGetWayView()
	if self.type == 1 then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif self.type == 2 then
		ViewManager.Instance:Open(ViewName.RepeatRechargeView)
	elseif self.type == 3 then 
		ViewManager.Instance:Open(ViewName.Boss)
	end
	self:Close()
end