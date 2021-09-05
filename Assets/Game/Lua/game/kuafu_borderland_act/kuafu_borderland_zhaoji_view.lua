KuaFuBorderlandZhaojiView = KuaFuBorderlandZhaojiView or BaseClass(BaseView)

local CloseViewTime = 5
function KuaFuBorderlandZhaojiView:__init()
	self.ui_config = {
		{"uis/views/kuafuborderland_prefab", "KFBorderlandZhaoJiView"},
	}

	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
end

function KuaFuBorderlandZhaojiView:__delete()

end

function KuaFuBorderlandZhaojiView:ReleaseCallBack()
	if self.close_view_timer then
		CountDown.Instance:RemoveCountDown(self.close_view_timer)
		self.close_view_timer = nil
	end
	
end

function KuaFuBorderlandZhaojiView:LoadCallBack()
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnBtnGo, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

end

function KuaFuBorderlandZhaojiView:OpenCallBack()
	self.node_list["Bg"].canvas_group.alpha = 0
	self:Flush()
end

function KuaFuBorderlandZhaojiView:CloseCallBack()
	if self.close_view_timer then
		CountDown.Instance:RemoveCountDown(self.close_view_timer)
		self.close_view_timer = nil
	end


end

function KuaFuBorderlandZhaojiView:OnFlush()
	if self.close_view_timer then
		CountDown.Instance:RemoveCountDown(self.close_view_timer)
		self.close_view_timer = nil
	end

	UITween.MoveShowPanel(self.node_list["Bg"] , Vector3(835, 0, 0), 0.5)
	UITween.AlpahShowPanel(self.node_list["Bg"] , true, 0.5, DG.Tweening.Ease.InExpo)

	self.close_view_timer = CountDown.Instance:AddCountDown(
		CloseViewTime, 1, function (elapse_time, total_time)
			if elapse_time < total_time then
				self.node_list["TxtTime"].text.text = string.format(Language.KFBorderland.TimeCloseView, ToColorStr(math.ceil(total_time - elapse_time), TEXT_COLOR.GREEN))
			else
				if self.close_view_timer then
					CountDown.Instance:RemoveCountDown(self.close_view_timer)
					self.close_view_timer = nil
				end
				self:Close()
			end
		end)


	self.zhaoji_info = KuaFuBorderlandData.Instance:GetKFBorderlandZhaojiData()
	if nil == self.zhaoji_info or nil == next(self.zhaoji_info) then
		self:Close()
		return
	end

	self.node_list["RoleName"].text.text = self.zhaoji_info.member_name
	local member_info = GuildData.Instance:GetGuildMemberInfo(self.zhaoji_info.member_uid)
	if member_info then
		-- print_error(member_info)
	end
	-- AvatarManager.Instance:SetAvatar(self.role_id, self.node_list["RawIcon"], self.node_list["DefIcon"], self.data.sex, self.data.prof, false)
end

function KuaFuBorderlandZhaojiView:OnBtnGo()
	if nil == self.zhaoji_info or nil == next(self.zhaoji_info) then
		return
	end

	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.zhaoji_info.member_scene_id then
		local callback = function()
			MoveCache.task_id = 0
			MoveCache.end_type = MoveEndType.Fight
			GuajiCtrl.Instance:MoveToPos(scene_id, self.zhaoji_info.member_pos_x, self.zhaoji_info.member_pos_y, 4, 2)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)	
	end
end

	-- self.sos_type =  MsgAdapter.ReadInt()
	-- self.member_uid =  MsgAdapter.ReadInt()
	-- self.member_name =  MsgAdapter.ReadStrN(32)
	-- self.member_scene_id =  MsgAdapter.ReadInt()
	-- self.member_pos_x =  MsgAdapter.ReadShort()
	-- self.member_pos_y =  MsgAdapter.ReadShort()
	-- self.enemy_uid =  MsgAdapter.ReadInt()
	-- self.enemy_name =  MsgAdapter.ReadStrN(32)
	-- self.enemy_camp =  MsgAdapter.ReadInt()
	-- self.enemy_guild_id =  MsgAdapter.ReadInt()
	-- self.enemy_guild_name =  MsgAdapter.ReadStrN(32)
