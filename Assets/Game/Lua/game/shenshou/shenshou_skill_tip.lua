ShenShouSkillTip = ShenShouSkillTip or BaseClass(BaseView)

function ShenShouSkillTip:__init()
	self.ui_config = {{"uis/views/shenshouview_prefab", "ShenShouSkillTip"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenShouSkillTip:__delete()

end

function ShenShouSkillTip:ReleaseCallBack()
	self.data = nil
	self.index = 0
end

function ShenShouSkillTip:LoadCallBack()
	--self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function ShenShouSkillTip:ShowIndexCallBack()
	self:Flush()
end

function ShenShouSkillTip:SetData(index, cell)
	self.index = index
	self.data = cell.data
	self:Flush()
end

function ShenShouSkillTip:OnFlush()
	local skill_cfg = ShenShouData.Instance:GetShenShouSkillCfg(self.data.skill_type, self.data.level)
	if nil == skill_cfg then return end

	local bundle, asset = ResPath.GetShenShouSkillIcon(skill_cfg.icon_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["TxtSkillName"].text.text = skill_cfg.name
	self.node_list["TxtTypeDes"].text.text = skill_cfg.buff

	local loop = 1
	local value_list = {}
	if skill_cfg then
		for i = 1, 7 do
			if skill_cfg["param_" .. i] ~= "" then
				value_list[loop] = skill_cfg["param_" .. i] >= 100 and skill_cfg["param_" .. i] / 100 or skill_cfg["param_" .. i]
				loop = loop + 1
			end
		end
	end

	local desc = string.format(skill_cfg.description, value_list[1], value_list[2], value_list[3], value_list[4], value_list[5], value_list[6], value_list[7])
	self.node_list["Txtskilldec"].text.text = desc
end
