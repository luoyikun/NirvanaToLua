MainUIViewExp = MainUIViewExp or BaseClass(BaseRender)

function MainUIViewExp:__init()
	-- 属性事件处理
	self.attr_handlers = {
		exp = BindTool.Bind1(self.OnExpChanged, self),
		max_exp = BindTool.Bind1(self.OnExpChanged, self),
	}

	-- 监听系统事件
	self.player_data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)

	-- 首次刷新数据
	self:OnExpInitialized()
end

function MainUIViewExp:__delete()
	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)
	self.player_data_change_callback = nil
	
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MainUIViewExp:PlayerDataChangeCallback(attr_name, value, old_value)
	local handler = self.attr_handlers[attr_name]
	if handler ~= nil then
		handler()
	end
end

function MainUIViewExp:OnExpInitialized()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["Slider"].slider.value = vo.exp / vo.max_exp
	self.node_list["TxtEXP"].text.text = CommonDataManager.ConverExp(vo.exp) .. "/" .. CommonDataManager.ConverExp(vo.max_exp)
end

function MainUIViewExp:OnExpChanged()
	self:SetAutoTalkTime()
	self:OnExpInitialized()
end

function MainUIViewExp:SetAutoTalkTime()
	if self.count_down then return end
	self.node_list["Effect"]:SetActive(true)
	self.count_down = CountDown.Instance:AddCountDown(0.6, 0.1, BindTool.Bind(self.CountDown, self))
end

function MainUIViewExp:CountDown(elapse_time, total_time)
	if total_time - elapse_time <= 0 then
		self.node_list["Effect"]:SetActive(false)
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end
