ShenGeOperateView = ShenGeOperateView or BaseClass(BaseView)

function ShenGeOperateView:__init()
	self.ui_config = {{"uis/views/shengeview_prefab", "ShenGeOperateView"}}
	self.play_audio = true
	self.fight_info_view = true
	self.is_from_bag = true
	self.is_modal = true
end

function ShenGeOperateView:ReleaseCallBack()
	self.item:DeleteMe()
	self.item = nil
end

function ShenGeOperateView:LoadCallBack()
	self.node_list["ImgUpGrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpgrade, self))
	self.node_list["BtnDecompose"].button:AddClickListener(BindTool.Bind(self.OnClickDecompose, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnChange"].button:AddClickListener(BindTool.Bind(self.OnClickChange, self))
	self.node_list["BtnTakeOff"].button:AddClickListener(BindTool.Bind(self.OnClickTakeOff, self))
	self.node_list["BtnTakeOn"].button:AddClickListener(BindTool.Bind(self.OnClickTakeOn, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
	self.item:SetData()
end

function ShenGeOperateView:JudgeState(ShowFromBag)
	self.node_list["BtnTakeOn"]:SetActive(ShowFromBag)
	self.node_list["BtnChange"]:SetActive(not ShowFromBag)
	self.node_list["BtnDecompose"]:SetActive(ShowFromBag)
	self.node_list["BtnTakeOff"]:SetActive(not ShowFromBag)
end

function ShenGeOperateView:OpenCallBack()
	self:SetPanelData()
end

function ShenGeOperateView:CloseCallBack()
	self.node_list["TxtName"].text.text = ""
	self.node_list["TxtAttr1"].text.text = ""
	self.node_list["TxtAttr2"].text.text = ""
	if nil ~= self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
end

function ShenGeOperateView:OnClickUpgrade()
	local close_call_back = function()
		self:Close()
	end
	ShenGeCtrl.Instance:ShowUpgradeView(self.data, self.is_from_bag, close_call_back)
end

function ShenGeOperateView:OnClickDecompose()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE, 0, 0, 0, 1, {[1] = self.data.shen_ge_data.index})
	self:Close()
end

function ShenGeOperateView:OnClickTakeOn()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local slot_state_list = ShenGeData.Instance:GetSlotStateList()
	local shen_ge_data = self.data.shen_ge_data
	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == attr_cfg then return end

	local min_index = (attr_cfg.quyu - 1) * 4
	local max_index = min_index + 3
	for i = min_index, max_index do
		local inlay_data = ShenGeData.Instance:GetInlayData(cur_page, i)
		if slot_state_list[i] and (nil == inlay_data or inlay_data.item_id <= 0) then
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SET_RUAN, self.data.shen_ge_data.index, cur_page, i)
			self:Close()
			return
		end
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.HaveNoShenGeCanUse)
	self:Close()
end

function ShenGeOperateView:OnClickTakeOff()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_UNLOAD_SHENGE, cur_page, self.data.shen_ge_data.index)
	self:Close()
end

function ShenGeOperateView:OnClickChange()
	local index = self.data.shen_ge_data.index
	local quyu = math.floor(index / 4) + 1
	local call_back = function(data)
		if nil == data then
			self:Close()
			return
		end
		local cur_page = ShenGeData.Instance:GetCurPageIndex()
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SET_RUAN, data.shen_ge_data.index, cur_page, index)
		self:Close()
	end
	ShenGeCtrl.Instance:ShowSelectView(call_back, {[1] = quyu}, "from_inlay")
end

function ShenGeOperateView:SetData(data)
	self.data = data
	if nil == self.data or nil ==self.data.item_id or self.data.item_id <= 0 then
		return
	end
	self:Open()
end

function ShenGeOperateView:SetIsFromBag(value)
	self.is_from_bag = value or false
end

function ShenGeOperateView:SetCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function ShenGeOperateView:SetPanelData()
	self:JudgeState(self.is_from_bag)
	self.item:SetData(self.data)
	if nil == self.data or nil == self.data.shen_ge_data then
		return
	end
	local shen_ge_data = self.data.shen_ge_data
	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == attr_cfg then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local level_str = attr_cfg.name
	local level_to_color = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..level_str.."</color>"
	self.node_list["TxtName"].text.text = level_to_color

	local attr_list = {}
	for i = 0, 1 do
		local attr_value = attr_cfg["add_attributes_"..i]
		local attr_type = attr_cfg["attr_type_"..i]
		local attr_key = Language.ShenGe.AttrType[attr_type]
		if attr_value > 0 then
			if attr_type == 8 or attr_type == 9 then
				self.node_list["TxtAttr" .. (i + 1)].text.text = Language.ShenGe.AttrTypeName[attr_type].."  +"..(attr_value / 100).."%"
			else
				attr_list[attr_key] = attr_value
				self.node_list["TxtAttr" .. (i + 1)].text.text = Language.ShenGe.AttrTypeName[attr_type].."  +"..attr_value
			end
		else
			self.node_list["TxtAttr" .. (i + 1)].text.text = ""
		end
	end

	local power = CommonDataManager.GetCapabilityCalculation(attr_list)
	self.node_list["TxtNumber"].text.text = power + attr_cfg.capbility
end

function ShenGeOperateView:OnClickClose()
	self:Close()
end