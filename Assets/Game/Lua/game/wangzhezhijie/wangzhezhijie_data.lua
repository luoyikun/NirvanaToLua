 WangZheZhiJieData = WangZheZhiJieData or BaseClass()

function WangZheZhiJieData:__init()
	if WangZheZhiJieData.Instance then
		print_error("[WangZheZhiJieData] Attempt to create singleton twice!")
		return
	end
	WangZheZhiJieData.Instance = self

	self.kuafu_1v1_cfg = ConfigManager.Instance:GetAutoConfig("cross_1v1_auto")

 end

 function WangZheZhiJieData:__delete()
	WangZheZhiJieData.Instance = nil
 end

 function WangZheZhiJieData:GetRingShowByIndex(index)
 	for k,v in pairs(self.kuafu_1v1_cfg.xndex) do
 		if v.seq == index then
 			return v.img_pic
 		end
 	end
 end

 function WangZheZhiJieData:GetRingShowCount()
 	return #self.kuafu_1v1_cfg.xndex
 end

function WangZheZhiJieData:GetSeasonRingItemCfg(season,grade)
	local cfg = self.kuafu_1v1_cfg.season_ring
	for k,v in pairs(cfg) do
		if v.season == season and v.grade == grade then
			return v
		end
	end
end

function WangZheZhiJieData:GetSeasonShowCfg(season)
	local cfg = self.kuafu_1v1_cfg.season_ring
	for k,v in pairs(cfg) do
		if v.season_show == season then
			return v
		end
	end
end

function WangZheZhiJieData:GetSeasonRingItemAttr(season, grade)
	local cfg = self:GetSeasonRingItemCfg(season, grade)
	local attr = CommonDataManager.GetAttributteByClass(cfg)

	local data = {}
	if attr.max_hp and attr.max_hp > 0 then
		table.insert(data, {name = "max_hp",value = attr.max_hp})
	end
	if attr.gong_ji and attr.gong_ji > 0 then
		table.insert(data, {name = "gong_ji",value = attr.gong_ji})
	end
	if attr.fang_yu and attr.fang_yu > 0 then
		table.insert(data, {name = "fang_yu",value = attr.fang_yu})
	end
	if attr.pvp_zengshang and attr.pvp_zengshang > 0 then
		table.insert(data, {name = "pvp_zengshang",value = attr.pvp_zengshang / 100 .. "%"})
	end
	if attr.pvp_jianshang and attr.pvp_jianshang > 0 then
		table.insert(data, {name = "pvp_jianshang",value = attr.pvp_jianshang / 100 .. "%"})
	end
	return data

end

--使用了那个赛季的戒指
function WangZheZhiJieData:GetUseRingData()
	return KuaFu1v1Data.Instance:GetUseRingData()
end

function WangZheZhiJieData:GetCurSeason()
	return KuaFu1v1Data.Instance:GetCurSeason()
end

function WangZheZhiJieData:GetHaveRingData()
	return KuaFu1v1Data.Instance:GetHaveRingData()
end

--根据赛季获取戒指  获取戒指的段位 0表示空
function WangZheZhiJieData:GetRingIsHaveGrande(season)
	local data = self:GetHaveRingData()
	return data[season]
end

function WangZheZhiJieData:GetUseRingBySeason(season)
	local data = self:GetUseRingData()
	for k,v in pairs(data) do
		if v == season then
			return true
		end
	end
	return false
end