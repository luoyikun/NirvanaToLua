TipsZhiBaoSkillView = TipsZhiBaoSkillView or BaseClass(BaseView)

function TipsZhiBaoSkillView:__init()
	self.ui_config = {{"uis/views/tips/zhibaoskilltips_prefab", "ZhiBaoSkillTips"}}
	self.skill_data = nil
	self.next_skill_data = nil
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsZhiBaoSkillView:SetData(skill_data, next_skill_data)
	self.skill_data = skill_data
	self.next_skill_data = next_skill_data
end

-- 创建完调用
function TipsZhiBaoSkillView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
end

function TipsZhiBaoSkillView:CloseView()
	self:Close()
end

function TipsZhiBaoSkillView:OpenCallBack()
	if self.skill_data ~= nil then
		--激活
		--TODO目前没有图标
		self.node_list["ImgSkill"].image:LoadSprite(ResPath.GetBaoJuSkillIcon(self.skill_data.skill_idx + 1))
		self.node_list["TxtProName"].text.text = string.format("%s%s", self.skill_data.skill_name, "")
		self.node_list["TxtSkillLevel"].text.text = string.format(Language.Tips.MoJieTisLevel, self.skill_data.skill_level)
		self.node_list["TxtCurEffect"].text.text = self.skill_data.skill_dec
	else
		--未激活
		--TODO目前没有图标
		self.node_list["ImgSkill"].image:LoadSprite(ResPath.GetBaoJuSkillIcon(self.next_skill_data.skill_idx + 1))
		self.node_list["TxtProName"].text.text = string.format("%s%s", self.next_skill_data.skill_name, string.format("(%s)", ToColorStr(Language.Common.NoActivate, TEXT_COLOR.RED)))
		self.node_list["TxtCurEffect"].text.text = Language.Common.No
		self.node_list["TxtSkillLevel"].text.text = string.format(Language.Tips.MoJieTisLevel, 0)
	end

	if self.next_skill_data ~= nil then
		self.node_list["PanelMaxLevel"]:SetActive(true)
		self.node_list["TxtUpgrade"].text.text = Language.BaoJu.ZhiBaoUpGrade..ToColorStr(self.next_skill_data.zhibao_level, TEXT_COLOR.GREEN)..Language.Common.Ji
		self.node_list["TxtNextLevel"].text.text = Language.BaoJu.NextSkill
		self.node_list["TxtNextEffect"].text.text = self.next_skill_data.skill_dec
	else
		self.node_list["PanelMaxLevel"]:SetActive(false)
		self.node_list["TxtNextEffect"].text.text = ""
		self.node_list["TxtNextLevel"].text.text = Language.Common.YiManJi
		self.node_list["TxtUpgrade"].text.text = Language.Common.MaxLevel
	end
end

