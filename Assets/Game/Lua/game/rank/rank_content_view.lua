RankContentView = RankContentView or BaseClass(BaseRender)

local FIX_SHOW_TIME = 8
local MAX_NUM = 100

function RankContentView:LoadCallBack()
	self.node_list["BtnSendFlower"].button:AddClickListener(BindTool.Bind(self.OnSendFlowerClick, self))
	self.node_list["BtnOpenCheck"].button:AddClickListener(BindTool.Bind(self.OnOpenCheckClick, self))
	self.role_info_event = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoChange, self))
	self.cur_rank_info = nil
	self.cur_type = 0
	self.prefab_preload_id = 0
	self.role_id_cache = 0
	self.cur_type_cache = -1
	self.cell_list = {}
	self.cell_tag_list = {}
	self.is_need_jump = false
	self.full_screen = true
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLi"])
	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.my_rank_cell = RankCell.New(self.node_list["my_rank_cell"], self)
end

function RankContentView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.cell_tag_list = {}

	if self.my_rank_cell then
		self.my_rank_cell:DeleteMe()
		self.my_rank_cell = nil
	end

	if self.role_info_event then
		GlobalEventSystem:UnBind(self.role_info_event)
		self.role_info_event = nil
	end

	self.cur_rank_info = nil
	self.fight_text = nil
	self.role_id_cache = 0
	self.cur_type_cache = -1
	self.cur_type = 0
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	self.fire_change_model = nil
end

function RankContentView:OnFlush(param_list)
	if not self.root_node.transform.parent.parent.gameObject.activeSelf then return end 		--界面未激活时不让刷新

	local rank_list = RankData.Instance:GetRankList()
	if self.cell_tag_list[self.cur_type] == nil then
		self:SetCurRoleInfo(rank_list[1])
	end
	self:SetReload(rank_list)
	self:FlushMyRank()
	self:FlushShowZhanli()
	self:CheckIsNoRank()

	if self.is_need_jump and #rank_list > 0 then
		for k, v in pairs(self.cell_list) do
			if v.rank == 1 then
				v:ToggleClick(true)
				break
			end
		end

		if self.node_list["list_view"] and self.node_list["list_view"].gameObject.activeInHierarchy then
			self.node_list["list_view"].scroller:RefreshActiveCellViews()
			self.node_list["list_view"].scroller:JumpToDataIndex(0)
		end
		self.is_need_jump = false
	end

	for k, v in pairs(param_list) do
		if k == "flush_model" and self.fire_change_model then
			self:ClearRoleIDCache()
			self:SetModle()
		end
	end
end

function RankContentView:SetIsNeedJump(is_need_jump)
	self.is_need_jump = is_need_jump
end

function RankContentView:InitSetMoudle()
	UIScene:DeleteModel()
	UIScene:ClearWeiYanData()
	-- local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role")
	-- transform.rotation = Quaternion.Euler(8, -162, 0)
	-- UIScene:SetCameraTransform(transform)
end

function RankContentView:GetNumberOfCells()
	return #RankData.Instance:GetRankList()
end

function RankContentView:GetCellSizeDel(data_index)
	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM or self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		data_index = data_index + 1
		return data_index == 1 and 185 or 105
	else
		return 105
	end
end

function RankContentView:RefreshCell(cell, cell_index)
	cell_index = cell_index + 1
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = RankCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		self.cell_list[cell]:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	self.cell_list[cell]:SetRank(cell_index)
	self.cell_list[cell]:Flush()
end

function RankContentView:SetCurType(rank_type)
	self.cur_type = rank_type
end

function RankContentView:SetCurKuaFuType(rank_type)
	self.cur_kuafu_type = rank_type
end

function RankContentView:GetCurType()
	return self.cur_type
end

function RankContentView:GetCurKuaFuType()
	return self.cur_kuafu_type
end

function RankContentView:FlushShowZhanli()
	if nil == self.node_list["NodeZhanLiFrame"] then
		return
	end
	local rank_info = RankData.Instance:GetRankList()
	if self.cur_kuafu_type then
		self.node_list["NodeZhanLiFrame"]:SetActive(self.cur_kuafu_type ~= CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ROLE_LEVEL)
	else
		local  node_frame = self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
			and self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL
			and self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER
			and self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL
			and #rank_info ~= 0
		self.node_list["NodeZhanLiFrame"]:SetActive(node_frame)
	end
end

function RankContentView:SetCurRoleInfo(cur_rank_info)
	if self.cur_rank_info == nil then
		self.cur_rank_info = RankData.Instance:GetRankList()[1]
	else
		if cur_rank_info ~= nil then
			local vip_level = cur_rank_info.vip_level or 0
			vip_level = IS_AUDIT_VERSION and 0 or vip_level
			self.node_list["ImgVIP"]:SetActive(vip_level ~= 0)  
			self.cur_rank_info = cur_rank_info

			local asset, bundle = ResPath.GetVipLevelIcon(vip_level)
			self.node_list["ImgVIP"].image:LoadSprite(asset, bundle .. ".png")
		end
	end
end

function RankContentView:GetCurRoleInfo()
	return self.cur_rank_info
end

--送花
function RankContentView:OnSendFlowerClick()
	if nil == self.cur_rank_info or nil == self.cur_rank_info.user_id then return end

	if self.cur_rank_info.user_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNotSendFollwerToSelf)
		return
	end
	FlowersCtrl.Instance:SetFriendInfo(self.cur_rank_info)
	ViewManager.Instance:Open(ViewName.Flowers)
end

--打开查看面板
function RankContentView:OnOpenCheckClick()
	local check_data = CheckData.Instance:UpdateAttrView()
	if not next(check_data) then
		return
	end
	
	ViewManager.Instance:Open(ViewName.CheckEquip)
	self:CancelTheQuest()
	self.role_id_cache = 0
	self.cur_type_cache = -1
end

--查看角色有变化时,只在可以刷新的页面刷模型
function RankContentView:RoleInfoChange(role_id)
	self.fire_change_model = true
	local cur_top_type = RankData.Instance:GetCurTopType()
	if self.cur_rank_info and self.cur_rank_info.user_id == role_id and 
		(cur_top_type == RANKPANEL.GEREN or cur_top_type == RANKPANEL.MEILI or cur_top_type == RANKPANEL.KUAFU) then
		self:SetModle()
	end
end

--没人进排行榜
function RankContentView:CheckIsNoRank()
	if #RankData.Instance:GetRankList() == 0 then
		UIScene:DeleteModel()
		self.node_list["TxtName"].text.text = ""
		self.node_list["NodeZhanLiFrame"]:SetActive(false)
		self.node_list["ImgVIP"]:SetActive(false)
	end
end

function RankContentView:SetModle()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.role_id == self.role_id_cache and self.cur_type == self.cur_type_cache and self.role_id_cache ~= 0 and self.cur_type_cache ~= -1 then
		return
	else
		self.role_id_cache = role_info.role_id
		self.cur_type_cache = self.cur_type
	end

	UIScene:DeleteModel()
	UIScene:ClearWeiYanData()
	self:CancelTheQuest()
	self:CheckIsNoRank()

	if role_info == nil then return end
	self.node_list["TxtName"].text.text = CheckData.Instance:GetName(self.cur_type)
	UIScene:SetActionEnable(false)
	self:SetTransForm()
	UIScene:SetFightBool(false)
	local key = "role"
	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then 				--坐骑
		self:SetMountModle(role_info)
		key = "mount"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then 		--足迹
		self:SetFootModel(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO then 			--法宝
		self:SetFaBaoModle(role_info)
		key = "baoju"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG then 		--时装
		self:SetFashionModel(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI then 	--神兵
		self:SetShenBing(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then----仙女
		self:SetGoddessModel(role_info, true, true, DISPLAY_TYPE.XIAN_NV)
		key = "goddess"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then 		--神弓(仙环）
		self:SetGoddessModel(role_info, false, true, DISPLAY_TYPE.SHENGONG)
		key = "goddess"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then 			--神翼(仙阵)
		self:SetGoddessModel(role_info, true, false, DISPLAY_TYPE.SHENYI)
		key = "goddess"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then --精灵
		self:SetSpiritModle(role_info)
		key = "spirit"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then  -- 战骑
		self:SetMountModle(role_info)
		key = "fightmount"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_YAOSHI then 		-- 腰饰
		self:SetWaistModel(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_TOUSHI then 		-- 头饰
		self:SetTouShiModle(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_QILINBI then 		-- 麒麟臂
		self:SetQilinBiModel(role_info)
		key = "arm"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK then 		-- 面具
		self:SetMaskModel(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU then 		-- 灵珠
		self:SetLingZhuModel(role_info)
		key = "lingzhu"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO then 		-- 仙宝
		self:SetXianBaoModel(role_info)
		key = "xianbao"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGTONG then 	-- 灵童
		self:SetLingTongModel(role_info)
		key = "lingchong"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG then 	-- 灵弓
		self:SetLingGongModel(role_info)
		key = "linggong"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI then 		-- 灵骑
		self:SetLingQiModel(role_info)
		key = "lingqi"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEIYAN then 		-- 尾焰
		self:SetWeiYanModel(role_info)
		key = "mount"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHOUHUAN then 	-- 手环
		self:SetShouHuanModel(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_TAIL then 		-- 尾巴
		self:SetTailModel(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLYPET then 		-- 飞宠
		self:SetFlyPetModel(role_info)
		key = "flypet"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ClOAk then 		-- 披风
		self:SetCloakModel(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGREN then 		-- 灵刃
		self:SetLingRenModel(role_info)
		key = "hunqi"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then 		-- 羽翼
		self:SetWingModel(role_info)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then 		-- 光环
		self:SetHaloModel(role_info)
		UIScene:SetActionEnable(false)
		key = "role"
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL or self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL or 
		self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER or self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		self:SetRoleModel(role_info)
		UIScene:SetActionEnable(true, true)
		-- UIScene:SetFightBool(true)
		key = "role"
	else
		UIScene:SetRoleModelResInfo(role_info)
		UIScene:SetActionEnable(true, true)
		-- UIScene:SetFightBool(true)
		key = "role"
	end
	self:SetAnim()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, key)
	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		transform.rotation = Quaternion.Euler(25, -162, 6.6)
	else
		if key == "role" or key == "lingchong" then
			transform.rotation = Quaternion.Euler(8, -162, 0)
			if key == "lingchong" then
				transform.position = Vector3(0, 1.84, 4.5)
			end
		elseif key == "goddess" then
			transform.rotation = Quaternion.Euler(7.5, 180, 0)
		elseif key == "lingzhu" then
			transform.rotation = Quaternion.Euler(0, 180, 0)
		else
			transform.rotation = Quaternion.Euler(0, -162, 0)
		end
	end

	if key == "goddess" or key == "lingzhu" then
		UIScene:SetCameraTransform(transform, {x = -0.5})
	else
		UIScene:SetCameraTransform(transform)
	end
end

function RankContentView:SetMountModle(role_info)
	local image_id = 0
	local res_id = nil

	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		image_id = role_info.mount_info.grade == 1 and role_info.mount_info.grade or role_info.mount_info.grade - 1
		local cfg = MountData.Instance:GetMountImageCfg()[image_id]
		if cfg then
			res_id = cfg.res_id
		end

		local bundle, asset = ResPath.GetMountModel(res_id)
		UIScene:LoadSceneEffect(bundle, asset)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		image_id = role_info.fight_mount_info.grade == 1 and role_info.fight_mount_info.grade or role_info.fight_mount_info.grade - 1
		local cfg = FightMountData.Instance:GetMountImageCfg()[image_id]
		if cfg then
			res_id = cfg.res_id
		end
	end
	local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("mount", res_id)
	if advance_transform_cfg then
		local call_back = function(model, obj)
			obj.gameObject.transform.localPosition = advance_transform_cfg.position
			obj.gameObject.transform.localRotation = advance_transform_cfg.rotation
		end
		UIScene:SetModelLoadCallBack(call_back)
	end
	if res_id then
		local bundle, asset = {}
		if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
			bundle, asset = ResPath.GetMountModel(res_id)
		elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
			bundle, asset = ResPath.GetFightMountModel(res_id)
		end
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		
		UIScene:ModelBundle(bundle_list, asset_list)
		
	end
end

function RankContentView:SetFootModel(role_info)
	local info = {}
	info.foot_info = {used_imageid = role_info.foot_info.grade == 1 and role_info.foot_info.grade or role_info.foot_info.grade - 1}
	info.prof = role_info.prof
	info.sex = role_info.sex
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.shizhuang_part_list = {{image_id = 0}, {image_id = fashion_id}}
	UIScene:SetRoleModelResInfo(info, true, true, true, true, true, true)
end

function RankContentView:SetWingModel(role_info)
	local info = {}
	info.wing_info = {used_imageid = role_info.wing_info.grade == 1 and role_info.wing_info.grade or role_info.wing_info.grade - 1}
	info.prof = role_info.prof
	info.sex = role_info.sex
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.shizhuang_part_list = {{image_id = 0}, {image_id = fashion_id}}
	UIScene:SetRoleModelResInfo(info, true, false, true, true)
end

function RankContentView:SetHaloModel(role_info)
	local info = {}
	info.halo_info = {used_imageid = role_info.halo_info.grade == 1 and role_info.halo_info.grade or role_info.halo_info.grade - 1}
	info.prof = role_info.prof
	info.sex = role_info.sex
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.shizhuang_part_list = {{image_id = 0}, {image_id = fashion_id}}
	UIScene:SetRoleModelResInfo(info, true, true, false, true)
end

function RankContentView:SetRoleModel(role_info)
	local info = TableCopy(role_info)
	info.appearance = {}
	info.appearance.mask_used_imageid = role_info.mask_info.used_imageid
	info.appearance.toushi_used_imageid = role_info.head_info.used_imageid
	info.appearance.yaoshi_used_imageid = role_info.waist_info.used_imageid
	info.appearance.qilinbi_used_imageid = role_info.arm_info.used_imageid
	info.appearance.shouhuan_used_imageid = role_info.upgrade_sys_info[UPGRADE_TYPE.SHOU_HUAN].used_imageid
	info.appearance.tail_used_imageid = role_info.upgrade_sys_info[UPGRADE_TYPE.TAIL].used_imageid

	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
	info.appearance.fashion_wuqi = wuqi_id
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, false, false, false, false, false, false)
end

function RankContentView:SetMaskModel(role_info)
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.mask_used_imageid = role_info.mask_info.grade == 1 and role_info.mask_info.grade or role_info.mask_info.grade - 1
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

function RankContentView:SetLingZhuModel(role_info)
	local lingzhu_info = role_info.upgrade_sys_info[UPGRADE_TYPE.LING_ZHU]
	local grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(lingzhu_info.grade)
	if nil == grade_info then return end
	local image_cfg = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_cfg then return end

	local bundle, asset = ResPath.GetLingZhuModel(image_cfg.res_id, true)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function RankContentView:SetXianBaoModel(role_info)
	local xianbao_info = role_info.upgrade_sys_info[UPGRADE_TYPE.XIAN_BAO]
	local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_info.grade)
	if nil == grade_info then return end
	local image_cfg = XianBaoData.Instance:GetXianBaoImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_cfg then return end
	
	local bundle, asset = ResPath.GetXianBaoModel(image_cfg.res_id, true)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function RankContentView:SetLingTongModel(role_info)
	local lingtong_info = role_info.upgrade_sys_info[UPGRADE_TYPE.LING_TONG]
	local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingtong_info.grade)
	if nil == grade_info then return end
	local image_cfg = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_cfg then return end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle_effect, asset_effect = ResPath.GetLingChongModelEffect(image_cfg.res_id_h)
	UIScene:LoadSceneEffect(bundle_effect, asset_effect)
	local bundle, asset = ResPath.GetLingChongModel(image_cfg.res_id_h)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function RankContentView:SetLingGongModel(role_info)
	local linggong_info = role_info.upgrade_sys_info[UPGRADE_TYPE.LING_GONG]
	local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_info.grade)
	if nil == grade_info then return end
	local image_cfg = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_cfg then return end

	local bundle, asset = ResPath.GetLingGongModel(image_cfg.res_id_h)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function RankContentView:SetLingQiModel(role_info)
	local lingqi_info = role_info.upgrade_sys_info[UPGRADE_TYPE.LING_QI]
	local grade_info = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(lingqi_info.grade)
	if nil == grade_info then return end
	local image_cfg = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_cfg then return end

	local bundle, asset = ResPath.GetLingQiModel(image_cfg.res_id, true)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function RankContentView:SetWeiYanModel(role_info)
	local weiyan_info = role_info.upgrade_sys_info[UPGRADE_TYPE.WEI_YAN]
	local grade_info = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(weiyan_info.grade)
	if nil == grade_info then return end
	local image_cfg = WeiYanData.Instance:GetWeiYanImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_cfg then return end

	-- local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
	-- local mount_res_id = (mulit_mount_res_id > 0 and mulit_mount_res_id) or MountData.Instance:GetMountResIdByImageId(MountData.Instance:GetUsedImageId())
	-- if mount_res_id <= 0 then
	-- 	return
	-- end
	local mount_res_id = nil
	local image_id = role_info.mount_info.grade == 1 and role_info.mount_info.grade or role_info.mount_info.grade - 1
	local cfg = MountData.Instance:GetMountImageCfg()[image_id]
	if cfg then
		mount_res_id = cfg.res_id
	else
		return
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local mount_bundle, mount_asset = ResPath.GetMountModel(mount_res_id)
	local load_list = {{mount_bundle, mount_asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		UIScene:SetWeiYanResid(image_cfg.res_id, mount_res_id)
		local bundle_list = {[SceneObjPart.Main] = mount_bundle}
		local asset_list = {[SceneObjPart.Main] = mount_asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function RankContentView:SetShouHuanModel(role_info)
	local shouhuan_info = role_info.upgrade_sys_info[UPGRADE_TYPE.SHOU_HUAN]
	local grade_info = ShouHuanData.Instance:GetShouHuanGradeCfgInfoByGrade(shouhuan_info.grade)
	if nil == grade_info then return end

	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.shouhuan_used_imageid = grade_info.image_id
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

function RankContentView:SetTailModel(role_info)
	local tail_info = role_info.upgrade_sys_info[UPGRADE_TYPE.TAIL]
	local grade_info = TailData.Instance:GetTailGradeCfgInfoByGrade(tail_info.grade)
	if nil == grade_info then return end

	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.tail_used_imageid = grade_info.image_id
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

function RankContentView:SetFlyPetModel(role_info)
	local flypet_info = role_info.upgrade_sys_info[UPGRADE_TYPE.FLY_PET]
	local grade_info = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(flypet_info.grade)
	if nil == grade_info then return end
	local image_cfg = FlyPetData.Instance:GetFlyPetImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_cfg then return end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetFlyPetModel(image_cfg.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function RankContentView:SetCloakModel(role_info)
	local info = TableCopy(role_info)
	info.appearance = {}
	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	local cfg = CloakData.Instance:GetCloakLevelCfg(role_info.cloak_info.level)
	local used_imageid = cfg and cfg.active_image or 0
	if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
		used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
	end
	info.cloak_info.used_imageid = used_imageid

	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, false)
	UIScene:SetActionEnable(false)
end

function RankContentView:SetLingRenModel(role_info)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetHunQiModel(17007)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function RankContentView:SetTouShiModle(role_info)
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.toushi_used_imageid = role_info.head_info.grade == 1 and role_info.head_info.grade or role_info.head_info.grade - 1
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

function RankContentView:SetWaistModel(role_info)
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.yaoshi_used_imageid = role_info.waist_info.grade == 1 and role_info.waist_info.grade or role_info.waist_info.grade - 1
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

function RankContentView:SetQilinBiModel(role_info)
	local grade = role_info.arm_info.grade
	local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(grade)
	if nil == grade_info then return end

	local image_info = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_info then return end

	local bundle, asset = ResPath.GetQilinBiModel(image_info["res_id" .. role_info.sex .. "_h"], role_info.sex)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

function RankContentView:SetFaBaoModle(role_info)
	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(role_info.fabao_info.grade)
	local image_cfg = FaBaoData.Instance:GetFaBaoImageCfg()
	if fabao_grade_cfg == nil then return end
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	local bundle, asset = ResPath.GetFaBaoModel(image_cfg[fabao_grade_cfg.image_id].res_id)
	local load_list = {{bundle, asset}}

	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

function RankContentView:SetFashionModel(role_info)
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	local fashion_info = role_info.shizhuang_part_list[2]
	info.is_normal_fashion = true
	local fashion_id = fashion_info.grade == 0 and fashion_info.grade or fashion_info.grade - 1
	info.shizhuang_part_list = {{image_id = 0}, {image_id = fashion_id}}
	UIScene:SetRoleModelResInfo(info, true, true, true, true)
end

function RankContentView:SetShenBing(role_info)
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.is_not_show_weapon = false

	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	info.is_normal_wuqi = true
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	local wuqi_id = wuqi_info.grade == 0 and wuqi_info.grade or wuqi_info.grade - 1
	info.shizhuang_part_list = {{image_id = wuqi_id}, {image_id = fashion_id}}
	UIScene:SetRoleModelResInfo(info)
end

function RankContentView:SetGoddessModel(role_info, ignore_halo, ignore_fazhen, display_type)
	local attr = CheckData.Instance:UpdateAttrView()
	local goddess_data = GoddessData.Instance
	local info = {}
	info.is_goddess = true
	info.role_res_id = -1
	info.halo_res_id = -1
	info.fazhen_res_id = -1

	local goddess_huanhua_id = attr.xiannv_attr.huanhua_id

	if goddess_huanhua_id > 0 then
		info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
	else
		local goddess_id = attr.xiannv_attr.pos_list[1]
		if goddess_id == -1 then
			goddess_id = 0
		end
		info.role_res_id = goddess_data:GetXianNvCfg(goddess_id).resid
	end
	if not ignore_fazhen then
		local grade = role_info.shenyi_info.grade == 1 and role_info.shenyi_info.grade or role_info.shenyi_info.grade - 1
		local shenyi_cfg = ShenyiData.Instance:GetShenyiImageCfg()[grade]
		if shenyi_cfg == nil then
			return
		end
		info.fazhen_res_id = shenyi_cfg.res_id
	end

	if not ignore_halo then
		local grade = role_info.shengong_info.grade == 1 and role_info.shengong_info.grade or role_info.shengong_info.grade - 1
		local shengong_cfg = ShengongData.Instance:GetShengongImageCfg()[grade]
		if shengong_cfg == nil then
			return
		end
		info.halo_res_id = shengong_cfg.res_id
	end
	UIScene:SetGoddessModelResInfo(info)
end

function RankContentView:SetSpiritModle(role_info)
	local huanhua_id = self.cur_rank_info.flexible_int
	local spirit_id = self.cur_rank_info.flexible_ll
	local is_special = false
	if huanhua_id < 0 then
		spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(spirit_id)
	else
		is_special = true
		spirit_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(huanhua_id)
	end
	if spirit_cfg ~= nil then
		local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		if not is_special then
			UIScene:LoadSceneEffect(bundle, asset)
		end
		UIScene:ModelBundle(bundle_list, asset_list)
	end
end

function RankContentView:CancelTheQuest()
	if UIScene.role_model then
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		-- if self.time_quest then
		-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
		-- 	self.time_quest = nil
		-- end
		if self.time_quest_2 then
			GlobalTimerQuest:CancelQuest(self.time_quest_2)
			self.time_quest_2 = nil
		end
		if self.time_quest_foot then
			GlobalTimerQuest:CancelQuest(self.time_quest_foot)
			self.time_quest_foot = nil
		end
	end
end

function RankContentView:ClearRoleIDCache()
	self.role_id_cache = 0
	self.cur_type_cache = -1
end

function RankContentView:SetTransForm()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info == nil then return end
	local prof = role_info.prof and role_info.prof % 10 or 0

	local rotation = Quaternion.Euler(0, 0, 0)
	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		rotation = Quaternion.Euler(0, -60, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
		if prof == GameEnum.ROLE_PROF_2 then
			rotation = Quaternion.Euler(8, -155, 0)
		elseif prof == GameEnum.ROLE_PROF_1 then
			rotation = Quaternion.Euler(0, 155, 0)
		elseif prof == GameEnum.ROLE_PROF_3 then
			rotation = Quaternion.Euler(8, 170, 0)
		else
			rotation = Quaternion.Euler(8, -170, 0)
		end
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI then
		if prof == GameEnum.ROLE_PROF_4 then
			rotation = Quaternion.Euler(0, -45, 0)
		elseif prof == GameEnum.ROLE_PROF_1 then
			rotation = Quaternion.Euler(0, -90, 0)
		else
			rotation = Quaternion.Euler(0, 0, 0)
		end
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then
		rotation = Quaternion.Euler(0, -90, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		rotation = Quaternion.Euler(0, -35, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then 
		rotation = Quaternion.Euler(0, 3, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_YAOSHI then
		rotation = Quaternion.Euler(0, 45, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG then
		-- rotation = Quaternion.Euler(-30, -90, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI then
		rotation = Quaternion.Euler(0, -45, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEIYAN then
		rotation = Quaternion.Euler(0, 150, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_TAIL then
		if prof == GameEnum.ROLE_PROF_1 or prof == GameEnum.ROLE_PROF_3 then
			rotation = Quaternion.Euler(0, 130, 0)
		else
			rotation = Quaternion.Euler(0, 160, 0)
		end
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLYPET then
		rotation = Quaternion.Euler(0, -35, 0)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ClOAk then
		if prof == GameEnum.ROLE_PROF_2 then
			rotation = Quaternion.Euler(0, 170, 0)
		elseif prof == GameEnum.ROLE_PROF_1 or prof == GameEnum.ROLE_PROF_3 then
			rotation = Quaternion.Euler(0, 130, 0)
		else
			rotation = Quaternion.Euler(0, 165, 0)
		end
	elseif self.cur_type ==  PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHOUHUAN then
		rotation = Quaternion.Euler(0, 90, 0)
	else
		rotation = Quaternion.Euler(0, 0, 0)
	end
	local call_back = function(model, obj)
			obj.gameObject.transform.localRotation = rotation
			if self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then
				model:ClearFoot()
			end
			if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEIYAN then
				model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 120, 0)
			end
		end
	UIScene:SetModelLoadCallBack(call_back)
end

function RankContentView:SetAnim()
	self:CancelTheQuest()
	if UIScene.role_model then
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
				-- part:SetTrigger(ANIMATOR_PARAM.REST)
				part:SetLayer(1, 1)
				part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
				part:SetTrigger(ANIMATOR_PARAM.STATUS)
			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI then
				part:SetBool(ANIMATOR_PARAM.FIGHT, true)
			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY or self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
				-- local count = math.random(1, 4)
				-- part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
				part:SetTrigger(ANIMATOR_PARAM.REST)
			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then
				part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
				part:SetTrigger(ANIMATOR_PARAM.REST)
			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_YAOSHI then
				part:SetTrigger(ANIMATOR_PARAM.STATUS)
			end
		end
	end
end

function RankContentView:SetFootAnim()
	self.timer_foot = 0
	self:CancelTheQuest()
	if UIScene.role_model then
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		self.time_quest_foot = GlobalTimerQuest:AddRunQuest(function()
			self.timer_foot = self.timer_foot - UnityEngine.Time.deltaTime
			if self.timer_foot <= 0 then
				if part then
					if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then
						part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
					end
				end
				self.timer_foot = FIX_SHOW_TIME
			end
		end, 0)
	end
end

-- function RankContentView:PlayAnim(is_change_tab)
-- 	local is_change_tab = is_change_tab
-- 	if self.time_quest_2 then
-- 		GlobalTimerQuest:CancelQuest(self.time_quest_2)
-- 		self.time_quest_2 = nil
-- 	end
-- 	local timer = GameEnum.GODDESS_ANIM_SHORT_TIME
-- 	local count = 1
-- 	self.time_quest_2 = GlobalTimerQuest:AddRunQuest(function()
-- 		timer = timer - UnityEngine.Time.deltaTime
-- 		if timer <= 0 or is_change_tab == true then
-- 			if UIScene.role_model then
-- 				local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
-- 				if part then
-- 					part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
-- 					count = count + 1
-- 				end
-- 				timer = GameEnum.GODDESS_ANIM_SHORT_TIME
-- 				is_change_tab = false
-- 				if count == 5 then
-- 					GlobalTimerQuest:CancelQuest(self.time_quest_2)
-- 					self.time_quest_2 = nil
-- 					self:CalToShowAnim(nil, true)
-- 				end
-- 			end
-- 		end
-- 	end, 0)
-- end

-- function RankContentView:CalToShowAnim(is_change_tab, is_shenyi)
-- 	if self.time_quest then
-- 		GlobalTimerQuest:CancelQuest(self.time_quest)
-- 		self.time_quest = nil
-- 	end
-- 	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
-- 	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
-- 		timer = timer - UnityEngine.Time.deltaTime
-- 		if timer <= 0 or is_change_tab == true then
-- 			if is_change_tab then
-- 				local func = function()
-- 					self:PlayAnim(is_change_tab)
-- 					is_change_tab = false
-- 					timer = GameEnum.GODDESS_ANIM_LONG_TIME
-- 					GlobalTimerQuest:CancelQuest(self.time_quest)
-- 				end
-- 				if is_shenyi then
-- 					if timer <= 6 then
-- 						func()
-- 					end
-- 				else
-- 					func()
-- 				end
-- 			else
-- 				self:PlayAnim(is_change_tab)
-- 				is_change_tab = false
-- 				timer = GameEnum.GODDESS_ANIM_LONG_TIME
-- 				GlobalTimerQuest:CancelQuest(self.time_quest)
-- 			end
-- 		end
-- 	end, 0)
-- end

function RankContentView:SetReload(rank_list)
	if not self.node_list["list_view"] or not self.node_list["list_view"].gameObject.activeInHierarchy then
		return
	end

	if self.cell_tag_list[self.cur_type] ~= nil and self.cell_tag_list[self.cur_type] ~= 0 and rank_list and #rank_list > 0 then
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
		self.node_list["list_view"].scroller:JumpToDataIndex(self.cell_tag_list[self.cur_type] - 1)
		-- self.node_list["list_view"].scroller:JumpToDataIndex(0)
		self:SetClick()
	else
		-- for k,v in pairs(self.cell_list) do
		-- 	if v.rank == 1 then
		-- 		v:ToggleClick(true)
		-- 	end
		-- end
		self.node_list["list_view"].scroller:ReloadData(0)
	end
end

function RankContentView:ReloadRankList()
	if self.node_list["list_view"] and self.node_list["list_view"].scroller and next(self.cell_list) then
		self.node_list["list_view"].scroller:ReloadData(0)
	end
	self.role_id_cache = 0
	self.cur_type_cache = -1
end

function RankContentView:SetClick()
	for k,v in pairs(self.cell_list) do
		if v.rank == self.cell_tag_list[self.cur_type] then
			v:FlushToggleClick(true)
		else
			v:FlushToggleClick(false)
		end
	end
end

function RankContentView:SetZhanliText(show_zhanli_value)
	if show_zhanli_value ~= nil then
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = show_zhanli_value
		end
	end
end

function RankContentView:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

function RankContentView:FlushMyRank()
	self.my_rank_cell:FlushMyRank()
end

function RankContentView:SetShowCheck(is_show)
	self.node_list["BtnSendFlower"]:SetActive(is_show)
	self.node_list["BtnOpenCheck"]:SetActive(is_show)
end
----------------------------------------------------
----------------------每条记录----------------------
------------------------------------ImgTitle----------------
RankCell = RankCell or BaseClass(BaseCell)

function RankCell:__init(instance, parent)
	self.title = ""
	self.node_list["IconBtn"].button:AddClickListener(BindTool.Bind(self.HeadClick, self))
	self.node_list["RawImageBtn"].button:AddClickListener(BindTool.Bind(self.HeadClick, self))
	if self.node_list["RankItem"] ~= nil then
		self.node_list["RankItem"].toggle:AddClickListener(BindTool.Bind(self.ToggleClick, self))
	end
	self.parent = parent
	self.rank = 0
end

function RankCell:__delete()
	self.parent = nil
	if self.node_list and self.node_list["ImgTitle"] then
		TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
	end
end

function RankCell:SetRank(rank)
	self.rank = rank
end

function RankCell:OnFlush()
	self.root_node.gameObject:SetActive(true)
	self.node_list["ImgRank"]:SetActive(false)
	self.root_node.toggle.isOn = false
	local rank_info = RankData.Instance:GetRankList()[self.rank]
	if rank_info == nil then
		self.root_node.gameObject:SetActive(false)
		return
	end

	local cur_type = self.parent:GetCurType()
	if cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		if self.rank > 1 then
			self.node_list["Node"]:SetActive(false)
		else
			local title_id = TitleData.Instance:GetRankTitle(rank_info.sex, cur_type)
			local bundle, asset = ResPath.GetTitleIcon(title_id)
			self.node_list["ImgTitle"].image:LoadSprite(bundle, asset .. ".png")
			TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle"], title_id, true)
			local title_cfg = TitleData.Instance:GetTitleCfg(title_id)
			self.node_list["TxtZhanLi"].text.text = CommonDataManager.GetCapabilityCalculation(title_cfg)
			-- local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
			-- self.node_list["JingJieText"].text.text = (JingJieData.GetjingjieNum(cur_jingjie_level))
			-- local asset1, bundle1 = ResPath.GetJingJieLevelIcon(JingJieData.GetjingjieIcon(cur_jingjie_level))
			-- self.node_list["JingJieImage"].image:LoadSprite(asset1, bundle1)
			self.node_list["Node"]:SetActive(true)
			if cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
				self.node_list["TxtText2"].text.text = Language.Rank.RankTitleName[7]
			else
				self.node_list["TxtText2"].text.text = Language.Rank.RankTitleName[8]
			end
		end
	else
		self.node_list["Node"]:SetActive(false)
	end
	self:FlushRankInfo()
	self:SetHead()
end

function RankCell:FlushMyRank()
	local rank_data = RankData.Instance
	local cur_type = self.parent:GetCurType()
	local cur_kuafu_type = self.parent:GetCurKuaFuType()
	local rank_info = rank_data:GetRankList()
	self.rank = rank_data:GetMyInfoList(cur_type)

	if self.rank == -1 then --100名以外
		local game_role = GameVoManager.Instance:GetMainRoleVo()
		self.node_list["ImgRank1"]:SetActive(false)
		self.node_list["ImgRank2"]:SetActive(false)
		self.node_list["ImgRank"]:SetActive(true)
		self.node_list["TxtName"].text.text = game_role.role_name
		self.title = rank_data:GetRankTitleDes(cur_type, cur_kuafu_type)
		local power_value = rank_data:GetMyPowerValue(cur_type)
		if type(power_value) == "number" then
			power_value = math.floor(power_value)
		end
		if power_value == "" and self.title == Language.Rank.RankTitleName[5] then
			self.node_list["TxtText"].text.text = self.title .. ":" .. "0"..Language.Rank.RankTitleName[6]
		elseif power_value == "" then
			self.node_list["TxtText"].text.text = self.title .. ":" .. CommonDataManager.GetDaXie(0)
		else
			self.node_list["TxtText"].text.text = self.title .. ":" .. tostring(power_value)
		end
		-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(GameVoManager.Instance:GetMainRoleVo().level)
		-- self.node_list["TxtLevel"].text.text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
		-- self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(GameVoManager.Instance:GetMainRoleVo().level)
		-- local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
		-- self.node_list["JingJieText"].text.text = (JingJieData.GetjingjieNum(cur_jingjie_level))
		-- local asset1, bundle1 = ResPath.GetJingJieLevelIcon(JingJieData.GetjingjieIcon(cur_jingjie_level))
		-- self.node_list["JingJieImage"].image:LoadSprite(asset1, bundle1)

		if game_role.vip_level > 0 then
			local asset, bundle = ResPath.GetVipLevelIcon(game_role.vip_level)
			self.node_list["ImgVip"].image:LoadSprite(asset, bundle .. ".png")
			self.node_list["ImgVip"]:SetActive(true)
		end
	else
		self.node_list["ImgRank"]:SetActive(false)
		local rank_info = rank_data:GetRankList()[self.rank]
		if rank_info == nil then return end

		self:FlushRankInfo()
	end
	self:SetHead()
end

function RankCell:FlushToggleClick(is_click)
	if is_click then
		self:ToggleClick(is_click)
	else
		if self.node_list["ImgHighLight"] then
			self.root_node.toggle.isOn = false
			self.node_list["ImgHighLight"]:SetActive(false)
		end
	end
end

function RankCell:ToggleClick(is_click)
	local cur_type = self.parent:GetCurType()
	local cur_kuafu_type = self.parent:GetCurKuaFuType()
	local rank_info = RankData.Instance:GetRankList()[self.rank]
	if (cur_type == nil and cur_kuafu_type == nil) or rank_info == nil then return end

	if is_click then
		self.parent:SetHighLighFalse()
		CheckData.Instance:SetCurrentHLUserId(rank_info.user_id, rank_info.plat_type)
		CheckData.Instance:SetCurrentUserId(rank_info.user_id)
		local cur_kuafu_type = self.parent:GetCurKuaFuType()
		if cur_kuafu_type and rank_info.plat_type then
			CheckCtrl.Instance:SendCrossQueryRoleInfo(rank_info.plat_type, rank_info.user_id)
		else
			CheckCtrl.Instance:SendQueryRoleInfoReq(rank_info.user_id)
		end
		if cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
			if cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
				self.parent:SetZhanliText(rank_info.flexible_int)
			else
				self.parent:SetZhanliText(rank_info.rank_value)
			end
		end
		self.parent:SetCurRoleInfo(rank_info)
		if self.node_list["ImgHighLight"] then
			self.node_list["ImgHighLight"]:SetActive(true)
		end
		self.parent:SetShowCheck(not (rank_info.user_id == GameVoManager.Instance:GetMainRoleVo().role_id))
		self.parent.cell_tag_list[cur_type or cur_kuafu_type] = self.rank
	end
end

function RankCell:FlushClick()
	local cur_type = self.parent:GetCurType()
	local cur_kuafu_type = self.parent:GetCurKuaFuType()
	self.parent:SetHighLighFalse()
	local rank_info = RankData.Instance:GetRankList()[self.rank]
	CheckData.Instance:SetCurrentUserId(rank_info.user_id)

	if cur_kuafu_type and rank_info.plat_type then
		CheckCtrl.Instance:SendCrossQueryRoleInfo(rank_info.plat_type, rank_info.user_id)
	else
		CheckCtrl.Instance:SendQueryRoleInfoReq(rank_info.user_id)
	end
	if cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL then
		if cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
			self.parent:SetZhanliText(rank_info.flexible_int)
		else
			self.parent:SetZhanliText(rank_info.rank_value)
		end
	end
	self.parent:SetCurRoleInfo(rank_info)
	self.node_list["ImgHighLight"]:SetActive(true)
	self.parent:SetShowCheck(not (rank_info.user_id == GameVoManager.Instance:GetMainRoleVo().role_id))
end

function RankCell:HeadClick()
	local rank_info = RankData.Instance:GetRankList()[self.rank]
	if rank_info == nil then return end

	local cur_kuafu_type = self.parent:GetCurKuaFuType()
	if rank_info.user_id ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		CheckData.Instance:SetCurrentUserId(rank_info.user_id)
		if cur_kuafu_type and rank_info.plat_type then
			CheckCtrl.Instance:SendCrossQueryRoleInfo(rank_info.plat_type, rank_info.user_id)
			local uuid = {plat_type = rank_info.plat_type, role_id = rank_info.user_id}
			ScoietyCtrl.Instance:ShowOperateListGlobal(ScoietyData.DetailType.RankList, uuid, nil, nil, BindTool.Bind(self.CloseBtnCallBack, self))
		else
			CheckCtrl.Instance:SendQueryRoleInfoReq(rank_info.user_id)
			ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.RankList, rank_info.user_name, nil, nil, BindTool.Bind(self.CloseBtnCallBack, self))
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
	end
end

function RankCell:CloseBtnCallBack()
	local hl_user_id, hl_plat_type = CheckData.Instance:GetCurrentHLUserId()
	if hl_user_id then
		CheckData.Instance:SetCurrentUserId(hl_user_id, hl_plat_type)
		if hl_plat_type then
			CheckCtrl.Instance:SendCrossQueryRoleInfo(hl_plat_type, hl_user_id)
		else
			CheckCtrl.Instance:SendQueryRoleInfoReq(hl_user_id)
		end
	end
end

function RankCell:SetHighLigh(is_hl)
	if is_hl or (self.root_node.toggle and self.root_node.toggle.isOn) then
		self.node_list["ImgHighLight"]:SetActive(true)
	else
		self.node_list["ImgHighLight"]:SetActive(is_hl)
	end
end

function RankCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function RankCell:FlushRankInfo()
	local rank_data = RankData.Instance
	local rank_list = rank_data:GetRankList()
	if rank_list == nil then return end

	local rank_info = rank_list[self.rank]
	self.title = rank_data:GetRankTitleDes(self.parent:GetCurType(), self.parent:GetCurKuaFuType())
	if rank_info.server_id then
		self.node_list["TxtName"].text.text = rank_info.user_name .. "_S" .. rank_info.server_id
	else
		self.node_list["TxtName"].text.text = rank_info.user_name
	end
	local rank_value = rank_data:GetRankValue(self.rank)
	if type(rank_value) == "number" then
		rank_value = math.floor(rank_value)
	end
	if self.node_list["TxtText"] ~= nil then
		self.node_list["TxtText"].text.text = self.title .. ":" .. tostring(rank_value)
		if self.parent:GetCurType() == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
			self.node_list["TxtText"].text.text = self.title .. ":" .. tostring(rank_value) .. Language.Rank.RankTitleName[6]
		end
	end
	-- local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
	-- self.node_list["JingJieText"].text.text = (JingJieData.GetjingjieNum(cur_jingjie_level))
	-- local asset1, bundle1 = ResPath.GetJingJieLevelIcon(JingJieData.GetjingjieIcon(cur_jingjie_level))
	-- self.node_list["JingJieImage"].image:LoadSprite(asset1, bundle1)
	if self.rank <= 3 then
		self.node_list["ImgRank1"]:SetActive(true)
		self.node_list["ImgRank2"]:SetActive(false)
		local bundle, asset = ResPath.GetRankImg("rank_" .. self.rank)
		self.node_list["ImgImage"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["TxtNum"].text.text = self.rank
		self.node_list["ImgRank1"]:SetActive(false)
		self.node_list["ImgRank2"]:SetActive(true)
	end
	if rank_info.vip_level then
		local asset, bundle = ResPath.GetVipLevelIcon(rank_info.vip_level)
		self.node_list["ImgVip"].image:LoadSprite(asset, bundle .. ".png")
		self.node_list["ImgVip"]:SetActive(true)
	else
		self.node_list["ImgVip"]:SetActive(false)
	end

	if self.parent:GetCurRoleInfo() == nil then
		return
	end

	if self.parent:GetCurRoleInfo().user_id == rank_info.user_id then
		if self.root_node.toggle ~= nil then
			self.root_node.toggle.isOn = true
			self.node_list["ImgHighLight"]:SetActive(true)
			-- if not self.root_node.toggle.isActiveAndEnabled then
			-- 	self:ToggleClick(true)
			-- end
		end
	else
		if self.root_node.toggle ~= nil then
			self.root_node.toggle.isOn = false
			self.node_list["ImgHighLight"]:SetActive(false)
		end
	end
	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(rank_info.level)
	-- self.node_list["TxtLevel"].text.text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
	-- self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(rank_info.level)
	-- local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
	-- self.node_list["JingJieText"].text.text = (JingJieData.GetjingjieNum(cur_jingjie_level))
	-- local asset1, bundle1 = ResPath.GetJingJieLevelIcon(JingJieData.GetjingjieIcon(cur_jingjie_level))
	-- self.node_list["JingJieImage"].image:LoadSprite(asset1, bundle1)

	-- if self.parent.cell_tag_list[self.parent.cur_type] == self.rank then 
	-- 	self:ToggleClick(true)
	-- end
end

function RankCell:SetHead()
	local rank_data = RankData.Instance
	local rank_info = rank_data:GetRankList()[self.rank]
	self.node_list["IconBtn"]:SetActive(false)
	self.node_list["RawImageBtn"]:SetActive(false)
	local user_id = 0
	local avatar_key_big = 0
	local avatar_key_small = 0
	local prof = 0
	local sex = 0
	if rank_info then
		user_id = rank_info.user_id
		user_name = rank_info.user_name
		avatar_key_big = rank_info.avatar_key_big
		avatar_key_small = rank_info.avatar_key_small
		prof = rank_info.prof
		sex = rank_info.sex
	else
		local vo = GameVoManager.Instance:GetMainRoleVo()
		user_id = vo.role_id
		avatar_key_big = vo.avatar_key_big
		avatar_key_small = vo.avatar_key_small
		prof = vo.prof
		sex = vo.sex
	end
	if (prof % 10) >= 3 then
		sex = 0
	end
	AvatarManager.Instance:SetAvatar(user_id, self.node_list["RawImageBtn"], self.node_list["IconBtn"], sex, prof, false)

end