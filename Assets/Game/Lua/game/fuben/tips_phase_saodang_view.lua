FuBenPhaseSaoDangView = FuBenPhaseSaoDangView or BaseClass(BaseView)
local COLUMN = 2
function FuBenPhaseSaoDangView:__init(  )
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_1"},
		{"uis/views/fubenview_prefab", "AdvanceSaoDangTips"},
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_2"},
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function FuBenPhaseSaoDangView:__delete()

end

function FuBenPhaseSaoDangView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(904, 606, 0)
	self.node_list["Bg1"].rect.sizeDelta = Vector3(904, 606, 0)
	self.node_list["Txt"].text.text = Language.FuBen.SaoDangTitle

	-- local list_delegate = self.node_list["listview"].list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.cell_list = {}

	self.node_list["BtnSaoDang"].button:AddClickListener(BindTool.Bind(self.OnClickSaoDang, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.cost = 0

	self.send_list = {}
	self.vip_buy_count = {}
	self.fuben_info = {}
	self.obj_list = {}
end

function FuBenPhaseSaoDangView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
	self.cost = nil
	self.fuben_info = nil
	self.fuben_cfg = nil

end

function FuBenPhaseSaoDangView:CloseWindow()
	self:Close()
end

function FuBenPhaseSaoDangView:CloseCallBack()
	self.cost = 0
	if self.vip_buy_count then
		for k,v in pairs(self.vip_buy_count) do
			v.buy_count = 0
		end
	end
	for k,v in pairs(self.obj_list) do
		if v then
			ResMgr:Destroy(v)
		end
	end
	self.obj_list = {}
end

function FuBenPhaseSaoDangView:LoadCell()
	local data_list = FuBenData.Instance:GetSaoDangData()
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/fubenview_prefab", "AdvanceSaoDangItem", nil, function(prefab)
		if nil == prefab then
			return 
		end
		local num = FuBenData.Instance:GetSaoDangToggleNum() or 0
		local last_num = math.ceil(num / 2)
		for i = 1, last_num do
			local obj = ResMgr:Instantiate(prefab)
			self.obj_list[obj] = obj
			local cell = PhaseSaoDangGroup.New(obj.gameObject)
			self.cell_list[i] = cell
			cell:SetInstanceParent(self.node_list["Content"], false)
			for k = 1, COLUMN do
				local index = (i - 1) * COLUMN + k
				local data = data_list[index]
				cell:SetIndex(k,index)
				cell:SetActive(k, (data ~= nil))
				cell:SetParent(k, self)
				cell:SetData(k, data)
			end
		end
	end)
end

function FuBenPhaseSaoDangView:OpenCallBack()
	self:LoadCell()
	self:Flush()
end

function FuBenPhaseSaoDangView:OnFlush()
	self.fuben_info = FuBenData.Instance:GetPhaseFBInfo()
	self:FlushGoldCost()
	local num_list = FuBenData.Instance:GetToggleNum() or {}

	for i = 1, #num_list do
		local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(i - 1, 1) 						--暂定选第一个，如果免费次数不同再改
		if fuben_cfg and self.fuben_info and self.fuben_info[i - 1] then
			local enter_count = fuben_cfg.free_times + self.fuben_info[i - 1].today_buy_times - self.fuben_info[i - 1].today_times or 0
			self.send_list[i] = {}
			self.send_list[i].enter_count = enter_count
			self.send_list[i].is_pass = self.fuben_info[i - 1].is_pass

			self.vip_buy_count[i] = {}
			self.vip_buy_count[i].buy_count = 0
			self.vip_buy_count[i].is_pass = self.fuben_info[i - 1].is_pass
		end
	end
end

function FuBenPhaseSaoDangView:OnClickSaoDang()
	local function ok_func()
		for k,v in pairs(self.vip_buy_count) do
			if v.is_pass > 0 then
				if v and v.buy_count then
					for i = 1,v.buy_count do
						FuBenCtrl.Instance:SendGetPhaseFBInfoReq(PHASE_FB_OPERATE_TYPE.PHASE_FB_OPERATE_TYPE_BUY_TIMES, k - 1)
					end
				end
			end
		end
		for k,v in pairs(self.send_list) do
			if v.is_pass > 0 then
				if v and v.enter_count then
					for i = 1, v.enter_count do
						FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PHASE, k - 1, v.is_pass)
					end
				end
			end
		end
		self:Close()
		FuBenData.Instance:SetPhaseSaoDangList(self.send_list)
		for k,v in pairs(self.send_list) do
			if v and v.is_pass > 0 and v.enter_count > 0 then
				local data = FuBenData.Instance:GetSaoDangInfoData()
				FuBenCtrl.Instance:OpenFuBenGetView(data)
			end
		end
		for k,v in pairs(self.cell_list) do
			if v then
				for i = 1, 2 do
					v:SetBuyTime(i,0)
				end
			end
		end
	end
	if self.cost <= 0 then
		ok_func()
	else
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_vo then
			if self.cost <= main_vo.gold + main_vo.bind_gold then
				local describe = string.format(Language.FuBen.Cost, self.cost)
				TipsCtrl.Instance:ShowCommonAutoView("", describe, ok_func)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoEnoughGold)
			end
		end
	end
end

function FuBenPhaseSaoDangView:AddCount(index, enter_num, gold_cost, flag, add_num)
	if index and add_num and gold_cost then
		local cost = add_num * gold_cost
		self.cost = flag and self.cost + cost or self.cost - cost
		self:FlushGoldCost()
		if self.send_list[index] and self.send_list[index].enter_count then
			self.send_list[index].enter_count = enter_num
		end
	end
end

function FuBenPhaseSaoDangView:AddVIPBuyCount(index, vip_buy_count, flag)
	if self.vip_buy_count[index] and self.vip_buy_count[index].buy_count then
		self.vip_buy_count[index].buy_count = flag and self.vip_buy_count[index].buy_count + vip_buy_count or self.vip_buy_count[index].buy_count - vip_buy_count
	end
end

function FuBenPhaseSaoDangView:FlushGoldCost()
	self.node_list["TxtNum"].text.text = self.cost or 0
	self.node_list["Cost"]:SetActive(self.cost > 0)
end


-- function FuBenPhaseSaoDangView:GetNumberOfCells()
-- 	local num = FuBenData.Instance:GetSaoDangToggleNum() or 0
-- 	print_error("00000000000", num)
-- 	return math.ceil(num / 2)
-- end

-- function FuBenPhaseSaoDangView:RefreshCell(cell, cell_index)
-- 	local cell_group = self.cell_list[cell]
-- 	if nil == cell_group then
-- 		cell_group = PhaseSaoDangGroup.New(cell.gameObject)
-- 		self.cell_list[cell] = cell_group
-- 	end
-- 	local data_list = FuBenData.Instance:GetSaoDangData()
-- 	print_error("11111111111111", data_list)
-- 	for i = 1, COLUMN do
-- 		local index = (cell_index) * COLUMN + i
-- 		local data = data_list[index]
-- 		cell_group:SetIndex(i, index)
-- 		cell_group:SetActive(i, (data ~= nil))
-- 		cell_group:SetParent(i, self)
-- 		cell_group:SetData(i, data)
-- 	end
-- end

------------------------------------------------------------
PhaseSaoDangGroup = PhaseSaoDangGroup or BaseClass(BaseRender)

function PhaseSaoDangGroup:__init(  )
	self.item_list = {}
	for i = 1, COLUMN do
		local cell = PhaseSaoDangCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, cell)
	end
end

function PhaseSaoDangGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function PhaseSaoDangGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function PhaseSaoDangGroup:SetParent(i, parent)
	self.item_list[i]:SetParent(parent)
end

function PhaseSaoDangGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function PhaseSaoDangGroup:SetBuyTime(i, num)
	self.item_list[i]:SetBuyTime(num)
end

function PhaseSaoDangGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

------------------------------------------------------------
PhaseSaoDangCell = PhaseSaoDangCell or BaseClass(BaseCell)

function PhaseSaoDangCell:__init()
	self.node_list["BtnReduce"].button:AddClickListener(BindTool.Bind(self.OnClickReduce, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnClickAdd, self))
	self.node_list["BtnMax"].button:AddClickListener(BindTool.Bind(self.OnClickMax, self))
	self.is_max_first = true
	self.today_buy_times = 0
	self.enter_count = 0
	self.has_time = 0
	self.buy_time = 0
end

function PhaseSaoDangCell:__delete()
	self.fuben_info = nil
	self.fuben_cfg = nil
	self.max_buy_num = nil
	self.buy_time = nil
	self.has_time = nil
	self.enter_count = nil
	self.parent = nil
	self.today_buy_times = 0
end

function PhaseSaoDangCell:SetIndex(index)
	self.index = index
end

function PhaseSaoDangCell:OnFlush()
	if nil == self.data then
		return
	end
	self.node_list["TxtName"].text.text = Language.FuBen.PhaseSaoDangTipName[self.data.index + 1] or ""
	local bundle,asset = ResPath.GetFuBenSaoDangBg(self.data.index + 1)
	self.node_list["ImgBg"].raw_image:LoadSprite(bundle, asset)
	self.fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(self.data.index, self.data.is_pass)
	self.fuben_info = FuBenData.Instance:GetPhaseFBInfo()
	if self.fuben_cfg and self.fuben_info and self.fuben_info[self.data.index] then
		self.has_buy_times = self.fuben_info[self.data.index].today_buy_times or 0
		self.enter_count = self.fuben_cfg.free_times + self.has_buy_times + self.today_buy_times - self.fuben_info[self.data.index].today_times or 0
		self.max_buy_num = VipPower:GetParam(VipPowerId.fuben_phase_buy_times) or 0
		self.buy_time = self.max_buy_num - self.has_buy_times - self.today_buy_times
		self.node_list["TxtTime"].text.text = self.enter_count

		local flag = self.fuben_cfg.free_times + self.fuben_info[self.data.index].today_buy_times - self.fuben_info[self.data.index].today_times - self.enter_count >= 0
		self.has_time = flag and self.fuben_cfg.free_times + self.fuben_info[self.data.index].today_buy_times - self.fuben_info[self.data.index].today_times - self.enter_count or 0
		local color = self.has_time <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		self.node_list["TxtRestTime"].text.text = string.format(Language.FuBen.LastSaoDangTimes, color, self.has_time)

		local color2 = self.buy_time <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		self.node_list["TxtBuyTime"].text.text = string.format(Language.FuBen.LastBuyTimes, color2, self.buy_time)

		self.node_list["TxtBuyTime"]:SetActive(self.today_buy_times >= 0)
		self.node_list["TxtRestTime"]:SetActive(self.today_buy_times < 0)
	end
end

function PhaseSaoDangCell:SetParent(parent)
	self.parent = parent
end

function PhaseSaoDangCell:SetBuyTime(num)
	self.today_buy_times = num
end

function PhaseSaoDangCell:OnClickReduce()
	self.is_max_first = true
	if self.enter_count <= 0 then
		return
	end
	self.enter_count = self.enter_count - 1
	self.node_list["TxtTime"].text.text = self.enter_count
	if self.fuben_cfg and self.fuben_info and self.fuben_info[self.data.index] then
		if self.enter_count >= self.fuben_cfg.free_times + self.fuben_info[self.data.index].today_buy_times - self.fuben_info[self.data.index].today_times then
			self.buy_time = self.buy_time + 1
			self.today_buy_times = self.today_buy_times - 1
			local color2 = self.buy_time <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
			self.node_list["TxtBuyTime"].text.text = string.format(Language.FuBen.LastBuyTimes, color2, self.buy_time)

			local cost = FuBenData.Instance:GetPhaseFbResetGold(self.data.index) or 0
			self.parent:AddCount(self.data.index + 1, self.enter_count, cost, false, 1)
			self.parent:AddVIPBuyCount(self.data.index + 1, 1, false)
			self.node_list["TxtRestTime"].text.text = string.format(Language.FuBen.LastSaoDangTimes, TEXT_COLOR.RED, 0)
		else
			self.today_buy_times = self.today_buy_times - 1
			self.buy_time = self.max_buy_num - self.has_buy_times - self.today_buy_times
			self.parent:AddCount(self.data.index + 1, self.enter_count, 0, false, 0)
			self.has_time = self.has_time + 1
			local color = self.has_time <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
			self.node_list["TxtRestTime"].text.text = string.format(Language.FuBen.LastSaoDangTimes, color, self.has_time)
		end
		local flag = self.enter_count >= self.fuben_cfg.free_times + self.fuben_info[self.data.index].today_buy_times - self.fuben_info[self.data.index].today_times 
		self.node_list["TxtBuyTime"]:SetActive(flag)
		self.node_list["TxtRestTime"]:SetActive(not flag)
	end
end

function PhaseSaoDangCell:OnClickAdd()
	self.is_max_first = true
	local max_num = self.fuben_cfg.free_times + self.max_buy_num - self.fuben_info[self.data.index].today_times or 0
	if self.enter_count >= max_num then
		return
	end
	self.enter_count = self.enter_count + 1
	self.node_list["TxtTime"].text.text = self.enter_count
	if self.fuben_cfg and self.fuben_info and self.fuben_info[self.data.index] then
		if self.enter_count > self.fuben_cfg.free_times + self.fuben_info[self.data.index].today_buy_times - self.fuben_info[self.data.index].today_times then
			self.buy_time = self.buy_time - 1
			self.today_buy_times = self.today_buy_times + 1
			local color2 = self.buy_time <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
			self.node_list["TxtBuyTime"].text.text = string.format(Language.FuBen.LastBuyTimes, color2, self.buy_time)

			local cost = FuBenData.Instance:GetPhaseFbResetGold(self.data.index) or 0
			self.parent:AddCount(self.data.index + 1, self.enter_count,cost, true, 1)
			self.parent:AddVIPBuyCount(self.data.index + 1, 1, true)
			self.node_list["TxtRestTime"].text.text = string.format(Language.FuBen.LastSaoDangTimes, TEXT_COLOR.RED, 0)
		else
			self.today_buy_times = self.today_buy_times + 1
			self.buy_time = self.max_buy_num - self.has_buy_times - self.today_buy_times
			self.parent:AddCount(self.data.index + 1, self.enter_count, 0, true, 0)
			self.has_time = self.has_time - 1
			local color = self.has_time <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
			self.node_list["TxtRestTime"].text.text = string.format(Language.FuBen.LastSaoDangTimes, color, self.has_time)
		end
		local flag = self.enter_count >= self.fuben_cfg.free_times + self.fuben_info[self.data.index].today_buy_times - self.fuben_info[self.data.index].today_times 
		self.node_list["TxtBuyTime"]:SetActive(flag)
		self.node_list["TxtRestTime"]:SetActive(not flag)
	end
end

function PhaseSaoDangCell:OnClickMax()
	if self.is_max_first then
		if self.fuben_cfg and self.fuben_info and self.fuben_info[self.data.index] then
			local cost = FuBenData.Instance:GetPhaseFbResetGold(self.data.index) or 0
			self.is_max_first = false
			self.buy_time = 0
			if self.today_buy_times > 0 then
				self.parent:AddCount(self.data.index + 1, self.enter_count, cost, false, self.today_buy_times)
				self.parent:AddVIPBuyCount(self.data.index + 1, self.today_buy_times, false)
			end

			self.today_buy_times = self.max_buy_num - self.fuben_info[self.data.index].today_buy_times
			self.node_list["TxtBuyTime"].text.text = string.format(Language.FuBen.LastBuyTimes, TEXT_COLOR.RED, self.buy_time)
			self.enter_count = self.fuben_cfg.free_times + self.max_buy_num - self.fuben_info[self.data.index].today_times or 0
			self.node_list["TxtTime"].text.text = self.enter_count
			self.parent:AddVIPBuyCount(self.data.index + 1, self.today_buy_times, true)
			self.parent:AddCount(self.data.index + 1, self.enter_count, cost, true, self.today_buy_times)
			self.has_time = 0
			self.node_list["TxtRestTime"].text.text = string.format(Language.FuBen.LastSaoDangTimes, TEXT_COLOR.RED, self.has_time)
			self.node_list["TxtBuyTime"]:SetActive(true)
			self.node_list["TxtRestTime"]:SetActive(false)
		end
	end
end