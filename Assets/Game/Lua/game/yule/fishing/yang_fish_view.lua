YangFishView = YangFishView or BaseClass(BaseView)

function YangFishView:__init()
    self.ui_config = {
    	{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
    	{"uis/views/yuleview_prefab", "YangFishView"}
    }
    self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function YangFishView:__delete()

end

function YangFishView:RemindChangeCallBack()

end

function YangFishView:ReleaseCallBack()
	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	self.fish_obj_list = nil
end

function YangFishView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(936,590,0)
	self.node_list["Txt"].text.text = Language.Fishpond.YangYu

	self.fish_obj_list = {}
	for i = 1, FishingData.FISH_QUALITY_COUNT do
		table.insert(self.fish_obj_list, self.node_list["FishItem" .. i])
	end

	--初始化奖励
	self.item_list = {}
	for i = 1, FishingData.FISH_QUALITY_COUNT do
		local fish_info = FishingData.Instance:GetFishInfoByQuality(i - 1)
		if nil ~= fish_info then
			local item_list_obj = self.node_list["ItemList" .. i]
			local name_table = item_list_obj:GetComponent(typeof(UINameTable))

			local item_1_obj = name_table:Find("Item1")
			item_1_obj = U3DObject(item_1_obj)

			local item_2_obj = name_table:Find("Item2")
			item_2_obj = U3DObject(item_2_obj)

			--显示第一个道具
			local item_1_cell = ItemCell.New()
			item_1_cell:SetInstanceParent(item_1_obj)
			item_1_cell:SetData({item_id = ResPath.CurrencyToIconId.rune_jinghua, num = fish_info.rune_score * 5, is_bind = 0})
			table.insert(self.item_list, item_1_cell)

			local reward_item = fish_info.reward_item
			item_2_obj:SetActive(reward_item.item_id > 0)

			local item_2_cell = ItemCell.New()
			item_2_cell:SetInstanceParent(item_2_obj)
			item_2_cell:SetData({item_id = reward_item.item_id, num = reward_item.num * 5, is_bind = reward_item.is_bind})
			table.insert(self.item_list, item_2_cell)
		end
	end

	--初始化名字
	for i = 0, FishingData.FISH_QUALITY_COUNT - 1 do
		local fish_info = FishingData.Instance:GetFishInfoByQuality(i)
		if nil ~= fish_info then
			self.node_list["TxtName" .. i + 1].text.text = ToColorStr(fish_info.fish_name, FISH_NAME_COLOR[i])

			-- 经验要乘以等级再乘以数量
			local exp = fish_info.exp * (50 + Scene.Instance:GetMainRole().vo.level) * 5
			self.node_list["TxtExp" .. i + 1].text.text = string.format("<color=#FDE45CFF>%s</color>", CommonDataManager.ConverNum(exp))
		end
	end


	self.node_list["BtnFarmFish"].button:AddClickListener(BindTool.Bind(self.ClickFarmFish, self))
	self.node_list["BtnRefresh"].button:AddClickListener(BindTool.Bind(self.ClickRefresh, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function YangFishView:CloseWindow()
	self:Close()
end

function YangFishView:ClickFarmFish()
	local fish_list = FishingData.Instance:GetMyFishList()
	if nil == fish_list or fish_list.fang_fish_time > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotFarmFish)
		return
	end
	YuLeCtrl.Instance:SendFishPoolRaiseReq()
	self:Close()
end

function YangFishView:ClickRefresh()
	local fish_list = FishingData.Instance:GetMyFishList()
	if nil == fish_list or fish_list.fang_fish_time > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotRefresh)
		return
	end

	local fish_quality = fish_list.fish_quality
	if fish_quality >= FishingData.FISH_QUALITY_COUNT - 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.MaxQualityDes)
		return
	end
	local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_quality)
	if nil == fish_info then
		return
	end
	local up_level_cost = fish_info.up_quality_gold
	local des = string.format(Language.Fishpond.RefreshDes, up_level_cost)
	local function ok_callback()
		YuLeCtrl.Instance:SendFishPoolQueryReq(FISH_POOL_QUERY_TYPE.FISH_POOL_UP_FISH_QUALITY)
	end
	TipsCtrl.Instance:ShowCommonAutoView("refresh_fish", des, ok_callback)
end


function YangFishView:OpenCallBack()
	self:Flush()
end

function YangFishView:CloseCallBack()

end

function YangFishView:OnFlush()
	local fish_list = FishingData.Instance:GetMyFishList()
	if nil == fish_list then
		return
	end

	local fish_quality = fish_list.fish_quality
	self.fish_obj_list[fish_quality + 1].toggle.isOn = true

	local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_quality)
	if nil == fish_info then
		return
	end

	self.node_list["ImgCost"]:SetActive(fish_info.up_quality_gold > 0)
	self.node_list["TxtCost"]:SetActive(fish_info.up_quality_gold > 0)

	self.node_list["TxtCost"].text.text = fish_info.up_quality_gold
end