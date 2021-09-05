ImageFuLingView = ImageFuLingView or BaseClass(BaseView)

function ImageFuLingView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/imagefuling_prefab", "FuLingTalentView", {TabIndex.img_fuling_talent, TabIndex.img_fuling_suxing}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.full_screen = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	self.def_index = TabIndex.img_fuling_content
	self.play_audio = true
	self.temp_talent_type_tab = nil
end

function ImageFuLingView:__delete()
	self.temp_talent_type_tab = nil
end

function ImageFuLingView:ReleaseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.img_fuling_talent_view ~= nil then
		self.img_fuling_talent_view:DeleteMe()
		self.img_fuling_talent_view = nil
	end 

	-- 清理变量和对象
	self.red_point_list = nil

	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function ImageFuLingView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function ImageFuLingView:LoadCallBack()
	 local tab_cfg = {
		{name = Language.ImageFuLing.TianFuName, bundle = "uis/images_atlas", asset = "icon_tab_talent", func = "img_fuling_talent", tab_index = TabIndex.img_fuling_talent, remind_id = RemindName.ImgTianFu,},
		{name = Language.ImageFuLing.SuXingName, bundle = "uis/images_atlas", asset = "icon_tab_suxing", func = "img_fuling_talent", tab_index = TabIndex.img_fuling_suxing, remind_id = RemindName.ImgSuXing,},
	}
	self.def_index = TabIndex.img_fuling_content
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	-- self.tabbar:InitSubTab(self.node_list["TopTabContent"], sub_tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TxtTitle"].text.text = Language.Title.FuLing
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))
	self.node_list["TaiZi"]:SetActive(false)
	self.node_list["UnderBg"]:SetActive(false)
	self:SetBg()
end

function ImageFuLingView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if index_nodes then
		if index == TabIndex.img_fuling_talent or index == TabIndex.img_fuling_suxing then
			self.img_fuling_talent_view = ImageFuLingTalentView.New(index_nodes["FuLingTalentView"])
			self.img_fuling_talent_view:OpenCallBack()
			self.img_fuling_talent_view:UIsMove()
		end
	end
	self:SetBg()
	if index == TabIndex.img_fuling_talent then
		self.img_fuling_talent_view:UIsMove()
		self.img_fuling_talent_view:OnOpenTalent()
		self.img_fuling_talent_view:SetCurSelectIndex(self.temp_talent_type_tab, true)
		self.temp_talent_type_tab = nil
	elseif index == TabIndex.img_fuling_suxing then
		self.img_fuling_talent_view:OnOpenSuXing()
		self.img_fuling_talent_view:UISuxingMove()
	end
end

function ImageFuLingView:SetBg()
	local call_back = function ()
		self.node_list["UnderBg"]:SetActive(true)
	end
	self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/inlaycontent_bg2", "InlayContent_BG2.jpg", call_back)
end

function ImageFuLingView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ImageFuLingView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(count)
	end
	if attr_name == "bind_gold" then
		local count = vo.bind_gold
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(count)
	end
	-- RemindManager.Instance:Fire(RemindName.ImgTianFu)
	-- RemindManager.Instance:Fire(RemindName.ImgSuXing)
end

function ImageFuLingView:OpenCallBack()
	-- 监听系统事件
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
		-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
end

function ImageFuLingView:CloseCallBack()
	self.temp_talent_type_tab = nil
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function ImageFuLingView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_list) do
		if k == "talent_type_tab" then
			if self.img_fuling_talent_view then
				self.img_fuling_talent_view:SetCurSelectIndex(v[1], true)
				self.img_fuling_talent_view:Flush()
			else
				self.temp_talent_type_tab = v[1]
			end
		end
	end
	if self.img_fuling_talent_view then
		self.img_fuling_talent_view:OnFlushAll()
		self.img_fuling_talent_view:Flush("anim")
	end
	self.tabbar:FlushTabbar()
end

function ImageFuLingView:GetChouJiangData()
	if self.img_fuling_talent_view then
		self.img_fuling_talent_view:SetDataFlag(false)
	end
end

