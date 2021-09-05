--通用二级底板顶边标签
------------------------------------------------------
TabBarOneTop = TabBarOneTop or BaseClass()

function TabBarOneTop:__init()
	self.remind_id_to_index = {}
	self.tabindex_to_index = {}
	self.tab_button_list = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function TabBarOneTop:__delete()
	for k,v in pairs(self.tab_button_list) do
		v:DeleteMe()
	end
	self.tab_button_list = nil
	self.remind_id_to_index = nil
	self.tabindex_to_index = nil
	self.parent_view = nil

	RemindManager.Instance:UnBind(self.remind_change)
end

function TabBarOneTop:Init(parent_view, parent, tab_cfg, is_marry)
	if nil == parent or nil == tab_cfg then
		self:Clear()
		return
	end

	self.parent_view = parent_view
	self.parent = parent
	self.tab_cfg = tab_cfg
	self.is_marry = is_marry
	self:FlushTabbar()
end

function TabBarOneTop:FlushTabbar()
	self.tabindex_to_index = {}
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
			local bundle, asset = "uis/views/commonwidgets_prefab", "BaseFullPanelTopTab"
			if self.is_marry then
				bundle, asset = "uis/views/miscpreload_prefab", "BaseFullPanelTopTab"
			end
			if nil == tab_button then
				tab_button = TabButtonOneTop.New(ResPoolMgr:TryGetGameObject(bundle, asset))
				tab_button:SetInstanceParent(self.parent)
				tab_button.root_node.toggle.group = self.parent.toggle_group

				if self.is_marry then
					if 1 == i then
						tab_button.root_node.transform.localPosition = Vector3(-240, -47, 0)
					elseif 2 == i then
						tab_button.root_node.transform.localPosition = Vector3(-152, -31, 0)
					elseif 3 == i then
						tab_button.root_node.transform.localPosition = Vector3(-63, -33, 0)
					end
				end

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
			tab_btn.root_node.gameObject.name = self.tab_cfg[i].name
			tab_btn.root_node.transform:SetAsLastSibling()
		end 
	end
end

function TabBarOneTop:Clear()
	for k,v in pairs(self.tab_button_list) do
		v:SetActive(false)
	end
	self.cur_tab_index = nil
end

function TabBarOneTop:OnTabClick(index)
	if nil ~= self.select_index_callback then
		self.select_index_callback(index)
	end
end

function TabBarOneTop:ChangeToIndex(tab_index)
	if tab_index == self.cur_tab_index then
		return
	end
	
	self.cur_tab_index = tab_index
	
	local index = self.tabindex_to_index[tab_index]
	if nil == index then
		local first_open_tab_index = self:GetFirstOpenTabIndex()
		if nil ~= first_open_tab_index then
			self.parent_view:ChangeToIndex(first_open_tab_index)
			return
		end
	end

	if index ~= nil and nil ~= self.tab_button_list[index] then 
		for i,v in pairs(self.tab_button_list) do
			v:SetHighLight(index == i)
		end
	end
end

function TabBarOneTop:GetFirstOpenTabIndex()
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

function TabBarOneTop:GetTabButton(tab_index)
	local index = self.tabindex_to_index[tab_index]
	return self.tab_button_list[index]
end

function TabBarOneTop:RemindChangeCallBack(remind_name, num)
	local index = self.remind_id_to_index[remind_name]
	if nil ~= index and nil ~= self.tab_button_list[index] then
		self.tab_button_list[index]:ShowRemind(num > 0)
	end
end

function TabBarOneTop:SetSelectCallback(select_index_callback)
	self.select_index_callback = select_index_callback
end

------------------------------------------------------
--TabButtonOneTop
------------------------------------------------------

TabButtonOneTop = TabButtonOneTop or BaseClass(BaseRender)

function TabButtonOneTop:__init()
end

function TabButtonOneTop:__delete()
end

function TabButtonOneTop:ShowRemind(is_show)
	self.node_list["RedPointImg"]:SetActive(is_show)
end

function TabButtonOneTop:InitTab(cfg)
	self.node_list["HighLightText"].text.text = cfg.name
	self.node_list["HideText"].text.text = cfg.name
end

function TabButtonOneTop:SetHighLight(is_on)
	self.root_node.toggle.isOn = is_on
end