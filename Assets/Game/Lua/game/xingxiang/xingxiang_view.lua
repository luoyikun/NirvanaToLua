XingXiangView = XingXiangView or BaseClass(BaseView)

function XingXiangView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/xingxiangview_prefab", "XingXiangView", {TabIndex.xing_xiang}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.play_audio = true
	self.full_screen = true
	self.discount_close_time = 0
end

function XingXiangView:LoadCallBack()
	local tab_cfg = {
		{name = Language.XingXiang.TabbarName.xing_xiang, bundle = "uis/images_atlas", asset = "xing_xiang", func ="xing_xiang", tab_index = TabIndex.xing_xiang, remind_id = RemindName.XingXiangView},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["TxtTitle"].text.text = Language.XingXiang.TabbarName.xing_xiang
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))

	self.node_list["UnderBg"]:SetActive(true)
	self.node_list["TaiZi"]:SetActive(false)
end

function XingXiangView:ReleaseCallBack()
	if self.xing_xiang_view then
		self.xing_xiang_view:DeleteMe()
		self.xing_xiang_view = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

end

function XingXiangView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
end

function XingXiangView:CloseCallBack()
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	self.data_listen = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.xing_xiang_view ~= nil then
		self.xing_xiang_view:CloseCallBack()
	end

end

function XingXiangView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

function XingXiangView:OpenUplevel()
	if nil ~= self.xing_xiang_view then
		self.xing_xiang_view:FlushAll()
	end
end


function XingXiangView:ShowIndexCallBack(index ,index_nodes)
	self.tabbar:ChangeToIndex(index)
	self.node_list["UnderBg"]:SetActive(index ~= TabIndex.shengxiao_piece)
	if index_nodes then
		if index == TabIndex.xing_xiang then
			self.xing_xiang_view = XingXiangInfoView.New(index_nodes["XingXiangView"])
			self.xing_xiang_view:FlushAll()
		end
	end

	if index == TabIndex.xing_xiang then
		self.xing_xiang_view:UIsMove()
		self.xing_xiang_view:FlushAll()
		self.xing_xiang_view:Flush()
	end
end

function XingXiangView:OnClickClose()
	self:Close()
end

function XingXiangView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function XingXiangView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()

	if self.xing_xiang_view and cur_index == TabIndex.xing_xiang then
		self.xing_xiang_view:Flush()
	end
end