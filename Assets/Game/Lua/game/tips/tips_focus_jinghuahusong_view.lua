TipsFocusJingHuaHuSongView = TipsFocusJingHuaHuSongView or BaseClass(BaseView)			--精华护送提醒弹窗，精华刷新的时候弹出

function TipsFocusJingHuaHuSongView:__init()
	self.ui_config = {{"uis/views/tips/crystaltips_prefab", "FocusJingHuaHuSongTips"}}
	self.view_layer = UiLayer.Pop
end

function TipsFocusJingHuaHuSongView:LoadCallBack()
	-- self:ListenEvent("close_click",BindTool.Bind(self.CloseClick, self))
	-- self:ListenEvent("go_click",BindTool.Bind(self.GoClick, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseClick, self))
	self.node_list["BtnGoSmall"].button:AddClickListener(BindTool.Bind(self.GoClick, self))
	self.node_list["BtnGoBig"].button:AddClickListener(BindTool.Bind(self.GoClick2, self))
	-- self:ListenEvent("go_click_2",BindTool.Bind(self.GoClick2, self))
	-- self.time = self:FindVariable("time")
end

function TipsFocusJingHuaHuSongView:ReleaseCallBack()
	-- self.time = nil
end

function TipsFocusJingHuaHuSongView:OpenCallBack()
	self:Flush()
end

function TipsFocusJingHuaHuSongView:CloseClick()
	self:Close()
end

function TipsFocusJingHuaHuSongView:GoClick()
	local scene_type = Scene.Instance:GetSceneType()  
	if scene_type == SceneType.CrystalEscort then
		if JingHuaHuSongCtrl.Instance then
			JingHuaHuSongCtrl.Instance:MoveToGather(false, JingHuaHuSongData.JingHuaType.Small)
		end
	else
		JingHuaHuSongCtrl.Instance:GetIntoCrossShuiJing(JingHuaHuSongData.JingHuaType.Small)
	end
	self:Close()
end

function TipsFocusJingHuaHuSongView:GoClick2()
	local scene_type = Scene.Instance:GetSceneType()  
	if scene_type == SceneType.CrystalEscort then
		if JingHuaHuSongCtrl.Instance then
			JingHuaHuSongCtrl.Instance:MoveToGather(false, JingHuaHuSongData.JingHuaType.Big)
		end
	else
		JingHuaHuSongCtrl.Instance:GetIntoCrossShuiJing(JingHuaHuSongData.JingHuaType.Big)
	end
	self:Close()
end

function TipsFocusJingHuaHuSongView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsFocusJingHuaHuSongView:OnFlush()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.node_list["TxtTime"].text.text = string.format(Language.FocusTips.Time2, 15)
	self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusJingHuaHuSongView:CountDown(elapse_time, total_time)
	local surplus_time = math.floor(total_time - elapse_time) 
	self.node_list["TxtTime"].text.text = string.format(Language.FocusTips.Time2, surplus_time)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end