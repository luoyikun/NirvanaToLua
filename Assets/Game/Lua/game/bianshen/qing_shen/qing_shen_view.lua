-- 仙域-变身-请神
QingShenView = QingShenView or BaseClass(BaseRender)

function QingShenView:__init()

end

function QingShenView:__delete()
	for k, v in pairs(self.reward_item_list) do
		v.item:DeleteMe()
	end
	self.reward_item_list = {}

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

end

function QingShenView:LoadCallBack()
	local other_cfg = BianShenData.Instance:GetOtherCfg()
	self.node_list["BtnHouse"].button:AddClickListener(BindTool.Bind(self.OnClickOpenHouse, self))
	self.node_list["BtnGetOne"].button:AddClickListener(BindTool.Bind(self.OnClickChou, self, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_1_DRAW, other_cfg.draw_1_item_id))
	self.node_list["BtnGetTen"].button:AddClickListener(BindTool.Bind(self.OnClickChou, self, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_10_DRAW, other_cfg.draw_10_item_id))

	self.reward_item_list = {}
	for i = 1, 10 do
		local temp = {}
		temp.obj = self.node_list["ItemCell" .. i]
		temp.item = ItemCell.New()
		temp.item:SetInstanceParent(temp.obj)
		self.reward_item_list[i] = temp
	end

	if not self.item_change_callback then
		self.item_change_callback = BindTool.Bind(self.ItemChangeCallBack, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	end
	self:ItemChangeCallBack()

end

function QingShenView:OpenCallBack()

end


function QingShenView:OnFlush()
	local reward_cfg = BianShenData.Instance:GetShowReward()
	if nil == reward_cfg then
		return
	end
	local other_cfg = BianShenData.Instance:GetOtherCfg()
	local show_cfg = BianShenData.Instance:GetSingleDataBySeq(other_cfg.show_seq)
	if nil == other_cfg or nil == show_cfg then
		return
	end

	UIScene:SetModelLoadCallBack(function(model, obj)
		model:SetTrigger(ANIMATOR_PARAM.REST)
		obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		UIScene:SetRoleModelScale(1.3)
	end)
	local bundle, asset = ResPath.GetMingJiangRes(show_cfg.image_id)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)

	for k,v in pairs(self.reward_item_list) do
		if reward_cfg[k] and reward_cfg[k].reward_item then
			v.item:SetData(reward_cfg[k].reward_item)
			v.obj:SetActive(true)
			if reward_cfg[k].is_rare == 1 then
				v.item:ShowSpecialEffect(true)
				local bunble, asset = ResPath.GetItemEffect()
				v.item:SetSpecialEffect(bunble, asset)
			end
		else
			v.item:ShowSpecialEffect(false)
			v.obj:SetActive(false)
		end
	end
end

function QingShenView:ItemChangeCallBack()
	local other_cfg = BianShenData.Instance:GetOtherCfg()
	local have_num = ItemData.Instance:GetItemNumInBagById(other_cfg.draw_1_item_id)
	local color_1 = have_num >= other_cfg.draw_1_item_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
	self.node_list["HaveText1"].text.text = string.format(Language.BianShen.MaterialsNum2, color_1, have_num, other_cfg.draw_1_item_num)

	local is_first = BianShenData.Instance:IsFirstTenChou()
	local ten_num = is_first and other_cfg.daily_first_draw_10_item_num or other_cfg.draw_10_item_num
	local color_2 = have_num >= ten_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
	self.node_list["HaveText2"].text.text = string.format(Language.BianShen.MaterialsNum2, color_2, have_num, ten_num)
end

-- 打开请神仓库
function QingShenView:OnClickOpenHouse()
	ViewManager.Instance:Open(ViewName.BianShenWarehouseView)
end

function QingShenView:OnClickChou(chou_type, item_id)
	local is_auto_buy = TipsCommonBuyView.AUTO_LIST[item_id] and 1 or 0
	BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, chou_type, is_auto_buy)
end

function QingShenView:UITween()
	UITween.MoveShowPanel(self.node_list["ListBG"], Vector3(-248, 498, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["BtnPanel"] , true , 0.7 , DG.Tweening.Ease.Linear )
	UITween.MoveShowPanel(self.node_list["BtnGrop"], Vector3(-286, -472, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Image"], Vector3(0, -406, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["ImageName"], Vector3(400, 192, 0), 0.7)
end