MarryNoticeView = MarryNoticeView or BaseClass(BaseView)

function MarryNoticeView:__init()
	self.ui_config = {{"uis/views/marrynoticeview_prefab", "MarryNoticeView"}}	
	self.play_audio = true
end

function MarryNoticeView:__delete()

end

function MarryNoticeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnBlessing"].button:AddClickListener(BindTool.Bind(self.OnClickBlessing, self))
	self.node_list["BtnFlower"].button:AddClickListener(BindTool.Bind(self.OnClickFlower, self))
	self.role_id = 0
end

function MarryNoticeView:ReleaseCallBack()
	
end

function MarryNoticeView:OpenCallBack()

end

function MarryNoticeView:CloseCallBack()

end

function MarryNoticeView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "info" then
			self:FlushAvatar(v)
			self.role_id = v.uid1 or 0
			self.node_list["TxtShowBless"].text.text = string.format(Language.MarryNotice.Congratulation, v.name1, v.name2, v.server_marry_times)
		end
	end
end

function MarryNoticeView:FlushAvatar(info)
	--AvatarManager.Instance:SetAvatar(info.uid1, self.node_list["RawImage1"], self.node_list["DefaultImage1"], self.node_list["DefaultImage1"], GameEnum.MALE, info.prof1, true)
	--AvatarManager.Instance:SetAvatar(info.uid2, self.node_list["RawImage2"], self.node_list["DefaultImage2"], self.node_list["DefaultImage2"], GameEnum.FEMALE, info.prof2, true)
	self:SetAvatar(info.uid1, 1, 1, GameEnum.MALE, info.prof1, true)
	self:SetAvatar(info.uid2, 2, 2, GameEnum.FEMALE, info.prof2, true)

end

function MarryNoticeView:SetAvatar(role_id, imageindex, defaultIndex, sex, prof, is_big)
	if nil == role_id then return end
	is_big = is_big or false
	AvatarManager.Instance:SetAvatar(role_id, self.node_list["RawImage" .. imageindex], self.node_list["DefaultImage" .. defaultIndex], sex, prof, is_big)
end

-- 点击祝福
function MarryNoticeView:OnClickBlessing()
	MarryNoticeCtrl.Instance:SendMarryZhuheReq(self.role_id, MARRY_ZHUHE_TYPE.MARRY_ZHUHE_TYPE0)
	self:Close()
end

-- 点击送花
function MarryNoticeView:OnClickFlower()
	local role_id = self.role_id
	local yes_func = function()
		MarryNoticeCtrl.Instance:SendMarryZhuheReq(role_id, MARRY_ZHUHE_TYPE.MARRY_ZHUHE_TYPE1)
		self:Close()
	end
	local describe = string.format(Language.Marriage.SendFlower, MarryNoticeData.Instance:GetFlowerPrice())
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end
