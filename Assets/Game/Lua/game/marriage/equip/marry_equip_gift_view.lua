MarryGiftView = MarryGiftView or BaseClass(BaseView)

local CONSUMEGOLD = {
	288,
	588,
	888,
	1888,
	2888,
}
function MarryGiftView:__init()
	self.ui_config = {
		{"uis/views/marriageview_prefab", "MarryEquipGiftView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.marry_gift_endtime = 0
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MarryGiftView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Buy"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))

	self.item_cell_list = {}
	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["item"..i])
		self.item_cell_list[i] = item_cell
	end
end

function MarryGiftView:OpenCallBack()
	self:Flush()
	RemindManager.Instance:Fire(RemindName.MarryEquip)
end

function MarryGiftView:CloseCallBack()
	MarriageCtrl.Instance:FlushEquipInfo()
end

function MarryGiftView:ReleaseCallBack()
	if self.marry_gift_timer then
		GlobalTimerQuest:CancelQuest(self.marry_gift_timer)
		self.marry_gift_timer = nil
	end
end

function MarryGiftView:OnClickBuy()
	local cur_seq =	MarryEquipData.Instance:CurPurchasedSeq()
	local yes_func = function()
			MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.BUY_GIFT, cur_seq)
		end
	local describe = string.format(Language.Marriage.BuyCountByGold, CONSUMEGOLD[cur_seq + 1])
	TipsCommonAutoView.AUTO_VIEW_STR_T[""] = nil 								--有其他地方莫名其妙把""设为true
	TipsCtrl.Instance:ShowCommonAutoView("xunyou_red", describe, yes_func, nil, nil, nil, nil, nil, nil, true)
	-- MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.BUY_GIFT, cur_seq)
end

function MarryGiftView:OnFlush()
	local cur_seq = MarryEquipData.Instance:CurPurchasedSeq()
	local cfg = MarryEquipData.Instance:GetMarryGiftSeqCfg(cur_seq)
	if cfg then
		local all_list = {}
		local libao_list = nil
		local reward_list = cfg.reward_item
		for i = 0, #reward_list do
			if reward_list[i] then
				self.node_list["item"..(i + 1)]:SetActive(true)
				local _, big_type = ItemData.Instance:GetItemConfig(reward_list[i].item_id)
				-- if big_type ~= GameEnum.ITEM_BIGTYPE_GIF then
					table.insert(all_list, reward_list[i])
				-- else
				    -- libao_list = ItemData.Instance:GetGiftItemList(reward_list[i].item_id)
				    -- for i1,v1 in ipairs(libao_list) do
				    --    table.insert(all_list, v1)
				    -- end
		        -- end
		    end
		end
		for i = #reward_list + 2, 4 do
			self.node_list["item"..i]:SetActive(false)
		end
		for k,v in pairs(self.item_cell_list) do
			v:SetData(all_list[k])
		end
		self.marry_gift_endtime = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
		if self.marry_gift_timer == nil then
			self.marry_gift_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
		self.node_list["Fight"].text.text = cfg.might
		local bundle, asset = ResPath.GetMarryImage("yuanbao" .. (cur_seq + 1))
		self.node_list["Yuanbao"].image:LoadSprite(bundle, asset, function () self.node_list["Yuanbao"].image:SetNativeSize() end)
	else
		if self.marry_gift_timer then
			GlobalTimerQuest:CancelQuest(self.marry_gift_timer)
			self.marry_gift_timer = nil
		end
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NoMarryGiftTxt)
		self:Close()
	end
end

function MarryGiftView:FlushNextTime()
	local time = self.marry_gift_endtime - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		if time > 3600 * 24 then
			self.node_list["Time"].text.text = string.format(Language.Marriage.MarryGiftTimeTxt, TimeUtil.FormatSecond(time, 1))
		else
			self.node_list["Time"].text.text = string.format(Language.Marriage.MarryGiftTimeTxt, TimeUtil.FormatSecond(time, 3))
		end
	else
		self:Flush()
	end
end