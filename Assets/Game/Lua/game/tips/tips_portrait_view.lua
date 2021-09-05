TipsPortraitView = TipsPortraitView or BaseClass(BaseView)
TipsPortraitView.HasOpen = false
function TipsPortraitView:__init()
	self.ui_config = {{"uis/views/tips/portraittips_prefab", "PortraitTip"}}
	self.avatar_path_big = ""
	self.avatar_path_small = ""
	self.uploading_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsPortraitView:LoadCallBack()
	self.node_list["BtnPhotoAlbum"].button:AddClickListener(BindTool.Bind(self.OnClickPhotoAlbum, self))
	self.node_list["BtnCamera"].button:AddClickListener(BindTool.Bind(self.OnClickCamera, self))
	self.node_list["BtnDefault"].button:AddClickListener(BindTool.Bind(self.OnClickDefault, self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.OnClickSure, self))
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function TipsPortraitView:ReleaseCallBack()
	self.avatar_path_big = ""
	self.avatar_path_small = ""
end

function TipsPortraitView:OpenCallBack()
	self:Flush()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level >= GameEnum.AVTAR_REMINDER_LEVEL then
		TipsPortraitView.HasOpen = true
	end
	RemindManager.Instance:Fire(RemindName.AvatarChange)
end

function TipsPortraitView:OnClickPhotoAlbum()
	ImagePicker.PickFromPhoto(256, 32, function(pickPath, scaledPath)
		print_log("Pick from photo album: ", pickPath, scaledPath)
		self:SelectAvatarCallback(pickPath, scaledPath)
	end)
	self.default_ptr_flag = false
end

function TipsPortraitView:OnClickCamera()
	ImagePicker.PickFromCamera(256, 32, function(pickPath, scaledPath)
		print_log("Pick from photo album: ", pickPath, scaledPath)
		self:SelectAvatarCallback(pickPath, scaledPath)
	end)
	self.default_ptr_flag = false
end

function TipsPortraitView:OnClickDefault()
	self.node_list["PortraitRaw"]:SetActive(false)
	self.node_list["Portrait"]:SetActive(true)
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local bundle, asset = AvatarManager.GetDefAvatar(game_vo.prof, true, game_vo.sex)
	self.node_list["Portrait"].image:LoadSprite(bundle, asset)
	self.default_ptr_flag = true
end

function TipsPortraitView:OnClickSure()
	if (self.avatar_path_big == "" or self.avatar_path_small == "") and not self.default_ptr_flag then
		self:Close()
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = vo.role_id
	if IS_ON_CROSSSERVER then
		role_id = CrossServerData.Instance:GetRoleId()
	end
	if self.default_ptr_flag then
		AvatarManager.Instance:SetAvatarKey(role_id, 0, 0)
		PlayerCtrl.Instance:SendSetAvatarTimeStamp(0, 0)
		GlobalEventSystem:Fire(ObjectEventType.HEAD_CHANGE)
		self:Close()
		return
	end
	local picture_use_type = UtilU3d.IsFileInfoLimit(self.avatar_path_big, 2097152)
	if picture_use_type == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.NotPicture)
	    return
	elseif picture_use_type == 2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.PictureNotTooLarge)
	    return
	end

	--先设置头像，不等协议返回
	GlobalEventSystem:Fire(ObjectEventType.TEMP_HEAD_CHANGE, self.avatar_path_big)

	local url_big = AvatarManager.GetFileUrl(role_id, true)
	local callback_big = BindTool.Bind1(self.UploadCallback, self)
	self.uploading_list[url_big] = {url=url_big, path=self.avatar_path_big, callback=callback_big}
	if not HttpClient:Upload(url_big, self.avatar_path_big, callback_big) then
		self:CancelUpload()
		print("上传失败", url_big, self.avatar_path_big)
		return
	end

	local url_small = AvatarManager.GetFileUrl(role_id, false)
	local callback_small = BindTool.Bind1(self.UploadCallback, self)
	self.uploading_list[url_small] = {url=url_small, path=self.avatar_path_small, callback=callback_small}
	if not HttpClient:Upload(url_small, self.avatar_path_small, callback_small) then
		self:CancelUpload()
		print("上传失败", url_small, self.avatar_path_small)
		return
	end

	self.uploading_count = 2
	self:Close()
	print_log("点击确定")
end

function TipsPortraitView:OnClickClose()
	self:Close()
end

-- 上传头像回调
function TipsPortraitView:UploadCallback(url, path, is_succ, data)
	print(" TipsPortraitView:UploadCallback ####### ",url, path, is_succ)
	self.uploading_count = self.uploading_count - 1
	if not is_succ then
		self:CancelUpload()
		print(" 上传失败 UploadCallback ")
		return
	end

	if self.uploading_count <= 0 then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local avatar_key_big = AvatarManager.getFileKey(self.avatar_path_big)
		local avatar_key_small = AvatarManager.getFileKey(self.avatar_path_small)
		print("avatar_key_big", avatar_key_big, "avatar_key_small", avatar_key_small)
		PlayerCtrl.Instance:SendSetAvatarTimeStamp(avatar_key_big, avatar_key_small)
		AvatarManager.Instance:SetAvatarKey(role_id, avatar_key_big, avatar_key_small)
	end
end

-- 选择头像回调
function TipsPortraitView:SelectAvatarCallback(pickPath, scaledPath)
	if pickPath == nil or scaledPath == nil or pickPath == "" then
		print_log("选择路径为空  pickPath",  pickPath, "scaledPath", scaledPath)
		return
	end
	self.avatar_path_big = pickPath
	self.avatar_path_small = scaledPath
	self.node_list["PortraitRaw"].raw_image:LoadURLSprite(pickPath, function()
		self.node_list["PortraitRaw"]:SetActive(true)
		self.node_list["Portrait"]:SetActive(false)
	end)
end

-- 取消上传
function TipsPortraitView:CancelUpload()
	for k, v in pairs(self.uploading_list) do
		HttpClient:CancelUpload(v.url, v.callback)
	end

	self.uploading_count = 0
	self.uploading_list = {}
end

function TipsPortraitView:OnFlush(param_t)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:SetAvatar(vo.role_id, self.node_list["PortraitRaw"], self.node_list["Portrait"], vo.sex, vo.prof, true)
	if vo.is_change_avatar == 0 then
		self.node_list["TxtShowTips"]:SetActive(true)
	else
		self.node_list["TxtShowTips"]:SetActive(false)
	end
end