MojieMainView = MojieMainView or BaseClass(BaseView)

local PASSIVE_TYPE = 73

function MojieMainView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseMoJiePanel"},
		{"uis/views/player_prefab", "MojieMainView"},
	}

	self.is_modal = true
	self.play_audio = true
	--self.is_any_click_close = true

end

function MojieMainView:__delete()

end

function MojieMainView:ReleaseCallBack()


end



function MojieMainView:OpenCallBack()


end

function MojieMainView:LoadCallBack()
	for i = 1, 4 do
		self.node_list["ToggleRing" .. i].button:AddClickListener(BindTool.Bind(self.ClickMojie, self, i))
	end
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))

	-- 循环上下浮动动画
	local start_pos1 = Vector3(0 , 0 , 0)
	local end_pos1 = Vector3(0 , 15 , 0)
	UITween.MoveLoop(self.node_list["RawImage1"], start_pos1, end_pos1, 1)
	--UITween.MoveLoop(self.node_list["RingIcon1"], start_pos1, end_pos1, 0.5)

	local start_pos2 = Vector3(0 , 10 , 0)
	local end_pos2 = Vector3(0 , 25 , 0)
	UITween.MoveLoop(self.node_list["RawImage2"], start_pos2, end_pos2, 1)
	--UITween.MoveLoop(self.node_list["RingIcon2"], start_pos2, end_pos2, 0.5)


	local start_pos3 = Vector3(0 , 30 , 0)
	local end_pos3 = Vector3(0 , 15 , 0)
	UITween.MoveLoop(self.node_list["RawImage3"], start_pos3, end_pos3, 1)
	--UITween.MoveLoop(self.node_list["RingIcon3"], start_pos3, end_pos3, 0.5)


	local start_pos4 = Vector3(0 , 15 , 0)
	local end_pos4 = Vector3(0 , 30 , 0)
	UITween.MoveLoop(self.node_list["RawImage4"], start_pos4, end_pos4, 1)
	--UITween.MoveLoop(self.node_list["RingIcon4"], start_pos4, end_pos4, 0.5)

	
end

function MojieMainView:ClickMojie(index)
	MojieCtrl.Instance:OpenMoJieView(index)
end


