GaoZhanData = GaoZhanData or BaseClass(BaseEvent)

function GaoZhanData:__init()
	if GaoZhanData.Instance then
		print_error("[GaoZhanData] Attempt to create singleton twice!")
		return
	end
	GaoZhanData.Instance = self
	self.quality_first = true
end

function GaoZhanData:__delete()
	GaoZhanData.Instance = nil
end