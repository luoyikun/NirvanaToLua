ZhiBaoUpgradeView = ZhiBaoUpgradeView or BaseClass(BaseRender)

-- local AttrGetPower = nil
local EFFECT_CD = 1

local attr_order = {
	[1] = "gongji",
	[2] = "fangyu",
	[3] = "maxhp",
}
local attr_img = {
	[1] = "gj",
	[2] = "fy",
	[3] = "hp",
}

function ZhiBaoUpgradeView:__init()
	self.max_skill_num = 4
	self.effect_cd = 0
	-- --四个技能
	-- self.skill_list = {}
	-- for i = 1, self.max_skill_num do
	-- 	self.skill_list[i] = self.node_list["Skill"..i]
	-- 	self.skill_list[i].button:AddClickListener(BindTool.Bind(self.OnSkillClick, self, i))
	-- end

	--六个属性
	self.attr_list = {}
	local obj_group = self.node_list["ObjGroup"]
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "AttrGroup") ~= nil then
			self.attr_list[count] = ZhiBaoUpgradeAttrGroup.New(obj)
			self.attr_list[count]:SetIndex(count)
			count = count + 1
		end
	end

	--监听
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.OnUpgradeClick, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.HelpClick, self))


	--形象动画勋章
	-- local max_image = ZhiBaoData.Instance:GetMaxImageNum()
	self.selet_data_index = 1
	-- local get_icon_callback = BindTool.Bind(self.GetIconId, self)
	-- self.ani_medal = AniMedalIconPlus.New(self, max_image, get_icon_callback)
	self.ani_medal = AniMedalIconPlus.New(self)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNumber"])

	--阶级
	self.class_value = -1
	self:Flush()

end

function ZhiBaoUpgradeView:__delete()
	self.fight_text = nil
	if self.EquipModel then
		self.EquipModel:DeleteMe()
		self.EquipModel = nil
	end

	for k, v in ipairs(self.attr_list) do
		v:DeleteMe()
	end
	self.attr_list = {}

	if self.ani_medal then
		self.ani_medal:DeleteMe()
		self.ani_medal = nil
	end

end


-------------------------------
-- 结束
-------------------------------
function ZhiBaoUpgradeView:HelpClick()
	local tips_id = 20    -- 宝具tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ZhiBaoUpgradeView:RemindChangeCallBack(key, value)
end
-- function ZhiBaoUpgradeView:SetHuanHuaRedPoint()
-- end

--动画勋章 获取刷新数据
function ZhiBaoUpgradeView:GetIconId()
	local image = ZhiBaoData.Instance:GetZhiBaoImage()
	local level_cfg = ZhiBaoData.Instance:GetLevelImageCfg(self.selet_data_index)
	if not level_cfg then
		return
	end
	local cur_index = ZhiBaoData.Instance:GetZhiBaoImage()
	local name_str = ToColorStr(level_cfg.name, BAOJU_COLOR[level_cfg.color])
	self.node_list["TxtName"].text.text = name_str
	local id = level_cfg.image_id == 0 and 1 or level_cfg.image_id
	local bundle, asset = ResPath.GetHightBaoJuIcon(id)
	return bundle, asset
end

function ZhiBaoUpgradeView:OpenCallBack()
	self:SetNormalIcon()
	-- self:SetHuanHuaRedPoint()
end

function ZhiBaoUpgradeView:SetNormalIcon()
	local img_index = ZhiBaoData.Instance:GetZhiBaoImage()
	if img_index >= 1000 then
		self.selet_data_index = img_index - 1000
	elseif img_index == 0 then
		self.selet_data_index = 1
	else
		self.selet_data_index = img_index
	end
	self.ani_medal:IconSetData()

end

function ZhiBaoUpgradeView:ShowCurrentIcon()
	local level = ZhiBaoData.Instance:GetZhiBaoLevel()
	local cfg = ZhiBaoData.Instance:GetLevelCfgByLevel(level)
	if cfg ~= nil then
		self.selet_data_index = cfg.image_id
	else
		self.selet_data_index = 1
	end
	self.ani_medal:IconSetData()

end

function ZhiBaoUpgradeView:OnClassUpgrade()
	self:ShowCurrentIcon()
end

function ZhiBaoUpgradeView:AttrSetData(name, now_value, count, next_value)
	if count > #self.attr_list then
		print("属性超出最大可显示范围", name, now_value)
		return count
	end
	local data = {}
	local name_txt = name.." : "
	local value_txt = now_value
	data.now_attr_text = name_txt..ToColorStr(now_value, "#ffffff")
	if next_value ~= nil then
		data.next_attr_text = next_value
	end
	self.attr_list[count]:SetActive(true)
	self.attr_list[count]:SetData(data)
	count = count + 1
	return count
end

function ZhiBaoUpgradeView:UpGradeFlush()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectRoot"].transform,
			1.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ZhiBaoUpgradeView:Flush()
	self:PlayEffect()
	local zhibao_level = ZhiBaoData.Instance:GetZhiBaoLevel()
	if zhibao_level == nil then
		print_log('获取至宝等级失败')
		return
	end
	local next_image_cfg = ZhiBaoData.Instance:GetNextImageCfg()
	if next_image_cfg ~= nil then
		self.node_list["TxtMaxGrade"]:SetActive(true)
		self.node_list["TxtLevelValue"].text.text = next_image_cfg.level
	else
		self.node_list["TxtMaxGrade"]:SetActive(false)
	end

	self.node_list["ImgUpgradeRedPoint"]:SetActive(ZhiBaoData.Instance:CheckZhiBaoCanUpgrade())

	local cu_cfg = ZhiBaoData.Instance:GetLevelCfgByLevel(zhibao_level)
	local next_cfg = ZhiBaoData.Instance:GetLevelCfgByLevel(zhibao_level + 1)
	-- self.node_list["ImgLevelSlider"]:SetActive(next_cfg ~= nil)
	-- self.node_list["BtnUpgrade"]:SetActive(next_cfg ~= nil)
	-- self.node_list["TxtShowMaxLevel"]:SetActive(next_cfg == nil)
	--普通属性对
	local attrs = CommonDataManager.GetAttributteNoUnderline(cu_cfg)
	local next_attrs = CommonDataManager.GetAttributteNoUnderline(next_cfg)

	for k,v in pairs(self.attr_list) do
		v:SetActive(false)
	end
	local count = 1
	for i = 1, #attr_order do
		local key = attr_order[i]
			local name = CommonDataManager.GetAttrName(key)
			local next_attr_text = nil
			if next_cfg ~= nil then
				next_attr_text = next_attrs[key]
			end
			count = self:AttrSetData(name, attrs[key], count, next_attr_text)

	end
	--坐骑羽翼属性对
	--当前
	local mount_add = 0
	local wing_add = 0

	mount_add = cu_cfg.mount_attr_add
	wing_add = cu_cfg.wing_attr_add
	--下一
	local next_mount_cfg, next_wing_cfg = ZhiBaoData.Instance:GetNextAdditionCfg(mount_add, wing_add)
	--下一坐骑
	local m_name = Language.Common.AdvanceAttrName.mount_attr
	local m_value = '+'..(mount_add / 100)..'%'
	local m_next_value = nil
	if next_mount_cfg ~= nil then
		m_next_value = (next_mount_cfg.mount_attr_add / 100)..'%'..'('..next_mount_cfg.level..Language.Common.Ji..')'
	end
	count = self:AttrSetData(m_name, m_value, count, m_next_value)
	--下一羽翼
	local w_name = Language.Common.AdvanceAttrName.wing_attr
	local w_value = '+'..(wing_add / 100)..'%'
	local w_next_value = nil
	if next_wing_cfg ~= nil then
		w_next_value = (next_wing_cfg.wing_attr_add / 100)..'%'..'('..next_wing_cfg.level..Language.Common.Ji..')'
	end
	count = self:AttrSetData(w_name, w_value, count, w_next_value)
	--经验
	local playr_zhibao_exp = ZhiBaoData.Instance:GetZhiBaoExp()
	local next_level_text = ""
	local slider_value = 0
	local slider_text = ""
	UI:SetButtonEnabled(self.node_list["BtnUpgrade"], next_cfg ~= nil)
	if next_cfg ~= nil then
		slider_value = playr_zhibao_exp / cu_cfg.uplevel_exp
		next_level_text = 'Lv.'..zhibao_level + 1
		slider_text = playr_zhibao_exp..' / '..cu_cfg.uplevel_exp
		self.node_list["BtnUpgradeText"].text.text = Language.Common.UpGrade
	else
		slider_value = 1
		next_level_text = ""
		slider_text = Language.Common.YiMan
		self.node_list["BtnUpgradeText"].text.text = Language.Common.YiManJi
	end
	--等级
	self.node_list["TxtCurrentLevel"].text.text = "Lv."..zhibao_level
	--经验进度条
	self.node_list["SliderProgressBG"].slider.value = slider_value
	self.node_list["TxtSliderValue"].text.text = slider_text
	--阶级
	local cu_image_id = cu_cfg.image_id
	if cu_image_id > self.class_value then
		self.class_value = cu_cfg.image_id
		self:OnClassUpgrade()
	end

	-- --技能
	-- for i = 1, #self.skill_list do
	-- 	local cfg = ZhiBaoData.Instance:GetSkillCfgByIndex(i - 1)
	-- 	if cfg == nil then
	-- 		cfg = ZhiBaoData.Instance:GetSkillCfgBySkillLevel(i - 1, 1)
	-- 	end
	-- 	--TODO目前没有图标
	-- 	local bundle, asset = ResPath.GetBaoJuSkillIcon(cfg.skill_idx + 1)
	-- 	self.skill_list[i].image:LoadSprite(bundle, asset)
	-- 	local skill_data = ZhiBaoData.Instance:GetSkillCfgByIndex(i - 1)
	-- 	if skill_data then
	-- 		UI:SetGraphicGrey(self.skill_list[i], false)
	-- 	else
	-- 		UI:SetGraphicGrey(self.skill_list[i], true)
	-- 	end
	-- end
	--战斗力
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapability(attrs)
	end

	self.ani_medal:FlushMainIcon()

end

function ZhiBaoUpgradeView:PlayEffect()
	local res_id = self.selet_data_index
	local bundle_name, asset_name = ResPath.GetZhiBaoUpgradeEffect(res_id)
	self.node_list["EffectIcon"]:ChangeAsset(bundle_name, asset_name)
end

function ZhiBaoUpgradeView:OnSkillClick(skill_number)
	skill_number = skill_number - 1
	local skill_data = ZhiBaoData.Instance:GetSkillCfgByIndex(skill_number)
	local next_level = 0
	if skill_data ~= nil then
		next_level = skill_data.skill_level + 1
	else
		next_level = 1
	end
	local next_skill_data = ZhiBaoData.Instance:GetSkillCfgBySkillLevel(skill_number, next_level)
	TipsCtrl.Instance:ShowZhiBaoSkillView(skill_data, next_skill_data)
end

function ZhiBaoUpgradeView:OnUpgradeClick()
	if ZhiBaoData.Instance:GetZhiBaoCanUpgrade() then
		ZhiBaoCtrl.Instance:SendZhiBaoUpgrade()
		AudioService.Instance:PlayAdvancedAudio()
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotEnoughZhiBaoExp)
	end
end

-----------------ZhiBaoUpgradeAttrGroup属性对-----------

ZhiBaoUpgradeAttrGroup = ZhiBaoUpgradeAttrGroup or BaseClass(BaseCell)
function ZhiBaoUpgradeAttrGroup:__init()

end

function ZhiBaoUpgradeAttrGroup:__delete()
end

function ZhiBaoUpgradeAttrGroup:OnFlush()
	self.node_list["TxtNowAttr"].text.text = self.data.now_attr_text
	if self.data.next_attr_text ~= nil then
		self.node_list["ImgArrow"]:SetActive(true)
		self.node_list["TxtNextAttr"]:SetActive(true)
		self.node_list["TxtNextAttr"].text.text = self.data.next_attr_text
	else
		self.node_list["ImgArrow"]:SetActive(false)
		self.node_list["TxtNextAttr"]:SetActive(false)
	end
end
--通用动画勋章
AniMedalIconPlus = AniMedalIconPlus or BaseClass()

function AniMedalIconPlus:__init(mother_view)
	self.turning = false
	self.mother_view = mother_view

	self.left_arrow = mother_view.node_list["LeftArrow"]
	self.right_arrow = mother_view.node_list["RightArrow"]
	self.left_arrow.button:AddClickListener(BindTool.Bind(self.LeftClick, self))
	self.right_arrow.button:AddClickListener(BindTool.Bind(self.RightClick, self))

	self.get_icon_callback = get_icon_callback
	self.max_value = ZhiBaoData.Instance:GetMaxImageNum()
end

function AniMedalIconPlus:__delete()

end

--打开时重置显示
-- function AniMedalIconPlus:OpenCallBack()
-- 	self:IconSetData()
	
-- 	-- self.left_arrow:SetActive(self.mother_view.selet_data_index > 1)
-- 	-- self.right_arrow:SetActive(self.mother_view.selet_data_index < self.max_value)
-- end

--外部调用，刷新主勋章
function AniMedalIconPlus:FlushMainIcon()
	self:IconSetData()
end

--勋章 刷新数据
function AniMedalIconPlus:IconSetData()
	self.left_arrow:SetActive(self.mother_view.selet_data_index > 1)
	local cur_level = ZhiBaoData.Instance:GetZhiBaoImage()
	self.right_arrow:SetActive(self.mother_view.selet_data_index < cur_level +1 and self.mother_view.selet_data_index < self.max_value)
	local bundle, asset = self.mother_view:GetIconId()
	if nil == bundle or nil == asset then return end
	self.mother_view.node_list["ImgPicPath"].raw_image:LoadSprite(bundle, asset, function()
		self.mother_view.node_list["ImgPicPath"]:SetActive(true)
		self.mother_view.node_list["ImgPicPath"].raw_image:SetNativeSize()
		self.mother_view.node_list["ImgPicPath"].transform.localScale = Vector3(0.9, 0.9, 0.9)
		end)
end

--左换页
function AniMedalIconPlus:LeftClick()
	if self.turning or self.mother_view.selet_data_index - 1 <= 0 then
		return
	end
	self.mother_view.selet_data_index = self.mother_view.selet_data_index - 1
	self:IconSetData()
	self.mother_view:PlayEffect()
end

--右换页
function AniMedalIconPlus:RightClick()
	if self.turning or self.mother_view.selet_data_index + 1 > self.max_value then
		return
	end
	local cur_level = ZhiBaoData.Instance:GetZhiBaoLevel()
	local active_index = ZhiBaoData.Instance:GetJsByLevel(cur_level)
	if active_index >= self.mother_view.selet_data_index then
		self.mother_view.selet_data_index = self.mother_view.selet_data_index + 1
	end
	self:IconSetData()
	self.mother_view:PlayEffect()
end