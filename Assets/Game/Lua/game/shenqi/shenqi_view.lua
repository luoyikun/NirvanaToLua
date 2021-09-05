require("game/shenqi/shenqi_jianling_view")
require("game/shenqi/shenqi_fenjie_view")
require("game/shenqi/shenqi_baojia_view")

ShenqiView = ShenqiView or BaseClass(BaseView)

--这个prefab通用链接 (asset)
local url = "uis/views/shenqi_prefab"

-- 神器
function ShenqiView:__init()
	self.ui_config = {
		--{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/shenqi_prefab", "EquipContent", {TabIndex.shenbing}},
		{"uis/views/shenqi_prefab", "ClothContent", {TabIndex.baojia}},
		{"uis/views/shenqi_prefab", "RecykleContent", {TabIndex.fenjie}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},

	}

	self.full_screen = true								-- 是否是全屏界面(ViewManager里面调用)
	self.play_audio = true								-- 播放音效
	-- self:SetMaskBg()
	self.def_index = TabIndex.shenbing 					-- 神兵-升级
end

function ShenqiView:__delete()
	self.full_screen = nil
	self.play_audio = nil
	-- self.remind_change = nil
end

function ShenqiView:ReleaseCallBack()
	-- if RemindManager.Instance then
	-- 	RemindManager.Instance:UnBind(self.remind_change)
	-- end

	if self.jianling_view then
		self.jianling_view:DeleteMe()
		self.jianling_view = nil
	end

	if self.baojia_view then
		self.baojia_view:DeleteMe()
		self.baojia_view = nil
	end
	if self.fenjie_view then
		self.fenjie_view:DeleteMe()
		self.fenjie_view = nil
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	-- if self.toggle_list then
	-- 	for k,v in pairs(self.toggle_list) do
	-- 		if v then
	-- 			v = nil
	-- 		end
	-- 	end
	-- 	self.toggle_list = {}
	-- end

	-- if self.red_point_list then
	-- 	for k,v in pairs (self.red_point_list) do
	-- 		if v then
	-- 			v = nil
	-- 		end
	-- 	end
	-- 	self.red_point_list = nil
	-- end

	self.bind_gold = nil
	self.gold = nil

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end	

end

function ShenqiView:LoadCallBack()

	-- --监听UI事件
	-- self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	-- self:ListenEvent("ClickShenQi", BindTool.Bind(self.ClickShenQi, self))
	-- self:ListenEvent("ClickBaoJia", BindTool.Bind(self.ClickBaoJia, self))
	-- self:ListenEvent("ClickFenJie", BindTool.Bind(self.ClickFenJie, self))
	-- self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))

	-- -- 左边的标签页
	-- self.toggle_list = {}
	-- self.toggle_list[TabIndex.shenbing] = self:FindObj("ToggleEquip")				-- 神兵
	-- self.toggle_list[TabIndex.baojia] = self:FindObj("ToggleCloth")					-- 宝甲
	-- self.toggle_list[TabIndex.fenjie] = self:FindObj("ToggleRecyle")				-- 分解

	-- --variable
	-- self.bind_gold = self:FindVariable("BindGold")
	-- self.gold = self:FindVariable("Gold")
	-- -- 面板列表

	-- self.red_point_list = {
	-- 	[RemindName.ShenQiJiangLing] = self:FindVariable("JianLingRedPoint"),
	-- 	[RemindName.ShenQiBaoJia] = self:FindVariable("BaoJiaPoint"),
	-- }
	local tab_cfg = {
		{name = Language.ShenQi.ShenQiViewName[1], bundle = "uis/images_atlas", asset = "shen_qi_shenbing", func = "shenbing", 	tab_index = TabIndex.shenbing, 	remind_id = RemindName.ShenQiJiangLing },
		{name = Language.ShenQi.ShenQiViewName[2], bundle = "uis/images_atlas", asset = "shen_qi_baojia", func = "baojia", 	tab_index = TabIndex.baojia,remind_id = RemindName.ShenQiBaoJia },
		{name = Language.ShenQi.ShenQiViewName[3], bundle = "uis/images_atlas", asset = "shen_qi_fenjie", func = "fenjie",	tab_index = TabIndex.fenjie, 		remind_id = RemindName.ShenQiFenJie},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.view_list = {}

	self.node_list["TaiZi"]:SetActive(false)
	self.node_list["TxtTitle"].text.text = Language.ShenQi.ShenQiTitle
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	-- self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/shenqi_bg", "shenqi_bg.jpg")
	-- self.node_list["UnderBg"]:SetActive(true)
	self.node_list["TaiZi"]:SetActive(false)

	-- for k, _ in pairs(self.red_point_list) do
	-- 	RemindManager.Instance:Bind(self.remind_change, k)
	-- end

	-- RemindManager.Instance:Fire(RemindName.ShenQi)
end

function ShenqiView:OnClickClose()
	self:Close()
end

function ShenqiView:ShowIndexCallBack(index,index_nodes)
	-- self.show_index = index
	-- self.toggle_list[index].toggle.isOn = true
	-- self:LoadPrefabAsyn(index)
	self.tabbar:ChangeToIndex(index)
	if index_nodes then
		if index == TabIndex.shenbing then
			self.jianling_view = JianLingView.New(index_nodes["EquipContent"])
			self.jianling_view:OnFlush()
		elseif index == TabIndex.baojia then
			self.baojia_view = BaoJiaView.New(index_nodes["ClothContent"])
			self.baojia_view:OnFlush()
		elseif index == TabIndex.fenjie then
			self.fenjie_view = FenjieView.New(index_nodes["RecykleContent"])
			self.fenjie_view:OnFlush()
		end
	end
	if index == TabIndex.shenbing then
		self.jianling_view:OnFlush()
		self.jianling_view:UIsMove()
	elseif index == TabIndex.baojia then
		self.baojia_view:OnFlush()
		self.baojia_view:UIsMove()
	elseif index == TabIndex.fenjie then
	
		self.fenjie_view:OnFlush()
		self.fenjie_view:UIsMove()
	end
	if index ~= TabIndex.fenjie then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/shenqi_bg", "shenqi_bg.jpg")
		self.node_list["UnderBg"]:SetActive(true)
	elseif index == TabIndex.fenjie then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/shenqi_fenjie", "shenqi_fenjie.jpg")
		self.node_list["UnderBg"]:SetActive(true)
	end
	-- local show_tab_cfg_index = 1
	-- for k,v in pairs(self.tabbar.tab_cfg) do
	-- 	if v.tab_index == index then
	-- 		show_tab_cfg_index = k
	-- 		self.show_index = index
	-- 		break
	-- 	end
	-- end
	-- for k, toggle_button in pairs(self.tabbar.tab_button_list) do
	-- 	local root_node = toggle_button.root_node
	-- 	if k == show_tab_cfg_index then
	-- 		root_node.toggle.interactable = true
	-- 	else
	-- 		root_node.toggle.interactable = false
	-- 	end
	-- end

	-- self.tabbar:ChangeToIndex(index)
	-- if nil ~= index_nodes then
	-- 	if index == TabIndex.shenbing then
	-- 		self.view_list[index] = self.view_list[index] or JianLingView.New(index_nodes["EquipContent"])
	-- 	elseif index == TabIndex.baojia then
	-- 		self.view_list[index] = self.view_list[index] or BaoJiaView.New(index_nodes["ClothContent"])
	-- 	elseif index == TabIndex.fenjie then
	-- 		self.view_list[index] = self.view_list[index] or FenjieView.New(index_nodes["RecykleContent"])
	-- 	end
	-- end
	-- -- self.view_list[index]:FlushView()
	-- -- self.view_list[index]:OpenCallBack()
	-- self.view_list[index]:Flush()
	-- self.view_list[index]:OpenCallBack()
end

function ShenqiView:ReleaseAutoUpLevel()
	if self.jianling_view then
		self.jianling_view:SetUpLevelState(false)
	end

	if self.baojia_view then
		self.baojia_view:SetUpLevelState(false)
	end
end
function ShenqiView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

function ShenqiView:OpenCallBack()
	--监听系统事件

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
	RemindManager.Instance:Fire(RemindName.ShenQiBaoJia) 

	 -- 请求所有信息
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_INFO)
end

function ShenqiView:CloseCallBack()
	
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function ShenqiView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	-- local tab = self:GetTabByIndex(cur_index)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "all" then
			if cur_index == TabIndex.shenbing and self.jianling_view then
				self.jianling_view:Flush()
			elseif cur_index == TabIndex.baojia and self.baojia_view then
				self.baojia_view:Flush()
			elseif cur_index == TabIndex.fenjie and self.fenjie_view then
				self.fenjie_view:Flush()
			end
		end
	end

end

function ShenqiView:ToggleChange(index)
	if self.show_index == index then
		return
	end

	self:ShowIndex(index)
end


function ShenqiView:CloseView()
	self:Close()
end

function ShenqiView:ClickShenQi()
	if nil ~= self.jianling_view then
		self.jianling_view:SetLevel(0)
		self.jianling_view:ClearEffect()
	end
	self:ToggleChange(TabIndex.shenbing)
	ShenqiData.Instance:ChangeOpenJiangLing()
	RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
end

function ShenqiView:ClickBaoJia()
	if nil ~= self.baojia_view then
		self.baojia_view:SetLevel(0)
		self.baojia_view:ClearEffect()
	end
	self:ToggleChange(TabIndex.baojia)
	ShenqiData.Instance:ChangeOpenBaoJia()
	RemindManager.Instance:Fire(RemindName.ShenQiBaoJia)
end

function ShenqiView:ClickFenJie()
	self:ToggleChange(TabIndex.fenjie)
end

function ShenqiView:FlushCellUpLevelState()
	if self.jianling_view then
		self.jianling_view:FlushItemUpState()
	end

	if self.baojia_view then
		self.baojia_view:FlushItemUpState()
	end
end

function ShenqiView:ShenbingUpgradeOptResult(result)
	self.jianling_view:FlushUpgradeOptResult(result)
end

function ShenqiView:BaojiaUpgradeOptResult(result)
	self.baojia_view:FlushUpgradeOptResult(result)
end

function ShenqiView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end