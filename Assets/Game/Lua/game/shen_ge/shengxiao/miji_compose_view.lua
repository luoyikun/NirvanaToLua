MiJiComposeView = MiJiComposeView or BaseClass(BaseView)

local MAX_COMPOSE_NUM = 1

function MiJiComposeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengeview_prefab", "MiJiComposeView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function MiJiComposeView:__delete()
	-- body
end

function MiJiComposeView:ReleaseCallBack()
	for _, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	if self.item_cost then
		self.item_cost:DeleteMe()
		self.item_cost = nil
	end

	if nil ~= MiJiComposeData.Instance then
		MiJiComposeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end
end

function MiJiComposeView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(765, 426, 0)
	self.fight_info_view = true
	self.click_index = -1
	self.had_set_data_list = {list = {}, count = 0}
	self.had_set_data_count = 0
	self.item_list = {}
	self.node_list["Txt"].text.text = Language.ShengXiao.MiJiZhuanHua
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickYes, self))
	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.OnClickNo, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.item_cost = ItemCell.New()
	self.item_cost:SetInstanceParent(self.node_list["ItemDe"])
	self.item_cost:SetIsShowTips(false)
	self.item_cost:ShowHighLight(false)

	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetClearListenValue(false)
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i] = item
	end

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	MiJiComposeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function MiJiComposeView:OpenCallBack()
	self:ClearItemData()
end

function MiJiComposeView:CloseCallBack()
end

function MiJiComposeView:OnClickYes()
	if self.had_set_data_count < MAX_COMPOSE_NUM then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShengXiao.MaterialNoEnough)
		return
	end
	if(self.had_set_data_list.list[1] ~= nil) then
		ShengXiaoCtrl.Instance:SendHechengRequst(self.had_set_data_list.list[1].bag_info.index)
	end
	self:ClearItemData()
end

function MiJiComposeView:OnClickNo()
	self:ClearItemData()
end

function MiJiComposeView:OnClickClose()
	self:Close()
end

function MiJiComposeView:OnClickHelp()
	local tips_id = 179
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MiJiComposeView:OnClickItem(index)
	local call_back = function(data)
		self.item_list[index]:SetHighLight(false)
		if nil ~= data then
			if nil == self.item_list[index]:GetData().item_id then
				self.had_set_data_count = self.had_set_data_count + 1
			end
			self.item_list[index]:SetData({item_id = data.item_id, num = 1, is_bind = data.bag_info.is_bind})
			self.node_list["ImgPlus" .. index]:SetActive(false)
			self.had_set_data_list.list[index] = data

			if index == 1 then
				self.item_cost:SetData({item_id = 65534, num = ShengXiaoData.Instance:GetCostByMijiLevel(data.level)})
			end
			self.click_index = index
		end
	end
	self.had_set_data_list.count = self.had_set_data_count
	MiJiComposeCtrl.Instance:ShowSelectView(call_back, self.had_set_data_list, "from_compose")
end

function MiJiComposeView:OnDataChange(info_type, param1, param2, param3)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO then
	end
end


function MiJiComposeView:ClearItemData()
	for k, v in pairs(self.item_list) do
		v:SetData()
		self.node_list["ImgPlus" .. k]:SetActive(true)
	end
	self.had_set_data_list = {list = {}, count = 0}
	self.click_index = -1
	self.had_set_data_count = 0
	self.item_cost:SetData({item_id = 65534})
end