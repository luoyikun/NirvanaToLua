ShenGeDecomposeView = ShenGeDecomposeView or BaseClass(BaseView)

local SHOW_TIP_QUALITY = 3

local TOTAL_NUM = 6

function ShenGeDecomposeView:__init()
	self.ui_config = {{"uis/views/shengeview_prefab", "ShenGeDecomposeView"}}
	self.play_audio = true
	self.fight_info_view = true
	self.decompose_data_list = {}
	self.fragmen_num_list = {}
	self.select_num_list = {}
	self.is_modal = true
end

function ShenGeDecomposeView:ReleaseCallBack()
	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end
end

function ShenGeDecomposeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	
	self.node_list["BtnDecompose"].button:AddClickListener(BindTool.Bind(self.OnClickDecompose, self))

	for i = 1, TOTAL_NUM do
		self.node_list["Toggle" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.OnSelect, self, i))
		self.node_list["BtnResolve" .. i].button:AddClickListener(BindTool.Bind(self.OnClickDetails, self, i))
	end

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function ShenGeDecomposeView:OpenCallBack()
	local value = 0
	for k = 1, TOTAL_NUM do
		value = #ShenGeData.Instance:GetShenGeSameQualityItemData(k - 1)
		self.node_list["TxtResolve" .. k].text.text = string.format(Language.ShenGe.ShenGeXingHui, k, value)
	end
end

function ShenGeDecomposeView:CloseCallBack()
	ShenGeData.Instance:ClearOneKeyDecomposeData()
	self:ResetData()
end

function ShenGeDecomposeView:OnClickDetails(index)
	local call_back = function(index, is_select)
		self:SetFragments(index + 1, true)
	end
	ShenGeCtrl.Instance:ShowDecomposeDetail(index - 1, call_back, nil ~= self.decompose_data_list[index])
end

function ShenGeDecomposeView:OnSelect(index)
	self:SetSelectData(index)
end

function ShenGeDecomposeView:ResetData()
	self.node_list["TxtFragments"].text.text = string.format(Language.ShenGe.ShenGeFenJie, 0)
	self.fragmen_num_list = {}
	self.decompose_data_list = {}

	for i = 1, TOTAL_NUM do
		self.node_list["Toggle" .. i].toggle.isOn = false
	end

	for i = 1, TOTAL_NUM do
		self.node_list["TxtResolve" .. i].text.text = 0
	end
end

function ShenGeDecomposeView:SetSelectData(index)
	if nil ~= self.decompose_data_list[index] and self.node_list["Toggle" .. index].toggle.isOn == false then
		for k, v in pairs(self.decompose_data_list[index]) do
			v.is_select = false
		end
		self.decompose_data_list[index] = nil
		self.fragmen_num_list[index] = 0
	else
		self.decompose_data_list[index] = ShenGeData.Instance:GetShenGeSameQualityItemData(index - 1)
		local cfg = {}
		local fragment_num = 0
		local return_score = 0
		for k, v in pairs(self.decompose_data_list[index]) do
			v.is_select = true
			cfg = ShenGeData.Instance:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
			return_score = cfg and cfg.return_score or 0
			fragment_num = fragment_num + return_score
		end
		self.fragmen_num_list[index] = fragment_num
	end
	self:SetFragments(index, false)
end

function ShenGeDecomposeView:SetFragments(index, is_call_back)
	if is_call_back then
		local cfg = {}
		local fragment_num = 0
		local return_score = 0
		for k, v in pairs(ShenGeData.Instance:GetShenGeSameQualityItemData(index - 1)) do
			if v.is_select then
				cfg = ShenGeData.Instance:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
				return_score = cfg and cfg.return_score or 0
				fragment_num = fragment_num + return_score
			end
		end

		self.fragmen_num_list[index] = fragment_num
		self.decompose_data_list[index] = ShenGeData.Instance:GetShenGeSameQualityItemData(index - 1)
	end

	local num = 0
	for k, v in pairs(self.fragmen_num_list) do
		num = num + v
	end
	self.node_list["TxtFragments"].text.text = string.format(Language.ShenGe.ShenGeFenJie, num)
end

function ShenGeDecomposeView:OnClickDecompose()
	local send_index_list = {}
	local is_show_tip = false
	for k, v in pairs(self.decompose_data_list) do
		if #v > 0 and k >= SHOW_TIP_QUALITY and not is_show_tip then
			is_show_tip = true
		end
		for _, v2 in pairs(v) do
			if v2.is_select then
				table.insert(send_index_list, v2.shen_ge_data.index)
			end
		end
	end

	if #send_index_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenGe.NoChose)
		return
	end

	local ok_func = function()
		self.decompose_data_list = {}
		self.fragmen_num_list = {}
		self.node_list["TxtFragments"].text.text = string.format(Language.ShenGe.ShenGeFenJie, 0)
		for i = 1, TOTAL_NUM do
			self.node_list["Toggle" .. i].toggle.isOn = false
		end
		ShenGeData.Instance:ClearOneKeyDecomposeData()

		self.node_list["TxtFragments"].text.text = string.format(Language.ShenGe.ShenGeFenJie, 0)
		self.decompose_data_list = {}

		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE, 0, 0, 0, #send_index_list, send_index_list)
	end

	if is_show_tip then
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenGe.DecomposeTip , nil, nil, true, false, "decompose_shen_ge", false, "", "", false, nil, true, Language.Common.Cancel, nil, false)
		return
	end

	ok_func()

end

function ShenGeDecomposeView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if not self:IsOpen() then return end

	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO then
		for i = 1, TOTAL_NUM do
			local value = #ShenGeData.Instance:GetShenGeSameQualityItemData(i - 1)
			self.node_list["TxtResolve" .. i].text.text = string.format(Language.ShenGe.ShenGeXingHui, i, value)
		end
	end
end

function ShenGeDecomposeView:OnClickClose()
	self:Close()
end