TipsFishingSuccView = TipsFishingSuccView or BaseClass(BaseView)

function TipsFishingSuccView:__init()
	self.ui_config = {
		{"uis/views/fishing_prefab", "FishSuccPanel"}
	}
	self.view_layer = UiLayer.MainUILow
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsFishingSuccView:__delete()

end

function TipsFishingSuccView:ReleaseCallBack()

end 

function TipsFishingSuccView:LoadCallBack()
	self.node_list["RewardPanel"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function TipsFishingSuccView:CloseWindow()
	self:Close()
end

function TipsFishingSuccView:OnFlush()
	local flag = not self.event1 and not self.event2 and not self.is_box
	self.node_list["FishPlane"]:SetActive(flag)

	if self.index == 2 or self.index == 3 then
		index = 2
	elseif self.index == 1 then
		index = 3
	else
		index = 1
	end

	local bundle, asset = ResPath.GetRawImage("fish" .. self.index)
	self.node_list["ImgFish"].raw_image:LoadSprite(bundle, asset, function()
		self.node_list["ImgFish"].raw_image:SetNativeSize()
	end)

	local bundle1, asset1 = ResPath.GetRawImage("fish_succ_bg" .. index)
	self.node_list["ImgBgFish"].raw_image:LoadSprite(bundle1, asset1, function()
		self.node_list["ImgBgFish"].raw_image:SetNativeSize()
	end)
	local bundle2, asset2 = ResPath.GetFishingRes("icon_text_" .. index)
	self.node_list["ImgTxt"].image:LoadSprite(bundle2, asset2, function()
		self.node_list["ImgTxt"].image:SetNativeSize()
	end)

	local fish_cfg = CrossFishingData.Instance:GetFishingFishCfgByType(self.index)
	if fish_cfg then
		self.node_list["TxtFish"].text.text = fish_cfg.name
	end
	self.node_list["ImgNum"]:SetActive(self.num > 1)
	self.node_list["TxtFishNum"].text.text = self.num or 0
	self.node_list["TxtFishExplain"].text.text = Language.Fishing.FishExplain[self.index]

	local result_info = CrossFishingData.Instance:GetFishingCheckEventResult()
	self.node_list["Event1"]:SetActive(self.event1 and not self.is_oil)			--渔夫
	self.node_list["EventOil"]:SetActive(self.event1 and self.is_oil)			--香油
	self.node_list["Event2"]:SetActive(self.event2)			--强盗
	if result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_YUWANG or result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_YUCHA then
		self.node_list["TxtFisher"].text.text = string.format(Language.Fishing.Event[2], Language.Fishing.LabelGear[result_info.param1])
	elseif result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_ROBBER then
		local fish_cfg = CrossFishingData.Instance:GetFishingFishCfgByType(result_info.param1)
		if fish_cfg then
			self.node_list["TxtRobber"].text.text = string.format(Language.Fishing.Event[1], result_info.param2, fish_cfg.name)
		end
	else
		self.node_list["TxtFisher"].text.text = ""
		self.node_list["TxtRobber"].text.text = ""
	end

	self.node_list["ImgBox"]:SetActive(self.is_box)			--宝箱
	if self.is_steal then
		local bundle, asset = ResPath.GetRawImage("fish_steal_title")
		self.node_list["ImgTop"].raw_image:LoadSprite(bundle, asset)
	else
		local bundle, asset = ResPath.GetRawImage("fish_succ_title")
		self.node_list["ImgTop"].raw_image:LoadSprite(bundle, asset)
	end
end

function TipsFishingSuccView:SetData(index, num, event1, event2, box, is_steal, is_oil)
	self.index = index or 1
	self.num = num or 0
	self.event1 = event1 or false
	self.event2 = event2 or false
	self.is_box = box or false
	self.is_steal = is_steal or false
	self.is_oil = is_oil or false
end