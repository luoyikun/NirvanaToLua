ShenYinQiangHuaAttrView = ShenYinQiangHuaAttrView or BaseClass(BaseView)

function ShenYinQiangHuaAttrView:__init()
	self.ui_config = {{"uis/views/shenyinview_prefab", "QiangHuaAttrView"}}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.item_cell_list = {}
	self.is_modal = true	
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenYinQiangHuaAttrView:__delete()

end

function ShenYinQiangHuaAttrView:ReleaseCallBack()

end

function ShenYinQiangHuaAttrView:LoadCallBack()

	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose,self))
	--self.node_list["BtnBgClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose,self))
end

function ShenYinQiangHuaAttrView:OpenCallBack()
	self:Flush()
end

function ShenYinQiangHuaAttrView:OnClickClose()
	self:Close()
end

function ShenYinQiangHuaAttrView:ShowIndexCallBack(index)
	self:Flush()
end


function ShenYinQiangHuaAttrView:OnFlush(param_t)
	if self.index == nil then return end
	local data = ShenYinData.Instance:GetMarkSlotInfo()
	local item_data = data[self.index]
	self.node_list["FirstNode"]:SetActive(true)
	self.node_list["nextNode"]:SetActive(true)
	local max_data = ShenYinData.Instance:GetShenYinQiangHuaMax()
	if item_data == nil then
		self.node_list["nextNode"]:SetActive(false)
		self.node_list["Arrow"]:SetActive(false)
		self.node_list["gradeTxt"].text.text = CommonDataManager.GetDaXie(0)..Language.ShenYin.steps..CommonDataManager.GetDaXie(0)..Language.ShenYin.star
		self.node_list["shuxingTxt"].text.text = 0
		return
	end
	local is_show_first = not(item_data.grade == 0 and item_data.level == 0)
	local is_show_next = not (item_data.grade >= max_data.stage)
	self.node_list["FirstNode"]:SetActive(is_show_first)
	self.node_list["nextNode"]:SetActive(is_show_next)
	self.node_list["Arrow"]:SetActive(is_show_first and is_show_next)

	local up_star_cfg = ShenYinData.Instance:GetUpStarCFG(self.index, item_data.grade, item_data.level)
	local next_star_cfg = ShenYinData.Instance:GetUpStarCFG(self.index, item_data.grade + 1, item_data.level)
	self.node_list["gradeTxt"].text.text = CommonDataManager.GetDaXie(item_data.grade) .. Language.ShenYin.steps..CommonDataManager.GetDaXie(item_data.level)..Language.ShenYin.star
	self.node_list["nextgradeTxt"].text.text = CommonDataManager.GetDaXie(item_data.grade + 1) .. Language.ShenYin.steps..CommonDataManager.GetDaXie(0)..Language.ShenYin.star

	self.node_list["shuxingTxt"].text.text = string.format(Language.ShenYin.ShuXingTxtGreen,up_star_cfg.basics_addition)
	self.node_list["nextshuxingTxt"].text.text = string.format(Language.ShenYin.ShuXingTxtRed,tostring(next_star_cfg.basics_addition))
end

function ShenYinQiangHuaAttrView:SetSelectIndex(index)
	self.index = index
	self:Flush()
end