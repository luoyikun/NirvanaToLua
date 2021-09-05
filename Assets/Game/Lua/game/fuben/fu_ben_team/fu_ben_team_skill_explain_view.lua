TeamFBTowerSkillExplain = TeamFBTowerSkillExplain or BaseClass(BaseView)

function TeamFBTowerSkillExplain:__init()
	self.ui_config = {
		{"uis/views/fubenview_prefab", "TeamFBTowerSkillExplain"}
	}
	self.index = 1
end

function TeamFBTowerSkillExplain:ReleaseCallBack()
	
end

function TeamFBTowerSkillExplain:LoadCallBack()

end

function TeamFBTowerSkillExplain:OnFlush()
	local team_info = FuBenData.Instance:GetTeamTowerInfo()
	if team_info and team_info.skill_list and team_info.skill_list[self.index] then
		local bundle,asset = ResPath.GetTowerSkillIcon(team_info.skill_list[self.index].skill_id)
		self.node_list["ImgSkill"].image:LoadSprite(bundle,asset)
		self.node_list["TxtName"].text.text = Language.FuBen.TeamFbSkillName[team_info.skill_list[self.index].skill_id]
		self.node_list["TxtName1"].text.text = Language.FuBen.TeamFbSkillName[team_info.skill_list[self.index].skill_id]
		self.node_list["TxtExplain"].text.text = Language.FuBen.TeamFbSkillExplain[team_info.skill_list[self.index].skill_id]
	end
end

function TeamFBTowerSkillExplain:SetIndex(index)
	self.index = index
end
