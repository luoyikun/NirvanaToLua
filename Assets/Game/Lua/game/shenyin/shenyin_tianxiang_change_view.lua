ShenYinTianXiangChangeView = ShenYinTianXiangChangeView or BaseClass(BaseView)

function ShenYinTianXiangChangeView:__init()
	self.ui_config = {{"uis/views/shenyinview_prefab", "TianXiangChangeView"}}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.item_cell_list = {}
	self.is_modal = true
end

function ShenYinTianXiangChangeView:__delete()

end

function ShenYinTianXiangChangeView:ReleaseCallBack()
	self.select_type = 1
	self.boll_asset = nil
	self.show_mingzhong = nil
	self.item_cell_list = {}
end

function ShenYinTianXiangChangeView:LoadCallBack()
	self.select_type = 1
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnFalse"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["select_btn"].toggle:AddClickListener(BindTool.Bind(self.OnSelectList, self))
	self.node_list["BtnTrue"].button:AddClickListener(BindTool.Bind(self.OnClickTrue, self))

	self:LoadCell()
end

function ShenYinTianXiangChangeView:OpenCallBack()
	self:Flush()
end

function ShenYinTianXiangChangeView:LoadCell()
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/shenyinview_prefab", "TianXiangChangeBtn", nil, function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, 4 do
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["List"].transform, false)
			obj:GetComponent("Toggle").group = self.node_list["List"].toggle_group
			local item_cell = TianXiangChangeItem.New(obj, self)
			self.item_cell_list[i] = item_cell
		end
	end)
end


function ShenYinTianXiangChangeView:OnClickClose()
	self:Close()
end

function ShenYinTianXiangChangeView:OnSelectList()
	local other_cfg = ShenYinData.Instance:GetOtherTianxianBoll(self.type)
	for i = 1, 4 do
		if self.item_cell_list[i] then
			self.item_cell_list[i]:SetData(other_cfg[i], i)
		end
	end
end

function ShenYinTianXiangChangeView:OnClickTrue()
	local other_cfg = ShenYinData.Instance:GetOtherTianxianBoll(self.type)
	local change_type =  other_cfg[self.select_type].type or 0
	if change_type <= 0 then return end
	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.CHANGE_BEAD_TYPE, self.data.x - 1, self.data.y - 1, change_type)
	self:Close()
end

function ShenYinTianXiangChangeView:ShowIndexCallBack(index)
	self:Flush()
end


function ShenYinTianXiangChangeView:OnFlush(param_t)
	if self.data == nil or self.type == nil then return end
	local shenyin_other_cfg = ShenYinData.Instance:GetOtherCFG()
	
	local boll_cfg = ShenYinData.Instance:GetTianxianBollCfg(self.type)

	self.node_list["BollImg"].image:LoadSprite(ResPath.GetTianXiangPieceIcon(self.type))
	self.node_list["ChangeTxt"].text.text = string.format(Language.ShenYin.ChangeSpend, shenyin_other_cfg.change_bead_type_need_gold)
	self.node_list["Txthp"].text.text = string.format("+%s", boll_cfg.maxhp)
	self.node_list["Txtgongji"].text.text = string.format("+%s", boll_cfg.gongji)
	self.node_list["Txtfangyu"].text.text = string.format("+%s", boll_cfg.fangyu)
	self.node_list["Txtmingzhong"].text.text = string.format("+%s", boll_cfg.mingzhong)
	self.node_list["Txtshowhp"]:SetActive(boll_cfg.maxhp > 0)
	self.node_list["Txtshowgongji"]:SetActive(boll_cfg.gongji > 0)
	self.node_list["Txtshowfangyu"]:SetActive(boll_cfg.fangyu > 0)
	self.node_list["Txtshowmingzhong"]:SetActive(boll_cfg.mingzhong > 0)

	self:SetSelectToChangeBoll()
end

function ShenYinTianXiangChangeView:SetSelectToChangeBoll()
	local other_cfg = ShenYinData.Instance:GetOtherTianxianBoll(self.type)
	self.node_list["BollTxt"].text.text = other_cfg[self.select_type].name
	self.node_list["Imgboll"].image:LoadSprite(ResPath.GetTianXiangPieceIcon(other_cfg[self.select_type].type))
end

function ShenYinTianXiangChangeView:SetSelectType(select_type)
	self.select_type = select_type
	self:SetSelectToChangeBoll()
	if self.node_list["select_btn"] then
		self.node_list["select_btn"].accordion_element.isOn = false
	end
end

function ShenYinTianXiangChangeView:SetData(data, type)
	self.data = data
	self.type = type
	self:Flush()
end


---
------------------------------------------------
TianXiangChangeItem = TianXiangChangeItem or BaseClass(BaseCell)
function TianXiangChangeItem:__init(instance, parent)
	self.parent = parent
	self.node_list["TianXiangChangeBtn"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["SelectBtn"].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.OnClick, self))

end

function TianXiangChangeItem:__delete()
	self.parent = nil
end

function TianXiangChangeItem:SetData(data, select_type)
	self.data = data
	self.select_type = select_type
	self:OnFlush()
end

function TianXiangChangeItem:OnClick()
	self.parent:SetSelectType(self.select_type)
end

function TianXiangChangeItem:OnFlush()
	if self.data == nil then return end
	self.node_list["BollTxt"].text.text = self.data.name

	self.node_list["BollImg"].image:LoadSprite(ResPath.GetTianXiangPieceIcon(self.data.type))
end
