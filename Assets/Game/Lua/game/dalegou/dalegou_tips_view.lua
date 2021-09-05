DaLeGouTips = DaLeGouTips or BaseClass(BaseView)
function DaLeGouTips:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/dalegou_prefab", "DaLeGouTips"},
	}
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
	self.is_any_click_close = true
end

function DaLeGouTips:__delete()
end

function DaLeGouTips:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

end

function DaLeGouTips:LoadCallBack()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

	self.node_list["BuyBtn"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(473, 355, 0)

	self.node_list["Txt"].text.text = Language.DaLeGou.Name
end

function DaLeGouTips:ClickBuy()
	if self.data == nil then
		return
	end

	local function ok_callback()
		if self.data == nil then
			return
		end

		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DALEGOU, RA_CRACYBUY_TYPE.RA_CRACYBUY_BUY, self.data.seq)
	end

	local reward_item = self.data.reward_item
	local item_cfg = ItemData.Instance:GetItemConfig(reward_item.item_id)
	if item_cfg == nil then
		return
	end

	local gold_des = ToColorStr(self.data.gold_buy, TEXT_COLOR.YELLOW)
	local color = ITEM_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
	local name = ToColorStr(item_cfg.name, color)

	local des = string.format(Language.Common.BuyItemByGoldDes, gold_des, name)
	TipsCtrl.Instance:ShowCommonAutoView("dalegou", des, ok_callback)
end

function DaLeGouTips:CloseWindow()
	self:Close()
end

function DaLeGouTips:SetData(data)
	self.data = data
end

function DaLeGouTips:SetCloseCallBack(close_callback)
	self.close_callback = close_callback
end

function DaLeGouTips:OpenCallBack()
	self:Flush()
end

function DaLeGouTips:CloseCallBack()
	if self.close_callback then
		self.close_callback()
	end
end

function DaLeGouTips:OnFlush()
	if self.data == nil then
		return
	end

	local now_recharge = DaLeGouData.Instance:GetChongZhi()

	local color = TEXT_COLOR.YELLOW
	if now_recharge < self.data.gold_level then
		color = TEXT_COLOR.RED
	end
	
	local need_recharge = ToColorStr(self.data.gold_level, color)
	UI:SetButtonEnabled(self.node_list["BuyBtn"], now_recharge >= self.data.gold_level)
	self.node_list["ContentText1"].text.text = string.format(Language.DaLeGou.Txt1, need_recharge)
	self.node_list["ContentText2"].text.text = string.format(Language.DaLeGou.Txt2, self.data.gold_buy)


	local reward_item = self.data.reward_item
	self.item_cell:SetData(reward_item)

	local item_cfg = ItemData.Instance:GetItemConfig(reward_item.item_id)
	local name = ""
	if item_cfg then
		name = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	end

	self.node_list["ItemName"].text.text = name
	local limit_info = DaLeGouData.Instance:GetBuyLimitInfoBySeq(self.data.seq)
	if limit_info == nil then
		return
	end

	local person_limit = limit_info.person_limit
	local role_buy_times_limit = self.data.role_buy_times_limit
	color = TEXT_COLOR.GREEN
	local left_single_times = role_buy_times_limit - person_limit
	if left_single_times <= 0 then
		color = TEXT_COLOR.RED
	end
	local single_str = ToColorStr(left_single_times, color) .. " / " .. role_buy_times_limit
	self.node_list["ContentText3"].text.text = string.format(Language.DaLeGou.Txt3, single_str)


	local all_limit = limit_info.all_limit
	local server_buy_times_limit = self.data.server_buy_times_limit
	color = TEXT_COLOR.GREEN
	local left_total_times = server_buy_times_limit - all_limit
	if left_total_times <= 0 then
		color = TEXT_COLOR.RED
	end
	local total_str = ToColorStr(left_total_times, color) .. " / " .. server_buy_times_limit
	self.node_list["ContentText4"].text.text = string.format(Language.DaLeGou.Txt4, total_str)
end