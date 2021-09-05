BaojidayView2 = BaojidayView2 or BaseClass(BaseRender)

--暴击日
function BaojidayView2:LoadCallBack()
	self.node_list["BtnFanhuan"].button:AddClickListener(BindTool.Bind(self.OpenFanhuan, self))
    -- self.info = KaifuActivityData.Instance:GetBaojiDayCfg()
end

function BaojidayView2:__init()
	self:FlushUI()
end

function BaojidayView2:__delete()

end

function BaojidayView2:OnFlush()
	self:FlushUI()
end

function BaojidayView2:FlushUI()
	local act_type = KaifuActivityData.Instance:GetBaojiDay2ActType()
	if nil == act_type then return end
	local bundle, asset = ResPath.GetBaojiDayImage(act_type)
	self.node_list["ImgBaojiType1"].image:LoadSprite(bundle, asset,
		function ()
	 		self.node_list["ImgBaojiType1"].image:SetNativeSize()
		end)

	self.node_list["ImgBaojiType2"].image:LoadSprite(bundle, asset, 
		function()
			self.node_list["ImgBaojiType2"].image:SetNativeSize()
		end)
		
end

function BaojidayView2:OpenFanhuan()
	local act_type = KaifuActivityData.Instance:GetBaojiDay2ActType()
	if act_type == 1 then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.mount_jinjie)
	elseif act_type == 2 then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.wing_jinjie)
	elseif act_type == 3 then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fabao_jinjie)
	elseif act_type == 4 then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.role_shenbing)
	elseif act_type == 5 then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.foot_jinjie)
	elseif act_type == 6 then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.halo_jinjie)
	elseif act_type == 7 then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fashion_jinjie)
	elseif act_type == 8 then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fight_mount)
	elseif act_type == 9 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_toushi)
	elseif act_type == 10 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_mask)
	elseif act_type == 11 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_waist)
	elseif act_type == 12 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_qilinbi)
	elseif act_type == 13 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_lingtong)
	elseif act_type == 14 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_linggong)
	elseif act_type == 15 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_lingqi)
	elseif act_type == 16 then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shengong)
	elseif act_type == 17 then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shenyi)
	elseif act_type == 18 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_flypet)
	elseif act_type == 19 then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_weiyan)		
	end
end