TipsZhuanZhiView = TipsZhuanZhiView or BaseClass(BaseView)

function TipsZhuanZhiView:__init()
	self.ui_config = {{"uis/views/player_prefab", "ZhuanZhiTips"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.play_audio = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.is_auto_buy_stone = 0
	self.imp_guard_type = 0
	self.index = 1
	self.zhuan = 1
end

function TipsZhuanZhiView:LoadCallBack()
	self.node_list["BuyBtn"].button:AddClickListener(BindTool.Bind(self.OnClickBuyButton, self))
	self.node_list["LightenBtn"].button:AddClickListener(BindTool.Bind(self.OnClickLightenButton, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.material_cell_1 = ItemCell.New()
	self.material_cell_1:SetInstanceParent(self.node_list["MaterialCell1"])

	self.material_cell_2 = ItemCell.New()
	self.material_cell_2:SetInstanceParent(self.node_list["MaterialCell2"])
end

function TipsZhuanZhiView:ReleaseCallBack()
	if self.item_data_event ~= nil then
		if ItemData.Instance then
			ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		end
		self.item_data_event = nil
	end

	if self.material_cell_1 then
		self.material_cell_1:DeleteMe()
		self.material_cell_1 = nil
	end

	if self.material_cell_2 then
		self.material_cell_2:DeleteMe()
		self.material_cell_2 = nil
	end
end

function TipsZhuanZhiView:OpenCallBack()
	self:Flush()
end

function TipsZhuanZhiView:CloseCallBack()

end

function TipsZhuanZhiView:ItemDataChangeCallback(item_id)
	local zhuanzhi_cfg = ZhuanZhiData.Instance:GetZhuanZhiSingleCfgByZhuan(self.zhuan, self.index)
	if nil == zhuanzhi_cfg then
		return
	end

	if item_id == zhuanzhi_cfg.need_stuff_id then
		self:Flush()
	end
end

function TipsZhuanZhiView:SetData(zhuan, index)
	if nil == zhuan or nil == index then
		return
	end

	self.index = index
	self.zhuan = zhuan
end

function TipsZhuanZhiView:OnFlush()
	local zhuanzhi_cfg = ZhuanZhiData.Instance:GetZhuanZhiSingleCfgByZhuan(self.zhuan, self.index)
	if nil == zhuanzhi_cfg then
		return
	end
	local old_zhuanzhi_cfg = ZhuanZhiData.Instance:GetZhuanZhiSingleCfgByZhuan(self.zhuan, self.index - 1)

	self.node_list["MingGeName"].text.text = zhuanzhi_cfg.name
	self.node_list["Gongji"].text.text = old_zhuanzhi_cfg and (zhuanzhi_cfg.gongji - old_zhuanzhi_cfg.gongji) or zhuanzhi_cfg.gongji
	self.node_list["Fangyu"].text.text = old_zhuanzhi_cfg and (zhuanzhi_cfg.fangyu - old_zhuanzhi_cfg.fangyu) or zhuanzhi_cfg.fangyu
	self.node_list["Pojia"].text.text = old_zhuanzhi_cfg and (zhuanzhi_cfg.pojia - old_zhuanzhi_cfg.pojia) or zhuanzhi_cfg.pojia
	self.node_list["Hp"].text.text = old_zhuanzhi_cfg and (zhuanzhi_cfg.maxhp - old_zhuanzhi_cfg.maxhp) or zhuanzhi_cfg.maxhp

	local item_cfg = ItemData.Instance:GetItemConfig(zhuanzhi_cfg.need_stuff_id)
	local item_num = ItemData.Instance:GetItemNumInBagById(zhuanzhi_cfg.need_stuff_id)
	local role_exp = GameVoManager.Instance:GetMainRoleVo().exp
	local color_1 = TEXT_COLOR.RED
	local color_2 = TEXT_COLOR.GREEN
	local conver_num = CommonDataManager.ConverNum(role_exp)
	local need_exp = zhuanzhi_cfg.exp_factor * PlayerData.Instance:GetFBExpByLevel(GameVoManager.Instance:GetMainRoleVo().level)
	self.node_list["RedPoint"]:SetActive(tonumber(item_num) >= zhuanzhi_cfg.need_stuff_num)

	item_num = item_num >= zhuanzhi_cfg.need_stuff_num and ToColorStr(item_num, color_2) or ToColorStr(item_num, color_1)
	conver_num = role_exp >= need_exp and ToColorStr(conver_num, color_2) or ToColorStr(conver_num, color_1)

	-- self.node_list["Consume_1"].text.text = item_cfg.name .. " " ..item_num .. "个 / " .. ToColorStr(zhuanzhi_cfg.need_stuff_num, color_2) .. "个"
	-- self.node_list["Consume_2"].text.text = conver_num .. " / " .. ToColorStr(CommonDataManager.ConverNum(zhuanzhi_cfg.need_exp), color_2)
	self.node_list["Name1"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color]) 
	-- self.node_list["Num1"].text.text = item_num .. "个 / " .. ToColorStr(zhuanzhi_cfg.need_stuff_num, color_2) .. "个"
	self.node_list["Num1"].text.text = string.format("%s / %s", item_num, ToColorStr(zhuanzhi_cfg.need_stuff_num, color_2))
	self.material_cell_1:SetData({item_id = zhuanzhi_cfg.need_stuff_id, close_call_back = BindTool.Bind(self.OnClickClose, self)})

	self.node_list["Name2"].text.text = ToColorStr(Language.Player.ExpDesc, TEXT_COLOR.GREEN)
	self.node_list["Num2"].text.text = conver_num .. " / " .. ToColorStr(CommonDataManager.ConverNum(need_exp), color_2)
	self.material_cell_2:SetData({item_id = ResPath.CurrencyToIconId["exp"], close_call_back = BindTool.Bind(self.OnClickClose, self)})

	local zhuanzhi_info = ZhuanZhiData.Instance:GetSingleZhuanZhiInfo(self.zhuan)
	if nil == zhuanzhi_info then
		return
	end

	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local _, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	local accept_process = zhuanzhi_task_status and zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS or false
	
	if zhuanzhi_info == self.index - 1 and zhuan < self.zhuan and accept_process then
		self.node_list["BottomTxt"]:SetActive(false)
		self.node_list["Expend"]:SetActive(true)
		self.node_list["BtnList"]:SetActive(true)
	elseif zhuanzhi_info == self.index - 1 and zhuan < self.zhuan and zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT and self.index == 1 then
		self.node_list["BottomTxt"].text.text = Language.Player.NeedAcceptTask
		self.node_list["BottomTxt"]:SetActive(true)
		self.node_list["Expend"]:SetActive(true)
		self.node_list["BtnList"]:SetActive(true)
	elseif zhuanzhi_info < self.index - 1 and zhuan < self.zhuan then
		local last_wuzhuan_cfg = ZhuanZhiData.Instance:GetZhuanZhiSingleCfgByZhuan(self.zhuan, self.index - 1)
		self.node_list["BottomTxt"].text.text = string.format(Language.Player.NeedUpLevel, last_wuzhuan_cfg.name)
		self.node_list["BottomTxt"]:SetActive(true)
		self.node_list["Expend"]:SetActive(true)
		self.node_list["BtnList"]:SetActive(false)
	elseif zhuanzhi_info > self.index - 1 and zhuan < self.zhuan then
		self.node_list["BottomTxt"]:SetActive(true)
		self.node_list["BottomTxt"].text.text = Language.Player.IsLighten
		self.node_list["Expend"]:SetActive(false)
		self.node_list["BtnList"]:SetActive(false)
	elseif zhuan >= self.zhuan then
		self.node_list["BottomTxt"]:SetActive(true)
		self.node_list["BottomTxt"].text.text = Language.Player.IsLighten
		self.node_list["Expend"]:SetActive(false)
		self.node_list["BtnList"]:SetActive(false)
	else
		self.node_list["BottomTxt"]:SetActive(false)
		self.node_list["Expend"]:SetActive(false)
		self.node_list["BtnList"]:SetActive(false)
	end
end

function TipsZhuanZhiView:OnClickClose()
	self:Close()
end

function TipsZhuanZhiView:OnClickBuyButton()
	local zhuanzhi_cfg = ZhuanZhiData.Instance:GetZhuanZhiSingleCfgByZhuan(self.zhuan, self.index)
	if nil == zhuanzhi_cfg then
		return
	end

	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		if is_buy_quick then
			self.is_auto_buy_stone = 1
		end
	end
	local item_num = ItemData.Instance:GetItemNumInBagById(zhuanzhi_cfg.need_stuff_id)
	local need_num = zhuanzhi_cfg.need_stuff_num - item_num
	need_num = (need_num > 0) and need_num or 1
	TipsCtrl.Instance:ShowCommonBuyView(func, zhuanzhi_cfg.need_stuff_id, nofunc, need_num)
end

function TipsZhuanZhiView:OnClickLightenButton()
	local zhuanzhi_cfg = ZhuanZhiData.Instance:GetZhuanZhiSingleCfgByZhuan(self.zhuan, self.index)
	local item_num = ItemData.Instance:GetItemNumInBagById(zhuanzhi_cfg.need_stuff_id)
	-- if zhuanzhi_cfg.need_stuff_num > item_num then
		-- ZhuanZhiCtrl.Instance:SendRoleZhuanZhi(self.zhuan - 5, 1, self.is_auto_buy_stone)
	-- else
	ZhuanZhiCtrl.Instance:SendRoleZhuanZhi(self.zhuan - 5, 0, self.is_auto_buy_stone)
	-- end
	self:Close()
end