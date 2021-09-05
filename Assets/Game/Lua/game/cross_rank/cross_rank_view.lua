CrossRankView = CrossRankView or BaseClass(BaseView)
function CrossRankView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
		{"uis/views/crossrankview_prefab","CrossRankView"},	
	}
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
end

function CrossRankView:LoadCallBack()
	self.display = self.node_list["Display"]
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.rank_item_list = {}
	self.rank_list_view = self.node_list["RankListView"]
	self.node_list["ChengZhuTitle"].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, 1))
	self.node_list["ChengYuanTitle"].button:AddClickListener(BindTool.Bind(self.ClickTitle, self, 2))
	local rank_list_delegate = self.rank_list_view.list_simple_delegate
	rank_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfRankCells, self)
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankCell, self)

	-- self.tab_item_list = {}
	-- self.tab_list_view = self.node_list["TabListView"]
	-- local tab_list_delegate = self.tab_list_view.list_simple_delegate
	-- tab_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfTabCells, self)
	-- tab_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTabCell, self)

	self.my_rank = CrossRankRankItem.New(self.node_list["MyRank"])
	self.my_rank:SetClickCallBack(BindTool.Bind(self.OnClickRankCell, self))
	self.my_rank:SetIndex(0)		-- 自己的榜单信息默认index为0

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	for i = 1, 4 do
		self.node_list["Toggle"..i].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickToggleTab, self, i))
	end
	self.cur_index = 1
end

function CrossRankView:ReleaseCallBack()
	self.rank_list_view = nil
	self.tab_list_view = nil
	for k,v in pairs(self.rank_item_list) do
		v:DeleteMe()
	end
	-- self.rank_item_list = {}
	-- for k,v in pairs(self.tab_item_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.tab_item_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.display = nil

	if self.my_rank then
		self.my_rank:DeleteMe()
		self.my_rank = nil
	end
end

function CrossRankView:CloseCallBack()
	self.node_list["Toggle1"].toggle.isOn = true
end

function CrossRankView:OpenCallBack()
	-- 请求第一个标签的信息
	local type_list = CrossRankData.Instance:GetCrossRankTypeList()
	self.tab_index =  CrossRankData.Instance:GetSelectTableIndex()
	if next(type_list) ~= nil and self.tab_index == 1 then
		CrossRankCtrl.Instance:SendGetPersonCrossRankList(type_list[self.tab_index] or 0)
		CrossRankCtrl.Instance:SendGetSpecialRankValue(type_list[self.tab_index] or 0)
	end
	
	self.rank_index = -1
	self.cur_index = 1
	-- self:SetTabListHL(self.tab_index)
	self.node_list["Toggle".. self.tab_index].toggle.isOn = true
	self:FlushContentText()
	self.node_list["TextDes1"]:SetActive(true)
end

function CrossRankView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "rank_info" then
			self.rank_list_view.scroller:ReloadData(0)
			self:FlushMyRankInfo()
			self:FlushFashionModel()
			self:FlushContentText()
		elseif k == "model" then
			self:FlushPersonModel()
		end
	end
end

function CrossRankView:FlushContentText()
	local type_list = CrossRankData.Instance:GetCrossRankTypeList()
	if next(type_list) == nil then
		return
	end

	local rank_type = type_list[self.tab_index]
	local reward_date = CrossRankData.Instance:GetRewardDateByTime(rank_type)
	if #reward_date == 2 then
		-- self.node_list["TextDes1"].text.text = string.format(Language.CrossRank.CrossRankRewardTextUp, Language.CrossRank.CrossRankTypeFullName[rank_type])
		self.node_list["TextDes1"].text.text = Language.CrossRank.CrossRankTypeFullName[rank_type]
		if reward_date[1] == 0 then
			reward_date[1] = 7
		elseif reward_date[1] == 1 then
			reward_date[1] = 8
		end
		if reward_date[2] == 0 then
			reward_date[2] = 7
		elseif reward_date[2] == 1 then
			reward_date[2] = 8
		end
		if reward_date[1] > 1 then
			reward_date[1] = reward_date[1] - 1
		end
		if reward_date[2] > 1 then
			reward_date[2] = reward_date[2] - 1
		end
		local day1, day2 = reward_date[1], reward_date[2]
		if reward_date[1] > reward_date[2] then
			day1, day2 = reward_date[2], reward_date[1]		
		end
			
		self.node_list["TextDes2"].text.text = string.format(Language.CrossRank.CrossRankRewardTextDown, Language.Common.DayToChs[day1], Language.Common.DayToChs[day2])
	end
end

function CrossRankView:FlushMyRankInfo()
	local my_info_data = CrossRankData.Instance:GetPrivateCrossRankInfo()
	self.my_rank:SetData(my_info_data)
end

-- 时装模型
function CrossRankView:FlushFashionModel()
	local cross_rank_type_list = CrossRankData.Instance:GetCrossRankTypeList()
	if next(cross_rank_type_list) == nil then
		return
	end

	rank_type = cross_rank_type_list[self.tab_index] or 0
	self:ClearModel()
	if rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
		-- local game_vo = GameVoManager.Instance:GetMainRoleVo()
	 --    if game_vo then
	 --      self.model:SetModelResInfo(game_vo, false, true, true, nil, nil, nil, true)
	 --    end
	 	self.model:ClearModel()
		self.node_list["Display"]:SetActive(false)
		self.node_list["ChengZhuTitle"]:SetActive(true)
		self.node_list["ChengYuanTitle"]:SetActive(true)
	else
		self.node_list["Display"]:SetActive(true)
		self.node_list["ChengZhuTitle"]:SetActive(false)
		self.node_list["ChengYuanTitle"]:SetActive(false)
		local fashion_item = CrossRankData.Instance:GetFashionRewardByType(rank_type)
		ItemData.ChangeModel(self.model, fashion_item)
	end
	-- self.node_list["ChengZhuTitle"]:SetActive(rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS)
	self:SetTitleImage(self.rank_index, rank_type)
end

function CrossRankView:SetTitleImage(rank_index, rank_type)
	local current_title_id, chengyuan_title_id = CrossRankData.Instance:GetRewardTitle(rank_index, rank_type)
	if current_title_id then
		local bundle, asset = ResPath.GetTitleIcon(current_title_id)
		if self.node_list["ChengZhuTitle"].image then
			self.node_list["ChengZhuTitle"].image:LoadSprite(bundle, asset, function()
				-- self.node_list["ChengZhuTitle"]:SetActive(rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS)
				self.node_list["ChengZhuTitle"].image:SetNativeSize()
			end)
			TitleData.Instance:LoadTitleEff(self.node_list["ChengZhuTitle"], current_title_id, true)
		end
	end
	if chengyuan_title_id then
		local bundle, asset = ResPath.GetTitleIcon(chengyuan_title_id)
		if self.node_list["ChengYuanTitle"].image then
			self.node_list["ChengYuanTitle"].image:LoadSprite(bundle, asset, function()
				-- self.node_list["ChengYuanTitle"]:SetActive(rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS)
				self.node_list["ChengYuanTitle"].image:SetNativeSize()
			end)
			TitleData.Instance:LoadTitleEff(self.node_list["ChengYuanTitle"], chengyuan_title_id, true)
		end
	end
end

function CrossRankView:ClearModel()
	if self.model then
		self.model.display:SetRotation(Vector3(0, 0, 0))

		local halo_part = self.model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = self.model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = self.model.draw_obj:GetPart(SceneObjPart.Wing)
		local cloak_part = self.model.draw_obj:GetPart(SceneObjPart.Cloak)
		local head_part = self.model.draw_obj:GetPart(SceneObjPart.Head)
		local toushi_part = self.model.draw_obj:GetPart(SceneObjPart.TouShi)
		local waist_part = self.model.draw_obj:GetPart(SceneObjPart.Waist)
		local qilinbi_part = self.model.draw_obj:GetPart(SceneObjPart.QilinBi)
		local mask_part = self.model.draw_obj:GetPart(SceneObjPart.Mask)
		local tail_part = self.model.draw_obj:GetPart(SceneObjPart.Tail)
		local shouhuan_part = self.model.draw_obj:GetPart(SceneObjPart.ShouHuan)

		if halo_part then
			halo_part:RemoveModel()
		end
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
		if cloak_part then
			cloak_part:RemoveModel()
		end
		if head_part then
			head_part:RemoveModel()
		end
		if toushi_part then
			toushi_part:RemoveModel()
		end
		if waist_part then
			waist_part:RemoveModel()
		end
		if qilinbi_part then
			qilinbi_part:RemoveModel()
		end
		if mask_part then
			mask_part:RemoveModel()
		end
		if tail_part then
			tail_part:RemoveModel()
		end
		if shouhuan_part then
			shouhuan_part:RemoveModel()
		end
	end
end

-- 查询人物模型
function CrossRankView:FlushPersonModel()
	local role_info = CheckData.Instance:GetRoleInfo()

	if role_info.shizhuang_part_list == nil then
		return
	end
	self.node_list["ChengZhuTitle"]:SetActive(false)
	self.node_list["ChengYuanTitle"]:SetActive(false)
	local info = TableCopy(role_info)
	info.appearance = {}
	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
	info.appearance.fashion_wuqi = wuqi_id
	info.appearance.fashion_body = fashion_id
	
	self:ClearModel()
	self.model:SetModelResInfo(info, false, false, true)
	self:SetWaistModel()
	self:SetHeadModel()
	self:SetArmModel()
	self:SetMaskResid()
	self.node_list["Display"]:SetActive(true)

	local cross_rank_type_list = CrossRankData.Instance:GetCrossRankTypeList()
	if next(cross_rank_type_list) == nil then
		return
	end
	local rank_type = cross_rank_type_list[self.tab_index] or 0
	-- self.node_list["ChengZhuTitle"]:SetActive(rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS)
	self:SetTitleImage(self.rank_index, rank_type)
end

function CrossRankView:SetWaistModel()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.waist_info then
		if role_info.waist_info.capability > 0 then
			local grade_info = WaistData.Instance:GetWaistGradeCfgInfoByGrade(role_info.waist_info.grade)
			if nil == grade_info then
				return
			end

			--对应资源数据
			local image_info = WaistData.Instance:GetWaistImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_info then
				return
			end
			self.model:SetWaistResid(image_info.res_id)
		end
	end
end

function CrossRankView:SetHeadModel()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.head_info then
		if role_info.head_info.capability > 0 then
			local grade_info = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(role_info.head_info.grade)
			if nil == grade_info then
				return
			end

			--对应资源数据
			local image_info = TouShiData.Instance:GetTouShiImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_info then
				return
			end
			self.model:SetTouShiResid(image_info.res_id)
		end
	end
end

function CrossRankView:SetArmModel()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.arm_info then
		if role_info.arm_info.capability > 0 then
			local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(role_info.arm_info.grade)
			if nil == grade_info then
				return
			end
			--对应资源数据
			local image_info = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_info then
				return
			end
			self.model:SetQilinBiResid(image_info["res_id" .. role_info.sex], role_info.sex)
		end
	end
end

function CrossRankView:SetMaskResid()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.mask_info then
		if role_info.mask_info.capability > 0 then
			local grade_info = MaskData.Instance:GetMaskGradeCfgInfoByGrade(role_info.mask_info.grade)
			if nil == grade_info then
				return
			end
			local res_id = MaskData.Instance:GetResIdByImageId(grade_info.image_id)
			self.model:SetMaskResid(res_id)
		end
	end
end

function CrossRankView:OnClickClose()
	self:Close()
end

-- 榜单Item
function CrossRankView:GetNumberOfRankCells()
	local rank_list = CrossRankData.Instance:GetCrossRankList()
	local rank_num = math.min(#rank_list, 20)
	return rank_num
end

function CrossRankView:RefreshRankCell(cell, data_index)
	data_index = data_index + 1
	local rank_cell = self.rank_item_list[cell]
	if not rank_cell then
		rank_cell = CrossRankRankItem.New(cell.gameObject)
		self.rank_item_list[cell] = rank_cell
		rank_cell:SetClickCallBack(BindTool.Bind(self.OnClickRankCell, self))
	end
	rank_cell:SetIndex(data_index)
	local data = CrossRankData.Instance:GetCrossRankInfoByIndex(data_index)
	rank_cell:SetData(data)
	rank_cell:SetRankHL(self.rank_index)
end

function CrossRankView:ClickTitle(index)
	local cross_rank_type_list = CrossRankData.Instance:GetCrossRankTypeList()
	local rank_type = cross_rank_type_list[self.cur_index ] or 0
	local current_title_id, chengyuan_title_id = CrossRankData.Instance:GetRewardTitleItemId(rank_type)
	local data = {}
	if index == 1 then
		data = {item_id = current_title_id, is_bind = 0, num = 1}
	elseif index == 2 then
		data = {item_id = chengyuan_title_id, is_bind = 0, num = 1}
	end
	TipsCtrl.Instance:OpenItem(data)
end

function CrossRankView:SetRankListHL()
	for k,v in pairs(self.rank_item_list) do
		v:SetRankHL(self.rank_index)
	end
	self.my_rank:SetRankHL(self.rank_index)
end

function CrossRankView:OnClickRankCell(cell)
	if self.rank_index == cell:GetIndex() then
		return
	end

	local index = cell:GetIndex()
	self.rank_index = index
	self:SetRankListHL(self.rank_index)

	local data = cell:GetData()
	if data == nil then
		return
	end

	-- 请求角色查询
	if CrossRankData.Instance:GetIsCoupleRank() == false then
		CheckCtrl.Instance:SendCrossQueryRoleInfo(data.plat_type, data.uid)
		CheckData.Instance:SetCurrentUserId(data.uid)
		self.node_list["TextDes1"]:SetActive(false)
	end
end

function CrossRankView:OnClickToggleTab(index)
	if self.cur_index == index then return end
	self.cur_index = index
	self.tab_index = index
	local cross_rank_type_list = CrossRankData.Instance:GetCrossRankTypeList()
	local rank_type = cross_rank_type_list[index] or 0

	CrossRankCtrl.Instance:SendGetPersonCrossRankList(rank_type)
	CrossRankCtrl.Instance:SendGetSpecialRankValue(rank_type)

	self.node_list["TextDes1"]:SetActive(true)
	self.rank_index = -1
	self:SetRankListHL(self.rank_index)
end

-- 标签Item
function CrossRankView:GetNumberOfTabCells()
	return #CrossRankData.Instance:GetCrossRankTypeList()
end

function CrossRankView:RefreshTabCell(cell, data_index)
	data_index = data_index + 1
	local tab_cell = self.tab_item_list[cell]
	if not tab_cell then
		tab_cell = CrossRankTabItem.New(cell.gameObject)
		self.tab_item_list[cell] = tab_cell
		tab_cell:SetClickCallBack(BindTool.Bind(self.OnClickTabCell, self))
	end
	tab_cell:SetIndex(data_index)
	local cross_rank_type_list = CrossRankData.Instance:GetCrossRankTypeList()
	local data = {
		rank_type = cross_rank_type_list[data_index] or 0,
	}
	tab_cell:SetData(data)
	tab_cell:SetTabHL(self.tab_index)
end

function CrossRankView:SetTabListHL()
	for k,v in pairs(self.tab_item_list) do
		v:SetTabHL(self.tab_index)
	end
end

function CrossRankView:OnClickTabCell(cell)
	if self.tab_index == cell:GetIndex() then
		return
	end

	self.tab_index = cell:GetIndex()
	self:SetTabListHL(self.tab_index)

	local data = cell:GetData()
	if data ~= nil then
		CrossRankCtrl.Instance:SendGetPersonCrossRankList(data.rank_type)
		CrossRankCtrl.Instance:SendGetSpecialRankValue(data.rank_type)
	end
	self.node_list["TextDes1"]:SetActive(true)
	self.rank_index = -1
	self:SetRankListHL(self.rank_index)
end

----------------------------------- 跨服排行榜榜单Item -----------------------------------
CrossRankRankItem = CrossRankRankItem  or BaseClass(BaseCell)

function CrossRankRankItem:__init()
	self.person_module_list = {}
	for i = 1, 2 do
		local temp_person_info = {}
		temp_person_info.name = self.node_list["NameText"..i]
		temp_person_info.hlname = self.node_list["HLNameText"..i]
		-- temp_person_info.show_image = self.node_list["ShowImage"..i]
		temp_person_info.image_res = self.node_list["IconImage"..i]
		temp_person_info.raw_img_obj = self.node_list["RawImage"..i]
		self.person_module_list[i] = temp_person_info
	end

	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["ItemCell"])
	self.reward_item:SetShowOrangeEffect(true)

	self.node_list["MyRankInfo"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function CrossRankRankItem:__delete()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

	self.person_module_list = {}
end

function CrossRankRankItem:SetIndex(index)
	self.index = index
end

function CrossRankRankItem:SetData(data)
	if data == nil then
		return
	end
	self.data = data
	-- 名次
	local rank_index = self.index == 0 and CrossRankData.Instance:GetSelfRankNum() or self.index
	self.node_list["IsTopThree"]:SetActive(false)
	if rank_index > 3 then
		self.node_list["TextIsTopThree"].text.text = rank_index
	elseif rank_index == 0 then
		self.node_list["TextIsTopThree"].text.text = Language.CrossRank.NotOnTheListText
	else
		self.node_list["IsTopThree"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(rank_index)
		self.node_list["IsTopThree"].image:LoadSprite(bundle, asset)
	end

	local sever_name = LoginData.Instance:GetShowServerNameById(data.server_id) or ""
	self.node_list["ServerText"].text.text = sever_name
	self.node_list["HLServerText"].text.text = sever_name
	local str = Language.CrossRank.CrossRankRankText[data.rank_type] or ""
	self.node_list["AddText"].text.text = str .. tostring(data.rank_value)

	if next(self.person_module_list) == nil then
		return
	end

	-- 设置姓名头像信息
	if data.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
		self:SetGuildInfo(self.person_module_list[1])
		self.node_list["IsCoupleRank"]:SetActive(false)
		self.person_module_list[2].name:SetActive(false)
		self.person_module_list[2].hlname:SetActive(false)
	else
		local is_couple_rank = CrossRankData.Instance:GetIsCoupleRank(self.index == 0)
		self.node_list["IsCoupleRank"]:SetActive(is_couple_rank and self.data.is_married)
		self:SetPersonInfo(self.person_module_list[1], false)
		self.person_module_list[2].name:SetActive(false)
		self.person_module_list[2].hlname:SetActive(false)
		if is_couple_rank and self.data.is_married then
			self:SetPersonInfo(self.person_module_list[2], true)
			self.person_module_list[2].name:SetActive(true)
			self.person_module_list[2].hlname:SetActive(true)
		end
	end

	-- 奖励
	local reward_item_id = CrossRankData.Instance:GetRewardByRankNum(data.rank_type, rank_index)
	if reward_item_id ~= 0 then
		self.reward_item:SetActive(true)
		self.reward_item:SetData({item_id = reward_item_id})
	else
		self.reward_item:SetActive(false)
	end

end

-- 设置个人信息（头像姓名）
function CrossRankRankItem:SetPersonInfo(person_module_list, is_lover_info)
	if person_module_list == nil then
		return
	end

	-- local show_image = person_module_list.raw_img_obj
	local raw_image_obj = person_module_list.raw_img_obj
	local image_res = person_module_list.image_res

	local role_id = is_lover_info and self.data.lover_info.uid or self.data.uid or 0
	local sex = is_lover_info and self.data.lover_info.sex or self.data.sex or 0
	local prof = is_lover_info and self.data.lover_info.prof or self.data.prof or 0

	local function download_callback(path)
		if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
			return
		end
		local uid = is_lover_info and self.data.lover_info.uid or self.data.uid or 0
		if uid ~= role_id then
			return
		end
		image_res:SetActive(false)
		raw_image_obj:SetActive(true)
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		raw_image_obj.raw_image:LoadSprite(avatar_path,
		function()
			local uid = is_lover_info and self.data.lover_info.uid or self.data.uid or 0
			if uid ~= role_id then
				return
			end
		end)
	end
	image_res:SetActive(true)
	raw_image_obj:SetActive(false)

	CommonDataManager.NewSetAvatar(role_id, raw_image_obj, image_res, raw_image_obj, sex, prof, false, download_callback)

	person_module_list.name.text.text = (is_lover_info and self.data.lover_info.name or self.data.name)
	person_module_list.hlname.text.text = (is_lover_info and self.data.lover_info.name or self.data.name)
end

-- 设置仙盟信息（头像姓名）
function CrossRankRankItem:SetGuildInfo(person_module_list)
	if person_module_list == nil then
		return
	end
	local raw_image_obj = person_module_list.raw_img_obj
	local image_res = person_module_list.image_res
	local guild_id = self.data.guild_id or 0
	local role_id = self.data.uid or 0
	person_module_list.name.text.text = self.data.guild_name
	person_module_list.hlname.text.text = self.data.guild_name

	self.is_def_img = AvatarManager.Instance:isDefaultImg(guild_id, true) == 0

	image_res:SetActive(self.is_def_img)
	raw_image_obj:SetActive(not self.is_def_img)

	if self.is_def_img then
		local bundle, asset = ResPath.GetGuildBadgeIcon()
		image_res.image:LoadSprite(bundle, asset)
	else
		local callback = function(path)
			if self.is_def_img then
				return
			end
			if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
				return
			end
			local avatar_path_big = path or AvatarManager.GetFilePath(guild_id, true, true)
			if avatar_path_big then
				raw_image_obj.raw_image:LoadURLSprite(avatar_path_big, function()
					if self.is_def_img then
						return
					end
					image_res:SetActive(false)
					raw_image_obj:SetActive(true)
				end)
			end
		end
		AvatarManager.Instance:GetAvatar(guild_id, true, callback, guild_id)
	end
end

function CrossRankRankItem:SetRankHL(index)
	if index == nil or self.node_list["IsShowHL1"] == nil then return end
	self.node_list["IsShowHL1"]:SetActive(self.index == index)
	self.node_list["IsShowHL2"]:SetActive(self.index == index)
	self.node_list["Select"]:SetActive(self.index == index)
	self.node_list["Normal"]:SetActive(self.index ~= index)
end

----------------------------------- 跨服排行榜标签Item -----------------------------------
CrossRankTabItem = CrossRankTabItem  or BaseClass(BaseCell)

function CrossRankTabItem:__init()
	self.node_list["CrossRankTab"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function CrossRankTabItem:__delete()
end

function CrossRankTabItem:SetIndex(index)
	self.index = index
end

function CrossRankTabItem:SetData(data)
	if data == nil then
		return
	end
	self.data = data
	self.node_list["TextHL"].text.text = Language.CrossRank.CrossRankTypeName[data.rank_type] or ""
	self.node_list["Text"].text.text = Language.CrossRank.CrossRankTypeName[data.rank_type] or ""
	self.node_list["ImageHL"]:SetActive(false)
end

function CrossRankTabItem:SetTabHL(index)
	if index == nil then return end
	self.node_list["Text"]:SetActive(self.index ~= index)
	self.node_list["ImageHL"]:SetActive(self.index == index)
end