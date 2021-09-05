TipsSpiritHomeSendView = TipsSpiritHomeSendView or BaseClass(BaseView)

function TipsSpiritHomeSendView:__init()
	self.ui_config = {{"uis/views/tips/spirithometip_prefab", "SpiritHomeChooseView"}}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false

	self.select_index = nil
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsSpiritHomeSendView:__delete()
end

function TipsSpiritHomeSendView:ReleaseCallBack()
	self.select_index = nil

	for k,v in pairs(self.cell_list) do
		if v ~= nil then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	self.list_view = nil
end

function TipsSpiritHomeSendView:LoadCallBack()
	self.list_view = self.node_list["ListView"]
	if self.list_view ~= nil then
		local list_delegate = self.list_view.list_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	end

	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function TipsSpiritHomeSendView:SetData(put_index)
	self.put_index = put_index
	self:Open()
end

function TipsSpiritHomeSendView:OpenCallBack()
	if self.list_view ~= nil then
		self.list_view.scroller:ReloadData(0)
	end
end

function TipsSpiritHomeSendView:CloseCallBack()
end

function TipsSpiritHomeSendView:OnClickClose()
	self:Close()
end

function TipsSpiritHomeSendView:GetNumberOfCells()
	local num = #SpiritData.Instance:GetSendSpiritInfo()
	return num
end

function TipsSpiritHomeSendView:RefreshCell(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = SpiritHomeSendRender.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	local data_list = SpiritData.Instance:GetSendSpiritInfo(self.put_index)

	group_cell:SetIndex(data_index)
	group_cell:SetData(data_list[data_index + 1])
end

function TipsSpiritHomeSendView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function TipsSpiritHomeSendView:GetSelectIndex()
	return self.select_index
end

function TipsSpiritHomeSendView:FlushList()
	if self.list_view ~= nil then
		if self.select_index == 1 then
			self.list_view.scroller:ReloadData(0)
		else
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function TipsSpiritHomeSendView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "flush_count" == k then
			for k,v in pairs(self.cell_list) do
				if v ~= nil then
					if SpiritData.Instance:GetIsMyHome() then
						v:ShowCountDown()
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------
SpiritHomeSendRender = SpiritHomeSendRender or BaseClass(BaseRender)

function SpiritHomeSendRender:__init()
	self.is_select = false
	self.total_time = 0

	self.node_list["BtnClickChoose"].button:AddClickListener(BindTool.Bind(self.OnClickChoose, self))
end

function SpiritHomeSendRender:__delete()
	self.is_select = false
	
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.count_timer ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_timer)
		self.count_timer = nil
	end
	self.total_time = 0
end

function SpiritHomeSendRender:OnClickItem()
end

function SpiritHomeSendRender:OnClickChoose()
	if self.data == nil or next(self.data) == nil or self.index == nil then
		return
	end

	local is_my_home = SpiritData.Instance:GetIsMyHome()
	if is_my_home then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local opera_type =  JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_PUT_HOME
		
		if self.data.send_state == JING_LING_HOME_SEND_STATE.TAKE_BACK then
			opera_type = JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_OUT
			SpiritCtrl.Instance:SendJingLingHomeOperReq(opera_type, main_role_vo.role_id,
			 self.data.put_index - 1)
		else
			SpiritCtrl.Instance:SendJingLingHomeOperReq(opera_type, main_role_vo.role_id,
			 self.data.index, self.data.put_index - 1)
		end
	else
		if self.data.read_index ~= nil then
			SpiritData.Instance:SetEnterOtherSpirit(self.data.read_index)
			SpiritCtrl.Instance:ChangeSpiritHomeFightChoose()
		end
	end

	TipsCtrl.Instance:CloseSpiritHomeSendView()
end

function SpiritHomeSendRender:SetIndex(index)
	self.index = index
end

function SpiritHomeSendRender:GetIndex()
	return self.index
end

function SpiritHomeSendRender:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritHomeSendRender:FlushAll(data)
	if self.node_list["TxtSpiritCap"] ~= nil then
		self.node_list["TxtSpiritCap"].text.text = data.cap or 0
	end

	if self.node_list["TxtSpiritName"] ~= nil then
		self.node_list["TxtSpiritName"].text.text = data.spirit_name or ""
	end

	local is_my_home = SpiritData.Instance:GetIsMyHome()
	if self.node_list["TxtBtnStr"] ~= nil then
		local str = ""
		local language_str = Language.JingLing.SpiritHomeSendBtnStr
		if is_my_home then
			str = language_str[data.send_state]
		else
			if not self.data.is_enter then
				str = language_str[1]
			end
		end
		self.node_list["TxtBtnStr"].text.text = str
	end

	if self.node_list["ImgIsSend"] ~= nil then
		self.node_list["ImgIsSend"]:SetActive(data.send_state ~= JING_LING_HOME_SEND_STATE.SEND and is_my_home)
	end

	local timer_state = data.send_state == JING_LING_HOME_SEND_STATE.REPLACE
	if self.node_list["TxtTimeStr"] ~= nil then
		local showtime = timer_state and is_my_home
		local isshowbtn = not self.data.is_enter or is_my_home
		self.node_list["TxtTimeStr"]:SetActive(showtime)
		self.node_list["BtnClickChoose"]:SetActive((not showtime) and isshowbtn)
	end

	if is_my_home then
		if timer_state then
			self:ShowCountDown()
		end
	else
		self:CompleteBottom()
	end
end

function SpiritHomeSendRender:ShowCountDown()
	if self.count_timer ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_timer)
		self.count_timer = nil
	end

	if self.data == nil or self.data.send_state == nil then
		return
	end

	if self.data.send_state ~= JING_LING_HOME_SEND_STATE.REPLACE then
		return
	end

	local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(self.data.timer_index)
	if cfg == nil or next(cfg) == nil then
		return
	end

	local limlit = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit")
	if limlit == nil then
		return
	end
	if cfg.reward_times < limlit then
		local interval = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_interval")
		local total_time = cfg.reward_beging_time + interval - TimeCtrl.Instance:GetServerTime()
		self.total_time = total_time
		self.count_timer = CountDown.Instance:AddCountDown(interval, 0.1, BindTool.Bind(self.UpdateBottom, self, self.data.index + 1))	
	else
			self.node_list["TxtTimeStr"].text.text = Language.JingLing.SpiritHomeRewardLimlit
	end
end


function SpiritHomeSendRender:UpdateBottom(index, elapse_time, total_time)
	if self.node_list["TxtTimeStr"] ~= nil then
		local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(index)
		if cfg == nil or next(cfg) == nil then
			return
		end
		local time_value = TimeCtrl.Instance:GetServerTime() - cfg.last_get_time
		local time_t = TimeUtil.Format2TableDHMS(math.floor(time_value))
		self.node_list["TxtTimeStr"].text.text = string.format(Language.JingLing.NextRewardStr, time_t.hour, time_t.min, time_t.s)
	end

	if elapse_time - total_time >= 0 then
		self:CompleteBottom()
	end
end

function SpiritHomeSendRender:CompleteBottom()
	if self.count_timer ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_timer)
		self.count_timer = nil
	end
end

function SpiritHomeSendRender:ShowModel(is_show, res_id)
	if is_show and self.model == nil and self.node_list["Display"] ~= nil then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.node_list["Display"].ui3d_display)
	end

	if self.model ~= nil then
		if self.node_list["Display"] ~= nil then
			self.node_list["Display"]:SetActive(is_show or false)
		end

		if is_show then
			self.model:SetMainAsset(ResPath.GetSpiritModel(res_id))
		end
	end
end

function SpiritHomeSendRender:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "all" == k then
			if self.data ~= nil and next(self.data) ~= nil then
				self:FlushAll(self.data)
				self:ShowModel(true, self.data.res_id)
			end
		end
	end
end
