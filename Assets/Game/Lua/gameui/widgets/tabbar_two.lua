--通用二级底板侧边标签
------------------------------------------------------
TabBarTwo = TabBarTwo or BaseClass()

function TabBarTwo:__init()
	self.remind_id_to_index = {}
	self.tabindex_to_index = {}
	self.tab_button_list = {}
	self.sub_tab_cur_index = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function TabBarTwo:__delete()
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

	RemindManager.Instance:UnBind(self.remind_change)
end

function TabBarTwo:Init(parent_view, parent, tab_cfg)
	self.parent_view = parent_view
	self.parent = parent
	self.tab_cfg = tab_cfg
	self:FlushTabbar()
end

function TabBarTwo:InitSubTab(parent, tab_cfg)
	self.sub_parent = parent
	self.sub_tab_cfg = tab_cfg

	for k, v in pairs(self.sub_tab_cfg) do
		for i, value in ipairs(v) do
			self.tabindex_to_index[value.tab_index] = k
		end
	end
end

function TabBarTwo:FlushTabbar()
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
			if nil == tab_button then
				tab_button = TabButtonTwo.New(ResPoolMgr:TryGetGameObject("uis/views/commonwidgets_prefab", "BaseSecondPanelTab"))
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
		self.tab_button_list[i]:SetActive(false)
	end

	for i = 1, #self.tab_cfg do
		local tab_btn = self.tab_button_list[i]
		if tab_btn and not tab_btn:IsNil() then
			tab_btn.root_node.transform:SetAsLastSibling()
		end 
	end

	self:FlushSubTabbar(self.cur_tab_index)
end

function TabBarTwo:OnTabClick(tab_index)
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

function TabBarTwo:ChangeToIndex(tab_index)
	if tab_index == self.cur_tab_index and not self.allow_same then
		return
	end

	local index = self.tabindex_to_index[tab_index]
	if nil == index then
		local first_open_tab_index = self:GetFirstOpenTabIndex()
		if nil ~= first_open_tab_index then
			self.parent_view:ChangeToIndex(first_open_tab_index)
			return
		end
	end

	if nil ~= index and nil ~= self.tab_button_list[index] then
		self.tab_button_list[index]:SetHighLight(true)
	end
	self.cur_tab_index = tab_index

	self:FlushSubTabbar(tab_index)
end

function TabBarTwo:GetFirstOpenTabIndex()
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

function TabBarTwo:FlushSubTabbar(tab_index)
	if nil == tab_index then
		return
	end
	
	local index = self.tabindex_to_index[tab_index]
	local sub_tab_cfg = self.sub_tab_cfg and self.sub_tab_cfg[index] or nil
	if nil ~= sub_tab_cfg and nil ~= index then
		self.sub_tabbar = self.sub_tabbar or TabBarTwoTop.New()
		self.sub_tabbar:Init(self.parent_view, self.sub_parent, sub_tab_cfg)

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

function TabBarTwo:GetTabButton(tab_index)
	local index = self.tabindex_to_index[tab_index]
	return self.tab_button_list[index]
end

function TabBarTwo:RemindChangeCallBack(remind_name, num)
	local index = self.remind_id_to_index[remind_name]
	if nil ~= index and nil ~= self.tab_button_list[index] then
		self.tab_button_list[index]:ShowRemind(num > 0)
	end
end

function TabBarTwo:SetSelectCallback(select_index_callback)
	self.select_index_callback = select_index_callback
end

-- 设置允许相同标签点击高亮
function TabBarTwo:SetAllowSame(allow_same)
	self.allow_same = allow_same
end

------------------------------------------------------
--TabButtonTwo
------------------------------------------------------

TabButtonTwo = TabButtonTwo or BaseClass(BaseRender)

function TabButtonTwo:__init()
end

function TabButtonTwo:__delete()
end

function TabButtonTwo:ShowRemind(is_show)
	self.node_list["RedPointImg"]:SetActive(is_show)
end

function TabButtonTwo:InitTab(cfg)
	self.node_list["HighLightText"].text.text = cfg.name
	self.node_list["HideText"].text.text = cfg.name
end

function TabButtonTwo:SetHighLight(is_on)
	self.root_node.toggle.isOn = is_on
end

function TabButtonTwo:ShowXianShiDuiHuan(is_show, bundle, asset)
	if not self.node_list["XianShiDuiHuan"] then return end

	if bundle and asset then
		self.node_list["XianShiDuiHuanIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["XianShiDuiHuan"]:SetActive(is_show)
		end)
	else
		self.node_list["XianShiDuiHuan"]:SetActive(is_show)
	end
end