LoginjiangLiView =  LoginjiangLiView or BaseClass(BaseRender)

function LoginjiangLiView:__init()
	self.contain_cell_list = {}

end

function LoginjiangLiView:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	
	self.contain_cell_list = nil
end

function LoginjiangLiView:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
		end)

	self.node_list["TxtTotalDay"].text.text = HefuActivityData.Instance:GetLoginDay()--string.format(Language.HefuActivity.LoginDay,HefuActivityData.Instance:GetLoginDay())
end

function LoginjiangLiView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function LoginjiangLiView:OnFlush()
	if self.node_list["ListView"] then
		self.node_list["ListView"].scroller:ReloadData(0)
	end
	local str = HefuActivityData.Instance:GetLoginDay()--string.format(Language.HefuActivity.LoginDay,HefuActivityData.Instance:GetLoginDay())
	self.node_list["TxtTotalDay"].text.text = str
end

function LoginjiangLiView:SetTime(rest_time)
	-- local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	-- local temp = {}
	-- for k,v in pairs(time_tab) do
	-- 	if k ~= "day" then
	-- 		if v < 10 then
	-- 			v = tostring('0'..v)
	-- 		end
	-- 	end
	-- 	temp[k] = v
	-- end
	local str = TimeUtil.FormatSecond(rest_time, 13)--string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)
	self.node_list["Txt"].text.text = str
end

function LoginjiangLiView:GetNumberOfCells()
	return 3
end

function LoginjiangLiView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = LoginjiangLiViewCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	local data = HefuActivityData.Instance:GetLoginGiftCfgByDay(HefuActivityData.Instance:GetLoginDay())
	local index = self:GetNewIndexByIndex(cell_index) or cell_index

	contain_cell:SetIndex(cell_index, index)
	contain_cell:SetData(data)
	contain_cell:Flush()
end

function LoginjiangLiView:GetNewIndexByIndex(index)
	local data = HefuActivityData.Instance:GetLoginGiftCfgByDay(HefuActivityData.Instance:GetLoginDay())
	if data == nil or next(data) == nil then return end
	
	local data_list = {}
	local new_index = 1

	table.sort(data.sort_key, function (a, b)
		return a < b
	end)

	for k,v in pairs(data.sort_key) do
		if v > 3 then
			v = v - 3
		elseif v > 6 then -- vip等级的特殊处理
			v = v - 5
		end
		data_list[k] = v
	end

	-- local sort_key = data.sort_key[index].seq > 3 and sort_key - 3 or sort_key
	return data_list[index]
end

----------------------------LoginjiangLiViewCell---------------------------------
LoginjiangLiViewCell = LoginjiangLiViewCell or BaseClass(BaseCell)

function LoginjiangLiViewCell:__init()
	self.item_cell_obj_list = {}
	self.item_cell_list = {}

	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))

	for i = 1, 4 do
		self.item_cell_obj_list[i] = self.node_list["item_"..i]
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end

end

function LoginjiangLiViewCell:__delete()

	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function LoginjiangLiViewCell:SetData(data)
	self.data = data
end

function LoginjiangLiViewCell:SetIndex(index, new_index)
	self.index = index
	self.new_index = new_index
end

function LoginjiangLiViewCell:OnFlush()
	if self.data == nil then return end
	if self.new_index ~= 3 then
		self.node_list["TxtTopTitle0"].gameObject:SetActive(false)
		self.node_list["TxtTopTitle1"].text.text = Language.HefuActivity.LoginReward1[self.new_index]
	else
		self.node_list["TxtTopTitle0"].gameObject:SetActive(true)
		self.node_list["TxtTopTitle1"].text.text = string.format(Language.HefuActivity.LoginReward1[self.new_index],self.data.need_accumulate_days)
	end
	local item_list = ItemData.Instance:GetGiftItemList(self.data.data_list[self.new_index].item_id)
	if #item_list == 0 then
		item_list[1] = self.data.data_list[self.new_index]
	end
	
	for i = 1, 4 do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end
	

	if self.new_index == 1 then 
		--第一个格子的状态

		self.node_list["Effect"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["Button"], self.data.flag[self.new_index])
		--置灰按钮特殊处理 已领取
		if self.data.flag[self.new_index] then
			self.node_list["TxtButton01"].text.text = Language.HefuActivity.LingQu
			self.node_list["Button"].gameObject:SetActive(true)
			self.node_list["YiLingQu"].gameObject:SetActive(false)
		else
			self.node_list["Button"].gameObject:SetActive(false)
			self.node_list["YiLingQu"].gameObject:SetActive(true)
			self.node_list["Effect"]:SetActive(false)
			-- self.node_list["TxtButton01"].text.text = Language.HefuActivity.YiLingQu
		end
	elseif self.new_index == 2 then
		--第二个格子的状态
		if self.data.flag["is_vip"] then

			self.node_list["Effect"]:SetActive(true)
			UI:SetButtonEnabled(self.node_list["Button"], self.data.flag[self.new_index])
			if self.data.flag[self.new_index] then
				self.node_list["TxtButton01"].text.text = Language.HefuActivity.LingQu
				self.node_list["Button"].gameObject:SetActive(true)
				self.node_list["YiLingQu"].gameObject:SetActive(false)
			else
				self.node_list["Button"].gameObject:SetActive(false)
				self.node_list["YiLingQu"].gameObject:SetActive(true)
				self.node_list["Effect"]:SetActive(false)
			end
		else
			self.node_list["TxtButton01"].text.text = Language.Common.WEIDACHENG
			self.node_list["Effect"]:SetActive(false)
			UI:SetButtonEnabled(self.node_list["Button"], self.data.flag["is_vip"])
		end
	elseif self.new_index == 3 then
		--第三个格子的状态
		if self.data.flag["is_need_accumulate_days"] then
			if self.data.flag[self.new_index] then
				self.node_list["Effect"]:SetActive(true)
				self.node_list["Button"].gameObject:SetActive(true)
				UI:SetButtonEnabled(self.node_list["Button"], self.data.flag[self.new_index])
				self.node_list["TxtButton01"].text.text = Language.Common.LingQu
				self.node_list["YiLingQu"].gameObject:SetActive(false)
			else
				self.node_list["Effect"]:SetActive(false)
				self.node_list["Button"].gameObject:SetActive(false)
				UI:SetButtonEnabled(self.node_list["Button"], self.data.flag[self.new_index])
				-- self.node_list["TxtButton01"].text.text = Language.Common.LingQu
				self.node_list["YiLingQu"].gameObject:SetActive(true)
			end
		else
			self.node_list["Button"].gameObject:SetActive(true)
			UI:SetButtonEnabled(self.node_list["Button"], self.data.flag["is_need_accumulate_days"])
			self.node_list["Effect"]:SetActive(false)
			self.node_list["YiLingQu"].gameObject:SetActive(false)
			-- print_error(self.data, self.data.need_login_days, self.data.need_accumulate_days)
			self.node_list["TxtButton01"].text.text = Language.Common.WEIDACHENG
			-- if self.data.need_login_days < self.data.need_accumulate_days then
			-- 	self.node_list["TxtButton01"].text.text = Language.Common.WEIDACHENG
			-- else
			-- 	self.node_list["Button"].gameObject:SetActive(false)
			-- end
		end
	end

end

function LoginjiangLiViewCell:OnClickGet()
	if self.new_index == 1 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, CSA_LOGIN_GIFT_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_COMMON_REWARD, self.data.seq)
	elseif self.new_index == 2 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, CSA_LOGIN_GIFT_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_VIP_REWARD, self.data.seq)
	elseif self.new_index == 3 then
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift, CSA_LOGIN_GIFT_OPERA.CSA_LOGIN_GIFT_OPERA_FETCH_ACCUMULATE_REWARD, self.data.seq)
	end
end