
-- 头像管理
AvatarManager = AvatarManager or BaseClass()
local AVATAR_URL = ""
local upload_url = GLOBAL_CONFIG.param_list.upload_url
if nil ~= upload_url and "" ~= upload_url then
	AVATAR_URL = upload_url
else
	AVATAR_URL = "http://117.120.62.67:9981/dev/"
end

function AvatarManager:__init()
	if AvatarManager.Instance ~= nil then
		print_error("AvatarManager to create singleton twice!")
	end
	AvatarManager.Instance = self

	self.avatar_key_list = {}						-- 头像key列表
	self.guild_avatar_key_list = {}					-- 公会头像key列表
	self.quest_list = {}							-- 请求列表
	self.avatar_frame_list = {}						-- 头像框key列表
	self.get_avatar_req_list = {}					-- 下载头像请求
end

function AvatarManager:__delete()
	AvatarManager.Instance = nil

	self.get_avatar_req_list = {}

	for k, v in pairs(self.quest_list) do
		AvatarManager.CancelAvatar(v)
	end
	self.quest_list = {}
end

function AvatarManager:SetAvatarKey(role_id, avatar_key_big, avatar_key_small, is_guild)
	if not role_id then
		return
	end
	if is_guild then
		if 0 == avatar_key_big and 0 == avatar_key_small then
			self.guild_avatar_key_list[role_id] = nil
		else
			self.guild_avatar_key_list[role_id] = {big = avatar_key_big, small = avatar_key_small,}
		end
	else
		if 0 == avatar_key_big and 0 == avatar_key_small then
			self.avatar_key_list[role_id] = nil
		else
			self.avatar_key_list[role_id] = {big = avatar_key_big, small = avatar_key_small,}
		end
	end
end

function AvatarManager:GetAvatarKey(role_id, is_big, is_guild)
	is_big = true
	local avatar_key = 0
	local avatar = self.avatar_key_list[role_id]
	if is_guild then
		avatar = self.guild_avatar_key_list[role_id]
	end
	if nil ~= avatar then
		avatar_key = is_big and avatar.big or avatar.small
	end
	return avatar_key
end

function AvatarManager:ChangeAvatarKey(role_id, avatar_key, is_big, is_guild)
	is_big = true
	local avatar = self.avatar_key_list[role_id]
	if is_guild then
		avatar = self.guild_avatar_key_list[role_id]
	end
	if nil ~= avatar then
		if is_big then
			avatar.big = avatar_key
		else
			avatar.small = avatar_key
		end
	end
end

function AvatarManager.IsGetDefAvatar(role_id)
	local main_id = PlayerData.Instance.role_vo.role_id
	if IS_ON_CROSSSERVER and role_id ~= main_id then
		return true
	else
		return false
	end
end

--通用接口设置（防止因为异步加载有时差，回调错误）
function AvatarManager:SetAvatar(role_id, raw_image_obj, default_image_obj, sex, prof, is_big)
	is_big = is_big or false
	if self:isDefaultImg(role_id) == 0 then
		raw_image_obj.gameObject:SetActive(false)
		default_image_obj.gameObject:SetActive(true)
		
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
		default_image_obj.image:LoadSprite(bundle, asset .. ".png")

		self:CancelSetAvatar(raw_image_obj)
	else
		local callback = function (path)
			if nil == self.get_avatar_req_list[raw_image_obj] then
				return
			end
			if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
				return
			end
			local avatar_path = path or AvatarManager.GetFilePath(role_id, is_big)
			raw_image_obj.raw_image:LoadURLSprite(avatar_path, function()
				if nil == self.get_avatar_req_list[raw_image_obj] then
					return
				end
				if raw_image_obj and not IsNil(raw_image_obj.gameObject) then
					raw_image_obj.gameObject:SetActive(true)
				end
				if default_image_obj and not IsNil(default_image_obj.gameObject) then
					default_image_obj.gameObject:SetActive(false)
				end
				self:CancelSetAvatar(raw_image_obj)
			end)
		end
		self.get_avatar_req_list[raw_image_obj] = callback
		self:GetAvatar(role_id, is_big, self.get_avatar_req_list[raw_image_obj])
	end
end

function AvatarManager:CancelSetAvatar(raw_image_obj)
	if nil ~= self.get_avatar_req_list[raw_image_obj] then
		self.get_avatar_req_list[raw_image_obj] = nil
	end
end

-- 获取头像
-- callback(path, is_plist)
function AvatarManager:GetAvatar(role_id, is_big, callback, guild_id, is_fixbug)
	is_big = true
	local url = AvatarManager.GetFileUrl(role_id, is_big)
	local is_guild = nil ~= guild_id
	if is_guild then
		url = AvatarManager.GetGuildFileUrl(role_id, guild_id, is_big)
	end

	if is_fixbug then
		url = AvatarManager.GetFileUrl(role_id, is_big)
		is_guild = false
	end

	-- self.role_id = role_id
	-- self.is_big = is_big
	local avatar_key = self:GetAvatarKey(role_id, is_big, is_guild)
	local path = AvatarManager.GetFilePath(role_id, is_big, is_guild)
	if AvatarManager.HasCache(avatar_key, path) then
		if callback then
			callback(path)
		end
		return nil
	end
	local function load_callback(url2, path2, is_succ)
		if is_succ then
			local new_avatar_key = AvatarManager.getFileKey(path2)
			self:ChangeAvatarKey(role_id, new_avatar_key, is_big, is_guild)
			if callback then
				callback(path2)
			end
		else
			if not is_fixbug then
				self:GetAvatar(role_id, is_big, callback, guild_id, true)
			end
		end
	end

	-- 通过http下载
	if not HttpClient:Download(url, path, load_callback) then
		return nil
	end
	self.quest_list[url] = {["url"] = url, ["load_callback"] = load_callback}
end

function AvatarManager.HasCache(avatar_key, path)
	local file = io.open(path, "r")
	if file then
		io.close(file)
		if avatar_key == AvatarManager.getFileKey(path) then
			return true
		end
	end
	return false
end

function AvatarManager:CancelUpdateAvatar(url)
	local quest = self.quest_list[url]
	if nil ~= quest then
		self.quest_list[url] = nil
		AvatarManager.CancelAvatar(quest)
	end
end

-- 取消获取
function AvatarManager.CancelAvatar(quest)
	if nil ~= quest then
		HttpClient:CancelDownload(quest.url, quest.load_callback)
	end
end

local AvatarList = {
	[1] = 1,
	[2] = 1,
	[3] = 0,
	[4] = 0
}

-- 获取默认头像 sex: 1男 0女
function AvatarManager.GetDefAvatar(prof, is_big, sex)
	is_big = is_big
	prof = prof or 1
	if prof <= 0 then
		return "", 0
	end

	prof = PlayerData.Instance:GetRoleBaseProf(prof)

	if AvatarList[prof] then
		sex = AvatarList[prof]
	end

	if is_big then
		return ResPath.GetRoleHeadBig(prof, sex)
	end
	return ResPath.GetRoleHeadSmall(prof, sex)
end

function AvatarManager.GetFileName(role_id, is_big)
	is_big = true
	return role_id .. (is_big and "_big.jpg" or "_small.jpg")
end

function AvatarManager.GetFilePath(role_id, is_big, is_guild)
	is_big = true
	local path = "%s/cache/avatar/%s"
	if is_guild then
		path = "%s/cache/guild_avatar/%s"
	end
	return string.format(path,
		UnityEngine.Application.persistentDataPath,
		AvatarManager.GetFileName(role_id, is_big))
end

function AvatarManager.GetFileUrl(role_id, is_big)
	is_big = true
	return AVATAR_URL .. "/avatar/" .. UserVo.GetServerId(role_id or 0) .. "/" .. AvatarManager.GetFileName(role_id, is_big)
end

function AvatarManager.getFileKey(path)
	return MD5.GetMD5FromFile(path)
end

--判断现在使用的头像是否是默认头像
function AvatarManager:isDefaultImg(role_id, is_guild)
	local avatar_key = 0	--如果没有收到任何的当前使用头像的返回，则认为使用了默认头像
	if role_id ~= nil then
		avatar_key = self:GetAvatarKey(role_id, false, is_guild)
	end
	return avatar_key
end

---------------------------公会头像相关--------------------------------------
-- guild_id与role_id可能重复，会导致玩家头像和公会头像互相影响，所以需要把玩家头像和公会头像分开存放
function AvatarManager.GetGuildFileUrl(role_id, guild_id, is_big)
	is_big = true
	return AVATAR_URL .. "/guild_avatar/" .. UserVo.GetServerId(role_id or 0) .. "/" .. AvatarManager.GetFileName(guild_id, is_big)
end

--------------------------头像框信息存储-------------------------------------
function AvatarManager:SetAvatarFrameKey(role_id, use_frame_id)
	if not role_id then
		return
	end
	self.avatar_frame_list[role_id] = use_frame_id
end

function AvatarManager:GetAvatarFrameKey(role_id)
	if not role_id then
		return -1
	end
	return self.avatar_frame_list[role_id]
end