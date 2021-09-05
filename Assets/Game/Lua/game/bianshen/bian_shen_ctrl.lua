require("game/bianshen/bian_shen_view")
require("game/bianshen/bian_shen_data")
require("game/bianshen/bian_shen_head_item")
require("game/bianshen/bianshen_warehouse_view")
require("game/bianshen/equip/bianshen_equip_bag")
require("game/bianshen/strengthen/strengthen_select_material_view")
require("game/bianshen/bianshen_skill_tip_view")

BianShenCtrl = BianShenCtrl or BaseClass(BaseController)

function BianShenCtrl:__init()
	if BianShenCtrl.Instance ~= nil then
		ErrorLog("[BianShenCtrl] attempt to create singleton twice!")
		return
	end
	BianShenCtrl.Instance = self
	self.bian_shen_data = BianShenData.New()
	self:RegisterAllProtocols()
	self.bian_shen_view = BianShenView.New(ViewName.BianShenView)
	self.warehouse_view = BianShenWarehouseView.New(ViewName.BianShenWarehouseView)			--变身-请神仓库
	self.bianshen_equip_bag = BianShenEquipBag.New(ViewName.BianShenEquipBag)				-- 变身装备背包
	self.strengthen_select_material_view = StrengthenSelectMaterialView.New(ViewName.BianShenStrengthenSelectView)		-- 变身强化的挑选列表
	self.bianshen_skill_tip_view = BianShenSkillTipView.New(ViewName.BianShenSkillTipView)			-- 变身技能视图

	self.ui_layer = GameObject.Find("GameRoot/UILayer").transform
	self.ui_camera3 = GameObject.Find("GameRoot/UICamera3"):GetComponent(typeof(UnityEngine.Camera))
end

function BianShenCtrl:__delete()
	BianShenCtrl.Instance = nil
	
	if self.bian_shen_view then
		self.bian_shen_view:DeleteMe()
		self.bian_shen_view = nil
	end

	if self.bian_shen_data ~= nil then
		self.bian_shen_data:DeleteMe()
		self.bian_shen_data = nil
	end

	if self.warehouse_view then
		self.warehouse_view:DeleteMe()
		self.warehouse_view = nil
	end

	if self.bianshen_equip_bag then
		self.bianshen_equip_bag:DeleteMe()
		self.bianshen_equip_bag = nil
	end

	if self.strengthen_select_material_view then
		self.strengthen_select_material_view:DeleteMe()
		self.strengthen_select_material_view = nil
	end

	if self.bianshen_skill_tip_view then
		self.bianshen_skill_tip_view:DeleteMe()
		self.bianshen_skill_tip_view = nil
	end

	self.ui_layer = nil
	self.ui_camera3 = nil
end

-- 协议注册
function BianShenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGreateSoldierItemInfo, "OnGreateSoldierItemInfo")
	self:RegisterProtocol(SCGreateSoldierOtherInfo, "OnGreateSoldierOtherInfo")
	self:RegisterProtocol(SCGreateSoldierSlotInfo, "OnGreateSoldierSlotInfo")
	self:RegisterProtocol(SCGreateSoldierFetchReward, "OnGreateSoldierFetchReward")
	self:RegisterProtocol(SCGreateSoldierGoalInfo, "OnSCGreateSoldierGoalInfo")
end

function BianShenCtrl:SetCurSelectIndex(index)
	self.select_index = index
end

function BianShenCtrl:GetCurSelectIndex()
	if self.select_index then
		return self.select_index
	end
end

-- 名将/变身请求
function BianShenCtrl:SendRequest(req_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGreateSoldierOpera)
	protocol.req_type = req_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end

-- 名将吞噬强化装备请求 名将seq/装备槽位/消耗物品数量/物品下标列表 
function BianShenCtrl:SendStrengthReq(seq, equip_index, destroy_num, destroy_backpack_index_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGreateSoldierReqStrength)
	protocol.seq = seq or 0
	protocol.equip_index = equip_index or 0
	protocol.destroy_num = destroy_num or 0
	protocol.destroy_backpack_index_list = destroy_backpack_index_list or {}
	protocol:EncodeAndSend()
end

-- 名将/变身信息
function BianShenCtrl:OnGreateSoldierItemInfo(protocol)
	self.bian_shen_data:SetGreateSoldierItemInfo(protocol)
	self.bian_shen_view:Flush("bianshen_msg")
	self.bian_shen_view:Flush("bianshen_qianneng")
	self.bian_shen_view:Flush("bianshen_equipcontent")
	self.bian_shen_view:Flush("bianshen_strengthen")
	RemindManager.Instance:Fire(RemindName.BianShenMsg)
	RemindManager.Instance:Fire(RemindName.BianShenQianNeng)
	RemindManager.Instance:Fire(RemindName.BianShenEquip)
	RemindManager.Instance:Fire(RemindName.BianShenStrengthen)
end

--  名将/变身其他信息
function BianShenCtrl:OnGreateSoldierOtherInfo(protocol)
	self.bian_shen_data:SetGreateSoldierOtherInfo(protocol)
	self.bian_shen_view:Flush()
	MainUICtrl.Instance:FlushView("check_skill")
	MainUICtrl.Instance:FlushView("flush_bianshen_cd")
	MainUICtrl.Instance:FlushView("general_bianshen", {"skill"})
	TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
end

-- 名将/变身将位信息
function BianShenCtrl:OnGreateSoldierSlotInfo(protocol)
	self.bian_shen_data:SetGreateSoldierSlotInfo(protocol)
	self.bian_shen_view:Flush("bianshen_msg")
	MainUICtrl.Instance:FlushView("check_skill")
end


function BianShenCtrl:OnGreateSoldierFetchReward(protocol)
	self.bian_shen_data:SetGreateSoldierFetchReward(protocol)
	TipsCtrl.Instance:FlushBeautyFamousTaskVIew()
end

-- 名将/变身目标
function BianShenCtrl:OnSCGreateSoldierGoalInfo(protocol)
	self.bian_shen_data:SetGeneralGoalInfo(protocol)
end

-- 刷新仓库视图
function BianShenCtrl:FlushWarehouseView()
	 self.warehouse_view:Flush()
end

-- 帅新变身信息
function BianShenCtrl:FlushMsgView()
	self.bian_shen_view:Flush("bianshen_msg")
end

-- 改变装备背包的槽位、神魔品质、名将索引
function BianShenCtrl:SetBianShenEquipIndex(index, quality, select_index)
	self.bianshen_equip_bag:SetSlotIndex(index, quality, select_index)
end

function BianShenCtrl:SetStrengthenSelectMaterialViewCallBack(callback)
	self.strengthen_select_material_view:SetCallBack(callback)
end

function BianShenCtrl:SetStrengthenCancelViewCallBack(callback)
	self.strengthen_select_material_view:SetCallBack(callback , "Cancel")
end

function BianShenCtrl:SetStrengthenSelectMaterialViewCloseCallBack(callback)
	self.strengthen_select_material_view:SetCloseCallBack(callback)
end

-- 打开技能信息视图
function BianShenCtrl:OpenSkillTipView(skill_id, select_role_index, is_passivity_skill, is_special_skill)
	ViewManager.Instance:Open(ViewName.BianShenSkillTipView)
	self.bianshen_skill_tip_view:SetData(skill_id, select_role_index, is_passivity_skill, is_special_skill)
end

-- 变身时播放特效展示
function BianShenCtrl:ShowBianShen(cur_use_imageid)
	if cur_use_imageid == 0 then return end
	local obj = ResPoolMgr:TryGetGameObject("uis/views/miscpreload_prefab", "PaintingEffect")
	local obj_transform = obj.transform
	obj_transform:SetParent(self.ui_layer, false)
	local canvas = obj_transform:GetComponent(typeof(UnityEngine.Canvas))
	canvas.worldCamera = self.ui_camera3
	if SettingCtrl.Instance:UnlockIsOpen() then
		obj_transform:SetAsFirstSibling()
	end
	AudioManager.PlayAndForget("audios/sfxs/other", "bianshen")

	local node_list = U3DNodeList(obj:GetComponent(typeof(UINameTable)), self)
	local animator = obj:GetComponent(typeof(UnityEngine.Animator))
	if cur_use_imageid then
		local huan_hua = ""
		local ues_seq = BianShenData.Instance:GetSeqByImageId(cur_use_imageid)
		if ues_seq == nil then
			ues_seq = BianShenData.Instance:GetCurHuanHuaCfgID(cur_use_imageid)
			huan_hua = ues_seq == nil and "" or "HuanHua_"
		end
		ues_seq = ues_seq == nil and 0 or ues_seq
		local bundle, asset = ResPath.GetRawImage("BianShen_" .. huan_hua .. ues_seq)
		node_list["ImageRight"].raw_image:LoadSprite(bundle, asset)
		node_list["ImageLeft"].raw_image:LoadSprite("uis/rawimages/generalbianshen_bg", "GeneralBianShen_Bg.png")
		if not IsNil(animator) then
			animator:WaitEvent("EffectStop", function ()
				if not IsNil(obj) then
					ResPoolMgr:Release(obj)
				end
			end)
		end
	else
		local use_seq = BianShenData.Instance:GetCurUseSeq()
		local bundle, asset = ResPath.GetRawImage("BianShen_" .. use_seq)
		node_list["ImageRight"].raw_image:LoadSprite(bundle, asset)
		node_list["ImageLeft"].raw_image:LoadSprite("uis/rawimages/generalbianshen_bg", "GeneralBianShen_Bg.png")
		if not IsNil(animator) then
			animator:WaitEvent("EffectStop", function ()
				if not IsNil(obj) then
					ResPoolMgr:Release(obj)
				end
			end)
		end
	end
end

function BianShenCtrl:LoadSprite(bundle_name, asset_name, callback)
	LoadSprite(self, bundle_name, asset_name, callback)
end

function BianShenCtrl:LoadRawImage(arg0, arg1, arg2)
	LoadRawImage(self, arg0, arg1, arg2)
end


