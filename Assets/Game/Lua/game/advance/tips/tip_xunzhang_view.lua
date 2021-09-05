TipXunZhangView = TipXunZhangView or BaseClass(BaseView)

local FROM_MOUNT = 1		-- 从坐骑界面打开
local FROM_WING = 2			-- 从羽翼界面打开
local FROM_HALO = 3			-- 从光环界面打开
local FROM_FABAO = 7 		-- 从法宝界面打开
local FROM_FIGHTMOUNT = 14	-- 从战骑界面打开
local FROM_LINGTONG = 17	-- 从灵童界面
local FROM_FLYPET = 23		-- 从飞宠界面打开

local EFFECT_CD = 1
function TipXunZhangView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/advanceview_prefab","TipXunZhangView"},
	}
	self.play_audio = true
	self.info = nil
	self.cur_index = nil
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipXunZhangView:__delete()
	
end

function TipXunZhangView:ReleaseCallBack()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
	self.item_id = nil
	self.cur_index = nil
	self.need_pro_id = {}
	self.skill_name = nil
	self.fight_text_cur = nil
	self.fight_text_next = nil

	if self.challenge_count_down then
		CountDown.Instance:RemoveCountDown(self.challenge_count_down)
		self.challenge_count_down = nil
	end
end

function TipXunZhangView:LoadCallBack()
	self.item = ItemCell.New()
	self.need_pro_id = {}
	self.cur_index = nil
	self.item:SetInstanceParent(self.node_list["NeedItem"])
	self.node_list["BtnRecycle"].button:AddClickListener(BindTool.Bind(self.OnUpGrade, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(734, 500, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close,self))
	self.node_list["BtnFuBen"].button:AddClickListener(BindTool.Bind(self.OnClickFuBen,self))
	self.node_list["RawImgBg"].raw_image:LoadSprite("uis/rawimages/bg_xunzhang", "bg_xunzhang.png", function()
		self.node_list["RawImgBg"]:SetActive(true)
		self.node_list["RawImgBg"].raw_image:SetNativeSize()
	end)

	local left_time = FuBenData.Instance:GetLastTime()
	if left_time > 0 then
		local last_time = TimeUtil.FormatSecond(left_time, 16)
		self.node_list["TextWarn"].text.text = string.format(Language.Advance.TipXunZhangRestTime, last_time)
	end

	self.fight_text_cur = CommonDataManager.FightPower(self, self.node_list["CurTextFightPower"])
	self.fight_text_next = CommonDataManager.FightPower(self, self.node_list["NextTextFightPower"])
end

function TipXunZhangView:CloseCallBack()
	self.cur_index = nil
end

function TipXunZhangView:OpenCallBack()
	if self.cur_index ~= nil then
		self:SetData()
	end
	self:FlushRestChallengeTime()
end


function TipXunZhangView:OnClickFuBen()
	ViewManager.Instance:Open(ViewName.FuBen)
	self:Close()
end

function TipXunZhangView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "mountskill" then
			self.cur_index = v.index
			self.from_view = FROM_MOUNT
		elseif k == "wingskill" then
			self.cur_index = v.index
			self.from_view = FROM_WING
		elseif k == "haloskill" then
			self.cur_index = v.index
			self.from_view = FROM_HALO
		elseif k == "fabaoskill" then
			self.cur_index = v.index
			self.from_view = FROM_FABAO
		elseif k == "fightmountskill" then
			self.cur_index = v.index
			self.from_view = FROM_FIGHTMOUNT
		elseif k == "lingchongskill" then
			self.cur_index = v.index
			self.from_view = FROM_LINGTONG
		elseif k == "flypet_skill" then
			self.cur_index = v.index
			self.from_view = FROM_FLYPET
		end
	end

	if self.cur_index ~= nil then
		self:SetData()
	end
end

function TipXunZhangView:SetData()
	local bundle, asset = nil, nil
	local cur_level = 0
	local next_level = 1
	local cur_desc = nil
	-- local next_desc = nil
	local is_active = false
	local base_power = 0
	self.node_list["Txt"].text.text = Language.Advance.NAME_LIST[self.from_view] .. Language.Advance.Medal
	-- 坐骑技能
	if self.from_view == FROM_MOUNT then
		base_power = MountData.Instance:GetCurGradeBaseFightPower()
		self.cur_data = MountData.Instance:GetMountSkillCfgById(self.cur_index) or {}
		self.info = MountData.Instance:GetMountInfo()
		bundle, asset = ResPath.GetMountSkillIcon(self.cur_index + 1)
		self.skill_cfg = MountData.Instance:GetMountSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = MountData.Instance:GetMountSkillCfgById(self.cur_index, next_level) or {}

	-- 羽翼技能
	elseif self.from_view == FROM_WING then
		base_power = WingData.Instance:GetCurGradeBaseFightPower()
		self.cur_data = WingData.Instance:GetWingSkillCfgById(self.cur_index) or {}
		self.info = WingData.Instance:GetWingInfo()
		bundle, asset = ResPath.GetWingSkillIcon(self.cur_index + 1)
		self.skill_cfg = WingData.Instance:GetWingSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = WingData.Instance:GetWingSkillCfgById(self.cur_index, next_level) or {}

	-- 光环技能
	elseif self.from_view == FROM_HALO then
		base_power = HaloData.Instance:GetCurGradeBaseFightPower()
		self.cur_data = HaloData.Instance:GetHaloSkillCfgById(self.cur_index) or {}
		self.info = HaloData.Instance:GetHaloInfo()
		bundle, asset = ResPath.GetAdvanceHaloSkillIcon(self.cur_index + 1)
		self.skill_cfg = HaloData.Instance:GetHaloSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = HaloData.Instance:GetHaloSkillCfgById(self.cur_index, next_level) or {}

	-- 法宝技能
	elseif self.from_view == FROM_FABAO then
		base_power = FaBaoData.Instance:GetCurGradeBaseFightPower()
		self.cur_data = FaBaoData.Instance:GetFaBaoSkillCfgById(self.cur_index) or {}
		self.info = FaBaoData.Instance:GetFaBaoInfo()
		bundle, asset = ResPath.GetFaBaoSkillIcon(self.cur_index + 1)
		self.skill_cfg = FaBaoData.Instance:GetFaBaoSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FaBaoData.Instance:GetFaBaoSkillCfgById(self.cur_index, next_level) or {}

	-- 战骑技能
	elseif self.from_view == FROM_FIGHTMOUNT then
		base_power = FightMountData.Instance:GetCurGradeBaseFightPower()
		self.cur_data = FightMountData.Instance:GetMountSkillCfgById(self.cur_index) or {}
		self.info = FightMountData.Instance:GetFightMountInfo()
		bundle, asset = ResPath.GetFightMountSkillIcon(self.cur_index + 1)
		self.skill_cfg = FightMountData.Instance:GetMountSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FightMountData.Instance:GetMountSkillCfgById(self.cur_index, next_level) or {}

	-- 灵童
	elseif self.from_view == FROM_LINGTONG then
		base_power = LingChongData.Instance:GetCurGradeBaseFightPower()
		self.cur_data = LingChongData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = LingChongData.Instance:GetLingChongInfo()
		bundle, asset = ResPath.GetLingTongSkillIcon(self.cur_index + 1)
		self.skill_cfg = LingChongData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = LingChongData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}

	-- 飞宠
	elseif self.from_view == FROM_FLYPET then
		base_power = FlyPetData.Instance:GetCurGradeBaseFightPower()
		self.cur_data = FlyPetData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = FlyPetData.Instance:GetFlyPetInfo()
		bundle, asset = ResPath.GetSkillIcon("FlyPetSkill_" .. (self.cur_index + 1))
		self.skill_cfg = FlyPetData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FlyPetData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}

	end

	self.item_id = self.cur_data.uplevel_stuff_id or self.next_data_cfg.uplevel_stuff_id
	local count = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local data = {item_id = self.item_id, is_bind = 0}
	if item_cfg ~= nil then
		self.item:SetData(data)
	end
	if next(self.cur_data) then
		-- self.node_list["Arrow"]:SetActive(true)
		-- self.node_list["LeftInfo"]:SetActive(true)
		self.node_list["TextLevel"].text.text = self.cur_data.skill_name or ""
		local cur_grade = self.cur_data.skill_level or 1
		local bundle, asset = ResPath.GetMedalLevelImage(cur_grade)
		self.node_list["TextWu"]:SetActive(false)
		self.node_list["ImgXunZhang"]:SetActive(true)
		self.node_list["ImgXunZhang"].image:LoadSprite(bundle, asset)

		local next_desc = string.gsub(self.cur_data.desc, "%b()%%", function (str)
			return  (tonumber(self.cur_data[string.sub(str, 2, -3)]) / 1000)..""
		end)
		next_desc = string.gsub(next_desc, "%b[]%%", function (str)
			return (tonumber(self.cur_data[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		next_desc = string.gsub(next_desc, "%[.-%]", function (str)
			return self.cur_data[string.sub(str, 2, -2)]
		end)
		self.node_list["CurAttr"].text.text = next_desc

		local skill_name = self.cur_data.skill_name or ""
		self.node_list["TextLevel"].text.text = skill_name
		self.node_list["Plus"]:SetActive(true)
		self.node_list["HpValue"].text.text = self.cur_data.maxhp
		self.node_list["DefValue"].text.text = self.cur_data.fangyu
		self.node_list["GongjiValue"].text.text = self.cur_data.gongji

		local add_per = self.cur_data.base_attr_add_per* 0.0001
		local attr = CommonDataManager.GetAttributteByClass(self.cur_data)
		local power = CommonDataManager.GetCapabilityCalculation(attr)
		local all_power = power + base_power * add_per
		self.node_list["CurTextFightPower"]:SetActive(false)
		if self.fight_text_cur and self.fight_text_cur.text then
			self.fight_text_cur.text.text = math.ceil(all_power)
		end
	else
		-- self.node_list["Arrow"]:SetActive(false)
		-- self.node_list["LeftInfo"]:SetActive(false)
		self.node_list["CurTextFightPower"]:SetActive(false)
		self.node_list["Plus"]:SetActive(false)
		self.node_list["ImgXunZhang"]:SetActive(false)
		self.node_list["TextWu"]:SetActive(true)
		self.node_list["TextLevel"].text.text = Language.Advance.NotName
	end

	if next(self.next_data_cfg) then
		self.node_list["Arrow"]:SetActive(true)
		self.node_list["RightInfo"]:SetActive(true)
		self.node_list["TextNextLevel"].text.text = self.next_data_cfg.skill_name or ""
		local next_grade = self.next_data_cfg.skill_level or 1
		local bundle, asset = ResPath.GetMedalLevelImage(next_grade)
		self.node_list["ImgNextXunzhang"].image:LoadSprite(bundle, asset)

		local next_desc = string.gsub(self.next_data_cfg.desc, "%b()%%", function (str)
			return  (tonumber(self.next_data_cfg[string.sub(str, 2, -3)]) / 1000)..""
		end)
		next_desc = string.gsub(next_desc, "%b[]%%", function (str)
			return (tonumber(self.next_data_cfg[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		next_desc = string.gsub(next_desc, "%[.-%]", function (str)
			return self.next_data_cfg[string.sub(str, 2, -2)]
		end)
		self.node_list["NextAttr"].text.text = next_desc

		local skill_name = self.next_data_cfg.skill_name or ""
		self.node_list["TextNextLevel"].text.text = skill_name

		self.node_list["NextHpValue"].text.text = self.next_data_cfg.maxhp
		self.node_list["NextDefValue"].text.text = self.next_data_cfg.fangyu
		self.node_list["NextGongjiValue"].text.text = self.next_data_cfg.gongji

		local need_pro_num = self.next_data_cfg.uplevel_stuff_num
		if count < self.next_data_cfg.uplevel_stuff_num then
			local have_pro_num = string.format(Language.Mount.ShowRedNum, count)
			self.node_list["StuffNum"].text.text = string.format("%s / %s", have_pro_num, need_pro_num)
		else
			local have_pro_num = string.format(Language.Mount.ShowGreenStr, count)
			self.node_list["StuffNum"].text.text = string.format("%s / %s", have_pro_num, need_pro_num)
		end
		UI:SetButtonEnabled(self.node_list["BtnRecycle"], true)

		local add_per = self.next_data_cfg.base_attr_add_per* 0.0001
		local attr = CommonDataManager.GetAttributteByClass(self.next_data_cfg)
		local power = CommonDataManager.GetCapabilityCalculation(attr)
		local all_power = power + base_power * add_per

		self.node_list["NextTextFightPower"]:SetActive(false)
		if self.fight_text_next and self.fight_text_next.text then
			self.fight_text_next.text.text = math.ceil(all_power)
		end
	else
		self.node_list["NextTextFightPower"]:SetActive(false)
		self.node_list["Arrow"]:SetActive(false)
		self.node_list["RightInfo"]:SetActive(false)
		local textcost = "- / -"
		self.node_list["StuffNum"].text.text = ToColorStr(textcost, TEXT_COLOR.WHITE)
		UI:SetButtonEnabled(self.node_list["BtnRecycle"], false)
		self.node_list["TextWarn"]:SetActive(false)
	end
end

function TipXunZhangView:OnUpGrade()
	if not self.info or self.info.grade == 0 then
		return
	end
	if nil == next(self.next_data_cfg) then
		return
	end

	if self.info.grade < self.next_data_cfg.grade then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.NotEnoughGrade, Language.Advance.NAME_LIST[self.from_view]))
		return
	end
	if ItemData.Instance:GetItemNumInBagById(self.item_id) <= 0 or
		ItemData.Instance:GetItemNumInBagById(self.item_id) < self.next_data_cfg.uplevel_stuff_num then

		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			self:Close()
			return
		end
		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(self.item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id)
		return
	end
	if self.from_view == FROM_MOUNT then
		MountCtrl.Instance:MountSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_WING then
		WingCtrl.Instance:WingSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_HALO then
		HaloCtrl.Instance:HaloSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_FABAO then
		FaBaoCtrl.Instance:FaBaoSkillUplevelReq(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_UPLEVELSKILL,self.cur_index)
	elseif self.from_view == FROM_FIGHTMOUNT then
		FightMountCtrl.Instance:FightMountSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_LINGTONG then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_TONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	elseif self.from_view == FROM_FLYPET then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.FLY_PET, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_SKILL_UPGRADE, self.cur_index)
	end
end

-- function TipXunZhangView:UpGradeFlush()
-- 	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
-- 		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_jinjietishengchenggong")
-- 		EffectManager.Instance:PlayAtTransformCenter(
-- 			bundle_name,
-- 			asset_name,
-- 			self.node_list["EffectRoot"].transform,
-- 			1.0)
-- 		self.effect_cd = Status.NowTime + EFFECT_CD
-- 	end
-- end

function TipXunZhangView:FlushRestChallengeTime()
	local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local left_time = FuBenData.Instance:GetLastTime()
	if left_time < 0 then 						-- 开服前5天
		self.node_list["TextWarn"]:SetActive(false)
		return
	end
	if self.node_list["TextWarn"] then
		self.node_list["TextWarn"]:SetActive(true)
	end
	if nil == self.challenge_count_down then
		local diff_time = function(elapse_time, total_time)
			local time = math.floor(total_time - elapse_time + 0.5)
			local last_time = TimeUtil.FormatSecond(time, 16)
			if self.node_list and self.node_list["TextWarn"] then
				self.node_list["TextWarn"].text.text = string.format(Language.Advance.TipXunZhangRestTime, last_time)
			end
			if elapse_time >= total_time then
				self.node_list["TextWarn"]:SetActive(false)
				if self.challenge_count_down then
					CountDown.Instance:RemoveCountDown(self.challenge_count_down)
					self.challenge_count_down = nil
				end
			end
		end
		self.challenge_count_down = CountDown.Instance:AddCountDown(left_time, 1, diff_time)
	end
end
