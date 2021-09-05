TitleShopView = TitleShopView or BaseClass(BaseView)
local pos_cfg = {
	{position = Vector3(0, 1.46, 5.73), rotation = Vector3(0, 180, -20)},
	{position = Vector3(0, 1.85, 7.33), rotation = Vector3(0, 180, -20)},
}

function TitleShopView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab","BaseActivityPanelTwo_1"},
		{"uis/views/randomact/huanzhuangshop_prefab", "TitleShopView"},
		{"uis/views/commonwidgets_prefab","BaseActivityPanelTwo_2"},
	}
	self.play_audio = true
	self.cell_list = {}
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = false	
end

function TitleShopView:__delete()

end

function TitleShopView:LoadCallBack()
	self.show_type = RA_HUANZHUANG_SHOP_TYPE.TITLE_SHOP_TYPE
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	--self.node_list["BtnOneKeyBuy"].button:AddClickListener(BindTool.Bind(self.OneKeyBuy, self))
	-- self.node_list["toggle1"].toggle:AddClickListener(BindTool.Bind(self.OnClickTab, self, 1))
	-- self.node_list["toggle2"].toggle:AddClickListener(BindTool.Bind(self.OnClickTab, self, 0))
	self:InitScroller()
	if self.node_list["ListView"] then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TitleShopView:ReleaseCallBack()
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

-- function TitleShopView:OnClickTab(show_type)
-- 	if self.show_type == show_type then
-- 		return
-- 	end
-- 	self.show_type = show_type
-- 	self.data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType(self.show_type)
-- 	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
-- end

--一键购买
-- function TitleShopView:OneKeyBuy()
-- 	if nil == self.data then
-- 		return
-- 	end

-- 	local info = HuanzhuangShopData.Instance:GetRAMagicShopAllInfo()
-- 	local magic_shop_buy_flag = bit:d2b(info.magic_shop_buy_flag)

-- 	local cost = 0
-- 	for _, v in ipairs(self.data) do
-- 		if magic_shop_buy_flag[32 - v.index] == 0 then
-- 			cost = cost + v.need_gold
-- 		end
-- 	end

-- 	if cost == 0 then
-- 		--说明已经没得买了
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.IsSellOutDes)
-- 		return
-- 	end

-- 	local function ok_callback()
-- 		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, HuanzhuangShopData.OPERATE.ONE_KEY)
-- 	end
-- 	local des = string.format(Language.Activity.AutoBuyHuanZhuangShopDes, math.floor(cost * 0.8))
-- 	TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
-- end

function TitleShopView:InitScroller()
	self.data = HuanzhuangShopData.Instance:GetTitleShopRewardCfgByShowType()
	local delegate = self.node_list["ListView"].list_simple_delegate
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			target_cell = TitleShopCell.New(cell.gameObject)
			self.cell_list[cell] = target_cell
			-- target_cell:SetFlushModelValue(true)
			target_cell:SetIndex(data_index)
		else
			-- target_cell:SetFlushModelValue(false)
		end
		-- target_cell:SetShowType(self.show_type)
		target_cell:SetData(self.data[data_index])
		target_cell:Flush()
	end
end

function TitleShopView:OpenCallBack()
	-- RemindManager.Instance:Fire(RemindName.NiChongWoSong)
	RemindManager.Instance:SetRemindToday(RemindName.TitleShopTodayRemind)
	self:Flush()
end

function TitleShopView:ShowIndexCallBack(index)

end

function TitleShopView:CloseCallBack()

end

function TitleShopView:OnFlush(param_t)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	for k2,v2 in pairs(self.cell_list) do
		local data = HuanzhuangShopData.Instance:GetTitleShopRewardCfgByShowType()
		v2:SetData(data[v2:GetIndex()])
		v2:Flush("FlsuhData")
	end
	local info = HuanzhuangShopData.Instance:GetRATitleShopAllInfo()
	local magic_shop_chongzhi_value = info.magic_shop_chongzhi_value
	self.node_list["ValueTxt"].text.text = CommonDataManager.ConverMoney(magic_shop_chongzhi_value)

	-- for k,v in pairs(param_t) do
	-- 	if k == "FlsuhData" then
			
	-- 	else
			
	-- 	end
	-- end
	-- self.node_list["ImgRemind"]:SetActive(HuanzhuangShopData.Instance:ShowHuanZhuangShopPoint() > 0)
end

function TitleShopView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG)
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

TitleShopCell = TitleShopCell or BaseClass(BaseRender)

function TitleShopCell:__init()
	self.show_type = RA_HUANZHUANG_SHOP_TYPE.TITLE_SHOP_TYPE
	-- self.flush_model = true
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	-- self.model = RoleModel.New()
	-- self.model:SetDisplay(self.node_list["display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	-- self:FlushModel()
end

function TitleShopCell:__delete()
	-- if self.model then
	-- 	self.model:DeleteMe()
	-- 	self.model = nil
	-- end
	TitleData.Instance:ReleaseTitleEff(self.node_list["TxtTitle2"])
end

-- function TitleShopCell:SetShowType(show_type)
-- 	self.show_type = show_type		
-- end

function TitleShopCell:OnFlush(param_t)
	for k,v in pairs(param_t) do
		self:FlushAttr()
		-- if k == "FlsuhData" then
		-- 	self:FlushAttr()
		-- else
		-- 	self:FlushAttr()
		-- 	-- self:FlushModel()
		-- end
	end
end

function TitleShopCell:FlushAttr()
	if nil == self.data then
		return
	end
	
	local info = HuanzhuangShopData.Instance:GetRATitleShopAllInfo()
	local magic_shop_fetch_reward_flag = bit:d2b(info.magic_shop_fetch_reward_flag)
	local magic_shop_chongzhi_value = info.magic_shop_chongzhi_value
	local activity_day = info.activity_day

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	self.node_list["TxtText"].text.text = item_cfg.name
	self.node_list["TxtTitle"]:SetActive(self.show_type == 1)
	self.node_list["Node"]:SetActive(self.show_type ~= 1)
	self.node_list["ImgImage"]:SetActive(self.show_type == 1)
	self.node_list["TxtButtonText"]:SetActive(self.show_type == 1)
	self.node_list["TxtButtonText"].text.text =  Language.Common.LingQu
	self.node_list["TxtButtonText2"]:SetActive(self.show_type ~= 1)
	self.node_list["display"]:SetActive(self.show_type ~= 0)
	self.node_list["TxtTitle2"]:SetActive(self.show_type == 0)

	-- if 1 == self.show_type then
	-- 	local num = 1 == magic_shop_buy_flag[32 - self.data.index] and 0 or 1
	-- 	self.node_list["TxtText2"].text.text = string.format(Language.HuanZhuangShop.RechargeNum, recharge_num)
	-- 	self.node_list["TxtMoney"].text.text = self.data.need_gold
	-- 	self.node_list["TxtCost"].text.text = self.data.need_gold
	-- 	UI:SetButtonEnabled(self.node_list["BtnBuy"], num >= 1)
	-- 	if num >= 1 then
	-- 		self.node_list["TxtButtonText"].text.text = Language.HuanZhuangShop.GouMai
	-- 	else
	-- 		self.node_list["TxtButtonText"].text.text = Language.HuanZhuangShop.YiGouMai
	-- 	end
	-- else
	self.node_list["TxtTitle2"].image:LoadSprite(ResPath.GetTitleIcon(item_cfg.param1))
	self.node_list["TxtTitle2"].image:SetNativeSize()
	TitleData.Instance:LoadTitleEff(self.node_list["TxtTitle2"], item_cfg.param1, true)
	local str = magic_shop_chongzhi_value < self.data.need_gold and Language.Common.WEIDACHENG or (0 == magic_shop_fetch_reward_flag[32 - self.data.index] and Language.Common.LingQu or Language.Common.YiLingQu)
	self.node_list["TxtText2"].text.text = Language.HuanZhuangShop.RechargeNum --self.data.need_gold
	self.node_list["TxtMoney"].text.text = self.data.need_gold
	self.node_list["TxtButtonText2"].text.text = str
	local flag = magic_shop_chongzhi_value >= self.data.need_gold and 0 == magic_shop_fetch_reward_flag[32 - self.data.index]
	UI:SetButtonEnabled(self.node_list["BtnBuy"], flag)
	-- end
end

function TitleShopCell:SetData(data)
	self.data = data
end

function TitleShopCell:SetIndex(index)
	self.index = index
end

function TitleShopCell:GetIndex()
	return self.index
end

-- function TitleShopCell:SetFlushModelValue(value)
-- 	self.flush_model = value
-- end

-- function TitleShopCell:FlushModel()
-- 	local info = HuanzhuangShopData.Instance:GetRAMagicShopAllInfo()
-- 	local activity_day = info.activity_day
-- 	-- if 1 == self.show_type then
-- 	-- 	local tbl = Split(self.data.item_show, ",")
-- 	-- 	if #tbl == 1 then
-- 	-- 		ItemData.ChangeModel(self.model, tonumber(tbl[1]), nil)
-- 	-- 	elseif tbl[3] then
-- 	-- 		if tonumber(tbl[3]) == 0 then
-- 	-- 			self.model:SetMainAsset(tbl[1], tbl[2])
-- 	-- 		elseif tonumber(tbl[3]) == 1 then
-- 	-- 			self.model:ClearModel()
-- 	-- 		end
-- 	-- 	end
-- 	-- end
-- end

function TitleShopCell:OnClick()
	-- local opera_type = 0
	-- if self.show_type == 0 then
	-- local opera_type = HuanzhuangShopData.OPERATE.RECHARGE
	-- else
	-- 	opera_type = HuanzhuangShopData.OPERATE.BUY
	-- end
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG, CHONGZHI_GIFT_OPER_TYPE.CHONGZHI_GIFT_OPER_TYPE_FETCH, self.data.index)
	-- self:FlushAttr()
end