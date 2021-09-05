VARIABLE_VALUE_TYPE = {
	STRING = 1,
	BOOL = 2,
	FLOAT = 3,
	ASSET = 4
}

VARIABLE_BIND_TYPE = {
	BIND_ACTIVE = 1,				--（bool） 	节点显示隐藏
	BIND_ATTACH = 2,				-- (asset) 	特效预制体
	BIND_COLOR = 3,					-- (bool) 	颜色
	BIND_DROPDOWN = 4,				-- (string)	下拉菜单（无用）
	BIND_GRAY = 5,					-- (bool) 	灰度
	BIND_IMAGE = 6,					-- (asset) 	图片
	BIND_IMAGE_BOOL = 7,			-- (bool) 	图片状态(无用)
	BIND_INTERACTABLE = 8,			-- (bool) 	是否可点
	BIND_RAWIMAGE = 9,				-- (asset) 	大图
	BIND_RAWIMAGE_URL = 10,			-- (string) 大图URL
	BIND_SLIDER = 11,				-- (float) 	进度条
	BIND_TEXT = 12,					-- (string) 文字
	BIND_TOGGLE = 13,				-- (bool) 	复选
}

EVENT_BIND_TYPE = {
	BIND_CLICK = 1,
    BIND_DROPDOWN = 2,
    BIND_INPUTFIELD_VALUE = 3,
    BIND_INPUTFIELD_END = 4,
    BIND_INPUTFIELDKEY = 5,
    BIND_PRESSDOWN = 6,
    BIND_PRESSUP = 7,
    BIND_SLIDER = 8,
    BIND_TOGGLE = 9,
    BIND_TOUCH_UP = 10,
    BIND_TOUCH_DOWN = 11,
}

BOOL_LOGIC_TYPE = {
	AND = 0,
	OR = 1,
}

UIVariableManager = UIVariableManager or {}
UIVariableManager.cfg_list = {}

function UIVariableManager:Create(view, variable_param)
	local class = nil
	if variable_param.value_type == VARIABLE_VALUE_TYPE.STRING then
		class = UIVariableBindString.New(view, variable_param)
	elseif variable_param.value_type == VARIABLE_VALUE_TYPE.BOOL then
		class = UIVariableBindBool.New(view, variable_param)
	elseif variable_param.value_type == VARIABLE_VALUE_TYPE.FLOAT then
		class = UIVariableBindFloat.New(view, variable_param)
	elseif variable_param.value_type == VARIABLE_VALUE_TYPE.ASSET then
		class = UIVariableBindAsset.New(view, variable_param)
	end
	return class
end

function UIVariableManager:GetEventConfig(res_path, table_key)
	local cfg = self:GetConfig(res_path, table_key)
	return cfg.Event
end

function UIVariableManager:GetVariableConfig(res_path, table_key)
	local cfg = self:GetConfig(res_path, table_key)
	return TableCopy(cfg.Variable)
end

function UIVariableManager:GetConfig(res_path, table_key)
	if nil == res_path or "" == res_path or nil == table_key or "" == table_key then
		return nil
	end

	local file_path = "gameui/variable/" .. string.lower(string.gsub(res_path, "/", "_") .. "_var")
	if nil == self.cfg_list[file_path] then
		self.cfg_list[file_path] = require(file_path)
	end

	if nil == self.cfg_list[file_path][table_key] then
		print_error("variable config require failed! " .. file_path .. ":" .. table_key)
		return nil
	end

	return self.cfg_list[file_path][table_key]
end

function UIVariableManager:EventBind(view, node_param_list, listener)
	if nil == view or nil == node_param_list or nil == listener then
		return
	end

	local function_list = {
		[EVENT_BIND_TYPE.BIND_CLICK] = function(v)
			if nil ~= view.node_list[v.name].button then
				view.node_list[v.name].button:AddClickListener(listener)
			elseif nil ~= view.node_list[v.name].toggle then
				view.node_list[v.name].toggle:AddClickListener(listener)
			else
				local etl = view.node_list[v.name]:GetOrAddComponent(typeof(EventTriggerListener))
				etl:AddPointerClickListener(listener)
			end
		end,

		[EVENT_BIND_TYPE.BIND_DROPDOWN] = function(v)
			if nil == view.node_list[v.name].dropdown then
				print_error("node " .. v.name .. " do not have \"dropdown\" Component!")
			else
				view.node_list[v.name].dropdown.onValueChanged:AddListener(listener)
			end
		end,

		[EVENT_BIND_TYPE.BIND_INPUTFIELD_VALUE] = function(v)
			if nil == view.node_list[v.name].input_field then
				print_error("node " .. v.name .. " do not have \"input_field\" Component!")
			else
				view.node_list[v.name].input_field.onValueChanged:AddListener(listener)
			end
		end,

		[EVENT_BIND_TYPE.BIND_INPUTFIELD_END] = function(v)
			if nil == view.node_list[v.name].input_field then
				print_error("node " .. v.name .. " do not have \"input_field\" Component!")
			else
				view.node_list[v.name].input_field.onEndEdit:AddListener(listener)
			end
		end,

		[EVENT_BIND_TYPE.BIND_INPUTFIELDKEY] = function(v)
			if nil == view.node_list[v.name].input_field then
				print_error("node " .. v.name .. " do not have \"input_field\" Component!")
			else
				--v.key_code
			end
		end,

		[EVENT_BIND_TYPE.BIND_PRESSDOWN] = function(v)
			if nil == view.node_list[v.name].event_trigger_listener then
				print_error("node " .. v.name .. " do not have \"EventTriggerListener\" Component! type = BIND_PRESSDOWN")
			end

			local etl = view.node_list[v.name]:GetOrAddComponent(typeof(EventTriggerListener))
			etl:AddPointerDownListener(listener)
		end,

		[EVENT_BIND_TYPE.BIND_PRESSUP] = function(v)
			if nil == view.node_list[v.name].event_trigger_listener then
				print_error("node " .. v.name .. " do not have \"EventTriggerListener\" Component! type = BIND_PRESSUP")
			end
			
			local etl = view.node_list[v.name]:GetOrAddComponent(typeof(EventTriggerListener))
			etl:AddPointerUpListener(listener)
		end,

		[EVENT_BIND_TYPE.BIND_SLIDER] = function(v)
			if nil == view.node_list[v.name].slider then
				print_error("node " .. v.name .. " do not have \"slider\" Component!")
			else
				view.node_list[v.name].slider.onValueChanged:AddListener(listener)
			end
		end,

		[EVENT_BIND_TYPE.BIND_TOGGLE] = function(v)
			if nil == view.node_list[v.name].toggle then
				print_error("node " .. v.name .. " do not have \"toggle\" Component!")
			else
				view.node_list[v.name].toggle.onValueChanged:AddListener(listener)
			end
		end,

		[EVENT_BIND_TYPE.BIND_TOUCH_UP] = function(v)
			if nil == view.node_list[v.name].event_trigger_listener then
				print_error("node " .. v.name .. " do not have \"EventTriggerListener\" Component! type = BIND_TOUCH_UP")
			end
			
			local etl = view.node_list[v.name]:GetOrAddComponent(typeof(EventTriggerListener))
			etl:AddPointerUpListener(listener)
		end,

		[EVENT_BIND_TYPE.BIND_TOUCH_DOWN] = function(v)
			if nil == view.node_list[v.name].event_trigger_listener then
				print_error("node " .. v.name .. " do not have \"EventTriggerListener\" Component! type = BIND_TOUCH_DOWN")
			end

			local etl = view.node_list[v.name]:GetOrAddComponent(typeof(EventTriggerListener))
			etl:AddPointerDownListener(listener)
		end,
	}

	for k,v in pairs(node_param_list) do
		if nil ~= view.node_list[v.name] then
			if nil ~= function_list[v.event_type] then
				listener = BindTool.Bind(listener)
				function_list[v.event_type](v)
			end
		else
			print_error("EventBind Node: " .. v.name .. " is not in NameTable!")
		end
	end
end

--------------------------------------------------
UIVariableBase = UIVariableBase or BaseClass()

function UIVariableBase:__init(view, variable_param)
	self.view = view
	self.variable_param = variable_param or {}
	self.name = ""
end

function UIVariableBase:__delete()
	self.view = nil
	self.variable_param = nil
	self.name = ""
end

function UIVariableBase:InitValue(value)
	self.variable_param.value = value
	self:SetValue(self.variable_param.value)
end

function UIVariableBase:GetValue()
	return self.variable_param.value
end

function UIVariableBase:GetBoolean()
	if type(self.variable_param.value) == "boolean" then
		return self.variable_param.value
	end
end

function UIVariableBase:GetFloat()
	if type(self.variable_param.value) == "number" then
		return self.variable_param.value
	end
end

function UIVariableBase:GetInteger()
	if type(self.variable_param.value) == "number" then
		return self.variable_param.value
	end
end

function UIVariableBase:ResetAsset()
	self:SetAsset("", "")
end

function UIVariableBase:SetAsset(bundle, asset)
	-- override
end

function UIVariableBase:SetValue(value)
	-- override
	if nil == self.variable_param then
		print_error("SetValue is not allow because Variable: " .. self.name .." is Invalid")
	end
end

--------------------------------------------------
UIVariableBindString = UIVariableBindString or BaseClass(UIVariableBase)

function UIVariableBindString:SetValue(value)
	self.variable_param.value = value

	if nil == self.variable_param.obj_list then return end

	for _, obj_param in pairs(self.variable_param.obj_list) do
		local str = self.variable_param.value
		if nil ~= obj_param.text and "" ~= obj_param.text then
			str = string.gsub(obj_param.text, "%{.-%}" , function(name)
				local variable_name = string.sub(name, 2, -2)
				if nil ~= self.view.ui_variables[variable_name] and nil ~= self.view.ui_variables[variable_name].class then
					return self.view.ui_variables[variable_name].class:GetValue() or name
				end
			end)
		end

		if nil ~= self.view.node_list[obj_param.name] then
			if VARIABLE_BIND_TYPE.BIND_TEXT == obj_param.bind_type then
				self.view.node_list[obj_param.name].text.text = str

			elseif VARIABLE_BIND_TYPE.BIND_DROPDOWN == obj_param.bind_type and type(self.variable_param.value) == "number" then
				self.view.node_list[obj_param.name].dropdown.value = tonumber(self.variable_param.value)

			elseif VARIABLE_BIND_TYPE.BIND_RAWIMAGE_URL == obj_param.bind_type then
				self.view.node_list[obj_param.name].raw_image:LoadURLSprite(self.variable_param.value)

			end
		else
			print_error(obj_param.name .. " is not in node_list!")
		end
	end
end

--------------------------------------------------
UIVariableBindBool = UIVariableBindBool or BaseClass(UIVariableBase)

function UIVariableBindBool:SetValue(value)
	self.variable_param.value = value

	if nil == self.variable_param.obj_list then return end

	for _, obj_param in pairs(self.variable_param.obj_list) do
		local is_true = (BOOL_LOGIC_TYPE.AND == obj_param.bool_logic)
		for k, v in pairs(obj_param.param_list) do
			local variable_value = self.view.ui_variables[k].class and self.view.ui_variables[k].class:GetValue() or false
			if true == v then
				variable_value = not variable_value
			end

			if BOOL_LOGIC_TYPE.AND == obj_param.bool_logic then
				is_true = is_true and variable_value
			elseif BOOL_LOGIC_TYPE.OR == obj_param.bool_logic then
				is_true = is_true or variable_value
			end
		end

		if nil ~= self.view.node_list[obj_param.name] then
			if VARIABLE_BIND_TYPE.BIND_ACTIVE == obj_param.bind_type then
				self.view.node_list[obj_param.name]:SetActive(is_true)

			elseif VARIABLE_BIND_TYPE.BIND_GRAY == obj_param.bind_type then
				UI:SetGraphicGrey(self.view.node_list[obj_param.name], is_true)

			elseif VARIABLE_BIND_TYPE.BIND_TOGGLE == obj_param.bind_type then
				self.view.node_list[obj_param.name].toggle.isOn = is_true

			elseif VARIABLE_BIND_TYPE.BIND_INTERACTABLE == obj_param.bind_type then
				local component = self.view.node_list[obj_param.name].button or self.view.node_list[obj_param.name].toggle
				component.interactable = is_true

			elseif VARIABLE_BIND_TYPE.BIND_IMAGE_BOOL == obj_param.bind_type then
				local asset = is_true and obj_param.on_res or obj_param.off_res

				if nil ~= asset[1] and "" ~= asset[1] and nil ~= asset[2] and "" ~= asset[2] then
					self.view.node_list[obj_param.name].image:LoadSprite(asset[1], asset[2])
				end

			elseif VARIABLE_BIND_TYPE.BIND_COLOR == obj_param.bind_type then
				local color = is_true and obj_param.on_color or obj_param.off_color
				self.view.node_list[obj_param.name].graphic.color = Color(color.r, color.g, color.b, color.a)
			end
		else
			print_error(obj_param.name .. " is not in node_list!")
		end
	end
end

--------------------------------------------------
UIVariableBindFloat = UIVariableBindFloat or BaseClass(UIVariableBase)

function UIVariableBindFloat:SetValue(value)
	self.variable_param.value = value

	if nil == self.variable_param.obj_list then return end

	for _, obj_param in pairs(self.variable_param.obj_list) do
		if nil ~= self.view.node_list[obj_param.name] then
			if VARIABLE_BIND_TYPE.BIND_SLIDER == obj_param.bind_type then
				self.view.node_list[obj_param.name].slider.value = self.variable_param.value
				-- obj_param.tween_type
				-- obj_param.tween_speed
			end
		else
			print_error(obj_param.name .. " is not in node_list!")
		end
	end
end

--------------------------------------------------
UIVariableBindAsset = UIVariableBindAsset or BaseClass(UIVariableBase)

function UIVariableBindAsset:SetAsset(bundle, asset)
	self.variable_param.value = {bundle, asset}

	if nil == self.variable_param.obj_list then return end

	for _, obj_param in pairs(self.variable_param.obj_list) do
		if nil ~= self.view.node_list[obj_param.name] then
			if VARIABLE_BIND_TYPE.BIND_IMAGE == obj_param.bind_type then
				local asset = self.variable_param.value
				if nil ~= asset[1] and "" ~= asset[1] and nil ~= asset[2] and "" ~= asset[2] then
					self.view.node_list[obj_param.name].image:LoadSprite(asset[1], asset[2] .. ".png")
				end

				if obj_param.auto_fit_size then
					self.view.node_list[obj_param.name].image:SetNativeSize()
				end

				if obj_param.auto_disable then
					self.view.node_list[obj_param.name].image.enabled = (nil ~= self.view.node_list[obj_param.name].image.sprite)
				end

			elseif VARIABLE_BIND_TYPE.BIND_RAWIMAGE == obj_param.bind_type then
				local asset = self.variable_param.value
				if nil ~= asset[1] and "" ~= asset[1] and nil ~= asset[2] and "" ~= asset[2] then
                    assert(nil)
					-- TexturePool.Instance:Load(
					-- 	AssetID(self.variable_param.value[1], self.variable_param.value[2]),
					-- 	function(texture)
					-- 		TexturePool.Instance:Free(texture, obj_param.is_realtime_unload)
					-- 		self.view.node_list[obj_param.name].raw_image.texture = texture
					-- 		self.view.node_list[obj_param.name].raw_image.enabled = true
					-- 	end, 
					-- 	obj_param.is_sync)

					-- if obj_param.auto_fit_size then
					-- 	self.view.node_list[obj_param.name].raw_image:SetNativeSize()
					-- end

					-- 不要抄上面这种方式，直接调用LoadSprite
					-- self.view.node_list[obj_param.name].raw_image:LoadSprite(self.variable_param.value[1], self.variable_param.value[2])
				end

			elseif VARIABLE_BIND_TYPE.BIND_ATTACH == obj_param.bind_type then
				self.view.node_list[obj_param.name]:ChangeAsset(self.variable_param.value[1], self.variable_param.value[2])
			end
		else
			print_error(obj_param.name .. " is not in node_list!")
		end
	end
end

