--通用全屏底板侧边标签
------------------------------------------------------
TabBarOne = TabBarOne or BaseClass()

function TabBarOne:__init()
	self.remind_id_to_index = {}
	self.tabindex_to_index = {}
	self.tab_button_list = {}
	self.sub_tab_cur_index = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function TabBarOne:__delete()
	for k,v in pairs(self.tab_button_list) do
		v:DeleteMe()
	end
	self.tab_button_list = nil
	self.remind_id_to_index = nil
	self.tabindex_to_index = nil
	self.parent_view = nil

	if nil ~= self.sub_tabbar then
		self.sub_tabbar:DeleteMe()
		self.sub_tabbar = nil
	end

	self.sub_tab_cur_index = nil
	self.list_scroll_rect = nil
	self.view_port_rect = nil

	RemindManager.Instance:UnBind(self.remind_change)
end

function TabBarOne:Init(parent_view, parent, tab_cfg, is_marry)
	self.parent_view = parent_view
	self.parent = parent
	self.list_scroll_rect = self.parent.transform.parent.parent:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.view_port_rect = self.parent.transform.parent:GetComponent(typeof(UnityEngine.RectTransform))
	self.tab_cfg = tab_cfg
	self.is_marry = is_marry
	self:FlushTabbar()
end

function TabBarOne:InitSubTab(parent, tab_cfg)
	self.sub_parent = parent
	self.sub_tab_cfg = tab_cfg

	for k, v in pairs(self.sub_tab_cfg) do
		for i, value in ipairs(v) do
			self.tabindex_to_index[value.tab_index] = k
		end
	end
end

function TabBarOne:FlushTabbar()
	for i, cfg in ipairs(self.tab_cfg) do
		local fun_is_open = true
		if nil ~= cfg.func and "" ~= cfg.func then
			if type(cfg.func) == "string" then
				fun_is_open = OpenFunData.Instance:CheckIsHide(cfg.func)

				if cfg.remind_id and nil == RemindFunName[cfg.remind_id] or cfg.func ~= RemindFunName[cfg.remind_id] then
					local key = RemindNameKey[cfg.remind_id]
					if nil ~= key then
						print_error("吊毛!!! 标签红点没设置对应的功能开启啊~~", string.format("[RemindName.%s] = \"%s\",", key, cfg.func))
					end
				end

			elseif type(cfg.func) == "function" then
				fun_is_open = cfg.func()
			end
		end
		if fun_is_open then
			local tab_button = self.tab_button_list[i]
			local bundle, asset = "uis/views/commonwidgets_prefab", "BaseFullPanelSideTab"
			if self.is_marry then
				bundle, asset = "uis/views/miscpreload_prefab", "BaseFullPanelSideTab"
			end
			if nil == tab_button then
				tab_button = TabButtonOne.New(ResPoolMgr:TryGetGameObject(bundle, asset))
				tab_button:SetInstanceParent(self.parent)
				tab_button.root_node.toggle.group = self.parent.toggle_group

				self.tab_button_list[i] = tab_button
			end

			tab_button:InitTab(cfg)
			tab_button:SetActive(true)
			
			local root_node = tab_button.root_node
			root_node.gameObject.name = cfg.name
			root_node.toggle:AddClickListener(BindTool.Bind(self.OnTabClick, self, cfg.tab_index))

			self.tabindex_to_index[cfg.tab_index] = i

			if nil ~= cfg.remind_id and "" ~= cfg.remind_id then
				self.remind_id_to_index[cfg.remind_id] = i
				RemindManager.Instance:Bind(self.remind_change, cfg.remind_id)
			end
		else
			if nil ~= self.tab_button_list[i] then
				self.tab_button_list[i]:SetActive(false)
			end
		end
	end

	for i = #self.tab_cfg + 1, #self.tab_button_list do
		if self.tab_button_list[i] then
			self.tab_button_list[i]:SetActive(false)
		end
	end

	for i = 1, #self.tab_cfg do
		local tab_btn = self.tab_button_list[i]
		if tab_btn and not tab_btn:IsNil() then
			tab_btn.root_node.transform:SetAsLastSibling()
		end 
	end

	self:FlushSubTabbar(self.cur_tab_index)
end

function TabBarOne:OnTabClick(tab_index)
	local index = self.tabindex_to_index[tab_index]
	local sub_tab_cfg = self.sub_tab_cfg and self.sub_tab_cfg[index] or nil
	if nil ~= index and nil ~= sub_tab_cfg then
		local cur_tab_index = self.sub_tab_cur_index[index] or (sub_tab_cfg[1] and sub_tab_cfg[1].tab_index or 0)
		self.sub_tab_cur_index[index] = cur_tab_index
		self.select_index_callback(self.sub_tab_cur_index[index])
		return
	else
		if nil ~= self.sub_tabbar then
			self.sub_tabbar:Clear()
		end
	end

	if nil ~= self.select_index_callback then
		self.select_index_callback(tab_index)
	end
end

function TabBarOne:ChangeToIndex(tab_index, is_jump)
	local index = self.tabindex_to_index[tab_index]
	if is_jump and nil ~= index then
		self:JumpToSelectIndex(index)
	end

	if tab_index == self.cur_tab_index then
		return
	end

	if nil == index then
		local first_open_tab_index = self:GetFirstOpenTabIndex()
		if nil ~= first_open_tab_index then
			self.parent_view:ChangeToIndex(first_open_tab_index)
			return
		end
	end

	if nil ~= index and nil ~= self.tab_button_list[index] then
		for i,v in pairs(self.tab_button_list) do
			v:SetHighLight(index == i)
		end
	end
	self.cur_tab_index = tab_index

	self:FlushSubTabbar(tab_index)
end

function TabBarOne:JumpToSelectIndex(index)
	local my_index = 0
	for i, cfg in ipairs(self.tab_cfg) do
		if nil ~= self.tab_button_list[i] then
			my_index = my_index + 1
			if index == i then
				break
			end
		end
	end

	local SINGLE_HEIGHT = 102
	local total_height = #self.tab_cfg * SINGLE_HEIGHT
	local view_port_height = self.view_port_rect.rect.height
	if total_height > view_port_height then
		local vnp = 1 - (my_index - 1) * (SINGLE_HEIGHT / (total_height - view_port_height))
		vnp = vnp < 0 and 0 or vnp
		self.list_scroll_rect.verticalNormalizedPosition = vnp
	end
end

function TabBarOne:GetFirstOpenTabIndex()
	for i, cfg in ipairs(self.tab_cfg) do
		local fun_is_open = false
		if nil ~= cfg.func and "" ~= cfg.func then
			if type(cfg.func) == "string" then
				fun_is_open = OpenFunData.Instance:CheckIsHide(cfg.func)
			elseif type(cfg.func) == "function" then
				fun_is_open = cfg.func()
			end
		end
		if fun_is_open then
			return cfg.tab_index
		end
	end
end

function TabBarOne:FlushSubTabbar(tab_index)
	if nil == tab_index then
		return
	end
	
	local index = self.tabindex_to_index[tab_index]
	local sub_tab_cfg = self.sub_tab_cfg and self.sub_tab_cfg[index] or nil
	if nil ~= sub_tab_cfg and nil ~= index then
		self.sub_tabbar = self.sub_tabbar or TabBarOneTop.New()
		self.sub_tabbar:Init(self.parent_view, self.sub_parent, sub_tab_cfg, self.is_marry)

		local select_callback = function(tab_id)
			self.sub_tab_cur_index[index] = tab_id
			self.select_index_callback(tab_id)
		end
		self.sub_tabbar:SetSelectCallback(select_callback)

		self.sub_tab_cur_index[index] = tab_index
		self.sub_tabbar:ChangeToIndex(self.sub_tab_cur_index[index])
	else
		if nil ~= self.sub_tabbar then
			self.sub_tabbar:Clear()
		end
	end
end

function TabBarOne:GetSubButton(tab_index)
	return self.sub_tabbar:GetTabButton(tab_index)
end

function TabBarOne:GetTabButton(tab_index)
	local index = self.tabindex_to_index[tab_index]
	return self.tab_button_list[index]
end

function TabBarOne:RemindChangeCallBack(remind_name, num)
	local index = self.remind_id_to_index[remind_name]
	if nil ~= index and nil ~= self.tab_button_list[index] then
		self.tab_button_list[index]:ShowRemind(num > 0)
	end
end

function TabBarOne:SetSelectCallback(select_index_callback)
	self.select_index_callback = select_index_callback
end

------------------------------------------------------
--TabButtonOne
------------------------------------------------------

TabButtonOne = TabButtonOne or BaseClass(BaseRender)

function TabButtonOne:__init()
end

function TabButtonOne:__delete()
end

function TabButtonOne:LoadCallBack()
	if self.node_list["BtnBiPin"] then
		self.node_list["BtnBiPin"].button:AddClickListener(BindTool.Bind(self.OnClickBiPin, self))
	end
end

function TabButtonOne:OnClickBiPin()
	ViewManager.Instance:CloseAll()
	if UIScene.role_model then
		UIScene:DeleteModels()
	end
	ViewManager.Instance:Open(ViewName.CompetitionActivity)
end

function TabButtonOne:ShowRemind(is_show)
	self.node_list["RedPointImg"]:SetActive(is_show)
end

function TabButtonOne:ShowBiPin(is_show, bundle, asset, is_icon, is_other)
	if not self.node_list["BtnBiPin"] then return end
	if is_other then
		if bundle and asset then
			self.node_list["BiPinImg"].image:LoadSprite(bundle, asset, function()
				self.node_list["BiPinImg"].transform.localPosition = Vector3(-10, -9, 0)
				self.node_list["BiPinImg"].image:SetNativeSize()
				self.node_list["BtnBiPin"]:SetActive(is_show)
			end)
		else
			self.node_list["BtnBiPin"]:SetActive(is_show)
		end
		local bipin_obj = self.node_list["BtnBiPin"]:GetComponent(typeof(Nirvana.UIBlock))
		if bipin_obj then
			bipin_obj.enabled = not is_icon
		end
		return
	end

	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ActivityData.Instance:GetActivityConfig(COMPETITION_ACTIVITY_TYPE[day])
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local level_show = false
	if cfg then
		level_show = cfg.min_level <= level 
	end

	if bundle and asset then
		self.node_list["BiPinImg"].image:LoadSprite(bundle, asset, function()
			self.node_list["BtnBiPin"]:SetActive(is_show and level_show)
		end)
	else
		self.node_list["BtnBiPin"]:SetActive(is_show and level_show)
	end

	local bipin_obj = self.node_list["BtnBiPin"]:GetComponent(typeof(Nirvana.UIBlock))
	if bipin_obj then
		bipin_obj.enabled = not is_icon
	end
end

function TabButtonOne:ShowXianShiDuiHuan(is_show, bundle, asset)
	if not self.node_list["XianShiDuiHuan"] then return  end

	if bundle and asset then
		self.node_list["XianShiDuiHuanIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["XianShiDuiHuan"]:SetActive(is_show)
			self.node_list["XianShiDuiHuanIcon"].image:SetNativeSize()
		end)
	else
		self.node_list["XianShiDuiHuan"]:SetActive(is_show)
	end
end

function TabButtonOne:InitTab(cfg)
	self.node_list["HideImg"].image:LoadSprite(cfg.bundle, cfg.asset, function ()
		self.node_list["HideImg"]:SetActive(true)
		self.node_list["HideImg"].image:SetNativeSize()
	end)
	self.node_list["HighLightImg"].image:LoadSprite(cfg.bundle, cfg.asset .. "_select", function ()
		self.node_list["HighLightImg"]:SetActive(true)
		self.node_list["HighLightImg"].image:SetNativeSize()
	end)

	self.node_list["HighLightText"].text.text = cfg.name
	self.node_list["HideText"].text.text = cfg.name
end

function TabButtonOne:SetHighLight(is_on)
	self.root_node.toggle.isOn = is_on
end
