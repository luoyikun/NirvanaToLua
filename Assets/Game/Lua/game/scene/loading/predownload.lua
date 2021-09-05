PreDownload = PreDownload or BaseClass(BaseView)

function PreDownload:__init()
	self.wait_queue = {}
	self.next_check_download_time = 0
	self.update_retry_times = 0
	self.is_downloading = false
	self.download_list = self:GetDownloadList()
	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskChange, self))
end

function PreDownload:__delete()
	Runner.Instance:RemoveRunObj(self)
	GlobalEventSystem:UnBind(self.task_change)
end

function PreDownload:OnTaskChange(task_event_type, task_id)
	if task_event_type == "accepted_add" then
		self:CalcNewDownloadItem()
	end
end

function PreDownload:Update(now_time, elapse_time)
	if now_time >= self.next_check_download_time then
		self:CalcNewDownloadItem()
		self.next_check_download_time = now_time + 5
	end
	
	self:CheckQueueDownload()
end

function PreDownload:Start()
	Runner.Instance:AddRunObj(self, 8)
end

function PreDownload:Stop()
	Runner.Instance:RemoveRunObj(self)
end

function PreDownload:CalcNewDownloadItem()
	if #self.download_list <= 0 then
		return
	end

	-- 审核服不偷偷下载
	if IS_AUDIT_VERSION then
		return
	end

	for i = #self.download_list, 1, -1 do
		local t = self.download_list[i]

		local is_in_scene = true
		if t.in_scene_id > 0 and Scene.Instance:GetSceneId() ~= t.in_scene_id then
			is_in_scene = false
		end

		local is_accept_task = true
		if t.accept_task > 0 and not TaskData.Instance:GetTaskIsAccepted(t.accept_task) then
			is_accept_task = false
		end

		local is_over_level = true
		if t.over_level > 0 and GameVoManager.Instance:GetMainRoleVo().level < t.over_level then
			is_over_level = false
		end

		local enough_quality = true
		if QualityConfig.QualityLevel > t.quality then  -- lQualityLevel高品质为0开始
			enough_quality = false
		end

		if is_in_scene 
			and is_accept_task 
			and enough_quality
			and is_over_level then

			table.insert(self.wait_queue, t)
			table.remove(self.download_list, i)
		end
	end
end

function PreDownload:CheckQueueDownload()
	if #self.wait_queue <= 0 or self.is_downloading then
		return
	end

	self.update_retry_times = 0
	self.is_downloading = true

	local t = table.remove(self.wait_queue, 1)
	self:DownloadBundle(t.bundle)
end

function PreDownload:DownloadBundle(bundle)
	print("PreDownload:DownloadBundle", bundle)

	ResMgr:UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)
			
		end,

		function(error_msg)
			if error_msg ~= nil and error_msg ~= "" then
				self:OnDownloadBundleFail(bundle)
			else
				print_log("download succ", bundle)
				self.is_downloading = false

				if self.update_retry_times > 0 then
					self.update_retry_times = 0
                    ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url)
				end
			end
		end)
end

-- 下载bundle失败后再尝试
function PreDownload:OnDownloadBundleFail(bundle)
	if self.update_retry_times < 8 then
		self.update_retry_times = self.update_retry_times + 1
		if GLOBAL_CONFIG.param_list.update_url2 ~= nil then -- 切换下载地址
			if self.update_retry_times % 2 == 1 
				and nil ~= GLOBAL_CONFIG.param_list.update_url2 
				and "" ~= GLOBAL_CONFIG.param_list.update_url2 then
                ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url2)
			else
                ResMgr:SetDownloadingURL(GLOBAL_CONFIG.param_list.update_url)
			end
		end

		print_log("retry download ", bundle, ", retry times=", self.update_retry_times, ", url=", ResMgr.download_list)
		self:DownloadBundle(bundle)
	else
		self.is_downloading = false
	end
end

-- 0.高配 1.中配 2.低配 3.超低配
function PreDownload:GetDownloadList()
	local list = {}
	-- 需要加载的bundle(策划配置)
	 table.insert(list, {quality = 3, bundle = "cg/w3_yw_zuihuayin_prefab", in_scene_id = 101, accept_task = 0, over_level = 0}) -- 太一仙境CG（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_yw_zuihuayin_main", in_scene_id = 101, accept_task = 0, over_level = 0}) -- 太一仙境（完成）
	 table.insert(list, {quality = 3, bundle = "cg/w3_yw_zhucheng_prefab", in_scene_id = 102, accept_task = 0, over_level = 0}) -- 主城CG（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_yw_zhucheng_main", in_scene_id = 102, accept_task = 0, over_level = 0}) -- 主城（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_yw_bingxue_main", in_scene_id = 103, accept_task = 0, over_level = 0}) -- 极北冰原（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_yw_haidi_main", in_scene_id = 104, accept_task = 0, over_level = 0}) -- 海底（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_yw_rongyan_main", in_scene_id = 105, accept_task = 0, over_level = 0}) -- 熔岩（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_yw_difu_main", in_scene_id = 106, accept_task = 0, over_level = 0}) -- 冥界（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_yw_senlin_main", in_scene_id = 0, accept_task = 0, over_level = 80}) -- 武器推图本1（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_yw_huangcheng_main", in_scene_id = 0, accept_task = 0, over_level = 154}) -- 套装BOSS（完成）
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_zc_1v1_main", in_scene_id = 0, accept_task = 0, over_level = 249}) -- 1v1
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_zc_gongchengzhan_main", in_scene_id = 0, accept_task = 0, over_level = 251}) -- 攻城战
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_zc_xianmengzhengba_main", in_scene_id = 0, accept_task = 0, over_level = 114}) -- 仙盟争霸（完成）
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_zc_xiuluota_main", in_scene_id = 0, accept_task = 0, over_level = 114}) -- 修罗塔（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_fb_feichuan_main", in_scene_id = 0, accept_task = 0, over_level = 149}) -- 战骑进阶本（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_feijian_main", in_scene_id = 0, accept_task = 0, over_level = 76}) -- 坐骑进阶本1（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_fuwenta_main", in_scene_id = 0, accept_task = 970, over_level = 0}) -- 战魂塔（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_guanghuan_main", in_scene_id = 0, accept_task = 17014, over_level = 0}) -- 光环（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_jingyan_main", in_scene_id = 0, accept_task = 0, over_level = 301}) -- 品质5（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_pata_main", in_scene_id = 0, accept_task = 0, over_level = 121}) -- 单人爬塔(完成)
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_shengong_main", in_scene_id = 0, accept_task = 0, over_level = 201}) -- 品质本4（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_fb_shenyi_main", in_scene_id = 0, accept_task = 0, over_level = 155}) -- 灵童进阶本（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_fb_tafang_main", in_scene_id = 0, accept_task = 0, over_level = 210}) -- 塔防(完成)
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_xingkong_main", in_scene_id = 0, accept_task = 0, over_level = 100}) -- 组队经验本（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_yuyi_main", in_scene_id = 0, accept_task = 0, over_level = 135}) -- 品质本2（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_fb_zhuanzhiboss_main", in_scene_id = 0, accept_task = 0, over_level = 115}) -- 转职BOSS（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_fb_zuoqi_main", in_scene_id = 0, accept_task = 0, over_level = 350}) -- 坐骑（完成）
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_hd_hunyan_main", in_scene_id = 0, accept_task = 0, over_level = 70}) -- 婚宴（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_baobaoboss_main", in_scene_id = 0, accept_task = 0, over_level = 203}) -- 宝宝boss（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_hd_dafuhao_main", in_scene_id = 0, accept_task = 0, over_level = 86}) -- 防具推图本(完成)
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_gonghuiboss_main", in_scene_id = 0, accept_task = 0, over_level = 103}) -- 仙盟答题（完成）
	 table.insert(list, {quality = 3, bundle = "scenes/map/w3_hd_jingjichang_main", in_scene_id = 0, accept_task = 0, over_level = 140}) -- 1V1竞技（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_kuafu3v3_main", in_scene_id = 0, accept_task = 0, over_level = 255}) -- 3v3（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_kuafuboss_main", in_scene_id = 0, accept_task = 0, over_level = 271}) -- 神域BOSS（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_kuafudiaoyudao_main", in_scene_id = 0, accept_task = 0, over_level = 105}) -- 跨服钓鱼（完成）
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_hd_liujie_fenchangjing_main", in_scene_id = 0, accept_task = 0, over_level = 114}) -- 攻城之战（完成）
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_hd_liujie_zhuchangjing_main", in_scene_id = 0, accept_task = 0, over_level = 116}) -- BOSS-简单（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_rongyanboss_main", in_scene_id = 0, accept_task = 17017, over_level = 0}) -- BOSS-困难（原精英）（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_shuijing_main", in_scene_id = 0, accept_task = 0, over_level = 116}) -- BOSS-困难(完成)
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_tianjiangcaibao_main", in_scene_id = 0, accept_task = 0, over_level = 996}) -- 天降财宝(完成)
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_vipboss_mian", in_scene_id = 0, accept_task = 0, over_level = 146}) -- BOSS-VIP(完成)
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_hd_wanglingtanxian_main", in_scene_id = 0, accept_task = 0, over_level = 102}) -- 地宫探险（完成）
	 table.insert(list, {quality = 2, bundle = "scenes/map/w3_hd_wenquan_main", in_scene_id = 0, accept_task = 0, over_level = 101}) -- 温泉答题（完成）
	 table.insert(list, {quality = 1, bundle = "scenes/map/w3_hd_xiangmo_main", in_scene_id = 0, accept_task = 0, over_level = 230}) -- 攻城之战
	 table.insert(list, {quality = 1, bundle = "cg/cg_jingjichang_prefab", in_scene_id = 0, accept_task = 0, over_level = 141}) -- 竞技场CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_feichuan_prefab", in_scene_id = 0, accept_task = 0, over_level = 148}) -- 飞船CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_feijian_prefab", in_scene_id = 0, accept_task = 0, over_level = 74}) -- 飞剑CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_guanghuan_prefab", in_scene_id = 0, accept_task = 17014, over_level = 0}) -- 光环CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_jingyan_prefab", in_scene_id = 0, accept_task = 0, over_level = 301}) -- 经验CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_shengong_prefab", in_scene_id = 0, accept_task = 0, over_level = 199}) -- 神弓CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_shenyi_prefab", in_scene_id = 0, accept_task = 0, over_level = 154}) -- 神翼CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_xingkong_prefab", in_scene_id = 0, accept_task = 0, over_level = 95}) -- 星空CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_yuyi_prefab", in_scene_id = 0, accept_task = 0, over_level = 133}) -- 神翼CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_zhuanzhiboss_prefab", in_scene_id = 0, accept_task = 0, over_level = 110}) -- 转职bossCG
	 table.insert(list, {quality = 1, bundle = "cg/w3_fb_zuoqi_prefab", in_scene_id = 0, accept_task = 0, over_level = 330}) -- 坐骑CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_gn_hunyan_prefab", in_scene_id = 0, accept_task = 0, over_level = 65}) -- 结婚CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_hd_dafuhao_prefab", in_scene_id = 0, accept_task = 0, over_level = 84}) -- 大富豪CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_hd_shuijing_prefab", in_scene_id = 0, accept_task = 0, over_level = 113}) -- 水晶CG
	 table.insert(list, {quality = 1, bundle = "cg/zz_nanjian_prefab", in_scene_id = 0, accept_task = 0, over_level = 80}) -- 男剑CG
	 table.insert(list, {quality = 1, bundle = "cg/zz_nanqin_prefab", in_scene_id = 0, accept_task = 0, over_level = 80}) -- 男琴CG
	 table.insert(list, {quality = 1, bundle = "cg/zz_nvpao_prefab", in_scene_id = 0, accept_task = 0, over_level = 80}) -- 女炮CG
	 table.insert(list, {quality = 1, bundle = "cg/zz_nvshuangjian_prefab", in_scene_id = 0, accept_task = 0, over_level = 80}) -- 女双剑CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_hd_liujie_fenchangjing_prefab", in_scene_id = 0, accept_task = 0, over_level = 115}) -- 攻城战CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_hd_liujie_zhuchangjing_prefab", in_scene_id = 0, accept_task = 0, over_level = 115}) -- 连服CG
	 table.insert(list, {quality = 1, bundle = "cg/w3_zc_xianmengzhengba_prefab", in_scene_id = 0, accept_task = 0, over_level = 115}) -- 仙盟争霸CG

	
	-- 处理成相关联的文件
	local download_list = {}
	local dic = {}
	for _, v in ipairs(list) do
		local uncached_bundles = ResMgr:GetBundlesWithoutCached(v.bundle)
		if uncached_bundles ~= nil then
			for v2 in pairs(uncached_bundles) do
				if not dic[v2] then
					dic[v2] = true
					table.insert(download_list, {quality = v.quality, bundle = v2, in_scene_id = v.in_scene_id, accept_task = v.accept_task, over_level = v.over_level})
				end
			end
		end
	end

	return download_list
end
