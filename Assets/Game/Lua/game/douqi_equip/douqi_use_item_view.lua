DouqiUseItemView = DouqiUseItemView or BaseClass(BaseView)

function DouqiUseItemView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/douqiview_prefab", "DouqiUseItemView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function DouqiUseItemView:__delete()
end

function DouqiUseItemView:ReleaseCallBack()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

function DouqiUseItemView:LoadCallBack()
	self.item_list = {}
	for i = 1, 3 do
		self.node_list["BtnUse" .. i].button:AddClickListener(BindTool.Bind(self.OnBtnUse, self, i))

		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_list[i] = item_cell
	end


	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.node_list["Txt"].text.text = Language.Douqi.ItemUseViewTitle

	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
end

function DouqiUseItemView:OpenCallBack()
	self:Flush()
end

function DouqiUseItemView:OnItemDataChange()
	self:Flush()
end

function DouqiUseItemView:CloseCallBack()

end

function DouqiUseItemView:OnFlush()
	self.item_datas = DouQiData.Instance:GetUseItemList() or {}

	for k, v in pairs(self.item_datas) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and k <= 3 then

			self.node_list["TxtItemName" .. k].text.text = string.format(Language.Douqi.ItemAddDouqi, item_cfg.name, ToColorStr(v.reward_exp, TEXT_COLOR.GREEN_4)) 
			self.item_list[k]:SetData(v)

			local temp_btn_desc
			if 0 == v.douqidan_type then
				self.node_list["TxtGetway" .. k].text.text = v.get_way
				temp_btn_desc = Language.Douqi.BtnDesc3
			else
				self.node_list["TxtGetway" .. k].text.text = v.price
				temp_btn_desc = Language.Douqi.BtnDesc2
			end

			local use_times = v.had_use_times >= v.day_used_limit and ToColorStr(v.had_use_times, TEXT_COLOR.RED) or ToColorStr(v.had_use_times, TEXT_COLOR.GREEN_4)
			local use_desc = (9999 <= v.day_used_limit) and Language.Douqi.NoLimitTimes or string.format("%s/%s", use_times, v.day_used_limit)
			self.node_list["TxtUseTime" .. k].text.text = string.format(Language.Douqi.EveryDayTimesLimit, use_desc)

			local have_item = ItemData.Instance:GetItemNumInBagById(v.item_id)
			self.node_list["Have" .. k].text.text = string.format(Language.Douqi.ItemHaveNum, ToColorStr(have_item, TEXT_COLOR.GREEN_4))

			local btn_dec = have_item > 0 and Language.Douqi.BtnDesc1 or temp_btn_desc
			self.node_list["BtnText" .. k].text.text = btn_dec

			local is_have_times = v.had_use_times < v.day_used_limit
			UI:SetButtonEnabled(self.node_list["BtnUse" .. k], is_have_times)
			UI:SetGraphicGrey(self.node_list["BtnUse" .. k], not is_have_times)
		end
	end
end

function DouqiUseItemView:OnBtnUse(btn_index)
	local click_data = self.item_datas[btn_index]
	if nil == click_data then return end

	local have_item = ItemData.Instance:GetItemNumInBagById(click_data.item_id)
	if have_item > 0 then
		if 3 == btn_index then
			local item_tab = ItemData.Instance:GetItems(click_data.item_id)
			for k, v in pairs(item_tab) do
				PackageCtrl.Instance:SendUseItem(v.index, v.num)
			end
		else
			local sur_num = click_data.day_used_limit - click_data.had_use_times
			local use_num = (have_item > sur_num) and sur_num or have_item
			local item = ItemData.Instance:GetItem(click_data.item_id)
			PackageCtrl.Instance:SendUseItem(item.index, use_num)
		end
	else
		if 1 == btn_index then
			if click_data.go_to then
				-- local spilt_tab = Split(click_data.go_to, "#")
				-- ViewManager.Instance:Open(ViewName[spilt_tab[1]], TabIndex[spilt_tab[2]])
				ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.shenyu_secret)
				ViewManager.Instance:FlushView(ViewName.ShenYuBossView, "KFJumpToIndex", {4})
			end
		elseif 2 == btn_index or 3 == btn_index then
			local ok_callback = function ()
				MarketCtrl.Instance:SendShopBuy(click_data.item_id, 1, 0, 1)
			end

			local item_cfg = ItemData.Instance:GetItemConfig(click_data.item_id)
			if item_cfg then
				local des = string.format(Language.Douqi.IsBuyDouqiItem, ToColorStr(click_data.price, TEXT_COLOR.GREEN_4), ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color]))
				TipsCtrl.Instance:ShowCommonAutoView("douqi_item" .. btn_index, des, ok_callback, nil, nil, nil, nil, nil, true, false)
			end
		end
	end
end
