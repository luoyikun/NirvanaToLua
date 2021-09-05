require("game/crazyhappyview/danbi_chongzhi_one")
require("game/crazyhappyview/danbi_chongzhi_two")
require("game/crazyhappyview/danbi_chongzhi_three")
require("game/crazyhappyview/crazy_happy_total_charge_one")
require("game/crazyhappyview/crazy_happy_total_charge_two")
require("game/crazyhappyview/crazy_happy_total_charge_three")
local CZY_NODE_NAME_LIST = {
	[1] = "DanBiChongZhiOne",
	[2] = "DanBiChongZhiTwo",
	[3] = "DanBiChongZhiThree",
	[4] = "TotalCharge",
	[5] = "TotalCharge",
	[6] = "TotalCharge",
}

local CRAZT_HAPPY_NAME_LIST = {
	[1] = DanBiChongZhiOne,
	[2] = DanBiChongZhiTwo,
	[3] = DanBiChongZhiThree,
	[4] = TotalChargeOne,
	[5] = TotalChargeTwo,
	[6] = TotalChargeThree,
}

CrazyHappyView = CrazyHappyView or BaseClass(BaseView)
-- 现在开服活动跟合服活动公用这个面板
function CrazyHappyView:__init()
	self.ui_config = {
		{"uis/views/crazyhappyview_prefab", "KaiFuAcitivityPanel_1"},

		{"uis/views/crazyhappyview_prefab", "NodeBackground"},
		{"uis/views/crazyhappyview_prefab", "LeftToggleGroup1"},
		{"uis/views/crazyhappyview_prefab", CZY_NODE_NAME_LIST[1], {1}},
		{"uis/views/crazyhappyview_prefab", CZY_NODE_NAME_LIST[2], {2}},
		{"uis/views/crazyhappyview_prefab", CZY_NODE_NAME_LIST[3], {3}},
		{"uis/views/crazyhappyview_prefab", CZY_NODE_NAME_LIST[4], {4}},
		{"uis/views/crazyhappyview_prefab", CZY_NODE_NAME_LIST[5], {5}},
		{"uis/views/crazyhappyview_prefab", CZY_NODE_NAME_LIST[6], {6}},

		{"uis/views/crazyhappyview_prefab", "KaiFuAcitivityPanel_2"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.cur_index = 1
	self.cell_list = {}
	self.panel_list = {}
	self.old_list = {}
	self.panel_obj_list = {}
end

function CrazyHappyView:__delete()
	
end

function CrazyHappyView:ReleaseCallBack()
	for k, v in pairs(self.panel_list) do
		v:DeleteMe()
	end
	self.panel_list = {}
	self.cur_index = 1
	self.cur_type = 0
	self.panel_obj_list = {}
end

function CrazyHappyView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.cur_type = 0
	self.last_type = 0

	local list_delegate = self.node_list["ScrollerToggleGroup"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local list = CrazyHappyData.Instance:GetOpenActivityList()
	if list and next(list) then
		self.cur_type = list[1].activity_type
	end
	self.cur_type = - 1
	self:Flush()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.CrazyHappyView, BindTool.Bind(self.GetUiCallBack, self))

end

function CrazyHappyView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end
function CrazyHappyView:GetNumberOfCells()
	self.cur_tab_list_length = #CrazyHappyData.Instance:GetOpenActivityList()
	return self.cur_tab_list_length
end

function CrazyHappyView:RefreshCell(cell, data_index)
	local list = CrazyHappyData.Instance:GetOpenActivityList()
	if not list or not next(list) then return end
	local activity_type = list[data_index + 1] and list[data_index + 1].activity_type or list[data_index + 1].sub_type or 0
	local activity_name = list[data_index + 1].name
	local data = {}
	data.activity_type = activity_type
	data.name = activity_name
	local tab_btn = self.cell_list[cell]
	if tab_btn == nil then
		tab_btn = LeftTableButton.New(cell.gameObject)
		self.cell_list[cell] = tab_btn
	end
	tab_btn:SetToggleGroup(self.node_list["ScrollerToggleGroup"].toggle_group)
	tab_btn:SetHighLight(self.cur_type == activity_type)

	tab_btn:AddClickCallback(BindTool.Bind(self.OnClickTabButton, self, activity_type, data_index + 1))

	data.is_show = false
	data.is_show_effect = false
	data.is_show_btn_eff = false
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT then				-- 每日好礼
		data.is_show = KaifuActivityData.Instance:DailyGiftRedPoint() > 0
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE 
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO 
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE then
		data.is_show = CrazyHappyData.Instance:IsTotalChargeRedPoint(activity_type)
	end

	tab_btn:SetData(data)
end

function CrazyHappyView:OnClickTabButton(activity_type, index)
	-- if self.cur_type == activity_type then
	-- 	return
	-- end
	self.last_type = self.cur_type
	self.cur_type = activity_type
	self.cur_index = index
	CrazyHappyData.Instance:SetSelect(self.cur_index)

	self:ChangeToIndex(CrazyHappyData.Instance:GetActivityTypeToIndex(self.cur_type))
	-- self:OpenPanel()
	--self:CloseChildPanel()
	self:Flush()
end

function CrazyHappyView:ShowIndexCallBack(index, index_nodes)
	self.cur_type = CrazyHappyData.Instance:GetActivityTypeByIndex(index)
	
	-- 打开界面时发送请求当前页面信息  -- 参考
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHIONE, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITWO, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBICHONGZHITHREE, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHIONE, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITWO, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LEIJICHONGZHITHREE, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	
	end

	if index_nodes then
		local prefab_name = CZY_NODE_NAME_LIST[index]
		self.panel_obj_list[index] = index_nodes[prefab_name]
		self.panel_list[index] = CRAZT_HAPPY_NAME_LIST[index].New(self.panel_obj_list[index])
	end
		
	if self.panel_list[index] and self.panel_list[index].OpenCallBack then
		self.panel_list[index]:OpenCallBack()
	end
	local list = CrazyHappyData.Instance:GetOpenActivityList()
	for k,v in pairs(list) do
		if v.activity_type == self.cur_type then
			self.cur_index = k
		end
	end
	self:Flush()
end

function CrazyHappyView:OpenCallBack()
	for i = 1,3 do
		if LEIJI_CHARGE_LIST[i] then
			local info = CrazyHappyData.Instance:GetTotalChargeInfo(LEIJI_CHARGE_LIST[i])
			if info and info.total_charge_value and info.total_charge_value > 0 then
				CrazyHappyData.Instance:SetIsFirstOpen(false)
				break
			end
		end
	end
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK, 0)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK, 0)
	self.node_list["ScrollerToggleGroup"].scroller:ReloadData(0)
	RemindManager.Instance:Fire(RemindName.CrazyHappyView)
end

function CrazyHappyView:CloseCallBack()
	self.last_type = self.cur_type
	self.cur_day = nil
	self.cur_index = 1
	self.cur_tab_list_length = 0

	for k,v in pairs(self.panel_list) do
		if v.CloseCallBack then
			v:CloseCallBack()
		end
	end
end

function CrazyHappyView:RemindChangeCallBack(remind_name, num)
	self:Flush()
end


function CrazyHappyView:OnFlush(param_t)
	local list = CrazyHappyData.Instance:GetOpenActivityList()
	if list and next(list) then
		self:FlushLeftTabListView(list, param_t)
		self:FlushRightPanel(list, param_t)
		if #self.old_list ~= #list then
			self.old_list = list
			self:OnClickTabButton(list[1].activity_type, 1)
		end
	elseif list == nil or nil == list[1] then
		self:Close()
	end
end

function CrazyHappyView:FlushRightPanel(list, param_t)
	local panel_index = self:ShowWhichPanelByType(self.cur_type) or 0
	if self.panel_list[panel_index] then
		self.panel_list[panel_index]:Flush(self.cur_type)
		if self.panel_list[panel_index].FlushView then
			self.panel_list[panel_index]:FlushView()
		end
	end
end
function CrazyHappyView:ShowWhichPanelByType(activity_type)
	if activity_type == nil then return nil end
	return CrazyHappyData.Instance:GetActivityTypeToIndex(activity_type)
end


function CrazyHappyView:FlushLeftTabListView(list, param_t)
	if list == nil or next(list) == nil then return end
	if self.node_list["ScrollerToggleGroup"].scroller.isActiveAndEnabled then
		if not list[self.cur_index] or (self.cur_type ~= list[self.cur_index].activity_type) then
			self.cur_index = 1
			self.cur_type = list[1] and list[1].activity_type or list[1].sub_type or 0
		end
		self.node_list["ScrollerToggleGroup"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end


--单笔充值1
function CrazyHappyView:FlushDanBiOneChongZhi()
	if self.panel_list[1] then
		self.panel_list[1]:Flush()
	end
end

function CrazyHappyView:FlushDanBiTwoChongZhi()
	if self.panel_list[2] then
		self.panel_list[2]:Flush()
	end
end

function CrazyHappyView:FlushDanBiThreeChongZhi()
	if self.panel_list[3] then
		self.panel_list[3]:Flush()
	end
end
--累计充值
function CrazyHappyView:FlushLeiJiOneChongZhi()
	if self.panel_list[4] then
		self.panel_list[4]:Flush()
	end
end

function CrazyHappyView:FlushLeiJiTwoChongZhi()
	if self.panel_list[5] then
		self.panel_list[5]:Flush()
	end
end

function CrazyHappyView:FlushLeiJiThreeChongZhi()
	if self.panel_list[6] then
		self.panel_list[6]:Flush()
	end
end

function CrazyHappyView:CloseChildPanel()
	if self.cur_type == self.last_type then
		return
	end

	local panel = self.combine_panel_list[self.last_type]

	if nil == panel then
		return
	end
	if panel.CloseCallBack then
		panel:CloseCallBack()
	end
end

LeftTableButton = LeftTableButton or BaseClass(BaseRender)

function LeftTableButton:__init(instance)

end

function LeftTableButton:SetData(data)
	if data == nil then return end
	self.data = data
	self.node_list["TxtLight"].text.text = data.name
	self.node_list["TxtHighLight"].text.text = data.name
	self.node_list["ImgRedPoint"]:SetActive(data.is_show)
	self.node_list["EffectInBtn"]:SetActive(data.is_show_btn_eff or false)
	self.node_list["ImgFlag"]:SetActive(data.is_show_effect or false)

end

function LeftTableButton:GetData()
	return self.data
end

function LeftTableButton:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function LeftTableButton:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function LeftTableButton:AddClickCallback(click_callback)
	self.node_list["TabButton"].toggle:AddClickListener(click_callback)
end


