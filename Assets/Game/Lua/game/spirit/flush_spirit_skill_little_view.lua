-- 仙宠技能单次刷新-FlsuhSpriteSkillLittleView-这个已屏蔽
FlushSpiriLittleSkillView = FlushSpiriLittleSkillView or BaseClass(BaseView)

function FlushSpiriLittleSkillView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/spiritview_prefab", "FlsuhSpriteSkillLittleView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function FlushSpiriLittleSkillView:__delete()

end

function FlushSpiriLittleSkillView:CloseCallBack()
end

function FlushSpiriLittleSkillView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(700, 550, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.JingLing.TabbarName[14]
	self.node_list["BtnFlush1"].button:AddClickListener(BindTool.Bind(self.FlsuhSkill, self))
	self.node_list["BtnFlush2"].button:AddClickListener(BindTool.Bind(self.FlsuhManySkill, self))
	self.node_list["BtnLearnSkill"].button:AddClickListener(BindTool.Bind(self.LearnSkill, self))
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
	self.item:SetData(nil)
end

function FlushSpiriLittleSkillView:ReleaseCallBack()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function FlushSpiriLittleSkillView:ShowIndexCallBack(index)
	self:Flush()
end

function FlushSpiriLittleSkillView:OnFlush(param_list)
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	-- 根据格子找技能的
	local cell_info = sprite_info.skill_refresh_item_list[0]
	if nil == cell_info then
		print_error("cell_info is nil !!!")
		return
	end

	-- 阶段描述处理
	local refresh_count = cell_info.refresh_count
	local skill_refresh_cfg = SpiritData.Instance:GetSkliiFlsuhStageByTimes(refresh_count)
	self.node_list["TxtText"].text.text = skill_refresh_cfg.desc or ""
	self.node_list["costTxt"].text.text = skill_refresh_cfg.once_gold or ""
	self.node_list["manyTxt"].text.text = skill_refresh_cfg.ten_gold or ""

	-- 星星处理
	local stage = skill_refresh_cfg.stage or 0
	local show_star = stage + 1

	local star_width = 41
	local star_height = 39
	local max_count = skill_refresh_cfg.max_count or 0
	local min_count = skill_refresh_cfg.min_count or 0
	local cur_star_full_times = max_count - min_count
	local cur_star_flush_times = refresh_count - min_count
	local star_percent = cur_star_flush_times / cur_star_full_times
	local cur_star_width = star_width * star_percent
	for i = 1, 8 do
		if i <= show_star then
			self.node_list["star" .. i]:SetActive(true)
			if i == show_star then
				-- 当前的星星要做遮罩显示处理
				self.node_list["star" .. i].rect.sizeDelta = Vector2(cur_star_width, star_height)
			else
				self.node_list["star" .. i].rect.sizeDelta = Vector2(star_width, star_height)
			end
		else
			self.node_list["star" .. i]:SetActive(false)
		end
	end

	-- 免费次数刷新
	local free_refresh_times = SpiritData.Instance:GetFreeFlushLeftTimes()
	if free_refresh_times > 0 then
		local desc = string.format(Language.JingLing.FreeRefreshTimes, free_refresh_times)
		self.node_list["refreshTxt"].text.text = desc
		self.node_list["costTxt"].text.text = ""
		self.node_list["DiamondIcon"]:SetActive(false)
	else
		self.node_list["refreshTxt"].text.text = ""
		self.node_list["costTxt"].text.text = skill_refresh_cfg.once_gold or ""
		self.node_list["DiamondIcon"]:SetActive(true)
	end

	-- 图标处理 取第一个
	local skill_id = cell_info.skill_list[0]
	local skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritIcon("skill_" .. skill_id)
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	if nil ~= one_skill_cfg then
		local color = SPRITE_SKILL_LEVEL_COLOR[one_skill_cfg.skill_level]
		local skill_name = ToColorStr(one_skill_cfg.skill_name, color)
		self.node_list["SkillTxt"].text.text = skill_name
		self.item:SetData({["item_id"] = one_skill_cfg.book_id})
	else
		self.node_list["SkillTxt"].text.text = ""
		self.item:SetData(nil)
	end
	self.node_list["Txtredpoint"]:SetActive(free_refresh_times > 0)
end

function FlushSpiriLittleSkillView:FlsuhSkill()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, 0)
end

function FlushSpiriLittleSkillView:FlsuhManySkill()
	SpiritCtrl.Instance:OpenFlsuhSkillBigView()
	self:Close()
end

function FlushSpiriLittleSkillView:LearnSkill()
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	local cell_info = sprite_info.skill_refresh_item_list[0]
	local skill_id = cell_info.skill_list[0]
	if skill_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseFlushSkill)
		return
	end
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_GET, 0)
	self:Close()
end