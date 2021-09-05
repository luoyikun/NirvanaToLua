TipsPataSkillView = TipsPataSkillView or BaseClass(BaseView)

function TipsPataSkillView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "PaTaSkillFBTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	-- self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsPataSkillView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
end

function TipsPataSkillView:ReleaseCallBack()
	
end

function TipsPataSkillView:OpenCallBack()
end

function TipsPataSkillView:CloseCallBack()
	self.data = nil
	self.name = nil
end

function TipsPataSkillView:CloseView()
	self:Close()
end


function TipsPataSkillView:SetData(data,name)
	self.data = data
	self.name = name
	self:Flush()
end

function TipsPataSkillView:OnFlush()
	if self.data then
		local skill_bundle, skill_asset = ResPath.GetFuBenViewImage("peijian_skill_" .. self.data)
		self.node_list["Skillicon"].image:LoadSprite(skill_bundle, skill_asset)
		local next_mojie_cfg = FuBenData.Instance:GetMoJieAllInfo()[self.data]
		local params = next_mojie_cfg.skill_param
		self.node_list["Skilltitle"].text.text = self.name
		self.node_list["SkillDesc"].text.text = string.format(Language.FubenTower.TowerMoJieSkillDes[self.data], params[1], params[2], params[3], params[4])
	end
end