HuanzhuangShopView = HuanzhuangShopView or BaseClass(BaseView)
local pos_cfg = {
	{position = Vector3(0, 1.46, 5.73), rotation = Vector3(0, 180, -20)},
	{position = Vector3(0, 1.85, 7.33), rotation = Vector3(0, 180, -20)},
}

function HuanzhuangShopView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab","BaseActivityPanelTwo_1"},
		{"uis/views/randomact/huanzhuangshop_prefab", "HuangZhuangShopView"},
		{"uis/views/commonwidgets_prefab","BaseActivityPanelTwo_2"},
	}
	self.play_audio = true
	self.cell_list = {}
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = false	
end

function HuanzhuangShopView:__delete()

end

function HuanzhuangShopView:LoadCallBack()
	self.show_type = RA_HUANZHUANG_SHOP_TYPE.HUANZHUANG_SHOP_TYPE
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnOneKeyBuy"].button:AddClickListener(BindTool.Bind(self.OneKeyBuy, self))
	-- self.node_list["toggle1"].toggle:AddClickListener(BindTool.Bind(self.OnClickTab, self, 1))
	-- self.node_list["toggle2"].toggle:AddClickListener(BindTool.Bind(self.OnClickTab, self, 0))
	self:InitScroller()
end

function HuanzhuangShopView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	-- 清理变量和对象
	for i,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

-- function HuanzhuangShopView:OnClickTab(show_type)
-- 	if self.show_type == show_type then
-- 		return
-- 	end
-- 	self.show_type = show_type
-- 	self.data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType(self.show_type)
-- 	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
-- end

--一键购买
function HuanzhuangShopView:OneKeyBuy()
	if nil == self.data then
		return
	end

	local info = HuanzhuangShopData.Instance:GetRAMagicShopAllInfo()
	local magic_shop_buy_flag = bit:d2b(info.magic_shop_buy_flag)

	local cost = 0
	local is_have_buy = false
	for _, v in ipairs(self.data) do
		if magic_shop_buy_flag[32 - v.index] == 0 then
			cost = cost + v.need_gold
		else
			is_have_buy = true
		end
	end

	if cost == 0 then
		--说明已经没得买了
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.IsSellOutDes)
		return
	end

	local function ok_callback()
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, HuanzhuangShopData.OPERATE.ONE_KEY)
	end
	local des = string.format(Language.Activity.AutoBuyHuanZhuangShopDes, math.floor(cost * 0.8))
	if is_have_buy then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, HuanzhuangShopData.OPERATE.ONE_KEY)
	else
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
	end
end

function HuanzhuangShopView:InitScroller()
	self.data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType()
	local delegate = self.node_list["ListView"].list_simple_delegate
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			target_cell = HuanZhuangShopCell.New(cell.gameObject)
			self.cell_list[cell] = target_cell
			target_cell:SetFlushModelValue(true)
			target_cell:SetIndex(data_index)
		else
			target_cell:SetFlushModelValue(false)
		end
		-- target_cell:SetShowType(self.show_type)
		target_cell:SetData(self.data[data_index])
		target_cell:Flush()
	end
end

function HuanzhuangShopView:OpenCallBack()
	RemindManager.Instance:SetRemindToday(RemindName.ShowHuanZhuangShopPoint)
	self:Flush()
end

function HuanzhuangShopView:ShowIndexCallBack(index)

end

function HuanzhuangShopView:CloseCallBack()

end

function HuanzhuangShopView:OnFlush(param_t)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	for k,v in pairs(param_t) do
		if k == "FlsuhData" then
			for k2,v2 in pairs(self.cell_list) do
				local data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType()
				v2:SetData(data[v2:GetIndex()])
				v2:Flush("FlsuhData")
			end
		else
			if self.node_list["ListView"] then
				self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
	end
	-- self.node_list["ImgRemind"]:SetActive(HuanzhuangShopData.Instance:ShowHuanZhuangShopPoint() > 0)
end

function HuanzhuangShopView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		local temp_time = ToColorStr( TimeUtil.FormatSecond(time, 6),TEXT_COLOR.GREEN_4)
		self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, temp_time)
	elseif time > 3600 then
		local temp_time = ToColorStr(TimeUtil.FormatSecond(time, 3),TEXT_COLOR.GREEN_4)
		self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, temp_time)
	else
		local temp_time = ToColorStr(TimeUtil.FormatSecond(time, 3),TEXT_COLOR.GREEN_4)
		self.node_list["TxtTime"].text.text = string.format(Language.RechargeCapacity.ActTime, temp_time)
	end
end

---------------------------------------------------------------
--滚动条格子

HuanZhuangShopCell = HuanZhuangShopCell or BaseClass(BaseRender)

function HuanZhuangShopCell:__init()
	self.show_type = RA_HUANZHUANG_SHOP_TYPE.HUANZHUANG_SHOP_TYPE
	self.flush_model = true
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"], "FightPower3")
end

function HuanZhuangShopCell:__delete()
	self.fight_text = nil
	
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function HuanZhuangShopCell:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "FlsuhData" then
			self:FlushAttr()
		else
			self:FlushAttr()
			self:FlushModel()
		end
	end
end

function HuanZhuangShopCell:FlushAttr()
	if nil == self.data then
		return
	end
	
	local info = HuanzhuangShopData.Instance:GetRAMagicShopAllInfo()
	local magic_shop_buy_flag = bit:d2b(info.magic_shop_buy_flag)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	local name_str = item_cfg ~= nil and item_cfg.name or ""
	if self.data.show_name and self.data.show_name ~= "" then
		name_str = self.data.show_name .. name_str
	end

	self.node_list["TxtText"].text.text = name_str
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = self.data.power
	end
	self.node_list["TxtTitle"]:SetActive(self.show_type == 1)
	self.node_list["Node"]:SetActive(self.show_type ~= 1)
	self.node_list["ImgImage"]:SetActive(self.show_type == 1)
	self.node_list["TxtButtonText"]:SetActive(self.show_type == 1)
	self.node_list["TxtButtonText2"]:SetActive(self.show_type ~= 1)
	self.node_list["display"]:SetActive(self.show_type ~= 0)
	self.node_list["TxtTitle2"]:SetActive(self.show_type == 0)
	local num = 1 == magic_shop_buy_flag[32 - self.data.index] and 0 or 1
	self.node_list["TxtText2"].text.text = string.format(Language.HuanZhuangShop.RechargeNum, recharge_num)
	self.node_list["TxtMoney"].text.text = self.data.need_gold
	self.node_list["TxtCost"].text.text = self.data.need_gold
	UI:SetButtonEnabled(self.node_list["BtnBuy"], num >= 1)
	if num >= 1 then
		self.node_list["TxtButtonText"].text.text = Language.HuanZhuangShop.GouMai
	else
		self.node_list["TxtButtonText"].text.text = Language.HuanZhuangShop.YiGouMai
	end
end

function HuanZhuangShopCell:SetData(data)
	self.data = data
end

function HuanZhuangShopCell:SetIndex(index)
	self.index = index
end

function HuanZhuangShopCell:GetIndex()
	return self.index
end

function HuanZhuangShopCell:SetFlushModelValue(value)
	self.flush_model = value
end

function HuanZhuangShopCell:FlushModel()
	local info = HuanzhuangShopData.Instance:GetRAMagicShopAllInfo()
	local activity_day = info.activity_day
	if 1 == self.show_type then
		local tbl = Split(self.data.item_show, ",")
		if #tbl == 1 then
			ItemData.ChangeModel(self.model, tonumber(tbl[1]), nil)
			if tonumber(tbl[1]) == 24933 then
				self.model:SetCameraSetting({position = Vector3(0, 1.9, 10), rotation = Quaternion.Euler(0, 180, 0)})
			elseif tonumber(tbl[1]) == 25248 then
				self.model:SetCameraSetting({position = Vector3(0, 3.8, 6.2), rotation = Quaternion.Euler(25, 180, 6.6)})
			end
		elseif tbl[3] then
			if tonumber(tbl[3]) == 0 then
				self.model:SetMainAsset(tbl[1], tbl[2])
			elseif tonumber(tbl[3]) == 1 then
				self.model:ClearModel()
			end
		end
		local cfg = ItemData.Instance:GetItemConfig(tonumber(tbl[1]))
		if cfg.is_display_role == DISPLAY_TYPE.FASHION then
			self.model:ShowRest()
			self.model:SetBool("fight", true)
		end
	end
end

function HuanZhuangShopCell:OnClick()
	local func = function()
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, HuanzhuangShopData.OPERATE.BUY, self.data.index)
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	local name_str = item_cfg ~= nil and item_cfg.name or Language.Activity.HuanZhuanGoods
	local str = string.format(Language.Activity.HuanZhuanShopTip, self.data.need_gold, name_str)
	TipsCtrl.Instance:ShowCommonAutoView("huan_zhuang_shop", str, func, nil, nil, nil, nil, nil, nil, false)
end