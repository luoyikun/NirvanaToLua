XiLianContentView = XiLianContentView or BaseClass(BaseRender)

function XiLianContentView:OpenCallBack()
	local left_pos = self.node_list["Left"].transform.anchoredPosition
	local help_pos = self.node_list["BtnHelp"].transform.anchoredPosition
	local bottom_pos = self.node_list["bottom"].transform.anchoredPosition
	local title_pos = self.node_list["Title"].transform.anchoredPosition
	
	self.select_stuff_cfg = HunQiData.Instance:GetHunQiXiLianDefaultInfo()
	UITween.MoveShowPanel(self.node_list["Left"], Vector3(left_pos.x - 200, left_pos.y, left_pos.z))
	UITween.MoveShowPanel(self.node_list["BtnHelp"], Vector3(help_pos.x, help_pos.y + 120, help_pos.z))
	UITween.MoveShowPanel(self.node_list["bottom"], Vector3(bottom_pos.x, bottom_pos.y - 200, bottom_pos.z))
	UITween.MoveShowPanel(self.node_list["Title"], Vector3(title_pos.x, title_pos.y + 120, title_pos.z))
	UITween.AlpahShowPanel(self.node_list["Center"], true, nil, DG.Tweening.Ease.InExpo)

end

function XiLianContentView:__init()
	HunQiData.Instance:SetXiLianContentView(self)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
	self.hunqi_btn_list = {}
	for i = 1, 8 do
		local hunqi_btn = HunQiXiLianBtn.New(self.node_list["hunqi" .. i])
		hunqi_btn:SetIndex(i)
		hunqi_btn:SetClickCallBack(BindTool.Bind(self.HunQiBtnClick, self))
		table.insert(self.hunqi_btn_list, hunqi_btn)
	end

	self.hunqi_attr_list = {}
	for i = 1, 8 do
		local element = XiLianElement.New(self.node_list["Element" .. i])
		element:SetIndex(i)
		table.insert(self.hunqi_attr_list, element)
	end
	self.last_select_hunqi = 0
	self.current_select_hunqi = 1
	self.lock_slot_num = 0
	self.lock_slot_flag = 0
	self.xilian_comsume_color = 0
	self.open_xilian_slot_num = 0

	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self.node_list["item"])
	self.stuff_cell:ListenClick(BindTool.Bind(self.SelectStuff, self))

	self.lock_cell = ItemCell.New()
	self.lock_cell:SetInstanceParent(self.node_list["lock_item"])

	self.select_stuff_cfg = HunQiData.Instance:GetHunQiXiLianDefaultInfo()

	self.node_list["BtnXiLian"].button:AddClickListener(BindTool.Bind(self.OnClickXiLian, self))
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.SelectStuff, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.select_stuff = GlobalEventSystem:Bind(OtherEventType.HUNQI_XILIAN_STUFF_SELECT, BindTool.Bind(self.OnSelectStuff, self))

	--监听物品变化
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
end

function XiLianContentView:__delete()
	if HunQiData.Instance then 
		HunQiData.Instance:SetXiLianContentView(nil)
	end

	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	if self.lock_cell then
		self.lock_cell:DeleteMe()
		self.lock_cell = nil
	end

	for k,v in pairs(self.hunqi_btn_list) do
		v:DeleteMe()
	end
	self.hunqi_btn_list = {}

	for k,v in pairs(self.hunqi_attr_list) do
		v:DeleteMe()
	end
	self.hunqi_attr_list = {}
	GlobalEventSystem:UnBind(self.select_stuff)

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	self.fight_text = nil
end

function XiLianContentView:OnItemDataChange(item_id)
	self:FlushStuff()
end

function XiLianContentView:FlushHigh()
	for i,v in ipairs(self.hunqi_btn_list) do
		if v:GetIndex() == self.current_select_hunqi then
			v:SetShowHigh(true)
		else
			v:SetShowHigh(false)
		end
	end
end

function XiLianContentView:HunQiBtnClick(hunqi_btn)
	if self.current_select_hunqi == hunqi_btn:GetIndex() then
		return 
	end
	local data = hunqi_btn:GetData()
	if data.star_level <= 0 then
		local cfg_data = HunQiData.Instance:GetHunQiXiLianOpenCfg(hunqi_btn:GetIndex() - 1, 0)
		local name = HunQiData.Instance:GetHunQiNameAndColorByIndex(hunqi_btn:GetIndex() - 1)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.HunQi.New_XiLianOpenLimitDesc, name))
		self:FlushHigh()
		return 
	end
	self.current_select_hunqi = hunqi_btn:GetIndex()
	self:FlushModel()
	self:FlushView()
	self:ResertLock()
end

function XiLianContentView:SetLockNum()
	local lock_flag = 0
	local num = 0
	for i,v in ipairs(self.hunqi_attr_list) do
		if v:GetIsLock() then
			num = num + 1
			lock_flag = lock_flag + math.pow(2 , i - 1)
		end
	end
	self.lock_slot_num = num
	self.lock_slot_flag = lock_flag
end

function XiLianContentView:GetIsLockByIndex(index)
	if self.hunqi_attr_list[index] then
		return self.hunqi_attr_list[index]:GetIsLock()
	end
	return false
end

function XiLianContentView:GetCanLock()
	return self.lock_slot_num == self.open_xilian_slot_num - 1
end

function XiLianContentView:ResertLock()
	for i,v in ipairs(self.hunqi_attr_list) do
		v:SetToggle(false)
	end
	self:SetLockNum()
	self:FlushStuff()
end

function XiLianContentView:FlushAttr()
	local xilian_data = HunQiData.Instance:GetHunQiXiLianInfoById(self.current_select_hunqi)
	if not xilian_data then
		return
	end
	self.open_xilian_slot_num = 0
	for i = 1, 8 do
		local cfg_data = HunQiData.Instance:GetHunQiXiLianOpenCfg(self.current_select_hunqi - 1, i - 1)
		local data = {}
		data.hunqi_id = self.current_select_hunqi
		data.slot_id = i
		data.gold_cost = cfg_data.gold_cost
		data.lingshu_level_limit = cfg_data.lingshu_level_limit
		data.xilian_slot_open_falg = xilian_data.xilian_slot_open_falg[33 - i]
		data.xilian_shuxing_type = xilian_data.xilian_shuxing_type[i]
		data.xilian_shuxing_star = xilian_data.xilian_shuxing_star[i]
		data.xilian_shuxing_value = xilian_data.xilian_shuxing_value[i]
		self.hunqi_attr_list[i]:SetData(data)
		if 1 == data.xilian_slot_open_falg then 
			self.open_xilian_slot_num = self.open_xilian_slot_num + 1 
		end
	end

	local total_star = HunQiData.Instance:GetHunQiXiLianTotalStarNumById(self.current_select_hunqi)
	local cur_attr, next_attr = HunQiData.Instance:GetHunQiXiLianSuitAttrById(self.current_select_hunqi - 1)
	local cur_add_per = 0
	local next_add_per = 0
	local cur_star = 0
	local next_star = 0
	if cur_attr then
		cur_add_per = cur_attr.add_per / 100
		cur_star = cur_attr.need_start_count
	end
	if next_attr then
		next_add_per = next_attr.add_per / 100
		next_star = next_attr.need_start_count
	end
	self.node_list["TxtAttr1"].text.text = string.format(Language.HunQi.XiLianSuitAttr, cur_add_per, total_star, cur_star)
	self.node_list["TxtAttr2"].text.text = string.format(Language.HunQi.XiLianSuitAttr, next_add_per, ToColorStr(total_star, COLOR.RED), next_star)
	local capability = HunQiData.Instance:GetHunQiXiLianCapability(self.current_select_hunqi)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end
	self.node_list["TxtAttr1"]:SetActive(cur_attr ~= nil)
	self.node_list["TxtAttr2"]:SetActive(next_attr ~= nil)
end

function XiLianContentView:FlushHunQiList()
	for i,v in ipairs(self.hunqi_btn_list) do
		local data = {}
		data.star_level = HunQiData.Instance:GetHunQiXiLianTotalStarNumById(i)
		data.open_limit = HunQiData.Instance:GetHunQiXiLianOpenCfg(i - 1, 0).lingshu_level_limit
		v:SetData(data)
	end
end

function XiLianContentView:FlushStuff()
	local stuff_cfg = self.select_stuff_cfg
	local data_id = stuff_cfg.consume_item.item_id
	self.stuff_cell:SetData({item_id = data_id})
	self.xilian_comsume_color = stuff_cfg.comsume_color
	self.stuff_item_id = stuff_cfg.consume_item.item_id
	self.node_list["toggle"]:SetActive(self.select_stuff_cfg.comsume_color < HunQiData.XiLianStuffColor.PURPLE)
	if self.select_stuff_cfg.comsume_color >= HunQiData.XiLianStuffColor.PURPLE then
		local pos = self.node_list["BtnXiLian"].transform.anchoredPosition
		self.node_list["BtnXiLian"].transform.anchoredPosition = Vector3(0, pos.y, pos.z)
	else
		local pos = self.node_list["BtnXiLian"].transform.anchoredPosition
		self.node_list["BtnXiLian"].transform.anchoredPosition = Vector3(-90, pos.y, pos.z)
	end
	
	local free_max_times = HunQiData.Instance:GetOtherCfg().free_xilian_times
	local yet_free_times = HunQiData.Instance:GetHunQiXiLianFreeTimes()
	local surplus = free_max_times - yet_free_times

	--local need_lock_item_cfg = HunQiData.Instance:GetHunQiXiLianLockConsumeByLockNumAndLockComsumeID(self.lock_slot_num, stuff_cfg.consume_item.item_id)
	if surplus > 0 then
		self.node_list["TxtNum"].text.text = string.format(Language.HunQi.FreeTimes, surplus)
	else
		local num = ItemData.Instance:GetItemNumInBagById(stuff_cfg.consume_item.item_id)
		local need_num = stuff_cfg.consume_item.num
		if self.lock_slot_num >= #self.hunqi_attr_list then
			return
		end
		-- local need_num = 0
		-- if self.lock_slot_num ~= 0 then
		-- 	need_num = need_lock_item_cfg[1].lock_comsume_item.num + stuff_cfg.consume_item.num
		-- else
		-- 	need_num = stuff_cfg.consume_item.num
		-- end
		local color = num >= need_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4
		self.node_list["TxtNum"].text.text = ToColorStr(num, color) .. " / " .. need_num
	end

	if stuff_cfg.comsume_color >= 1 then
		self.node_list["TxtTips"]:SetActive(true)
		local name = string.format(Language.Common.ToColor, SOUL_NAME_COLOR[stuff_cfg.color + 1], ItemData.Instance:GetItemName(data_id))
		local color = string.format(Language.Common.ToColor, SOUL_NAME_COLOR[stuff_cfg.color + 1], Language.HunQi.ItemDesc[stuff_cfg.comsume_color])
		local txt = string.format(Language.HunQi.XilianTip, name, color)
		self.node_list["TxtTips"].text.text = txt
		local pos = self.node_list["NodeButton"].transform.anchoredPosition
		self.node_list["NodeButton"].transform.anchoredPosition = Vector3(pos.x, -30, pos.z)
	else
		self.node_list["TxtTips"]:SetActive(false)
		local pos = self.node_list["NodeButton"].transform.anchoredPosition
		self.node_list["NodeButton"].transform.anchoredPosition = Vector3(pos.x, 0, pos.z)
	end

	local lock_stuff_cfg = HunQiData.Instance:GetHunQiXiLianLockConsume(self.lock_slot_num)
	if self.lock_slot_num >= #self.hunqi_attr_list then
		return
	end
	
	local need_lock_stuff_num = lock_stuff_cfg.lock_comsume_item.num
	if 0 == lock_stuff_cfg.lock_comsume_item.item_id then
		need_lock_stuff_num = 0
	end 
	local has_lock_stuff_num = ItemData.Instance:GetItemNumInBagById(lock_stuff_cfg.lock_comsume_ID)
	self.lock_cell:SetData({item_id = lock_stuff_cfg.lock_comsume_ID})
	local color = has_lock_stuff_num >= need_lock_stuff_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4
	self.node_list["TxtLocknum"].text.text = ToColorStr(has_lock_stuff_num, color) .. " / " .. need_lock_stuff_num
end

function XiLianContentView:FlushModel()
	if self.current_select_hunqi > 0 and self.current_select_hunqi ~= self.last_select_hunqi then
		local bundle, asset = ResPath.GetYiHuoImg(self.current_select_hunqi)
		self.node_list["ImgYiHuo"].image:LoadSprite(bundle, asset)
		self.node_list["NodeEffect"]:ChangeAsset(ResPath.GetHunYinEffect(HunQiData.EFFECT_PATH[self.current_select_hunqi]))
		self.last_select_hunqi = self.current_select_hunqi
	end

	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.current_select_hunqi - 1)
	local color = ITEM_COLOR[color_num]
	hunqi_name = ToColorStr(hunqi_name, color)
	self.node_list["TxtName"].text.text = hunqi_name
end

function XiLianContentView:InitView()
	self:FlushView()
end

function XiLianContentView:FlushView()
	self:FlushAttr()
	self:FlushStuff()
	self:FlushHunQiList()
	self:FlushHigh()
	self:FlushModel()
end

function XiLianContentView:OnClickXiLian()
	if ItemData.Instance:GetItemNumInBagById(self.stuff_item_id) <= 0 and not self.node_list["toggle"].toggle.isOn 
		and self.select_stuff_cfg.comsume_color < HunQiData.XiLianStuffColor.RED then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.stuff_item_id]
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.node_list["toggle"].toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.stuff_item_id, nil, 1)
		return
	end

	--锁道具不足
	local lock_stuff_cfg = HunQiData.Instance:GetHunQiXiLianLockConsume(self.lock_slot_num)
	if self.lock_slot_num >= #self.hunqi_attr_list or not lock_stuff_cfg then
		return
	end
	local need_lock_stuff_num = lock_stuff_cfg.lock_comsume_item.num
	if 0 == lock_stuff_cfg.lock_comsume_item.item_id then
		need_lock_stuff_num = 0
	end
	local lock_id = lock_stuff_cfg.lock_comsume_ID
	if ItemData.Instance:GetItemNumInBagById(lock_id) < need_lock_stuff_num and not self.node_list["toggle"].toggle.isOn then
		--TipsCtrl.Instance:ShowItemGetWayView(lock_id)
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.node_list["toggle"].toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, lock_id, nil, need_lock_stuff_num)
		return
	end

	local has_rare, num = HunQiData.Instance:GetHunQiXiLianHasRareById(self.current_select_hunqi)
	local des = string.format(Language.HunQi.XiLianConfireTips, num)
	local function ok_callback()
		-- 请求洗练，param1 魂器类型， param2锁定槽0-7位表示1-8位属性, param3洗练材料类型,param4 是否自动购买, param5 是否免费
		local free_max_times = HunQiData.Instance:GetOtherCfg().free_xilian_times
		local yet_free_times = HunQiData.Instance:GetHunQiXiLianFreeTimes()
		local surplus = free_max_times - yet_free_times
		local is_free = surplus > 0 and 1 or 0
		local is_auto_buy = self.node_list["toggle"].toggle.isOn and 1 or 0
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_XILIAN_REQ, self.current_select_hunqi - 1, self.lock_slot_flag, self.xilian_comsume_color, is_auto_buy, is_free) 
	end
	if has_rare then
		TipsCtrl.Instance:ShowCommonAutoView("XiLian", des, ok_callback, nil, nil, nil, nil, nil, true, false)
	else
		ok_callback()
	end
end

function XiLianContentView:SelectStuff()
	ViewManager.Instance:Open(ViewName.HunQiXiLianStuffView)
end

function XiLianContentView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(237)
end

function XiLianContentView:OnSelectStuff(operate_type, stuff_cfg)
	if 1 == operate_type then
		self:SetLockNum()
	else
		self.select_stuff_cfg = stuff_cfg
		self.node_list["toggle"].toggle.isOn = false
	end
	self:FlushStuff()
end

----------------------------炼魂里面的小格子-----------------------------------
XiLianElement = XiLianElement or BaseClass(BaseCell)

function XiLianElement:__init()
	self.node_list["Toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function XiLianElement:__delete()

end

function XiLianElement:OnClick()
	if 0 == self.data.xilian_slot_open_falg then
		if HunQiData.Instance:GetHunQiLevelByIndex(self.data.hunqi_id - 1) < self.data.lingshu_level_limit then
			local name = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.data.hunqi_id - 1)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.HunQi.XiLianOpenLimitDesc, name, self.data.lingshu_level_limit))
			self.node_list["Toggle"].toggle.isOn = false
			return
		end

		local open_num, open_consume, open_list = HunQiData.Instance:GetHunQiXiLianOpenConsume(self.data.hunqi_id, self.data.slot_id)
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_XILIAN_OPEN_SLOT, self.data.hunqi_id - 1, self.data.slot_id - 1) 
		self.node_list["Toggle"].toggle.isOn = false
	else
		if self.node_list["Toggle"].toggle.isOn and HunQiData.Instance:GetXiLianContentView():GetCanLock() then
			SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.LockTip)
			self.node_list["Toggle"].toggle.isOn = false
		end
		GlobalEventSystem:Fire(OtherEventType.HUNQI_XILIAN_STUFF_SELECT, 1)
	end
end

function XiLianElement:GetIsLock()
	return self.node_list["Toggle"].toggle.isOn
end

function XiLianElement:SetToggle(value)
	self.node_list["Toggle"].toggle.isOn = value
end

function XiLianElement:OnFlush(param_t)
	if not self.data then
		return
	end

	if 1 == self.data.xilian_slot_open_falg then
		local str = ""
		local attr_type = Language.HunQi.XiLianAttrType[self.data.xilian_shuxing_type]
		local shuxing_classify = HunQiData.Instance:GetHunQiXiLianShuXingType(self.data.hunqi_id - 1, self.data.xilian_shuxing_type).shuxing_classify or 0
		local attr_value = self.data.xilian_shuxing_value
		if shuxing_classify ~= 1 then
			attr_value = attr_value / 100 .. "%"
		end
		local color = TEXT_COLOR.BLUE
		if self.data.xilian_shuxing_star >= 9 then
			color = TEXT_COLOR.RED
		elseif self.data.xilian_shuxing_star >= 7 then 
			color = TEXT_COLOR.ORANGE_3
		elseif self.data.xilian_shuxing_star >= 4 then 
			color = TEXT_COLOR.PURPLE_3
		end
		str = string.format(Language.HunQi.XiLianAttrDesc, attr_type, color, attr_value, self.data.xilian_shuxing_star)
		self.node_list["Txtattr"].text.text = str
	else
		self.node_list["Txt"].text.text = self.data.gold_cost
	end
	self.node_list["Btn"]:SetActive(1 ~= self.data.xilian_slot_open_falg)
	self.node_list["ListCost"]:SetActive(1 ~= self.data.xilian_slot_open_falg)
	self.node_list["Txtattr"]:SetActive(1 == self.data.xilian_slot_open_falg)
	self.node_list["Toggle"]:SetActive(1 == self.data.xilian_slot_open_falg)
end

---------------------HunQiXiLianBtn----------------------------
HunQiXiLianBtn = HunQiXiLianBtn or BaseClass(BaseCell)
function HunQiXiLianBtn:__init()
	self.node_list["ToggleEquip"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function HunQiXiLianBtn:__delete()

end

function HunQiXiLianBtn:OnFlush()
	local flag = HunQiData.Instance:CalcHunQiXiLianShuRedPointById(self:GetIndex())
	self.node_list["ImgRedPoint"]:SetActive(flag > 0)
		--设置图标
	local model_res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.index - 1)
	local param = model_res_id - 17000
	local res_id = "HunQi_" .. param
	UI:SetGraphicGrey(self.node_list["Img"], self.data.star_level == 0)
	self.node_list["Img"].image:LoadSprite(ResPath.GetHunQiImg(res_id))
	self.node_list["TxtStarLevel"].text.text = self.data.star_level
end

function HunQiXiLianBtn:SetShowHigh(value)
	self.root_node.toggle.isOn = value
	self.node_list["High"]:SetActive(value)
end