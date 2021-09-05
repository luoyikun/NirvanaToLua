require("game/myth/myth_pianzhan_view")
require("game/myth/myth_gongming_view")

MythView = MythView or BaseClass(BaseView)

function MythView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/myth_prefab", "PianZhangContent", {TabIndex.shenhua_pianzhang}},
		{"uis/views/myth_prefab", "GongMingContent", {TabIndex.shenhua_gongming}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"}, 
	}
	self.full_screen = true
	self.play_audio = true
	self.is_check_reduce_mem = true
	self.is_init_toggle = true

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
end

function MythView:__delete()
end

function MythView:ReleaseCallBack()
	if self.myth_pianzhang_view ~= nil then
		self.myth_pianzhang_view:DeleteMe()
		self.myth_pianzhang_view = nil
	end

	if self.myth_gongming_view ~= nil then
		self.myth_gongming_view:DeleteMe()
		self.myth_gongming_view = nil
	end
	

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function MythView:LoadCallBack()
	local tab_cfg = {
		{name = Language.ShenHua.ChapterAttr,  bundle = "uis/images_atlas", asset = "tab_icon_pianzhang", func = "mythview_myth_pianzhang", tab_index = TabIndex.shenhua_pianzhang, remind_id = RemindName.ShenHuaPianZhang},
		{name = Language.ShenHua.GongMing,  bundle = "uis/images_atlas", asset = "tab_icon_gongming", func = "mythview_myth_gongming", tab_index = TabIndex.shenhua_gongming, remind_id = RemindName.ShenHuaGongMing},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))
	self.node_list["TxtTitle"].text.text = Language.Title.ShenHua
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
end

function MythView:OpenIndexCheck(to_index)
	self:ChangeToIndex(to_index)
end

function MythView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MythView:HandleClose()
	self:Close()
end

function MythView:OpenCallBack()
	-- 监听系统事件
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
end

function MythView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
end

function MythView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function MythView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MythView:ShowIndexCallBack(index, index_nodes, is_jump)
	self.tabbar:ChangeToIndex(index, is_jump)
	if nil ~= index_nodes then
		if index == TabIndex.shenhua_pianzhang then
			self.myth_pianzhang_view = MythPianZhangView.New(index_nodes["PianZhangContent"])
		elseif index == TabIndex.shenhua_gongming then
			self.myth_gongming_view = MythGongMingView.New(index_nodes["GongMingContent"])
		end
	end
	self.node_list["UnderBg"]:SetActive(true)
	self.node_list["TaiZi"]:SetActive(false)
	if index == TabIndex.shenhua_pianzhang then
		self.myth_pianzhang_view:OpenCallBack()
		self.myth_pianzhang_view:UIsMove()
	elseif index == TabIndex.shenhua_gongming then
		self.myth_gongming_view:OpenCallBack()
		self.myth_gongming_view:UIsMove()
	end
end

function MythView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if cur_index == TabIndex.shenhua_pianzhang then
			self.myth_pianzhang_view:Flush(k, v)
		elseif cur_index == TabIndex.shenhua_gongming then
			self.myth_gongming_view:Flush(k, v)
		end
	end
end

function MythView:ItemDataChangeCallback()
	self:Flush()
end