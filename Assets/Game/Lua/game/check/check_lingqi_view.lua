CheckLingQiView = CheckLingQiView or BaseClass(BaseRender)
function CheckLingQiView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckLingQiView:__delete()
	self.lingqi_attr = nil
	self.fight_text = nil
end


function CheckLingQiView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end


function CheckLingQiView:OnFlush()
	if self.lingqi_attr then
		local grade_info = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(self.lingqi_attr.grade)
		if nil == grade_info then return end
		local image_info = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.node_list["TxtName"].text.text = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = LingQiData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(LingQiShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = self.lingqi_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.node_list["TxtGongji"].text.text = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.node_list["TxtFangyu"].text.text = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.node_list["TxtShengming"].text.text = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.node_list["TxtMingzhong"].text.text = switch_attr_list.ming_zhong or 0 
		self.node_list["TxtShanbi"].text.text = switch_attr_list.shan_bi or 0 
		self.node_list["TxtBaoji"].text.text = switch_attr_list.bao_ji or 0
		self.node_list["TxtKangbao"].text.text = switch_attr_list.jian_ren or 0 
		self.node_list["TxtZengshang"].text.text = switch_attr_list.per_pofang or 0 
		self.node_list["TxtMianshang"].text.text = switch_attr_list.per_mianshang or 0 

		self.node_list["GongJi"]:SetActive(switch_attr_list.gong_ji and switch_attr_list.gong_ji + zizhi_gongji > 0)
		self.node_list["FangYu"]:SetActive(switch_attr_list.fang_yu and switch_attr_list.fang_yu + zizhi_fangyu > 0)
		self.node_list["ShengMing"]:SetActive(switch_attr_list.max_hp and switch_attr_list.max_hp + zizhi_hp > 0)
		self.node_list["MingZhong"]:SetActive(switch_attr_list.ming_zhong and switch_attr_list.ming_zhong > 0)
		self.node_list["ShanBi"]:SetActive(switch_attr_list.shan_bi and switch_attr_list.shan_bi > 0)
		self.node_list["BaoJi"]:SetActive(switch_attr_list.bao_ji and switch_attr_list.bao_ji > 0)
		self.node_list["KangBao"]:SetActive(switch_attr_list.jian_ren and switch_attr_list.jian_ren > 0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.lingqi_attr.capability
		end

		self:SetModle(image_info)
	end
end

function CheckLingQiView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.lingqi_attr then
		self.lingqi_attr = check_attr.lingqi_attr
		self:Flush()
	end
end

function CheckLingQiView:SetModle(image_cfg)
	local bundle, asset = ResPath.GetLingQiModel(image_cfg.res_id, true)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)

		-- local call_back = function(model, obj)
		-- 	obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
		-- end
		-- UIScene:SetModelLoadCallBack(call_back)
		-- -- local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingqi")
		-- -- UIScene:SetCameraTransform(transform, Vector2(-0.5, 0))
	end)
end
