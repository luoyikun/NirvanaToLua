require("game/player/player_info_view")
require("game/player/player_title_view")
require("game/player/player_equip_view")
require("game/player/player_zhuansheng_view")
require("game/advance/ling_ren/advance_lingren_view")
require("game/player/player_reincarnation_view")
require("game/player/player_shen_equip_view")
require("game/player/player_tulong_equip_view")
require("game/player/shengyin/player_shengyin_view")
require("game/player/skill/player_active_skill_view")
require("game/player/skill/player_passive_skill_view")
require("game/player/skill/player_innate_skill_view")
require("game/player/skill/player_tianshu_skill_view")
require("game/player/luoshu/luoshu_view")
require("game/player/zhuanzhi/zhuanzhi_view")
require("game/player/zhuanzhi/juexing_view")
require("game/player/zhuanzhi/juexing_one_view")
require("game/player/zhuanzhi/juexing_two_view")
require("game/player/zhuanzhi/juexing_three_view")
require("game/player/zhuanzhi/juexing_four_view")
require("game/player/zhuanzhi/juexing_five_view")

local INFO_TOGGLE = 1
local PACK_TOGGLE = 2
local FASHION_TOGGLE = 3
local TITLE_TOGGLE = 4
local SKILL_TOGGLE = 5
local ZHUANSHENG_TOGGLE = 6
local REINCARNATION_TOGGLE = 7
local TULONG_TOGGLE = 8

PlayerView = PlayerView or BaseClass(BaseView)

function PlayerView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/advanceview_prefab", "ModelDragLayer"},
		{"uis/views/player_prefab", "InfoContent", {TabIndex.role_intro}},
		{"uis/views/player_prefab", "TitlePanel", {TabIndex.role_title}},
		{"uis/views/player_prefab", "ActiveSkill", {TabIndex.role_active_skill}},
		{"uis/views/player_prefab", "PassiveSkill", {TabIndex.role_passive_skill}},
		{"uis/views/player_prefab", "TianShuSkill", {TabIndex.role_tianshu_skill}},
		{"uis/views/player_prefab", "InnateSkill", {TabIndex.role_innate_skill}},
		{"uis/views/player_prefab", "ReincarnationContentView", {TabIndex.role_reincarnation}},
		{"uis/views/player_prefab", "TulongEquipView", {TabIndex.role_tulong_equip, TabIndex.role_chuanshi_equip}},
		{"uis/views/player_prefab", "LuoShuView", {TabIndex.baoju_luoshu}},
		{"uis/views/player/shengyin_prefab", "ShengYinContent", {TabIndex.role_shengyin}},
		{"uis/views/player_prefab", "ZhuanZhiView", {TabIndex.role_zhuanzhi}},
		{"uis/views/player_prefab", "JueXingView", {TabIndex.role_juexing}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
	}
	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.role_intro
	self.role_model = nil
	self.last_role_model_show_type = nil
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))

	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.ZhuanZhiTaskChange, self))

	self.cur_toggle = INFO_TOGGLE
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.is_switch_to_shen_equip = false
	self.is_paly_role_ani = false 						-- 记录是否已经播放过人物动画

	self.base_prof = 1									-- 初始化基本职业

	-- -- 创建子View
	-- self.yijue_view = YiJueView.New(self.node_list["JueXing1"])
end

function PlayerView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)

	if self.task_change then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end
end

function PlayerView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Player)
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if nil ~= self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end


	if nil ~= self.title_view then
		self.title_view:DeleteMe()
		self.title_view = nil
	end
	
	if nil ~= self.active_skill_view then
		self.active_skill_view:DeleteMe()
		self.active_skill_view = nil
	end

	if nil ~= self.passive_skill_view then
		self.passive_skill_view:DeleteMe()
		self.passive_skill_view = nil
	end

	if nil ~= self.tianshu_skill_view then
		self.tianshu_skill_view:DeleteMe()
		self.tianshu_skill_view = nil
	end

	if nil ~= self.innate_skill_view then
		self.innate_skill_view:DeleteMe()
		self.innate_skill_view = nil
	end

	if nil ~= self.reincarnation_view then
		self.reincarnation_view:DeleteMe()
		self.reincarnation_view = nil
	end

	if nil ~= self.tulong_equip_view then
		self.tulong_equip_view:DeleteMe()
		self.tulong_equip_view = nil
	end

	if nil ~= self.shengyin_view then 
		self.shengyin_view:DeleteMe()
		self.shengyin_view = nil
	end
	
	if nil ~= self.luoshu_view then 
		self.luoshu_view:DeleteMe()
		self.luoshu_view = nil
	end
	
	if nil ~= self.zhuanzhi_view then 
		self.zhuanzhi_view:DeleteMe()
		self.zhuanzhi_view = nil
	end
	
	if nil ~= self.juexing_view then 
		self.juexing_view:DeleteMe()
		self.juexing_view = nil
	end
	
	if nil ~= self.role_dress_content then
		GlobalEventSystem:UnBind(self.role_dress_content)
		self.role_dress_content = nil
	end

	if nil ~= self.avater_type_event then
		GlobalEventSystem:UnBind(self.avater_type_event)
		self.avater_type_event = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.last_role_model_show_type = nil

	-- -- 清理变量和对象
	self.tab_equip = nil
	self.zs_button = nil

	self.baizhan_flag = nil
end

function PlayerView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.Player.PlayerViewName[1], bundle = "uis/images_atlas", asset = "icon_msg", func = "player", tab_index = TabIndex.role_intro, remind_id = RemindName.PlayerInfo},
		{name = Language.Player.PlayerViewName[2], bundle = "uis/images_atlas", asset = "icon_title", tab_index = TabIndex.role_title, remind_id = RemindName.PlayerTitle}, 
		{name = Language.Player.PlayerViewName[3], bundle = "uis/images_atlas", asset = "icon_skill", func = "role_active_skill", tab_index = TabIndex.role_active_skill, remind_id = RemindName.PlayerSkill},
		-- {name = Language.Player.PlayerViewName[4], bundle = "uis/images_atlas", asset = "truesure_duihuan", tab_index = TabIndex.role_reincarnation, remind_id = RemindName.Reincarnation}, 
		{name = Language.Player.PlayerViewName[6], bundle = "uis/images_atlas", asset = "icon_luoshu", func = "baoju_luoshu", tab_index = TabIndex.baoju_luoshu, remind_id = RemindName.HeSheLuoShu},
		{name = Language.Player.PlayerViewName[8], bundle = "uis/images_atlas", asset = "icon_zhuanzhi", func = "role_zhuanzhi", tab_index = TabIndex.role_zhuanzhi, remind_id = RemindName.AllZhuanZhi}, 
		{name = Language.Player.PlayerViewName[5], bundle = "uis/images_atlas", asset = "icon_tulong", func = "tulong_equip", tab_index = TabIndex.role_tulong_equip, remind_id = RemindName.TulongEquipGroup}, 
		{name = Language.Player.PlayerViewName[7], bundle = "uis/images_atlas", asset = "icon_shengyin", func = "rolebag_shengyin", tab_index = TabIndex.role_shengyin, remind_id = RemindName.PlayerShengYin}, 
	}

	local function innate_skill_openfun()
		local min_zhuan = SkillData.Instance:GetInnateSkillOpen("zhuan_gongfang") or 0
		local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
		zhuan = zhuan or 0
		return OpenFunData.Instance:CheckIsHide("role_innate_skill") and (min_zhuan <= zhuan)
	end

	local sub_tab_cfg = {
		nil,
		nil,
		{
			{name = Language.Player.TabbarName.ActiveSkill, tab_index = TabIndex.role_active_skill, remind_id = RemindName.PlayerActiveSkill, func = "role_active_skill",},
			{name = Language.Player.TabbarName.PassiveSkill, tab_index = TabIndex.role_passive_skill, remind_id = RemindName.PlayerPassiveSkill, func = "role_passive_skill",},
			{name = Language.Player.TabbarName.InnateSkill, tab_index = TabIndex.role_innate_skill, remind_id = RemindName.PlayerInnateSkill, func = innate_skill_openfun,},
			{name = Language.Player.TabbarName.TianShuSkill, tab_index = TabIndex.role_tianshu_skill, remind_id = RemindName.PlayerTianShuSkill, func = "role_tianshu_skill",},
		},
		-- {
		-- 	{name = Language.Player.TabbarName.LuoShu, tab_index = TabIndex.baoju_luoshu_upgrade, remind_id = RemindName.LuoShu,},
		-- 	{name = Language.Player.TabbarName.ShenHua, tab_index = TabIndex.baoju_luoshu_shenhua, remind_id = RemindName.ShenHua, func = BindTool.Bind(self.OpenLuoShuShenHua, self)},
		-- },
		nil,
		{
			{name = Language.Player.TabbarName.ZhuanZhi, tab_index = TabIndex.role_zhuanzhi, remind_id = RemindName.ZhuanZhi, func = "role_zhuanzhi",},
			{name = Language.Player.TabbarName.JueXing, tab_index = TabIndex.role_juexing, remind_id = RemindName.JueXing, func = "role_juexing",},
		},
		{
			{name = Language.Player.TabbarName.HeFu, tab_index = TabIndex.role_tulong_equip, remind_id = RemindName.TulongEquip},
			{name = Language.Player.TabbarName.ShengZhuang, tab_index = TabIndex.role_chuanshi_equip, remind_id = RemindName.CSTulongEquip},
		},
		nil,
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:InitSubTab(self.node_list["TopTabContent"], sub_tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["UnderBg"]:SetActive(true)

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Player, BindTool.Bind(self.GetUiCallBack, self))

	self.baizhan_flag = nil
end

function PlayerView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function PlayerView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
	-- if remind_name == RemindName.TulongEquipGroup and self.tulong_equip_view then
	-- 	self.tulong_equip_view:FlushRemind()
	-- end
	self:Flush()
end

function PlayerView:GetRoleModel()
	return self.role_model
end

function PlayerView:GetTitleView()
	return self.title_view
end

function PlayerView:SetSceneMaskState(value)
	value = value or false
	
	if self.node_list["ImgRemind"] then
		self.node_list["ImgRemind"]:SetActive(value)
	end

end

function PlayerView:Open(index)
	self.is_paly_role_ani = false
	BaseView.Open(self, index)
	self:Flush()

end

function PlayerView:OpenIndexCheck(to_index)
	self:ChangeToIndex(to_index)
end

function PlayerView:BanZhanChange(flag)
	self.baizhan_flag = flag
	self.base_prof = PlayerData.Instance:GetRoleBaseProf(PlayerData.Instance:GetAttr("prof"))
	local camera_transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. self.base_prof)
	local player_camera_position = camera_transform.position
	local player_camera_rotation = camera_transform.rotation
	local rotate_y = (index == TabIndex.role_title or index == TabIndex.role_active_skill or index == TabIndex.role_passive_skill) and -174 or -170
	player_camera_rotation = Quaternion.Euler(8, rotate_y, 0)

	self.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("bg_common1_under", true))

	if index == TabIndex.role_zhuanzhi or index == TabIndex.role_juexing or index == TabIndex.role_shengyin then
		self.node_list["TaiZi"]:SetActive(false)
	else
		self.node_list["TaiZi"]:SetActive(true)
		local plat_x = (index == TabIndex.role_title or index == TabIndex.role_active_skill or index == TabIndex.role_passive_skill) and -110 or -188
		self.node_list["TaiZi"].transform.localPosition = Vector3(plat_x, -318, 0)
	end	

	if self.baizhan_flag == true then
		local callback = function()

			local vo = GameVoManager.Instance:GetMainRoleVo()
			local temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
			for k,v in pairs(vo.appearance) do
				temp_vo.appearance[k] = v
			end
			temp_vo.appearance.halo_used_imageid = 0
			temp_vo.appearance.wing_used_imageid = 0
			UIScene:SetRoleModelResInfo(temp_vo)
			self:SetRoleFight(false)
			if index == TabIndex.role_reincarnation then
				UIScene:SetActionEnable(true)
			else
				if not self.is_paly_role_ani then
					UIScene:SetActionEnable(true)
					self.is_paly_role_ani = true
				end
			end
			UIScene:SetActionEnable(true)

			vo.is_normal_wuqi = vo.appearance.fashion_wuqi_is_special == 0 and true or false
			UIScene:SetRoleModelResInfo(vo)
	
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.position = player_camera_position
			transform.rotation = player_camera_rotation
			UIScene:SetCameraTransform(transform)
		end
		if self.is_paly_role_ani then
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.position = player_camera_position
			transform.rotation = player_camera_rotation
			UIScene:SetCameraTransform(transform)
		else
			self.is_paly_role_ani = true
		end
		UIScene:ChangeScene(self, callback)
		if self.info_view then
			self.info_view:FlushPanel()
		end
	elseif self.baizhan_flag == false then
		UIScene:ChangeScene(nil)
		self.is_paly_role_ani = false

		self.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("BaiZhanBG", true))
		self.node_list["TaiZi"]:SetActive(false)		
	end
end

function PlayerView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	self.base_prof = PlayerData.Instance:GetRoleBaseProf(PlayerData.Instance:GetAttr("prof"))
	local camera_transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. self.base_prof)
	local player_camera_position = camera_transform.position
	local player_camera_rotation = camera_transform.rotation
	local rotate_y = (index == TabIndex.role_title or index == TabIndex.role_active_skill or index == TabIndex.role_passive_skill or index == TabIndex.role_tianshu_skill) and -174 or -170
	player_camera_rotation = Quaternion.Euler(8, rotate_y, 0)

	self.node_list["UnderBg"]:SetActive(index ~= TabIndex.role_innate_skill)
	self.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("bg_common1_under", true))
	
	if index == TabIndex.role_zhuanzhi or index == TabIndex.role_juexing or index == TabIndex.role_shengyin then
		self.node_list["TaiZi"]:SetActive(false)
	else
		self.node_list["TaiZi"]:SetActive(true)
		local plat_x = (index == TabIndex.role_title or index == TabIndex.role_active_skill or index == TabIndex.role_passive_skill or index == TabIndex.role_tianshu_skill) and -110 or -188
		self.node_list["TaiZi"].transform.localPosition = Vector3(plat_x, -318, 0)
	end

	if index == TabIndex.role_intro and self.baizhan_flag == false then
		self.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("BaiZhanBG", true))
		self.node_list["TaiZi"]:SetActive(false)
	end

	if index_nodes then
		if index == TabIndex.role_intro then
			self.info_view = PlayerInfoView.New(index_nodes["InfoContent"])
			self.info_view:OpenCallBack()
			self:Flush()
		elseif index == TabIndex.role_title then
			self.title_view = PlayerTitleView.New(index_nodes["TitlePanel"])
			self.title_view:SetUiTitle(self.ui_title_res)
			self.title_view:Flush()
			self:Flush()
		elseif index == TabIndex.role_active_skill then
			self.active_skill_view = PlayerActiveSkillView.New(index_nodes["ActiveSkill"], self)
			self.active_skill_view:FlushSkillExpInfo()
			self.active_skill_view:OnClickProfessionButton()
		elseif index == TabIndex.role_passive_skill then
			self.passive_skill_view = PlayerPassiveSkillView.New(index_nodes["PassiveSkill"], self)
			self.passive_skill_view:FlushSkillExpInfo()
			self.passive_skill_view:FlushSkillInfo()
			self.passive_skill_view:OnClickPassiveButton()
		elseif index == TabIndex.role_tianshu_skill then
			self.tianshu_skill_view = PlayerTianShuSkillView.New(index_nodes["TianShuSkill"], self)
			self.tianshu_skill_view:OnClickPassiveButton()
		elseif index == TabIndex.role_innate_skill then
			self.innate_skill_view = PlayerInnateSkillView.New(index_nodes["InnateSkill"])
			self.innate_skill_view:Flush()
		elseif index == TabIndex.role_reincarnation then
			self.reincarnation_view = PlayerReincarnationView.New(index_nodes["ReincarnationContentView"])
			self.reincarnation_view:OpenCallBack()
			self:Flush()
			self.zs_button = self.reincarnation_view:GetZsButton()
			
		elseif index == TabIndex.role_tulong_equip or index == TabIndex.role_chuanshi_equip then
			self.tulong_equip_view = TulongEquipView.New(index_nodes["TulongEquipView"])
			self.tulong_equip_view:OpenCallBack(index)
			self:Flush()
		elseif index == TabIndex.role_shengyin then
			self.shengyin_view = ShengYinView.New(index_nodes["ShengYinContent"])
			self.shengyin_view:FlushBagView()
			self:Flush()
		elseif index == TabIndex.baoju_luoshu or index == TabIndex.baoju_luoshu_upgrade or index == TabIndex.baoju_luoshu_shenhua then
			self.luoshu_view = LuoShuView.New(index_nodes["LuoShuView"])
			-- self:Flush()
		elseif index == TabIndex.role_zhuanzhi then
			self.zhuanzhi_view = ZhuanZhiView.New(index_nodes["ZhuanZhiView"])
			self:Flush()
		elseif index == TabIndex.role_juexing then
			self.juexing_view = JueXingView.New(index_nodes["JueXingView"])
			self:Flush()
		end
		
	end

	if index == TabIndex.role_intro or index == TabIndex.role_tulong_equip or index == TabIndex.role_chuanshi_equip or index == TabIndex.role_reincarnation then
		local callback = function()

			local vo = GameVoManager.Instance:GetMainRoleVo()
			local temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
			for k,v in pairs(vo.appearance) do
				temp_vo.appearance[k] = v
			end
			temp_vo.appearance.halo_used_imageid = 0
			temp_vo.appearance.wing_used_imageid = 0
			UIScene:SetRoleModelResInfo(temp_vo)
			self:SetRoleFight(false)
			if index == TabIndex.role_reincarnation then
				UIScene:SetActionEnable(true)
			else
				if not self.is_paly_role_ani then
					UIScene:SetActionEnable(true)
					self.is_paly_role_ani = true
				end
			end
			UIScene:SetActionEnable(true)

			vo.is_normal_wuqi = vo.appearance.fashion_wuqi_is_special == 0 and true or false
			UIScene:SetRoleModelResInfo(vo)
	
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.position = player_camera_position
			transform.rotation = player_camera_rotation
			UIScene:SetCameraTransform(transform)
		end
		if self.is_paly_role_ani then
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.position = player_camera_position
			transform.rotation = player_camera_rotation
			UIScene:SetCameraTransform(transform)
		else
			self.is_paly_role_ani = true
		end

		if index == TabIndex.role_intro and self.baizhan_flag == false then
			UIScene:ChangeScene(nil)
			self.is_paly_role_ani = false
		else
			UIScene:ChangeScene(self, callback)
		end

		if self.info_view then
			self.info_view:FlushPanel()
		end

	elseif index == TabIndex.role_title then
		self:SetRoleFight(false)
		local callback = function()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			local temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
			for k,v in pairs(vo.appearance) do
				temp_vo.appearance[k] = v
			end
			temp_vo.appearance.halo_used_imageid = 0
			temp_vo.appearance.wing_used_imageid = 0
			UIScene:SetRoleModelResInfo(temp_vo)
			self:SetRoleFight(false)
			UIScene:SetActionEnable(true)
			vo.is_normal_wuqi = vo.appearance.fashion_wuqi_is_special == 0 and true or false
			UIScene:SetRoleModelResInfo(vo)

			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.position = player_camera_position
			transform.rotation = player_camera_rotation
			UIScene:SetCameraTransform(transform)
		end
		if self.is_paly_role_ani then
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.position = player_camera_position
			transform.rotation = player_camera_rotation
			UIScene:SetCameraTransform(transform)
		else
			UIScene:ChangeScene(self, callback)
			self.is_paly_role_ani = true
		end
	elseif index == TabIndex.role_active_skill or index == TabIndex.role_passive_skill or index == TabIndex.role_tianshu_skill then
		local callback = function()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			local temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
			for k,v in pairs(vo.appearance) do
				temp_vo.appearance[k] = v
			end
			temp_vo.appearance.halo_used_imageid = 0
			temp_vo.appearance.wing_used_imageid = 0
			UIScene:SetRoleModelResInfo(temp_vo)
			role_model_show_type = "role_skill_play"
			self:SetRoleFight(true)
			UIScene:SetRoleModelResInfo(GameVoManager.Instance:GetMainRoleVo())

			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.position = player_camera_position
			transform.rotation = player_camera_rotation
			UIScene:SetCameraTransform(transform)
		end
		
		if self.is_paly_role_ani then
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.position = player_camera_position
			transform.rotation = player_camera_rotation
			UIScene:SetCameraTransform(transform)
		else
			UIScene:ChangeScene(self, callback)
			self.is_paly_role_ani = true
		end
		-- if self.active_skill_view then self:SetRoleFight(true) end
		self:Flush()
	elseif index == TabIndex.role_shengyin then 
		UIScene:ChangeScene(nil)
		self.is_paly_role_ani =false
	elseif index == TabIndex.role_innate_skill then
		UIScene:ChangeScene(nil)
		self.is_paly_role_ani = false
	elseif index == TabIndex.role_zhuanzhi then
		self:Flush()
		UIScene:ChangeScene(nil)
		self.is_paly_role_ani = false
	elseif index == TabIndex.role_juexing then
		self:Flush()
		UIScene:ChangeScene(nil)
		self.is_paly_role_ani = false
	end


	if index == TabIndex.role_active_skill then
		if self.skill_view then 
			self:SetRoleFight(true)
		end
	end

	if index ~= TabIndex.role_passive_skill and self.passive_skill_view then
		self.passive_skill_view:StopLevelUp()
	end

	if index == TabIndex.role_intro then
		self.info_view:DoPanelTweenPlay()

	elseif index == TabIndex.role_title then 
		self.title_view:DoPanelTweenPlay()

	elseif index == TabIndex.role_active_skill then
		self.active_skill_view:DoPanelTweenPlay()

	elseif index == TabIndex.role_passive_skill then 
		self.passive_skill_view:DoPanelTweenPlay()

	elseif index == TabIndex.role_tianshu_skill then 
		self.tianshu_skill_view:DoPanelTweenPlay()
	
	elseif index == TabIndex.role_innate_skill then
		self.innate_skill_view:DoPanelTweenPlay()

	elseif index == TabIndex.role_tulong_equip or index == TabIndex.role_chuanshi_equip then
		self:Flush()
		self.tulong_equip_view:DoPanelTweenPlay()
	elseif index == TabIndex.baoju_luoshu then
		self.luoshu_view:UIsMove()
		self.luoshu_view:OnOpenLuoShu()
		UIScene:ChangeScene(nil)
		self.is_paly_role_ani =false
	elseif index == TabIndex.baoju_luoshu_shenhua then
		self.luoshu_view:ShenHuaMove()
		self.luoshu_view:OnOpenShenHua()
		UIScene:ChangeScene(nil)
		self.is_paly_role_ani =false
	elseif index == TabIndex.role_shengyin then
		self.shengyin_view:PlayTween()
		self.shengyin_view:OpenCallBack()
		self.shengyin_view:FlushBagView()
		UIScene:ChangeScene(nil)
		self.is_paly_role_ani =false
	elseif index == TabIndex.role_zhuanzhi then
		self.zhuanzhi_view:DoPanelTweenPlay()
	elseif index == TabIndex.role_juexing then
		self.juexing_view:DoPanelTweenPlay()
	end
end
function PlayerView:OpenCallBack()
	RemindManager.Instance:Fire(RemindName.PlayerInfo)
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- self.avater_type_event = GlobalEventSystem:Bind(AvaterType.FORBID_AVATER_CHANGE,
	-- 	BindTool.Bind(self.FlushForbidAvaterChange, self))
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:Flush()
	self:FlushTabbar()

	if not self.equip_data_change then
		self.equip_data_change = GlobalEventSystem:Bind(OtherEventType.EQUIP_DATA_CHANGE, BindTool.Bind(self.EquipDataChangeListen, self))
	end

	if self.equip_view then
		self.equip_view:OpenCallBack()
	end

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	SkillCtrl.Instance:SendRoleTelentOperate(GameEnum.ROLE_TALENT_OPERATE_TYPE.ROLE_TALENT_OPERATE_TYPE_INFO)   --临时写这里 请求天赋信息
	-- PlayerCtrl.Instance:SendImpGuardOperaReq(IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_ALL_INFO, param1, param2)	--请求小鬼信息
end

-- function PlayerView:FlushForbidAvaterChange()
-- 	self:Flush("forbid_avater_change")
-- end

function PlayerView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	RemindManager.Instance:Fire(RemindName.PlayerInfo)
	RemindManager.Instance:Fire(RemindName.AllZhuanZhi)
	self:FlushRolePackageView(index)
end

function PlayerView:SetRendering(value)
	if self.is_rendering ~= value then
		self.last_role_model_show_type = nil
	end

	BaseView.SetRendering(self, value)
end

function PlayerView:CloseCallBack()
	 if nil ~= self.last_role_model_show_type then 
	   self.last_role_model_show_type = nil 
	 end

	if self.equip_view then
		self.equip_view:CloseCallBack()
	end
	if self.info_view then
		self.info_view:CloseCallBack()
	end

	
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if nil ~= self.avater_type_event then
		GlobalEventSystem:UnBind(self.avater_type_event)
		self.avater_type_event = nil
	end

	if self.skill_view then
		self.skill_view:StopLevelUp()
		self.skill_view:CloseCallBack()
	end

	if self.fashion_view then
		self.fashion_view:CloseCallBack()
	end
	if self.equip_data_change then
		GlobalEventSystem:UnBind(self.equip_data_change)
		self.equip_data_change = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	Scene.Instance:GetMainRole():FixMeshRendererBug()
end

function PlayerView:EquipDataChangeListen()
	if UIScene.role_model then
		UIScene.role_model:EquipDataChangeListen()
	end
end

function PlayerView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	elseif attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "used_title_list" then
		self:Flush("title_change")
	end
end

-- 操作物品tip回调
function PlayerView:HandleItemTipCallBack(item_data, handleType, handle_param_t, item_cfg)
	if item_data == nil then
		return
	end

	if handleType == TipsHandleDef.HANDLE_STORGE then			--存仓库
		print_log("HandleItemTip: HANDLE_STORGE")
	elseif handleType == TipsHandleDef.HANDLE_BACK_BAG then 	--从仓库中取回到背包
		print_log("HandleItemTip: HANDLE_BACK_BAG")
	elseif handleType == TipsHandleDef.HANDLE_RECOVER then		--从背包到售卖(回收)
		PackageCtrl.Instance:AddRecycleItem(item_data)
	elseif handleType == TipsHandleDef.HANDLE_TAKEOFF then		--取下装备
		-- 转生装备
		if item_cfg.sub_type and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
			local zs_dess_index = ZhuanShengData.Instance:GetZhuanShengEquipIndex(item_cfg.sub_type)
			ZhuanShengCtrl.Instance:SendRoleZhuanSheng(ZHUANSHENG_REQ_TYPE.ZHUANSHENG_REQ_TYPE_TAKE_OFF_EQUIP, zs_dess_index, param2, param3)
			return
		end

		local yes_func = function()
			PlayerCtrl.Instance:CSTakeOffEquip(item_data.index)
			local empty_num = ItemData.Instance:GetEmptyNum()
			if empty_num > 0 then
				EquipData.Instance:SetTakeOffFlag(true)
			end
		end
		local equip_suit_type = ForgeData.Instance:GetCurEquipSuitType(item_data.index)
		if equip_suit_type ~= 0 then
			TipsCtrl.Instance:ShowCommonAutoView("", Language.Forge.ReturnSuitRock, yes_func)
		else
			PlayerCtrl.Instance:CSTakeOffEquip(item_data.index)
			local empty_num = ItemData.Instance:GetEmptyNum()
			if empty_num > 0 then
				EquipData.Instance:SetTakeOffFlag(true)
			end
		end
	end
end

-----------------------------------
-- 关闭事件
function PlayerView:HandleClose()
	ViewManager.Instance:Close(ViewName.Warehouse)
	ViewManager.Instance:Close(ViewName.Player)
end


-- 角色被拖转动事件
function PlayerView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function PlayerView:SetRoleFight(enable)
	UIScene:SetFightBool(enable)
end

function PlayerView:FlushRolePackageView(item_index)
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.role_zhuanzhi or cur_index == TabIndex.role_juexing then
		self:Flush("flush_zhuanzhi")
	else
		item_index = item_index or -1
		self:Flush("all", {["index" .. item_index] = item_index})
	end
end

function PlayerView:OnSwitchToShenEquip(is_switch)
	-- if self.package_view and (self.package_view:GetWareHourseState() or self.package_view:GetRecycleViewState())then
	-- 	self.node_list["RoleEquipView"]:SetActive(false)
	-- else
	-- 	self.node_list["RoleEquipView"]:SetActive(not is_switch)
	-- end
	-- self.node_list["Info"]:SetActive(not is_switch)
	-- self.node_list["BtnOpenTianShiEquip"]:SetActive(not is_switch)

	-- self.node_list["TianReturn"]:SetActive(is_switch)
	-- self.node_list["RoleShenEquipView"]:SetActive(is_switch)

	-- if is_switch and self.shen_equip_view then
	-- 	self.shen_equip_view:Flush()
	-- elseif self.package_view then
	-- 	self.package_view:FlushBagView()
	-- end
	-- self.is_switch_to_shen_equip = is_switch
	PlayerData.Instance:SetTianShiFlag(true)
	if self.info_view then
		self.info_view:Flush()
	end
end

function PlayerView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
	-- local open_fun_data = OpenFunData.Instance
	-- self.node_list["ToggleInfo"]:SetActive(open_fun_data:CheckIsHide("InfoContent"))
	-- self.node_list["ToggleTitle"]:SetActive(open_fun_data:CheckIsHide("TitlePanel"))
	-- self.node_list["ToggleSkill"]:SetActive(open_fun_data:CheckIsHide("SkillContent"))
	-- self.node_list["ToggleZhuanshen"]:SetActive(open_fun_data:CheckIsHide("role_rebirth"))
	-- self.node_list["ToggleTulongEquip"]:SetActive(open_fun_data:CheckIsHide("tulong_equip"))
end

function PlayerView:FlushSkillView()
	if self.skill_view then
		self.skill_view:FlushSkillExpInfo()
	end
end

function PlayerView:FlushMieShiSkillView()
	if self.skill_view then
		self.skill_view:FlushMieShiSkillView()
	end
end

function PlayerView:FlushInnateSkillView()
	if self.innate_skill_view then
		self.innate_skill_view:Flush()
	end
end

function PlayerView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "all" then
			if cur_index == TabIndex.role_active_skill then
				if self.active_skill_view then
					self.active_skill_view:FlushSkillExpInfo()
					self.active_skill_view:OnClickProfessionButton()
				end
			elseif cur_index == TabIndex.role_passive_skill then
				if self.passive_skill_view ~= nil then
					self.passive_skill_view:FlushSkillExpInfo()
					self.passive_skill_view:OnClickPassiveButton()
					self.passive_skill_view:FlushSkillState()
				end
			elseif cur_index == TabIndex.role_tianshu_skill then
				if self.tianshu_skill_view ~= nil then
					self.tianshu_skill_view:Flush()
				end
			elseif cur_index == TabIndex.role_innate_skill then
				if self.innate_skill_view ~= nil then
					self.innate_skill_view:Flush()
				end
			elseif cur_index == TabIndex.role_rebirth then
				if self.zhuansheng_view ~= nil then
					self.zhuansheng_view:FlushWeaponViewInfo()
				end
			elseif cur_index == TabIndex.role_title then
				if self.title_view then
					self.title_view:Flush()
				end
			elseif cur_index == TabIndex.role_reincarnation then
				if self.reincarnation_view then
					self.reincarnation_view:Flush()
				end

			elseif cur_index == TabIndex.role_shengyin then 
				if self.shengyin_view then
					self.shengyin_view:Flush()
				end
			elseif cur_index == TabIndex.role_zhuanzhi then
				if self.zhuanzhi_view then
					self.zhuanzhi_view:InitView()
				end
			elseif cur_index == TabIndex.role_juexing then 
				if self.juexing_view then
					self.juexing_view:InitView()
				end
			elseif cur_index == TabIndex.role_tulong_equip or cur_index == TabIndex.role_chuanshi_equip then
				if self.tulong_equip_view then
					self.tulong_equip_view:Flush()
				end
			end

			if self.shen_equip_view  then
				self.shen_equip_view:Flush()
			end
		elseif k == "bag" then
			if self.package_view then
				self.package_view:FlushBagView(v)
			end
		elseif k == "bag_recycle" then
			GlobalTimerQuest:AddDelayTimer(function()
				if self.package_view then
					self.package_view:FlushBagView()
					self.package_view:HandleOpenRecycle()
				end
			end, 0)
		elseif k == "title_change" then
			if self.title_view then
				self.title_view:Flush()
			end
		elseif k == "reincarnation" then
			if self.reincarnation_view  then
				self.reincarnation_view:Flush()
			end
		elseif k == "role_skill" then
			if self.skill_view  then
				self.skill_view:Flush()
			end
		elseif k == "tulong_equip" then
			if self.tulong_equip_view  then
				self.tulong_equip_view:Flush()
			end
		elseif k == "shen_equip_change" then
			if self.info_view then
				self.info_view:Flush()
				--self:Flush()
			end
		elseif k == "shenzhuang_view" then
			-- if cur_index == TabIndex.role_bag then
				self:OnSwitchToShenEquip(true)
			-- end
		elseif k == "shengyin_view" then 
			if self.shengyin_view then
				self.shengyin_view:Flush()
				--self:Flush()
			end
		elseif k == "luoshu_view" then
			if cur_index == TabIndex.baoju_luoshu then
				self:FlushTabbar()
			end
		elseif k == "luoshu" then
			if self.luoshu_view then
				self.luoshu_view:Flush()
			end
		elseif k == "flush_zhuanzhi" then
			if cur_index == TabIndex.role_zhuanzhi and self.zhuanzhi_view then
				self.zhuanzhi_view:FlushByItemChange()
			elseif cur_index == TabIndex.role_juexing and self.juexing_view then
				self.juexing_view:FlushByItemChange()
			end
		elseif k == "select_equip" then
			if cur_index == TabIndex.role_intro then
				if self.info_view then
					self.info_view:Flush("select_equip")
				end
			end
		-- elseif k == "forbid_avater_change" then
		-- 	if self.info_view then
		-- 		self.info_view:FlushForbidAvaterChange()
		-- 	end
		elseif k == "imp_guard_change" then
			if self.info_view then
				self.info_view:Flush("imp_guard_change")
			end
		elseif k == "xun_bao_act_btn" then
			if self.info_view then
				self.info_view:Flush("xun_bao_act_btn")	
			end		
		end
	end
end


function PlayerView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.role_reincarnation then
		self.node_list["ToggleReincarnation"].toggle.isOn = true
		if self.reincarnation_view then
			self.reincarnation_view:OpenCallBack()
			self.reincarnation_view:Flush()
		end
	end
end

function PlayerView:PackBagEquipClick()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
end

function PlayerView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if self.tabbar:GetTabButton(index) then
			local root_node = self.tabbar:GetTabButton(index).root_node
			local callback = BindTool.Bind(self.OpenIndexCheck, self, index)
			if index == self.show_index then
				return NextGuideStepFlag
			else
				return root_node, callback
			end
		end
	elseif ui_name == GuideUIName.ZhuanShengBtn then
		if self.zhuanzhi_view then
			return self.zhuanzhi_view:GetTaskBtn()
		end
	elseif ui_name == GuideUIName.TabEquip then
		if self.tab_equip and self.tab_equip.activeInHierarchy then
			if self.tab_equip.toggle.isOn then
				return NextGuideStepFlag
			end
			local callback = BindTool.Bind(self.PackBagEquipClick, self)
			return self.tab_equip, callback
		end
	elseif self[ui_name] then
		if self[ui_name].activeInHierarchy then
			return self[ui_name]
		end
	end
end

function PlayerView:ZhuanZhiTaskChange(task_event_type, task_id)
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	if task_cfg and task_cfg.task_type == TASK_TYPE.ZHUANZHI then
		if self.zhuanzhi_view and self.zhuanzhi_view:IsOpen() then
			self.zhuanzhi_view:Flush()
		end
		if self.juexing_view and self.juexing_view:IsOpen() then
			self.juexing_view:Flush()
		end
	end
end