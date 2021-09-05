-- 外观灵弓-ContentTwo
LingGongContentView = LingGongContentView or BaseClass(BaseRender)

local SHOWSPECGRADE = 10
function LingGongContentView:__init(instance)
	self.tesu_index = 0
	self.skill_list = {}
	self:GetSkill()
end

function LingGongContentView:LoadCallBack(instance)
	self.old_select_grade = 0
	self.select_grade = 0					--服务器阶数
	self.old_grade = -1

	self.node_list["UseButton"].button:AddClickListener(BindTool.Bind(self.ClickUse, self))
	self.node_list["BtnLeftButton"].button:AddClickListener(BindTool.Bind(self.ClickLeft, self))
	self.node_list["BtnRightButton"].button:AddClickListener(BindTool.Bind(self.ClickRight, self))
	self.node_list["BtnQualifications"].button:AddClickListener(BindTool.Bind(self.ClickZiZhi, self))
	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.ClickUpgrade, self, false))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.ClickUpgrade, self, true))
	self.node_list["BtnGrowup"].button:AddClickListener(BindTool.Bind(self.ClickGrowup, self))
	self.node_list["BtnTitle"].button:AddClickListener(BindTool.Bind(self.OnClickOpenSmallTarget, self))
	self.node_list["BtnBigTarget"].button:AddClickListener(BindTool.Bind(self.OnClickJinJieAward, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.ClickHuanHua, self))
	self.node_list["BtnEquipButton"].button:AddClickListener(BindTool.Bind(self.OnClickEquipBtn, self))
	self.node_list["ActPanel"].button:AddClickListener(BindTool.Bind(self.ClickActIcon, self))

	self.node_list["BtnGrowup"]:SetActive(false)
	self.node_list["BtnEquipButton"]:SetActive(true)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemParent"])

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	self.is_max = false
	self.is_can_tip = true
	self.prefab_preload_id = 0
end

function LingGongContentView:__delete()
	self:RemoveCountDown()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.clear_count_down then
		CountDown.Instance:RemoveCountDown(self.clear_count_down)
		self.clear_count_down = nil
	end
	self.tesu_index = 0
	self.skill_list = {}

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	self.fight_text = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["BtnTitle"])
end

function LingGongContentView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function LingGongContentView:GetSkill()
	for i = 1, 4 do
		local cur_level = 0
		local next_level = 1
		local skill = nil
		self.cur_data = LingGongData.Instance:GetSkillCfgById(i - 1) or {}
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = LingGongData.Instance:GetSkillCfgById(i - 1, next_level) or {}
		local is_teshu = false
		skill = self.node_list["Skill"..i]
		if self.cur_data and next(self.cur_data) and self.cur_data.is_teshu then
			is_teshu = self.cur_data.is_teshu == 1
		else
			if self.next_data_cfg and next(self.next_data_cfg) and self.next_data_cfg.is_teshu then
				is_teshu = self.next_data_cfg.is_teshu == 1
			end
		end
		if is_teshu then
			skill = self.node_list["SpecialSkill"]
			self.node_list["Skill" ..i ]:SetActive(false)
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
			self.tesu_index = i
		end

		self.node_list["SpecialSkill"]:SetActive(false)
		self.node_list["SpecialSkillText"]:SetActive(false)
		local bundle, asset = ResPath.GetLingGongSkillIcon(i)
		local icon = skill.transform:FindHard("Image")
		icon = U3DObject(icon, icon.transform, self)
		icon.image:LoadSprite(bundle, asset)
		table.insert(self.skill_list, {skill = skill, icon = icon})
		skill.toggle:AddClickListener(BindTool.Bind(self.ClickLingGongSkill, self, i))
	end
end

-- 点击灵弓幻化按钮
function LingGongContentView:ClickHuanHua()
	ViewManager.Instance:Open(ViewName.LingGongHuanHua)
end

-- 点击灵弓成长按钮
function LingGongContentView:ClickGrowup()
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if nil == linggong_info or nil == linggong_info.grade then return end
	local is_activie = linggong_info.grade - 1 >= APPEARANCE_SHUXINGDAN_LIMIT.CHENGZHANGDAN
	if not is_activie then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.MultiMount.UpGradeStartThree, Language.Common.NumToChs[APPEARANCE_SHUXINGDAN_LIMIT.CHENGZHANGDAN]))
	else
		ViewManager.Instance:Open(ViewName.TipChengZhang, nil, "linggongchengzhang", {item_id = LingGongShuXingDanId.ChengZhangDanId})
	end
end

-- 点击灵弓资质按钮
function LingGongContentView:ClickZiZhi()
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if nil == linggong_info or nil == linggong_info.grade then return end
	local is_activie = linggong_info.grade - 1 >= APPEARANCE_SHUXINGDAN_LIMIT.ZIZHIDAN
	if not is_activie  then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.MultiMount.UpGradeStartTwo, Language.Common.NumToChs[APPEARANCE_SHUXINGDAN_LIMIT.ZIZHIDAN]))
	else
		ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "linggong_zizhi", {item_id = LingGongShuXingDanId.ZiZhiDanId})
	end
end

-- 点击进阶装备
function LingGongContentView:OnClickEquipBtn()
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if nil ~= linggong_info and nil ~= linggong_info.grade then
		if linggong_info.grade <= APPEARANCE_SHUXINGDAN_LIMIT.EQUIPLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.MultiMount.UpGradeStartFour, Language.Common.NumToChs[APPEARANCE_SHUXINGDAN_LIMIT.EQUIPLEVEL]))
		else
			ViewManager.Instance:Open(ViewName.AppearacneEquipView, TabIndex.appearance_linggong)
		end
	end
end

-- 点击灵弓技能
function LingGongContentView:ClickLingGongSkill(index)
	if self.is_shake_skill and index == 1 then
		self.node_list["Special"].animator:SetBool("IsShake", false)
		self.is_shake_skill = nil
	end
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "linggongskill", {index = index - 1})
end

function LingGongContentView:ClickUse()
	local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.select_grade)
	if nil == grade_info then return end
	UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_GONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_USE_IMAGE, 0, grade_info.image_id)
end

function LingGongContentView:ClickLeft()
	self.select_grade = self.select_grade - 1
	self:FlushView()
end

function LingGongContentView:ClickRight()
	self.select_grade = self.select_grade + 1
	self:FlushView()
end

function LingGongContentView:ClickUpgrade(is_auto_upgrade)
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if nil == linggong_info then return end
	local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_info.grade)
	if nil == grade_info then return end

	local close_func = function()
		--获取下一级，不存在则满级
		local next_grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_info.grade + 1)
		if nil == next_grade_info then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.MaxGradeText)
			return
		end

		local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
		local item_id = grade_info.upgrade_stuff_id
		local item_id2 = grade_info.upgrade_stuff2_id
		local need_item_num = grade_info.upgrade_stuff_count
		local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)

		if is_auto_buy == 0 and have_item_num < need_item_num then
			local function buy_call_back(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
				self.node_list["AutoToggle"].toggle.isOn = is_buy_quick
			end
			TipsCtrl.Instance:ShowCommonBuyView(buy_call_back, item_id, nil, 1)
			return
		end

		-- 进阶一次
		if not is_auto_upgrade then
			UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_GONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_UPGRADE, 1, is_auto_buy)
			return
		end

		-- 自动进阶
		self.is_upgrade_state = not self.is_upgrade_state
		self:SetBtnState(self.is_upgrade_state, self.is_max)
		if self.is_upgrade_state then
			UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_GONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_UPGRADE,grade_info.pack_num, is_auto_buy)
		end
	end

	local describe = Language.Advance.AdvanceReturnNotLingQu
	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() and self.is_can_tip then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN)
		local is_not_lingqu_one = AdvancedReturnData.Instance:GetFanHuanRemind() == 1
		local is_not_lingqu_two = AdvancedReturnTwoData.Instance:GetFanHuanTwoRemind() == 1
		if open_advance_one == 1 and is_not_lingqu_one then
			local ok_func = function()
				ViewManager.Instance:Open(ViewName.AdvancedReturn)
			end
			TipsCtrl.Instance:ShowCommonTip(ok_func, nil, describe, nil, close_func)
			return 
		elseif open_advance_two == 1 and is_not_lingqu_two then
			local ok_func = function()
				ViewManager.Instance:Open(ViewName.AdvancedReturnTwo)
			end
			TipsCtrl.Instance:ShowCommonTip(ok_func, nil, describe, nil, close_func)
			return
		end
	end


	local is_have_zhishengdan, item_id = LingGongData.Instance:IsHaveZhiShengDanInGrade()
	local item = ItemData.Instance:GetItem(item_id)
	if is_have_zhishengdan and self.is_can_tip and item then
	    local function ok_callback()
	      PackageCtrl.Instance:SendUseItem(item.index, 1)
	    end  
	    TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Advance.IsUseZhiShengDan, linggong_info.grade), ok_callback, close_func)
	    return
	end
	
	close_func()
end

function LingGongContentView:OpenCallBack()
	self.is_upgrade_state = false
	self:SetBtnState(false, self.is_max)
	self.node_list["AutoToggle"].toggle.isOn = false

	self.old_select_grade = 0
	self.select_grade = 0
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	local is_huanhua_img = LingGongData.Instance:IsHuanHuaImage(linggong_info.used_imageid)
	if nil ~= linggong_info then
		--默认选择已使用的形象阶数
		if linggong_info.grade == 1 then
			--零阶和一阶使用相同形象
			self.select_grade = linggong_info.grade
		else
			if is_huanhua_img then
				local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_info.grade)
				if nil == grade_info then return end
				local image_cfg = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(grade_info.image_id)
				if nil == image_cfg then return end
				-- show_grade为客户端阶数由0开始，服务器阶数由1开始，所以要加1
				self.select_grade = image_cfg.show_grade + 1
			else
				local image_cfg = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(linggong_info.used_imageid)
				if nil == image_cfg then return end
				-- show_grade为客户端阶数由0开始，服务器阶数由1开始，所以要加1
				self.select_grade = image_cfg.show_grade + 1
			end

		end
	end
end

function LingGongContentView:FlushView()
	self:FlushLeft()
	self:FlushRight()
	self:FlushSkillIcon()
end

function LingGongContentView:FlushSkillIcon()
	local linggong_skill_list = LingGongData.Instance:GetLingGongInfo().skill_level_list

	if nil == linggong_skill_list then
		return
	end

	for k, v in pairs(self.skill_list) do
		local node = v.skill.transform:FindHard("Image")
		if node then
			UI:SetGraphicGrey(node, linggong_skill_list[k - 1] == 0)
		end
	end
	local cur_level = 0
	local next_level = 1
	local cur_data = LingGongData.Instance:GetSkillCfgById(self.tesu_index - 1) or {}
	if next(cur_data) then
		cur_level = cur_data.skill_level
		next_level = cur_level + 1
	end
	local next_data_cfg = LingGongData.Instance:GetSkillCfgById(self.tesu_index - 1, next_level) or {}
	if next(next_data_cfg) then
		self.node_list["JiHuo"]:SetActive(true)
		self.node_list["JiHuo"].text.text = next_data_cfg.jineng_desc or ""
	else
		self.node_list["JiHuo"]:SetActive(false)
	end
	self.node_list["MostFightPower"]:SetActive(self.tesu_index ~= 0)

	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if linggong_info ~= nil or next(linggong_info) ~= nil then
		if linggong_info.grade > SHOWSPECGRADE then
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
		end
	end
end

function LingGongContentView:FlushModel()
	local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.select_grade)
	if nil == grade_info then return end
	local image_cfg = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(grade_info.image_id)
	if nil == image_cfg then return end
	-- print_warning("<color=#07F862FF>灵弓_ID:" .. grade_info.image_id .. "</color>")

	local bundle, asset = ResPath.GetLingGongModel(image_cfg.res_id_h)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function LingGongContentView:FlushLeft()
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if nil == linggong_info then return end

	--初始记录旧阶数
	if self.old_grade < 0 then
		self.old_grade = linggong_info.grade
	end

	if self.old_grade ~= linggong_info.grade then
		--进阶成功
		AudioService.Instance:PlayAdvancedAudio()
		self:PlayEffect()
		self.old_grade = linggong_info.grade
		self.select_grade = linggong_info.grade
	end

	--刷新模型
	if self.select_grade ~= self.old_select_grade then
		self.old_select_grade = self.select_grade
		self:FlushModel()
	end

	local temp_grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.select_grade)
	if nil == temp_grade_info then return end
	local image_info = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(temp_grade_info.image_id)
	if nil == image_info then return end
	self.node_list["Name"].text.text = temp_grade_info.gradename .. "·" .. ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])

	-- 刷新使用状态
	local is_used = temp_grade_info.image_id == linggong_info.used_imageid
	if linggong_info.grade >= self.select_grade then
		self.node_list["UseImage"]:SetActive(is_used)
		self.node_list["UseButton"]:SetActive(not is_used)
	else
		self.node_list["UseImage"]:SetActive(false)
		self.node_list["UseButton"]:SetActive(false)
	end

	--刷新左右箭头
	local last_temp_grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.select_grade - 1)
	local is_show_left = true
	if nil == last_temp_grade_info or (linggong_info.grade > 1 and temp_grade_info.show_grade == 1) then
		--没有上一阶属性或者处于第一阶(服务器第二阶)不显示左箭头
		is_show_left = false
	end
	self.node_list["BtnLeftButton"]:SetActive(is_show_left)

	local next_temp_grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.select_grade + 1)
	local is_show_right = true
	if nil == next_temp_grade_info or self.select_grade > linggong_info.grade then
		is_show_right = false
	end
	self.node_list["BtnRightButton"]:SetActive(is_show_right)

	-- 刷新左侧技能列表特效
	local can_upgrade_skill_list = LingGongData.Instance:CanSkillUpLevelList()
	if can_upgrade_skill_list then
		for i = 1, 3 do 
			self.node_list["UpLevelEffect" .. i]:SetActive(can_upgrade_skill_list[i] ~= nil)
		end
	end

	self.node_list["EffectZiZhi"]:SetActive(LingGongData.Instance:IsShowZiZhiRemind())
	self.node_list["EffectBtnGrowup"]:SetActive(LingGongData.Instance:IsShowGrowupRemind())
	self.node_list["ShowEquipRemind"]:SetActive(LingGongData.Instance:CalAllEquipRemind() > 0)
	local is_show_huanhua_remind = LingGongData.Instance:CalcHuanHuaRemind() == 1 and true or false
	self.node_list["HuanhuaRedPoint"]:SetActive(is_show_huanhua_remind)
	self:SetBtnZiZhi(linggong_info)
	self:SetBtnGrowup(linggong_info)
	self:SetBtnEquip(linggong_info)
end

function LingGongContentView:FlushRight()
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if nil == linggong_info then return end
	local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_info.grade)
	if nil == grade_info then return end
	-- 获取下一阶属性，如果存在则不是最大等级
	local next_grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_info.grade + 1)
	local bless_value_ratio = linggong_info.grade_bless_val / grade_info.bless_val_limit

	local switch_attr_list_1 = CommonDataManager.GetOrderAttributte(next_grade_info)
	local switch_attr_list_0 = CommonDataManager.GetOrderAttributte(grade_info)

	-- 使用成长丹增加基础属性
	if linggong_info.grade == 1 then
		local index = 0
		for k, v in pairs(switch_attr_list_1) do
			local attr_name = Language.MultiMount.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = switch_attr_list_0[k].value or 0
				self.node_list["NextAttr" .. index]:SetActive(next_grade_info ~= nil)
				self.node_list["NextValue" .. index].text.text = v.value
			end
		end
	else
		local index = 0
		for k, v in pairs(switch_attr_list_0) do
			local attr_name = Language.MultiMount.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = v.value
				self.node_list["NextAttr" .. index]:SetActive(next_grade_info ~= nil)
				self.node_list["NextValue" .. index].text.text = switch_attr_list_1[k] and switch_attr_list_1[k].value - v.value or 0
			end
		end
	end

	local max_grade = LingGongData.Instance:GetLingGongMaxGrade()
	local active_grade, attr_type, attr_value = LingGongData.Instance:GetSpecialAttrActiveType()
	if active_grade and attr_type and attr_value then
		if linggong_info.grade < active_grade then
			local str = string.format(Language.Advance.LevelOpen, CommonDataManager.GetDaXie(active_grade - 1))
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = linggong_info.grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = LingGongData.Instance:GetSpecialAttrActiveType(i)
				if next_attr_value then
					if next_attr_value ~= attr_value then
						special_attr = next_attr_value - attr_value
						str = string.format(Language.Advance.NextAttr, CommonDataManager.GetDaXie(next_active_grade - 1), special_attr/100)
						break
					end
				end
			end
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		end
	else
		self.node_list["TxtSpecialAttr"]:SetActive(false)
	end

	local attr = LingGongData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
	-- 转换显示样式
	local switch_attr_list = CommonDataManager.SwitchAttri(attr)
	-- self.node_list["HPValue"].text.text = switch_attr_list.max_hp
	-- self.node_list["FangYu"].text.text = switch_attr_list.fang_yu
	-- self.node_list["GongJi"].text.text = switch_attr_list.gong_ji
	
	-- -- 特殊属性
	-- -- UI:SetGraphicGrey(self.node_list["TxtSpecialAttr"], grade_info.jianren == 0)
	-- local str_special_attr = ""
	-- if grade_info.jianren == 0 then
	-- 	str_special_attr = string.format(Language.MultiMount.SpecialAttribute[4] .. Language.MultiMount.LevelStart, 5)
	-- else
	-- 	local level, add_attr = LingGongData.Instance:GetGradeAndSpecialAttr()
	-- 	local str = ""
	-- 	if level and add_attr then
	-- 		str = string.format(Language.Advance.NextAttr, CommonDataManager.GetDaXie(level - 1), add_attr/100)
	-- 	end
	-- 	str_special_attr = string.format(Language.MultiMount.SpecialAttribute[4], grade_info.jianren / 100) .. str
	-- end
	-- self.node_list["TxtSpecialAttr"].text.text = str_special_attr

	-- -- 设置临时属性
	-- self.node_list["TmpGongjValue"]:SetActive(false)
	-- local tmp_attack_value = 0
	-- if grade_info and next_grade_info and linggong_info.grade_bless_val ~= 0 then
	-- 	tmp_attack_value = math.floor((next_grade_info.gongji - grade_info.gongji) * bless_value_ratio)
	-- 	self.node_list["TmpGongjValue"]:SetActive(true)
	-- 	self.node_list["TmpGongjValue"].text.text = string.format(Language.MultiMount.TmpAttr, tmp_attack_value)
	-- end

	if next_grade_info then
		self.is_max = false
		self.node_list["ProgressValue"].slider.value = tostring(bless_value_ratio)
		self.node_list["TxtProgress"].text.text = string.format("%s/%s", linggong_info.grade_bless_val, grade_info.bless_val_limit)
	else
		self.is_max = true
		self.node_list["ProgressValue"].slider.value = 1
		self.node_list["TxtProgress"].text.text = Language.Common.YiMan
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(attr) + CommonDataManager.GetCapabilityCalculation({gong_ji = tmp_attack_value})
	end
	self:SetBtnState(self.is_upgrade_state, self.is_max)
	self:FlushItem()
	self:ClearBlessTip(linggong_info, grade_info)
end

--祝福值提示 清空祝福值 清空时间
function LingGongContentView:ClearBlessTip(linggong_info, grade_cfg)
	-- 最大等级
	if self.is_max then
		if nil ~= self.clear_count_down then
			CountDown.Instance:RemoveCountDown(self.clear_count_down)
			self.clear_count_down = nil
		end
		self.node_list["TxtBlessTip"].text.text = ""
		return
	end

	-- 不清空祝福值则显示提示信息
	if APPEARANCE_CLEAR_BLESS.NOT_CLEAR == grade_cfg.is_clear_bless then
		self.node_list["TxtBlessTip"].text.text = Language.MultiMount.ClearBlessTip
		return
	end

	-- 当祝福值为0要清空计时器
	if linggong_info.grade_bless_val == 0 then
		if nil ~= self.clear_count_down then
			CountDown.Instance:RemoveCountDown(self.clear_count_down)
			self.clear_count_down = nil
		end
	end

	-- 显示清空祝福值倒计时
	if APPEARANCE_CLEAR_BLESS.CLEAR == grade_cfg.is_clear_bless then
		if linggong_info.grade_bless_val == 0  then
			self.node_list["TxtBlessTip"].text.text = Language.MultiMount.ClearBlessTipTwo
			return
		end
		local clear_bless_time = linggong_info.clear_upgrade_time
		local server_time = TimeCtrl.Instance:GetServerTime()
		local remaining_time = clear_bless_time - server_time
		if nil == self.clear_count_down then
			self:ClickTimer(remaining_time)
			self.clear_count_down = CountDown.Instance:AddCountDown(remaining_time,1,function()
				remaining_time = remaining_time - 1
				local tmp_time = TimeUtil.FormatSecond(remaining_time - 1)
				self.node_list["TxtBlessTip"].text.text = string.format(Language.MultiMount.ClearBlessStr,tostring(tmp_time))
			end)
		end
	end
end

-- 计时器,用于取消默认延迟1s显示
function LingGongContentView:ClickTimer(remaining_time)
	remaining_time = remaining_time - 1
	local tmp_time = TimeUtil.FormatSecond(remaining_time - 1)
	self.node_list["TxtBlessTip"].text.text = string.format(Language.MultiMount.ClearBlessStr,tostring(tmp_time))
end

function LingGongContentView:UpGradeResult(result)
	if not self.is_upgrade_state then return end
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if nil == linggong_info then return end
	local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_info.grade)
	if nil == grade_info then return end

	if result == 0 then
		self.is_upgrade_state = false
		self:SetBtnState(false, self.is_max)
		local item_id = grade_info.upgrade_stuff_id
		local item_id2 = grade_info.upgrade_stuff2_id
		local need_item_num = grade_info.upgrade_stuff_count
		local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)
		local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn
		if not is_auto_buy and not self.is_max and need_item_num > have_item_num then
			local function buy_call_back(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
				self.node_list["AutoToggle"].toggle.isOn = is_buy_quick
			end
			TipsCtrl.Instance:ShowCommonBuyView(buy_call_back, item_id, nil, 1)
		end
		return
	end

	self:SetBtnState(true, self.is_max)
	self:FlushView()

	local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
	UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_GONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_UPGRADE, grade_info.pack_num, is_auto_buy)
end

-- 设置进阶按钮状态
function LingGongContentView:SetBtnState(is_upgrade_state, is_max)
	self.is_can_tip = not is_upgrade_state
	if is_max then
		UI:SetButtonEnabled(self.node_list["AutoButton"], false)
		self.node_list["StartButton"]:SetActive(false)
		self.node_list["AutoButtonText"].text.text = Language.MultiMount.YiManJie
		return
	end

	if not is_max and not is_upgrade_state then
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
	end

	if is_upgrade_state then
		self.node_list["AutoButtonText"].text.text = Language.Common.Stop
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
	else
		self.node_list["AutoButtonText"].text.text = Language.Common.ZiDongJinJie
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
	end
end

-- 设置资质丹按钮状态
function LingGongContentView:SetBtnZiZhi(linggong_info)
 	local is_activie = linggong_info.grade - 1 >= APPEARANCE_SHUXINGDAN_LIMIT.ZIZHIDAN
 	UI:SetGraphicGrey(self.node_list["BtnQualifications"], not is_activie)
 	self.node_list["TxtZiZhi"].text.text = is_activie and Language.MultiMount.ZiZhi or
			string.format(Language.MultiMount.UpGradeStart, Language.Common.NumToChs[APPEARANCE_SHUXINGDAN_LIMIT.ZIZHIDAN])
end

-- 设置成长丹按钮状态
function LingGongContentView:SetBtnGrowup(linggong_info)
	local is_activie = linggong_info.grade - 1 >= APPEARANCE_SHUXINGDAN_LIMIT.CHENGZHANGDAN
	UI:SetGraphicGrey(self.node_list["BtnGrowup"], not is_activie)
	self.node_list["TxtBtnGrowup"].text.text = is_activie and Language.MultiMount.Growup or 
			string.format(Language.MultiMount.UpGradeStart, Language.Common.NumToChs[APPEARANCE_SHUXINGDAN_LIMIT.CHENGZHANGDAN])
end

-- 设置装备按钮状态
function LingGongContentView:SetBtnEquip(linggong_info)
	local is_activie = linggong_info.grade - 1 >= APPEARANCE_SHUXINGDAN_LIMIT.EQUIPLEVEL
	UI:SetGraphicGrey(self.node_list["BtnEquipButton"], not is_activie)
	self.node_list["TextEquip"].text.text = is_activie and Language.MultiMount.LinggongEquipType or 
			string.format(Language.MultiMount.UpGradeStart, Language.Common.NumToChs[APPEARANCE_SHUXINGDAN_LIMIT.EQUIPLEVEL])
end

function LingGongContentView:FlushItem()
	local linggong_info = LingGongData.Instance:GetLingGongInfo()
	if nil == linggong_info then return end
	local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_info.grade)
	if nil == grade_info then return end

	local item_id = grade_info.upgrade_stuff_id
	local item_id2 = grade_info.upgrade_stuff2_id
	local need_item_num = grade_info.upgrade_stuff_count
	local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)
	self.item_cell:SetData({item_id = item_id})

	local  str_have_num = have_item_num .. ""
	if have_item_num < need_item_num then
		str_have_num = ToColorStr(have_item_num, TEXT_COLOR.RED)
	end
	if self.is_max then
		self.node_list["TxtItemNum"].text.text = Language.MultiMount.MaxGradeDesc
	else
		self.node_list["TxtItemNum"].text.text = string.format("%s / %d", str_have_num, need_item_num)
	end
	self.node_list["RemindBtn"]:SetActive(LingGongData.Instance:IsShowUpgradeBtnRemind() and not self.is_upgrade_state)
end

function LingGongContentView:PlayEffect()
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_jinjiechenggeng")
	EffectManager.Instance:PlayAtTransformCenter(
		bundle_name,
		asset_name,
		self.node_list["ShowEffect"].transform,
		2.0)
end

function LingGongContentView:OnFlush(param_t)
	self:JinJieReward()
	for k, v in pairs(param_t) do
		if k == "all" then
			self:FlushView()
			self:FlushItem()
		elseif k == "linggong" then
			self:FlushView()
		elseif k == "linggong_upgrade" then
			self:UpGradeResult(v[1])
		elseif k == "linggong_item_change" then
			self:FlushItem()
		end
	end
end

function LingGongContentView:UITween()
	UITween.MoveShowPanel(self.node_list["BottomPanel"], Vector3(0, -10, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BtnGrop"], Vector3(-44.5, 550, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Title"], Vector3(0, 40, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["InfoPanel"], Vector3(63, -25.9, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["SkillPanel"], Vector3(0, -90.2, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["LeftPanel"], true, 0.5, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["RightPanel"], true, 0.5, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["Panel1"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["ActPanel"], GoddessData.TweenPosition.Up2 , 0.7)
end

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function LingGongContentView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_LINGGONG
	local is_show_small_target = JinJieRewardData.Instance:IsShowSmallTarget(system_type)
	self.node_list["JinJieSmallTarget"]:SetActive(is_show_small_target)
	local target_type
	if is_show_small_target then --小目标
		target_type = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		self:SmallTargetConstantData(system_type, target_type)
		self:SmallTargetNotConstantData(system_type, target_type)
	else -- 大目标
		target_type = JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET
		self:BigTargetConstantData(system_type, target_type)
		self:BigTargetNotConstantData(system_type, target_type)
	end

	JinJieRewardData.Instance:SetCurSystemType(system_type)

	local is_bipin = AdvanceData.Instance:GetIsBiPinSystemType(system_type)
	if is_bipin and OpenFunData.Instance:CheckIsHide("advance_target") then
		local linggong_info = LingGongData.Instance:GetLingGongInfo()
		if linggong_info == nil or linggong_info.grade == nil then
			return
		end
		
		local cur_img_grade = linggong_info.grade - 1
		if not self.old_img_grade then
			self.old_img_grade = cur_img_grade
		end

		if cur_img_grade < 5 then
			self.act_click_type = 1
			self.node_list["ActPanel"]:SetActive(true)
			self.node_list["ActDesc"].text.text = Language.Advance.ActStateText
			self:SetActTime()
		elseif cur_img_grade >= 5 and cur_img_grade < 8 then
			self.act_click_type = 2
			self.node_list["ActPanel"]:SetActive(true)
			self.node_list["ActDesc"].text.text = Language.Advance.ActStateText2
			self:SetActTime()
		elseif cur_img_grade == 8 then
			self.act_click_type = 3
			self.node_list["ActPanel"]:SetActive(true)
			self.node_list["ActDesc"].text.text = Language.Advance.ActStateText3
			self:SetActTime()
		else
			self.act_click_type = nil
			self.node_list["ActPanel"]:SetActive(false)
		end

		if self.act_click_type then
			local item_id = AdvanceData.Instance:GetSystemTypeJinJieItem(system_type, self.act_click_type)
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
			self.node_list["ActIcon"].image:LoadSprite(bundle, asset)
		end

		if self.old_img_grade == 2 and cur_img_grade == 3 then
			AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 1)
		elseif self.old_img_grade == 3 and cur_img_grade == 4 then
			local item_id = AdvanceData.Instance:GetSystemTypeJinJieItem(system_type, UPLEVEL_ITEM_TYPE.SMALL_TYPE)
			local item = ItemData.Instance:GetItem(item_id)
			if item then
				-- local function ok_callback()
				-- 	PackageCtrl.Instance:SendUseItem(item.index, 1)
				-- end	
				-- TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Advance.IsUseItem, ok_callback)
			else
				AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 2)
			end
		elseif self.old_img_grade == 4 and cur_img_grade == 5 then
			self:OnClickOpenSmallTarget()
		elseif self.old_img_grade == 5 and cur_img_grade == 6 then
			AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 3)
		elseif self.old_img_grade == 6 and cur_img_grade == 7 then
			local item_id = AdvanceData.Instance:GetSystemTypeJinJieItem(system_type, UPLEVEL_ITEM_TYPE.BIG_TYPE)
			local item = ItemData.Instance:GetItem(item_id)
			if item then
				-- local function ok_callback()
				-- 	PackageCtrl.Instance:SendUseItem(item.index, 1)
				-- end	
				-- TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Advance.IsUseItem2, ok_callback)
			else
				AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 4)
			end
		elseif self.old_img_grade == 7 and cur_img_grade == 8 then
			AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 5)
		elseif self.old_img_grade == 8 and cur_img_grade == 9 then
			self:OnClickJinJieAward()
		elseif self.old_img_grade == 9 and cur_img_grade == 10 then
			self.node_list["Special"].animator:SetBool("IsShake", true)
			self.is_shake_skill = true
		elseif self.is_shake_skill and cur_img_grade >= 11 then
			self.node_list["Special"].animator:SetBool("IsShake", false)
			self.is_shake_skill = nil
		end
		self.old_img_grade = cur_img_grade
	else
		self.node_list["ActPanel"]:SetActive(false)
	end		
end

function LingGongContentView:ClickActIcon()
	if not self.act_click_type then
		local system_type = JINJIE_TYPE.JINJIE_TYPE_LINGGONG
		local linggong_info = LingGongData.Instance:GetLingGongInfo()
		if linggong_info == nil or linggong_info.grade == nil then
			return
		end
		local cur_img_grade = linggong_info.grade - 1
		if cur_img_grade < 5 then
			self.act_click_type = 1
		elseif cur_img_grade >= 5 and cur_img_grade < 8 then
			self.act_click_type = 2
		elseif cur_img_grade == 8 then
			self.act_click_type = 3
		end
	end

	if self.act_click_type == 1 then
		local index = DailyChargeData.Instance:GetIsOpenActiveReward() and 3 or 2
		ViewManager.Instance:Open(ViewName.LeiJiDailyView, nil, "list_index", {["list_index"] = index})
	elseif self.act_click_type == 2 then
		local index = DailyChargeData.Instance:GetIsOpenActiveReward() and 5 or 4
		ViewManager.Instance:Open(ViewName.LeiJiDailyView, nil, "list_index", {["list_index"] = index})
	elseif self.act_click_type == 3 then
		ViewManager.Instance:Open(ViewName.CompetitionActivity)
	end
end

function LingGongContentView:SetActTime()
	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local diff_time = 24 * 3600 - cur_time
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			self.node_list["ActTime"].text.text = string.format(Language.Advance.ActTimeDesc, TimeUtil.FormatSecond(left_time, 10))
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end	
end

--清除大目标/小目标免费数据 target_type 目标类型  不传默认大目标
function LingGongContentView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = ""
		self.node_list["TitleFreeTime"]:SetActive(false)
	else    --大目标
		self.node_list["TextFreeTime"].text.text = ""
		self.node_list["TextFreeTime"]:SetActive(false)
	end
end

--大目标 变动显示
function LingGongContentView:BigTargetNotConstantData(system_type, target_type)
	local is_show_jin_jie = JinJieRewardData.Instance:IsShowJinJieRewardIcon(system_type)
	local speical_is_active = JinJieRewardData.Instance:GetSystemIsActiveSpecialImage(system_type)
	local active_is_end = JinJieRewardData.Instance:GetSystemFreeIsEnd(system_type)
	local active_big_target = JinJieRewardData.Instance:GetSystemIsGetActiveNeedItemFromInfo(system_type)
	local can_fetch = JinJieRewardData.Instance:GetSystemIsCanFreeLingQuFromInfo(system_type)
	self.node_list["JinJieBig"]:SetActive(is_show_jin_jie)
	self.node_list["RedPoint"]:SetActive(not speical_is_active)
	self.node_list["TextFreeTime"]:SetActive(not active_is_end)
	self.node_list["Panel1"].animator:SetBool("IsShake1", can_fetch and not active_big_target)
	self.node_list["big_goal_redpoint"]:SetActive(can_fetch and not active_big_target)
	UI:SetGraphicGrey(self.node_list["ItemImage"], not active_big_target)
	self:RemoveCountDown()

	if active_is_end then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	self:FulshJinJieFreeTime(end_time, target_type)
end

--小目标 变动显示
function LingGongContentView:SmallTargetNotConstantData(system_type, target_type)
	local is_free_end = JinJieRewardData.Instance:GetSystemSmallTargetFreeIsEnd(system_type)
	local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(system_type)
	UI:SetGraphicGrey(self.node_list["BtnTitle"], not is_can_free)
	-- UI:SetGraphicGrey(self.node_list["BtnBigTarget"], not is_can_free)
	self.node_list["TitleFreeTime"]:SetActive(not is_free_end)
	self.node_list["Panel1"].animator:SetBool("IsShake1", is_can_free)
	self.node_list["little_goal_redpoint"]:SetActive(is_can_free)
	self:RemoveCountDown()

	if is_free_end then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	self:FulshJinJieFreeTime(end_time, target_type)
end

--小目标固定显示
function LingGongContentView:SmallTargetConstantData(system_type, target_type)
	if self.set_small_target then
		return 
	end

	self.set_small_target = true
	local small_target_title_image = JinJieRewardData.Instance:GetSingleRewardCfgParam0(system_type, target_type)
	local bundle, asset = ResPath.GetTitleIcon(small_target_title_image)
	self.node_list["BtnTitle"].image:LoadSprite(bundle, asset)
	TitleData.Instance:LoadTitleEff(self.node_list["BtnTitle"], small_target_title_image or 0, true)

	local power = JinJieRewardData.Instance:GetSmallTargetTitlePower(target_type)
	self.node_list["TitlePower"].text.text = string.format(Language.Advance.AddFightPower, power)
end

--大目标固定显示
function LingGongContentView:BigTargetConstantData(system_type, target_type)
	local flag = JinJieRewardData.Instance:IsShowJinJieRewardIcon(system_type)
	if not flag or self.set_big_target then
		return
	end

	self.set_big_target = true
	local item_id = JinJieRewardData.Instance:GetSingleRewardCfgRewardId(system_type, target_type)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and self.node_list["ItemImage"] then
		local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["ItemImage"].image:LoadSprite(item_bundle, item_asset)
	end

	local bundle, asset = ResPath.GetAppearanceTargetTypeImage(system_type)
	self.node_list["TypeImage"].image:LoadSprite(bundle, asset)

	local per = JinJieRewardData.Instance:GetSingleAttrCfgAttrAddPer(system_type)
	local per_text = per * 0.01
	self.node_list["TextAdd"].text.text = string.format(Language.Advance.AddShuXing, per_text)
end

--刷新免费时间
function LingGongContentView:FulshJinJieFreeTime(end_time, target_type)
	if end_time == 0 then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = end_time - now_time
	self:SetJinJieFreeTime(rest_time, target_type)
	if rest_time >= 0 and nil == self.least_time_timer then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetJinJieFreeTime(rest_time, target_type)
		end)
	else
		self:RemoveCountDown()
		self:ClearJinJieFreeData(target_type)
	end	
end

--设置进阶时间
function LingGongContentView:SetJinJieFreeTime(time, target_type)
	if time > 0 then
		local time_str = TimeUtil.FormatSecond(time, 10)
		self:FreeTimeShow(time_str, target_type)
	else
		self:RemoveCountDown()
		self:ClearJinJieFreeData(target_type)
		self:JinJieReward()
	end
end

--免费时间显示
function LingGongContentView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	else    --大目标
		self.node_list["TextFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	end
end

--移除倒计时
function LingGongContentView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function LingGongContentView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_LINGGONG)
end

--打开小目标面板
function LingGongContentView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_LINGGONG
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_LINGGONG, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end