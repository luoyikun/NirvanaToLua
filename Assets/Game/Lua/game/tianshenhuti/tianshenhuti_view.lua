require("game/tianshenhuti/tianshenhuti_info_view")
require("game/tianshenhuti/tianshenhuti_compose_view")
require("game/tianshenhuti/tianshenhuti_conversion_view")
require("game/tianshenhuti/tianshenhuti_box_view")
-- require("game/tianshenhuti/tianshenhuti_bigboss_view")
-- require("game/tianshenhuti/tianshenhuti_boss_view")

TianshenhutiView = TianshenhutiView or BaseClass(BaseView)

function TianshenhutiView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/tianshenhutiview_prefab", "ModelDragLayer"},
		{"uis/views/tianshenhutiview_prefab", "InfoPanel", {TabIndex.tianshenhuti_info}},	-- 无双
		{"uis/views/tianshenhutiview_prefab", "TianShenCompose", {TabIndex.tianshenhuti_compose}},	-- 合成
		{"uis/views/tianshenhutiview_prefab", "ConversionPanel", {TabIndex.tianshenhuti_conversion}},	-- 转化
		{"uis/views/tianshenhutiview_prefab", "BoxPanel", {TabIndex.tianshenhuti_box}},	-- 宝箱
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.def_index = TabIndex.tianshenhuti_info
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
end

function TianshenhutiView:__delete()
	if self.open_trigger_handle then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
	end
end

function TianshenhutiView:ReleaseCallBack()

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.tianshenhuti_info_view then
		self.tianshenhuti_info_view:DeleteMe()
		self.tianshenhuti_info_view = nil
	end
	
	if self.tianshenhuti_compose_view then
		self.tianshenhuti_compose_view:DeleteMe()
		self.tianshenhuti_compose_view = nil
	end

	if self.tianshenhuti_conversion_view then
		self.tianshenhuti_conversion_view:DeleteMe()
		self.tianshenhuti_conversion_view = nil
	end

	if self.tianshenhuti_box_view then
		self.tianshenhuti_box_view:DeleteMe()
		self.tianshenhuti_box_view = nil
	end
end

function TianshenhutiView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Tianshenhuti.TabbarName[1], bundle = "uis/images_atlas", asset = "tab_icon_tian_shenhuti_wushuang", func = "tianshenhuti_info", tab_index = TabIndex.tianshenhuti_info, remind_id = RemindName.Tianshenhuti},	--无双
		{name = Language.Tianshenhuti.TabbarName[2], bundle = "uis/images_atlas", asset = "tab_icon_tian_shenhuti_hecheng", func = "tianshenhuti_compose", tab_index = TabIndex.tianshenhuti_compose},	--合成
		{name = Language.Tianshenhuti.TabbarName[3], bundle = "uis/images_atlas", asset = "tab_icon_tian_shenhuti_zhuanhua", func = "tianshenhuti_conversion", tab_index = TabIndex.tianshenhuti_conversion},	--转化
		{name = Language.Tianshenhuti.TabbarName[4], bundle = "uis/images_atlas", asset = "tab_icon_tian_shenhuti_baoxiang", func = "tianshenhuti_box", tab_index = TabIndex.tianshenhuti_box, remind_id = RemindName.TianshenhutiBox},	--宝箱
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TxtTitle"].text.text = Language.Tianshenhuti.TitleName
	self.node_list["UnderBg"]:SetActive(true)

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
	self:ShowTimeToOpenLable()
end

function TianshenhutiView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:Flush()
	self:BoxOpenLimit()
end

-- 元宝
function TianshenhutiView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function TianshenhutiView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function TianshenhutiView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function TianshenhutiView:OpenIndexCheck(to_index)
	self:ChangeToIndex(to_index)
end


function TianshenhutiView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function TianshenhutiView:ShowIndexCallBack(index, index_nodes, is_jump)
	self.tabbar:ChangeToIndex(index, is_jump)
	if nil ~= index_nodes then
		if index == TabIndex.tianshenhuti_info then 	-- 无双
			self.tianshenhuti_info_view = TianshenhutiInfoView.New(index_nodes["InfoPanel"])
		elseif index == TabIndex.tianshenhuti_compose then -- 合成
			self.tianshenhuti_compose_view = TianshenhutiComposeView.New(index_nodes["TianShenCompose"])
		elseif index == TabIndex.tianshenhuti_conversion then -- 转化
			self.tianshenhuti_conversion_view = TianshenhutiConversionView.New(index_nodes["ConversionPanel"])
		elseif index == TabIndex.tianshenhuti_box then 		-- 宝箱
			self.tianshenhuti_box_view = TianshenhutiBoxView.New(index_nodes["BoxPanel"])
		end
	end

	if index == TabIndex.tianshenhuti_info and self.tianshenhuti_info_view then
		self.node_list["TaiZi"]:SetActive(true)
		self.node_list["TaiZi"].transform.localPosition = Vector3(-274, -307, 0)
		self.tianshenhuti_info_view:OpenCallBack()
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
		local callback = function()
			self.tianshenhuti_info_view:FlushModel()
			self.tianshenhuti_info_view:UITween()

		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.tianshenhuti_compose then
		UIScene:ChangeScene(nil)
		self.node_list["TaiZi"]:SetActive(false)
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_tianshenhuti_compose", "bg_tianshenhuti_compose.jpg")
		if self.tianshenhuti_compose_view then
			self.tianshenhuti_compose_view:UITween()
			self.tianshenhuti_compose_view:OpenCallBack()
		end
	elseif index == TabIndex.tianshenhuti_conversion then
		UIScene:ChangeScene(nil)
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_tianshenhuti_compose", "bg_tianshenhuti_compose.jpg")
		self.node_list["TaiZi"]:SetActive(false)
		if self.tianshenhuti_conversion_view then
			self.tianshenhuti_conversion_view:UITween()
			self.tianshenhuti_conversion_view:OpenCallBack()
		end
	elseif index == TabIndex.tianshenhuti_box then
		UIScene:ChangeScene(nil)
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_tianshenhuti_box", "bg_tianshenhuti_box.jpg")
		self.node_list["TaiZi"]:SetActive(false)
		if self.tianshenhuti_box_view then
			self.tianshenhuti_box_view:UITween()
			self.tianshenhuti_box_view:OpenCallBack()
		end
	end
end

function TianshenhutiView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k,v in pairs(param_t) do
		if k == "all" then
			if cur_index == TabIndex.tianshenhuti_info and self.tianshenhuti_info_view then
				self.tianshenhuti_info_view:Flush()
			elseif cur_index == TabIndex.tianshenhuti_box and self.tianshenhuti_box_view then
				self.tianshenhuti_box_view:Flush()
			end
		elseif k == "" then

		end
	end
	
end

function TianshenhutiView:FlushTabbar()	
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function TianshenhutiView:ItemDataChangeCallback()
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.tianshenhuti_box and self.tianshenhuti_box_view then
		self.tianshenhuti_box_view:ItemDataChangeCallback()
	end
end

-- 宝箱侧标签显示限时开启标签
function TianshenhutiView:ShowTimeToOpenLable()
	if self.tabbar then
		local tab_button = self.tabbar:GetTabButton(TabIndex.tianshenhuti_box)
		if tab_button then
			tab_button:ShowXianShiDuiHuan(true, "uis/images_atlas", "label_status_time_to_open")
		end
	end		
end

-- 宝箱侧标签周二周四开启
function TianshenhutiView:BoxOpenLimit()
	local week_number = tonumber(os.date("%w", TimeCtrl.Instance:GetServerTime()))
	local is_show = (week_number == 2) or (week_number == 4)
	local tab_button = self.tabbar:GetTabButton(TabIndex.tianshenhuti_box)
	if tab_button then
		tab_button:SetActive(is_show)
	end
end
