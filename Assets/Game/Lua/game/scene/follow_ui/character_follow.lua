CharacterFollow = CharacterFollow or BaseClass(FollowUi)

function CharacterFollow:__init()
	self.obj_type = nil
	self.title_list = {}
	self.title_eff_list = {}
	self.is_show_title = true
	self.is_show_special_title = false
	self.special_title = 0
	self.has_title = false
	self.has_guild = false
	self.has_lover = false
	self.now_title_id = 0

	self.title_switch = false
end

function CharacterFollow:__delete()
	self:RemoveTitleList()
end

function CharacterFollow:OnRootCreateCompleteCallback(gameobj)
	FollowUi.OnRootCreateCompleteCallback(self, gameobj)

	self.hpbar:CreateRootNode(self.follow_hp_prefab_name, self.obj_type, self.node_list["Follow"].gameObject, function ()
		self:SetNameTextPosition()
	end)
end

function CharacterFollow:UpdateSetTitle()
	if nil == self.title_info or nil == self.root_node then
		return
	end
	self.has_title = false

	local index = self.title_info.index
	local title_id = self.title_info.title_id

	if self.title_list[index] ~= nil then
		ResPoolMgr:Release(self.title_list[index].gameObject)
		if TitleData.Instance ~= nil then
			TitleData.Instance:ReleaseTitleEff(self.title_list[index])
		end
		self.title_list[index] = nil
		if nil ~= self.title_eff_list[index] then
			ResPoolMgr:Release(self.title_eff_list[index].gameObject)
			self.title_eff_list[index] = nil
		end
	end

	if title_id == nil or title_id == 0 then return end
	self.has_title = true
	local asset_bundle, asset_name = ResPath.GetTitleModel(title_id)
	if not asset_bundle or not asset_name then
		return
	end

	self.now_title_id = title_id

	ResPoolMgr:GetDynamicObjAsyncInQueue(asset_bundle, asset_name, BindTool.Bind(self.OnTitleLoadComplete, self, index))
end

function CharacterFollow:OnTitleLoadComplete(index, obj)
	if IsNil(obj) or not self.root_node then
		ResPoolMgr:Release(obj)
		return
	end
	if self.title_list[index] ~= nil then
		if TitleData.Instance ~= nil then
			TitleData.Instance:ReleaseTitleEff(self.title_list[index])
		end
		ResPoolMgr:Release(self.title_list[index].gameObject)
		self.title_list[index] = nil
		if nil ~= self.title_eff_list[index] then
			ResPoolMgr:Release(self.title_eff_list[index].gameObject)
			self.title_eff_list[index] = nil
		end
	end
	self.title_list[index] = U3DObject(obj)

	if nil ~= self.title_list[index] then
		local the_follow = self.node_list["Follow"].transform
		self.title_list[index].gameObject.transform:SetParent(the_follow, false)
		local temp = index
		if temp == 0 then temp = 1 end
		local space = TitleData.Instance:IsLingPoTitle(self.now_title_id) and 0 or 30
		if self.has_guild then
			space = space + 30
		end
		if self.has_lover then
			space = space + 30
		end
		if self.special_title_img then
			space = space + 50
		end

		self.title_list[index].gameObject.transform:SetLocalPosition(0, temp * 50 + space, 0)
		if self.scale then
			self.title_list[index].gameObject.transform:SetLocalScale(self.scale[1], self.scale[2], self.scale[3])
		end
		local cs_equip_spec_active = self.vo and self.vo.combine_server_equip_active_special or 0
		if cs_equip_spec_active > 0 and self.title_eff_list[index] == nil then
			-- local asset_bundle, asset_name = ResPath.GetTitleEffect("UI_title")
			-- ResPoolMgr:GetDynamicObjAsync(asset_bundle, asset_name,
			-- 	BindTool.Bind(self.OnTitleEffectLoadComplete, self, index))
		elseif self.title_eff_list[index] then
			self.title_eff_list[index].gameObject:SetActive(cs_equip_spec_active > 0)
		end
	end
	local switch = self:IsNeedVisible(index)

	if self.obj_type == SceneObjType.MainRole then
		TitleData.Instance:LoadTitleEff(self.title_list[index], self.now_title_id, true)	
	end

	self.title_list[index].gameObject:SetActive(switch)
	-- self.title_switch = switch 					-- 先屏蔽一下
end

function CharacterFollow:OnTitleEffectLoadComplete(index, obj)
	if IsNil(obj) or not self.root_node then return end
	if nil ~= self.title_eff_list[index] then
		ResPoolMgr:Release(self.title_eff_list[index].gameObject)
		self.title_eff_list[index] = nil
	end
	self.title_eff_list[index] = U3DObject(obj)
	if self.title_list[index] and self.title_eff_list[index] then
		self.title_eff_list[index].gameObject.transform:SetParent(self.title_list[index].gameObject.transform, false)
	end
end

function CharacterFollow:SetLocalScale(scale)
	self.scale = scale
	for k,v in pairs(self.title_list) do
		v.gameObject.transform:SetLocalScale(self.scale[1], self.scale[2], self.scale[3])
	end
end

function CharacterFollow:CreateTitleEffect(vo)
	if nil == vo then return end
	self.vo = vo
	local selected_title = self:FilterTitle(self.vo.used_title_list)
	self.has_guild = vo.guild_id > 0
	self.has_lover = vo.lover_name and  vo.lover_name ~= ""
	if not selected_title then return end
	table.sort(selected_title, function(x,y)
			local a = TitleData.Instance:GetTitleCfg(x)
			local b = TitleData.Instance:GetTitleCfg(y)
			if a ~= nil and b ~= nil then
				return a.title_show_level < b.title_show_level
			end
		end)
	for i = 1, 4 do
		self:SetTitle(i, selected_title[i] or 0)
	end

	if self.is_show_special_title then
		self:SetTitle(0, self.special_title)
	end
end

-- 过滤称号
function CharacterFollow:FilterTitle(used_title_list)
	return used_title_list
end

function CharacterFollow:AchieveTitleFilter(selected_title, chengjiu_title_level)
	local chengjiu_title = 10000 + chengjiu_title_level - 1
	if chengjiu_title < 10000 then
		return
	end
	table.insert(selected_title, 1, chengjiu_title)
end

function CharacterFollow:RemoveTitleList()
	for k,v in pairs(self.title_list) do
		if v then
			if TitleData.Instance ~= nil then
				TitleData.Instance:ReleaseTitleEff(v)
			end
			ResPoolMgr:Release(v.gameObject)
			v = nil
		end
	end
	for k,v in pairs(self.title_eff_list) do
		ResPoolMgr:Release(v.gameObject)
	end
	self.title_eff_list = {}
end

function CharacterFollow:SetTitleVisible(is_visible)
	self.is_show_title = is_visible
	for k,v in pairs(self.title_list) do
		if v then
			local switch = self:IsNeedVisible(k)
			v.gameObject:SetActive(switch)
		end
	end
end

function CharacterFollow:ChangeSpecailTitle(res_id)
	if not res_id or res_id == 0 then
		self.is_show_special_title = false
		self.special_title = 0
	else
		self.is_show_special_title = true
		self.special_title = res_id
		self:SetTitle(0, res_id)
	end
	self:SetTitleVisible(self.is_show_title)
end

function CharacterFollow:IsNeedVisible(index)
	if index == 0 then
		if self.is_show_special_title then
			return true
		end
	else
		if self.is_show_title and not self.is_show_special_title then
			return true
		end
	end
	return false
end

function CharacterFollow:SetTemporaryEffectObj(bundle, asset, pos_x, pos_y)
	local space = 0
	if self.has_title then
		space = space + 80
	end
	if self.has_guild then
		space = space + 30
	end
	if self.has_lover then
		space = space + 30
	end
	if asset == "Title_tf_chicken" then
		space = space + 60
	end
	pos_y = pos_y + space

	FollowUi.SetTemporaryEffectObj(self, bundle, asset, pos_x, pos_y)
end
