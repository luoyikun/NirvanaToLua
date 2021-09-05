HunYinReplaceTipsView = HunYinReplaceTipsView or BaseClass(BaseView)
function HunYinReplaceTipsView:__init()
	self.ui_config = {{"uis/views/hunqiview_prefab", "HunYinReplaceTips"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function HunYinReplaceTipsView:__delete()
	-- body
end

function HunYinReplaceTipsView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickYes, self))
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtOldPower"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtNewPower"])
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
	self.current_hunqi_index = 0
	self.current_hunyin_index = 0
	self.current_item_id = 0
end

function HunYinReplaceTipsView:ReleaseCallBack()
	self.current_item_id = nil
	self.current_hunqi_index = nil
	self.current_hunyin_index = nil
	self.fight_text1 = nil
	self.fight_text2 = nil
end

function HunYinReplaceTipsView:OpenCallBack()
	local old_item_id = 0
	old_item_id , self.current_item_id, self.current_hunqi_index, self.current_hunyin_index = self.open_callback()
	local old_item_info = self.hunyin_info[old_item_id][1]
	local new_item_info = self.hunyin_info[self.current_item_id][1]

	self.node_list["TxtNewName"].text.text = Language.HunYinSuit["color_" .. new_item_info.hunyin_color] .. new_item_info.name .. "</color>"
	self.node_list["ImgNewIcon"].image:LoadSprite(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(new_item_info.hunyin_id)))
	self.node_list["TxtNewHp"].text.text = new_item_info.maxhp
	self.node_list["TxtNewFangYu"].text.text = new_item_info.fangyu
	self.node_list["TxtNewMingZhong"].text.text = new_item_info.mingzhong
	self.node_list["TxtNewGongJi"].text.text = new_item_info.gongji
	self.node_list["TxtNewBaoJi"].text.text = new_item_info.baoji
	self.node_list["TxtNewJianRen"].text.text = new_item_info.jianren
	self.node_list["TxtNewShanBi"].text.text = new_item_info.shanbi

	self.node_list["Text_hp_new"]:SetActive(new_item_info.maxhp > 0)
	self.node_list["Text_fangyu_new"]:SetActive(new_item_info.fangyu > 0)
	self.node_list["Text_mingzhong_new"]:SetActive(new_item_info.mingzhong > 0)
	self.node_list["Text_gongji_new"]:SetActive(new_item_info.gongji > 0)
	self.node_list["Text_baoji_new"]:SetActive(new_item_info.baoji > 0)
	self.node_list["Text_jianren_new"]:SetActive(new_item_info.jianren > 0)
	self.node_list["Text_shanbi_new"]:SetActive(new_item_info.shanbi > 0)

	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = CommonDataManager.GetCapability(new_item_info)
	end

	self.node_list["TxtOldName"].text.text = Language.HunYinSuit["color_" .. old_item_info.hunyin_color] .. old_item_info.name .. "</color>"
	self.node_list["ImgOldIcon"].image:LoadSprite(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(old_item_info.hunyin_id)))
	self.node_list["TxtOldHp"].text.text = old_item_info.maxhp
	self.node_list["TxtOldFangYu"].text.text = old_item_info.fangyu
	self.node_list["TxtOldMingZhong"].text.text = old_item_info.mingzhong
	self.node_list["TxtOldGongJi"].text.text = old_item_info.gongji
	self.node_list["TxtOldBaoJi"].text.text = old_item_info.baoji
	self.node_list["TxtOldJianRen"].text.text = old_item_info.jianren
	self.node_list["TxtOldShanBi"].text.text = old_item_info.shanbi

	self.node_list["Text_hp_old"]:SetActive(old_item_info.maxhp > 0)
	self.node_list["Text_fangyu_old"]:SetActive(old_item_info.fangyu > 0)
	self.node_list["Text_mingzhong_old"]:SetActive(old_item_info.mingzhong > 0)
	self.node_list["Text_gongji_old"]:SetActive(old_item_info.gongji > 0)
	self.node_list["Text_baoji_old"]:SetActive(old_item_info.baoji > 0)
	self.node_list["Text_jianren_old"]:SetActive(old_item_info.jianren > 0)
	self.node_list["Text_shanbi_old"]:SetActive(old_item_info.shanbi > 0)

	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = CommonDataManager.GetCapability(old_item_info)
	end
end

function HunYinReplaceTipsView:OnClickYes()
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_HUNYIN_INLAY, self.current_hunqi_index - 1, 
		self.current_hunyin_index - 1, ItemData.Instance:GetItemIndex(self.current_item_id))
	self:OnClickClose()
end

function HunYinReplaceTipsView:OnClickClose()
	self.close_callback()
	self:Close()
end

function HunYinReplaceTipsView:SetOpenCallBack(callback)
	self.open_callback = callback
end

function HunYinReplaceTipsView:SetCloseCallBack(callback)
	self.close_callback = callback
end