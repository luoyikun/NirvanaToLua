ShengXiaoSkillView = ShengXiaoSkillView or BaseClass(BaseView)

function ShengXiaoSkillView:__init()
	self.ui_config = {{"uis/views/shengxiaoview_prefab", "ShengXiaoSkill"}}
	self.view_layer = UiLayer.Pop
	self.chapter = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShengXiaoSkillView:__delete()

end

function ShengXiaoSkillView:ReleaseCallBack()
	self.fight_text = nil
end

function ShengXiaoSkillView:LoadCallBack()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightNumber"])
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	--self.node_list["BtnUIBlock"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self:Flush()
end

function ShengXiaoSkillView:OpenCallBack()
	self:Flush()
end

function ShengXiaoSkillView:SetChapter(chapter)
	self.chapter = chapter
	self:Open()
end

function ShengXiaoSkillView:OnFlush()
	if self.chapter > 5 then return end
	local cfg = ShengXiaoData.Instance:GetChapterAttrByChapter(self.chapter)
	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetShengXiaoSkillIcon(self.chapter))
	local max_chapter = ShengXiaoData.Instance:GetMaxChapter()
	-- local total_cap = ShengXiaoData.Instance:GetChapterTotalCap()
	local total_cap = CommonDataManager.GetCapability(cfg)
	self.node_list["TxtProName"].text.text = cfg.skill
	self.node_list["TxtLabel"].text.text = ShengXiaoData.Instance:GetOneChapterActive(self.chapter) and Language.ShengXiao.HasActive or Language.ShengXiao.NoActive
	self.node_list["TxtContent"].text.text = cfg.describe
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = math.floor(total_cap * (1 + cfg.per_attr / 100))
	end
	self.node_list["Text_maxhp"].text.text = cfg.maxhp
	self.node_list["Text_gongji"].text.text = cfg.gongji
	self.node_list["Text_fangyu"].text.text = cfg.fangyu
	self.node_list["Text_mingzhong"].text.text = cfg.mingzhong
	self.node_list["Text_shanbi"].text.text = cfg.shanbi
	self.node_list["Text_baoji"].text.text = cfg.baoji
	self.node_list["Text_jianren"].text.text = cfg.jianren
	self.node_list["Text_jingzhun"].text.text = (cfg.per_jingzhun/ 100) .. "%"

	self.node_list["maxhp"]:SetActive(cfg.maxhp > 0)
	self.node_list["gongji"]:SetActive(cfg.gongji > 0)
	self.node_list["fangyu"]:SetActive(cfg.fangyu > 0)
	self.node_list["mingzhong"]:SetActive(cfg.mingzhong > 0)
	self.node_list["shanbi"]:SetActive(cfg.shanbi > 0)
	self.node_list["baoji"]:SetActive(cfg.baoji > 0)
	self.node_list["jianren"]:SetActive(cfg.jianren > 0)
	self.node_list["jingzhun"]:SetActive(cfg.per_jingzhun > 0)
end

function ShengXiaoSkillView:CloseWindow()
	self:Close()
end