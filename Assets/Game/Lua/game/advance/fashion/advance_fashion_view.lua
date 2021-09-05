AdvanceFashionView = AdvanceFashionView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local ZIZHILEVEL = 3
local EQUIPLEVEL = 5
local TALENTLEVEL = 8
local MOVE_TIME = 0.5
local SHOWSPECGRADE = 10

function AdvanceFashionView:UIsMove()
	UITween.MoveShowPanel(self.node_list["InfoPanel"], Vector3(250 , -17 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["SkillPanel"], Vector3(0 , -560 , 0 ) , MOVE_TIME)
	-- UITween.MoveShowPanel(self.node_list["Panel1"], Vector3(165 , 600 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Panel4"], Vector3(-35 , 480 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["TitlePanel"], Vector3(0 , 400 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["BtnPanel"], Vector3(0 , -360 , 0 ) , MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["Panel3"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["Panel2"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["Panel1"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function AdvanceFashionView:__init()
	self.tesu_index = 0
	self:InitData()
	FashionCtrl.Instance:RegisterView(self)
end

function AdvanceFashionView:__delete()
	self:RemoveCountDown()
	self.tesu_index = 0
	FashionCtrl.Instance:UnRegisterView()
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	self.fashion_skill_list = nil
	if self.item ~= nil then
		self.item:DeleteMe()
	end

	if self.count ~= nil then
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = nil
	end
	self.remainder_num = nil
	self.remainder_need_num = nil
	self.tmp_grade = nil
	self.is_can_tip = nil

	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["BtnTitle"])

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

--------------------------------------处理数据star------------------------------------------
function AdvanceFashionView:InitData()
	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.StartAdvance, self))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.AutomaticAdvance, self))
	self.node_list["GrayUseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))
	self.node_list["BtnQualifications"].button:AddClickListener(BindTool.Bind(self.OnClickZiZhi, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickHuanHua, self))
	self.node_list["BtnLeftButton"].button:AddClickListener(BindTool.Bind(self.OnClickLastButton, self))
	self.node_list["BtnRightButton"].button:AddClickListener(BindTool.Bind(self.OnClickNextButton, self))
	self.node_list["BtnEquipButton"].button:AddClickListener(BindTool.Bind(self.OnClickEquipBtn, self))
	-- self.node_list["BtnFuLingButton"].button:AddClickListener(BindTool.Bind(self.OnClickTalent, self)) -- 屏蔽天赋
	self.node_list["AutoToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))
	self.node_list["BtnTitle"].button:AddClickListener(BindTool.Bind(self.OnClickOpenSmallTarget, self))
	self.node_list["BtnBigTarget"].button:AddClickListener(BindTool.Bind(self.OnClickJinJieAward, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemParent"])

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	self.is_on_look_list =false
	self.left_button = true
	self.right_button = true
	self.use_button = false
	self.use_image = true
	self.use_clothing_index = FashionData.Instance:GetUsedClothingIndex()--使用的形象
	self.show_index = self.use_clothing_index == 0 and self.use_clothing_index + 1 or self.use_clothing_index
	self.now_index = 1
	self.max_index = FashionData.Instance:GetShizhuangUpgradeMaxGrade() or 0
	self.jinjie_next_time = 0
	self.res_id = 0
	self.prefab_preload_id = 0
	self.is_automatic = false
	self.is_can_automatic = true
	self.is_can_tip = true
	self.fashion_skill_list = {}
	self.is_max = false
	self.tmp_grade = -1
end

function AdvanceFashionView:OnFlush()
	local advance_view = AdvanceCtrl.Instance:GetAdvanceView()
	if advance_view:IsOpen() and advance_view:GetShowIndex() ~= TabIndex.fashion_jinjie then return end
	
	self.now_index = FashionData.Instance:GetNowGrade()
	self.is_max = self.now_index == self.max_index
	local info = FashionData.Instance:GetFashionInfo()
	if info then
		self.show_index = info.is_used_special_img == 1 and info.grade or info.use_clothing_index + 1
	end
	self:JinJieReward()
	self:FlushOther()
	self:FlushSome()
	self:SetAutoButtonGray()
	self:InitSkill()
	self:FlushClearTime()
end

function AdvanceFashionView:SetShowIndex(index)
	if index > 0 and index <= self.max_index then
		self.show_index = index
	elseif index == 0 then
		self.show_index = 1
	end
end

--点击左右按钮要刷新
function AdvanceFashionView:FlushOther()
	self.now_index = FashionData.Instance:GetNowGrade()
	self.use_clothing_index = FashionData.Instance:GetUsedClothingIndex()
	self.use_clothing_index = self.use_clothing_index == 0 and self.use_clothing_index + 1 or self.use_clothing_index

	if self.now_index then
		self.node_list["TextZiZhi"].text.text = self.now_index > ZIZHILEVEL and Language.Advance.ZiZhi or Language.Advance.SanJieOpen
		self.node_list["TextEquip"].text.text = self.now_index > EQUIPLEVEL and Language.Advance.FashionEquipType or Language.Advance.SiJieOpen 
		self.node_list["TextTalent"].text.text = self.now_index > TALENTLEVEL and Language.Advance.Talent  or Language.Advance.WuJieOpen

		UI:SetGraphicGrey(self.node_list["BtnQualifications"], self.now_index <= ZIZHILEVEL)
		UI:SetGraphicGrey(self.node_list["BtnEquipButton"], self.now_index <= EQUIPLEVEL)
		-- UI:SetGraphicGrey(self.node_list["BtnFuLingButton"], self.now_index <= TALENTLEVEL)
		self.node_list["EffectTalent"]:SetActive(ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_SHENGGONG) > 0 and self.now_index > TALENTLEVEL)
	end

	self:FlushModel()
	local show_cfg = FashionData.Instance:GetShizhuangUpgrade(self.show_index)
	if not show_cfg then return end
	local image_id_cfg = FashionData.Instance:GetShizhuangImg(show_cfg.image_id)
	if not image_id_cfg then return end
	if self.show_index == 2 and self.now_index ~= 1 then
		self.left_button = false
		self.node_list["BtnLeftButton"]:SetActive(self.left_button and not self.is_on_look_list)
	elseif self.show_index <= 1 then
		self.left_button = false
		self.node_list["BtnLeftButton"]:SetActive(self.left_button and not self.is_on_look_list)
	else
		self.left_button = true
		self.node_list["BtnLeftButton"]:SetActive(self.left_button and not self.is_on_look_list)
	end

	if self.show_index >= self.max_index or self.now_index + 1 == self.show_index then
		self.right_button = false
		self.node_list["BtnRightButton"]:SetActive(self.right_button and not self.is_on_look_list)
	else
		self.right_button = true
		self.node_list["BtnRightButton"]:SetActive(self.right_button and not self.is_on_look_list)
	end

	local info = FashionData.Instance:GetFashionInfo()
	if not info then return end
	if info.is_used_special_img == 1 then
		self.node_list["UseImage1"]:SetActive(false)
		local use_button = self.show_index <= self.now_index and self.now_index ~= 1
		self.node_list["GrayUseButton"]:SetActive(use_button)
	elseif info.is_used_special_img == 0 then
		self.use_image = self.show_index == self.use_clothing_index
		self.node_list["UseImage1"]:SetActive(self.use_image)
		self.use_button = self.show_index <= self.now_index and self.show_index ~= self.use_clothing_index and self.now_index ~= 1
		self.node_list["GrayUseButton"]:SetActive(self.use_button)
	end

	local color = (self.show_index / 3 + 1) >= 5 and 5 or math.floor(self.show_index / 3 + 1)
	local name_str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. image_id_cfg.image_name .. "</color>"
	self.node_list["Name"].text.text = show_cfg.gradename .. "·" .. name_str
	self.node_list["BtnLeftButton"]:SetActive(self.left_button)
	self.node_list["BtnRightButton"]:SetActive(self.right_button)
end

--点击左右按钮不能刷新
function AdvanceFashionView:FlushSome()
	local show_cfg = FashionData.Instance:GetShizhuangUpgrade(self.now_index)
	if not show_cfg then return end
	local upgrade_stuff_id = show_cfg.upgrade_stuff_id
	-- local attr2.gong_ji = 0
	-- local attr3 = {
	-- 	gong_ji = 0,
	-- }
	local fashion_info = FashionData.Instance:GetFashionInfo()
	if nil == fashion_info and nil == fashion_info.grade then
		return
	end
	local attr = FashionData.Instance:GetFashionAttrNum()
	local capability = CommonDataManager.GetCapability(show_cfg)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end

	if self.tmp_grade < 0 then
		self.tmp_grade = fashion_info.grade
	else
		if self.tmp_grade < fashion_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.node_list["ShowEffect"]:SetActive(false)
				self.node_list["ShowEffect"]:SetActive(true)

				self.effect_cd = EFFECT_CD + Status.NowTime
			end
			self.tmp_grade = fashion_info.grade
		end
	end

	if fashion_info.grade == 1 then
		local attr1 = FashionData.Instance:GetFashionAttrNum(nil, true)
		local attr0 = FashionData.Instance:GetFashionAttrNum()
		local switch_attr_list_1 = CommonDataManager.GetOrderAttributte(attr1)
		local switch_attr_list_0 = CommonDataManager.GetOrderAttributte(attr0)
		local diff_attr = CommonDataManager.LerpAttributeAttr(attr0, attr1)
		local switch_diff_attr_list = CommonDataManager.GetOrderAttributte(diff_attr)
		local index = 0
		for k, v in pairs(switch_attr_list_1) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = switch_attr_list_0[k].value or 0
				self.node_list["Arrow" .. index]:SetActive(true)
				self.node_list["AddValue" .. index]:SetActive(true)
				self.node_list["AddValue" .. index].text.text = switch_diff_attr_list[k].value or 0				
			end
		end
	else
		local attr2 = FashionData.Instance:GetFashionAttrNum()
		local switch_attr_list = CommonDataManager.GetOrderAttributte(attr2)
		local next_attr = FashionData.Instance:GetFashionAttrNum(nil, true)
		local diff_attr = CommonDataManager.LerpAttributeAttr(attr2, next_attr)
		local switch_diff_attr_list = CommonDataManager.GetOrderAttributte(diff_attr)		
		local index = 0
		for k, v in pairs(switch_attr_list) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = v.value
				if self.is_max then
					self.node_list["Arrow" .. index]:SetActive(false)
					self.node_list["AddValue" .. index]:SetActive(false)
				else
					self.node_list["Arrow" .. index]:SetActive(true)
					self.node_list["AddValue" .. index]:SetActive(true)
					self.node_list["AddValue" .. index].text.text = switch_diff_attr_list[k].value or 0
				end				
			end
		end
	end

	local active_grade, attr_type, attr_value = FashionData.Instance:GetFashionSpecialAttrActiveType()
	local max_grade = FashionData.Instance:GetShizhuangUpgradeMaxGrade()
	if active_grade and attr_type and attr_value then
		if fashion_info.grade < active_grade then
			local str = string.format(Language.Advance.LevelOpen, CommonDataManager.GetDaXie(active_grade - 1))
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = fashion_info.grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = FashionData.Instance:GetSpecialAttrActiveType(i)
				if next_attr_value then
					if next_attr_value ~= attr_value then
						special_attr = next_attr_value - attr_value
						str = string.format(Language.Advance.NextAttr, CommonDataManager.GetDaXie(next_active_grade - 1), special_attr / 100)
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

	local num1 = ItemData.Instance:GetItemNumInBagById(upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(show_cfg.upgrade_stuff2_id)
	local num2 = FashionData.Instance:GetRemainderNeedNum()
	local color = num1 >= num2 and COLOR.GREEN or COLOR.RED
	self.remainder_num = ToColorStr(num1, color)

	local itemData = {item_id = upgrade_stuff_id}
	self.item:SetData(itemData)
	local bless = FashionData.Instance:GetNowGradeBless()
	local bless_val_limit = FashionData.Instance:GetBlessValLimit()
	if self.show_index < self.max_index then
		self.node_list["BlessRadio"].slider.value = bless/bless_val_limit
		self.node_list["CurBless"].text.text = bless .. "/" .. bless_val_limit
	else
		self.node_list["CurBless"].text.text = Language.Common.YiMan
	end

	local can_uplevel_skill_list = FashionData.Instance:CanSkillUpLevelList()
	for i = 1, SHIZHUANG.FASHION_SKILL_COUNT - 1 do
		self.node_list["ShowSkillUplevel" .. i]:SetActive(can_uplevel_skill_list[i])
	end

	local is_show_effect_equip = FashionData.Instance:CalAllFashionEquipRemind() ~= 0
	self.node_list["ShowEquipRemind"]:SetActive(is_show_effect_equip)
	-- self.node_list["EffectTalent"]:SetActive(ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_SHENGGONG) > 0 and show_cfg.grade > TALENTLEVEL)
	local is_show_huanhua = FashionData.Instance:CanFashionHuanhuaUpgrade()
	self.node_list["ShowHuanhuaRedPoint"]:SetActive(is_show_huanhua)
	local is_show_zizhi = FashionData.Instance:IsShowFashionZizhiRedPoint()
	self.node_list["ShowZizhiRedPoint"]:SetActive(is_show_zizhi)

	self:FlushNeedItemStr()
end

function AdvanceFashionView:FlushNeedItemStr()
	local cfg = FashionData.Instance:GetShizhuangUpgrade()
	local show_cfg = FashionData.Instance:GetShizhuangUpgrade(self.now_index)
	local num2 = FashionData.Instance:GetRemainderNeedNum()
	local bag_num = ItemData.Instance:GetItemNumInBagById(show_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(show_cfg.upgrade_stuff2_id)
	local bag_num_str = string.format(Language.Mount.ShowGreenNum, bag_num)
	if bag_num < num2 then
		bag_num_str = string.format(Language.Mount.ShowRedNum, bag_num)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(show_cfg.upgrade_stuff_id)

	local str = string.format("%s / %s", bag_num_str, num2)
	if self.now_index < self.max_index then
		self.node_list["PropText"].text.text = str
	else
		self.node_list["PropText"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
	end

	if bag_num >= num2 and cfg.is_clear_bless == 0 and (not self.is_automatic) then
		self.node_list["RemindBtn"]:SetActive(true)
	else
		self.node_list["RemindBtn"]:SetActive(false)
	end
end

function AdvanceFashionView:FlushClearTime()
	local cfg = FashionData.Instance:GetShizhuangUpgrade()
	if not cfg then return end

	self.node_list["ClearTime"]:SetActive(not self.is_max)
	if self.is_max then
		self.node_list["BlessRadio"].slider.value = 1
	end
	local fashion_info = FashionData.Instance:GetFashionInfo()
	if fashion_info == nil then
		return
	end
	if fashion_info.grade_bless_val == 0 then
		if nil ~= self.count then
			CountDown.Instance:RemoveCountDown(self.count)
			self.count = nil
		end
	end
	if cfg.is_clear_bless == 1 then
		if fashion_info.grade_bless_val == 0 then
			self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessStr1
			return
		end
		local cleartime = FashionData.Instance:GetSpecialImgGradeList()
		local servertime = TimeCtrl.Instance:GetServerTime()
		local offtime = cleartime - servertime
		if self.count == nil then
			self:ClickTimer(offtime)
			self.count = CountDown.Instance:AddCountDown(offtime, 1, function ()
			offtime = offtime - 1
			local offtime = TimeUtil.FormatSecond(offtime - 1)
				self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(offtime))
			end)
		end
	else
		self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessTip
	end
end

--计时器,用于取消默认延迟1s显示
function AdvanceFashionView:ClickTimer(offtime)
	offtime = offtime - 1
	local temptime = TimeUtil.FormatSecond(offtime - 1)
	self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(temptime))
end

function AdvanceFashionView:InitSkill()
	local info = FashionData.Instance:GetShizhuangSkillInfo()
	if not info then return end

	for i = 1, SHIZHUANG.FASHION_SKILL_COUNT do
		if #self.fashion_skill_list < SHIZHUANG.FASHION_SKILL_COUNT then
			local cur_level = 0
			local next_level = 1
			local skill = nil
			self.cur_data = FashionData.Instance:GetShizhuangSkillCfgById(i - 1) or {}
			if next(self.cur_data) then
				cur_level = self.cur_data.skill_level
				next_level = cur_level + 1
			end
			self.next_data_cfg = FashionData.Instance:GetShizhuangSkillCfgById(i - 1, next_level) or {}
			local is_teshu = false
			skill = self.node_list["AdvanceSkill"..i]
			if self.cur_data and next(self.cur_data) and self.cur_data.is_teshu then
				is_teshu = self.cur_data.is_teshu == 1
			else
				if self.next_data_cfg and next(self.next_data_cfg) and self.next_data_cfg.is_teshu then
					is_teshu = self.next_data_cfg.is_teshu == 1
				end
			end
			if is_teshu then
				skill = self.node_list["SpecialSkill"]
				self.node_list["AdvanceSkill" ..i ]:SetActive(false)
				self.node_list["SpecialSkill"]:SetActive(true)
				self.node_list["SpecialSkillText"]:SetActive(true)
				self.tesu_index = i
			end
			self.node_list["SpecialSkill"]:SetActive(false)
			self.node_list["SpecialSkillText"]:SetActive(false)
			local icon = skill.transform:FindHard("Image")
			icon = U3DObject(icon, icon.transform, self)
			table.insert(self.fashion_skill_list, {skill = skill, icon = icon})
		end
		-- if self.node_list["AdvanceSkill" .. i] then
		-- 	local node = self.node_list["AdvanceSkill"..i].transform:FindHard("Image")
		-- 	if node then
		-- 		UI:SetGraphicGrey(node, info.skill_level_list[i - 1] == 0)
		-- 	end
		-- end
	end
	local fashion_info = FashionData.Instance:GetFashionInfo()
	if fashion_info ~= nil or next(fashion_info) ~= nil then
		if fashion_info.grade > SHOWSPECGRADE then
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
		end
	end
	
	for k, v in pairs(self.fashion_skill_list) do
		local node = v.skill.transform:FindHard("Image")
		if node then
			UI:SetGraphicGrey(node,info.skill_level_list[k - 1] == 0)
		end
		local bundle, asset = ResPath.GetFashionSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickFashionSkill, self, k))
	end

	local cur_lvl = 0
	local next_lvl = 1
	local cur_data = FashionData.Instance:GetShizhuangSkillCfgById(self.tesu_index - 1) or {}
	if next(cur_data) then
		cur_lvl = cur_data.skill_level
		next_lvl = cur_lvl + 1
	end
	local next_data_cfg = FashionData.Instance:GetShizhuangSkillCfgById(self.tesu_index - 1, next_lvl) or {}
	if next(next_data_cfg) then
		self.node_list["JiHuo"]:SetActive(true)
		self.node_list["JiHuo"].text.text = next_data_cfg.jineng_desc or ""
	else
		self.node_list["JiHuo"]:SetActive(false)
	end
	self.node_list["MostFightPower"]:SetActive(self.tesu_index ~= 0)
end

function AdvanceFashionView:FlushModel()
	local upgrade_cfg = FashionData.Instance:GetShizhuangUpgrade(self.show_index)
	if not upgrade_cfg then return end
	local cfg = FashionData.Instance:GetShizhuangImg(upgrade_cfg.image_id)
	if not cfg then return end

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
	local prof = PlayerData.Instance:GetRoleBaseProf(role_vo.prof)

	local res_id = cfg["resouce" .. prof .. role_vo.sex]
	if self.res_id ~= res_id then
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

		local bundle, asset = ResPath.GetFashionShizhuangModel(res_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
		self.res_id = res_id
	end
end

function AdvanceFashionView:SetModle(is_show)
	if is_show then
		-- self.show_index = self.use_clothing_index == 0 and self.use_clothing_index + 1 or self.use_clothing_index
		self:FlushOther()
		FashionCtrl.Instance:RegisterView(self)
		self.res_id = 0
	else
		if self.upgrade_timer_quest then
			GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
			self.upgrade_timer_quest = nil
		end
		FashionCtrl.Instance:UnRegisterView()
		self.res_id = 0

		if self.count ~= nil then
			CountDown.Instance:RemoveCountDown(self.count)
			self.count = nil
		end
		self.node_list["ShowEffect"]:SetActive(false)
	end
end

function AdvanceFashionView:RemoveNotifyDataChangeCallBack()
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function AdvanceFashionView:ClearTempData()
	self.is_automatic = false
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function AdvanceFashionView:ResetModleRotation()
end

function AdvanceFashionView:OpenCallBack()
	self.node_list["ShowEffect"]:SetActive(false)
	self.node_list["UseImage"]:SetActive(false)
	self.node_list["BtnText"].text.text = Language.Advance.Use
	self.tmp_grade = -1
end

--物品不足，购买成功后刷新物品数量
function AdvanceFashionView:ItemDataChangeCallback()
	self:FlushNeedItemStr()
end

function AdvanceFashionView:SetAutoButtonGray()
	if not self.is_automatic then
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
		self.node_list["AutoButtonText"].text.text = Language.Common.ZiDongJinJie
	else
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		self.node_list["AutoButtonText"].text.text = Language.Common.Stop
	end

	self.is_max = self.now_index == self.max_index
	if self.is_max then
		self.node_list["StartButton"]:SetActive(false)
		self.node_list["AutoButtonText"].text.text = Language.Advance.MaxGradeText
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		UI:SetButtonEnabled(self.node_list["AutoButton"], false)
	end
end

function AdvanceFashionView:FashionUpgradeResult(result)
	if result == 0 then
		self.is_automatic = false
		self.is_can_auto = true
		self.use_clothing_index = FashionData.Instance:GetUsedClothingIndex()
		self:SetAutoButtonGray()
		self:SetShowIndex(FashionData.Instance:GetNowGrade())
	elseif self.is_automatic then
		self.is_automatic = true
		self:SetAutoButtonGray()
		self:AutoUpGradeOnce()
	elseif not self.is_automatic then
		self.is_can_tip = true
	end
	self.is_can_automatic = true
	self:FlushSome()
end
--------------------------------------处理数据end------------------------------------------

--------------------------------------点击事件star------------------------------------------
function AdvanceFashionView:OnClickZiZhi()
	local fashion_info = FashionData.Instance:GetFashionInfo()
	if nil ~= fashion_info and nil ~= fashion_info.grade then
		if fashion_info.grade <= ZIZHILEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SanJieOpen)
		else
			ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "fashionzizhi", {item_id = FashionDanId.ZiZhiDanId})
		end
	end
end

function AdvanceFashionView:OnClickHuanHua()
	AdvanceData.Instance:SetHuanHuaType(TabIndex.fashion_huan_hua)
	AdvanceData.Instance:SetImageFulingType(IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG)
	ViewManager.Instance:Open(ViewName.AdvanceHuanhua,TabIndex.mount_huanhua, "fashionhuanhua",{TALENT_TYPE.TALENT_SHENGGONG})
	AdvanceCtrl.Instance:FlushView("fashionhuanhua")
end

function AdvanceFashionView:OnClickUse()
	local upgrade_cfg = FashionData.Instance:GetShizhuangUpgrade(self.show_index)
	if upgrade_cfg then
		FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.BODY, 0, upgrade_cfg.image_id)
	end
end

function AdvanceFashionView:StartAdvance()
	local show_cfg = FashionData.Instance:GetShizhuangUpgrade()
	if not show_cfg then return end
	local is_auto_buy_toggle = self.node_list["AutoToggle"].toggle.isOn
	local upgrade_stuff_id = show_cfg.upgrade_stuff_id
	local is_one = false

	local close_func = function()
		--物品不足
		local pack_num = show_cfg.upgrade_stuff_count
		local count_num = ItemData.Instance:GetItemNumInBagById(upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(show_cfg.upgrade_stuff2_id)
		if count_num < pack_num and not is_auto_buy_toggle then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[upgrade_stuff_id]
			self.is_automatic = false
			self.is_can_automatic = not self.is_automatic
			self.is_can_tip = true
			self:SetAutoButtonGray()

			if item_cfg == nil then
				TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(upgrade_stuff_id, 2)
				return
			end

			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
				if is_buy_quick then
					self.node_list["AutoToggle"].toggle.isOn = true
				end
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, upgrade_stuff_id, nofunc, 1)
			return
		end
		local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
		local next_time = show_cfg.next_time

	FashionCtrl.Instance:SendFashionUpgradeReq(is_auto_buy, self.is_automatic)
	self.jinjie_next_time = Status.NowTime + (next_time or 0.1)
	end

	local describe = Language.Advance.AdvanceReturnNotLingQu
	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() and self.is_can_tip then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN)
		local is_not_lingqu_one = AdvancedReturnData.Instance:GetFanHuanRemind() == 1
		local is_not_lingqu_two = AdvancedReturnTwoData.Instance:GetFanHuanTwoRemind() == 1
		if open_advance_one == 1 and is_not_lingqu_one then
			local ok_func = function()
				ViewManager.Instance:Open(ViewName.AdvancedReturn)
				self.is_automatic = false
				self.is_can_automatic = true
				self:SetAutoButtonGray()
			end
			TipsCtrl.Instance:ShowCommonTip(ok_func, nil, describe, nil, close_func)
			return 
		elseif open_advance_two == 1 and is_not_lingqu_two then
			local ok_func = function()
				ViewManager.Instance:Open(ViewName.AdvancedReturnTwo)
				self.is_automatic = false
				self.is_can_automatic = true
				self:SetAutoButtonGray()
			end
			TipsCtrl.Instance:ShowCommonTip(ok_func, nil, describe, nil, close_func)
			return
		end
	end

	local is_have_zhishengdan, item_id = FashionData.Instance:IsFashionHaveZhiShengDanInGrade()
	local item = ItemData.Instance:GetItem(item_id)
	if is_have_zhishengdan and self.is_can_tip and item then
		local function ok_callback()
			self.is_automatic = false
			self.is_can_automatic = true
			self:SetAutoButtonGray()
			PackageCtrl.Instance:SendUseItem(item.index, 1)
		end	
		local fashion_info = FashionData.Instance:GetFashionInfo()
		if nil ~= fashion_info and nil ~= fashion_info.grade then
			TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Advance.IsUseZhiShengDan, fashion_info.grade), ok_callback, close_func)
			return
		end
	end

	close_func()
end

function AdvanceFashionView:AutomaticAdvance()
	if not self.is_can_automatic then return end

	self.is_automatic = self.is_automatic == false
	self.is_can_tip = self.is_automatic
	self.is_can_automatic = false
	self:StartAdvance()
	self:SetAutoButtonGray()
end

function AdvanceFashionView:AutoUpGradeOnce()
	local jinjie_next_time = 0 
	if self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	self.is_can_tip = true
	if self.now_index <= self.max_index and self.is_automatic then
		self.is_can_tip = false
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.StartAdvance,self), jinjie_next_time)
	end
end

function AdvanceFashionView:OnClickLastButton()
	if self.show_index > 0 then
		self.show_index = self.show_index - 1
		self:FlushOther()
	end
end

function AdvanceFashionView:OnClickNextButton()
	if self.show_index < self.max_index then
		self.show_index = self.show_index + 1
		self:FlushOther()
	end
end

function AdvanceFashionView:OnClickTalent()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("img_fuling_talent")
	if not is_open then
		TipsCtrl.Instance:ShowSystemMsg(tips)
		return
	end
	local fashion_info = FashionData.Instance:GetFashionInfo()
	if nil ~= fashion_info and nil ~= fashion_info.grade then
		if fashion_info.grade <= TALENTLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.WuJieOpen)
		else
			ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_talent, "talent_type_tab", {TALENT_TYPE.TALENT_SHENGGONG})
		end
	end
end

function AdvanceFashionView:OnClickEquipBtn()
	local is_active, activite_grade = FashionData.Instance:IsOpenShizhuangEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.fashion_jinjie] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade), name))
		return
	end
	local fashion_info = FashionData.Instance:GetFashionInfo()
	if nil ~= fashion_info and nil ~= fashion_info.grade then
		if fashion_info.grade <= EQUIPLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SiJieOpen)
		else
			ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.fashion_jinjie)
		end
	end
end

function AdvanceFashionView:OnClickFashionSkill(index)
	if self.is_shake_skill and index == 1 then
		self.node_list["Special"].animator:SetBool("IsShake", false)
		self.is_shake_skill = nil
	end
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "fashionskill", {index = index - 1})
end

function AdvanceFashionView:OnAutoBuyToggleChange(isOn)
end
--------------------------------------点击事件end------------------------------------------

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function AdvanceFashionView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_FASHION
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

	-- local cur_img_grade = (FashionData.Instance:GetNowGrade() or 0) - 1
	-- if not self.old_img_grade then
	-- 	self.old_img_grade = cur_img_grade
	-- end	

	-- local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	-- local now_time = TimeCtrl.Instance:GetServerTime()
	-- if end_time - now_time > 0 then

	-- 	if self.old_img_grade == 4 and cur_img_grade == 5 then
	-- 		self:OnClickOpenSmallTarget()
	-- 	elseif self.old_img_grade == 8 and cur_img_grade == 9 then
	-- 		self:OnClickJinJieAward()
	-- 	end
	-- end
	-- if self.old_img_grade == 9 and cur_img_grade == 10 then
	-- 	self.node_list["Special"].animator:SetBool("IsShake", true)
	-- 	self.is_shake_skill = true
	-- end
	-- self.old_img_grade = cur_img_grade
end

--清除大目标/小目标免费数据 target_type 目标类型  不传默认大目标
function AdvanceFashionView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = ""
		self.node_list["TitleFreeTime"]:SetActive(false)
	else    --大目标
		self.node_list["TextFreeTime"].text.text = ""
		self.node_list["TextFreeTime"]:SetActive(false)
	end
end

--大目标 变动显示
function AdvanceFashionView:BigTargetNotConstantData(system_type, target_type)
	local is_show_jin_jie = JinJieRewardData.Instance:IsShowJinJieRewardIcon(system_type)
	local speical_is_active = JinJieRewardData.Instance:GetSystemIsActiveSpecialImage(system_type)
	local active_is_end = JinJieRewardData.Instance:GetSystemFreeIsEnd(system_type)
	local active_big_target = JinJieRewardData.Instance:GetSystemIsGetActiveNeedItemFromInfo(system_type)
	local can_fetch = JinJieRewardData.Instance:GetSystemIsCanFreeLingQuFromInfo(system_type)

	self.node_list["JinJieBig"]:SetActive(is_show_jin_jie)
	self.node_list["RedPoint"]:SetActive(not speical_is_active)
	-- self.node_list["ItemImage"]:SetActive(speical_is_active)
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
function AdvanceFashionView:SmallTargetNotConstantData(system_type, target_type)
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
function AdvanceFashionView:SmallTargetConstantData(system_type, target_type)
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
function AdvanceFashionView:BigTargetConstantData(system_type, target_type)
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
	local bundle, asset = ResPath.GetAdvaneTargetTypeImage(system_type)
	self.node_list["TypeImage"].image:LoadSprite(bundle, asset)

	local per = JinJieRewardData.Instance:GetSingleAttrCfgAttrAddPer(system_type)
	local per_text = per * 0.01
	self.node_list["TextAdd"].text.text = string.format(Language.Advance.AddShuXing, per_text)
end

--刷新免费时间
function AdvanceFashionView:FulshJinJieFreeTime(end_time, target_type)
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
function AdvanceFashionView:SetJinJieFreeTime(time, target_type)
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
function AdvanceFashionView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	else    --大目标
		self.node_list["TextFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	end
end

--移除倒计时
function AdvanceFashionView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceFashionView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_FASHION)
end

--打开小目标面板
function AdvanceFashionView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_FASHION
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_FASHION, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end