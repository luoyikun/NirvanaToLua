-- 根据形象资源ID来展示UI中某些比较特殊的形象需要单独调position和rotation的
-- 注意！！！只能调小部分几个，不要依赖这个文件来调所有形象，否则你们活哥叼你们就准备受死吧。
return {
	["mount"] = {
		[7031001] = {position = Vector3(0, 0, 0), rotation = Quaternion.Euler(0, -60, 0)},
		[7013001] = {position = Vector3(0, -1.1, 0), rotation = Quaternion.Euler(0, -60, 0)},
	},
	["mount_huanhua"] = {
		[7095001] = {position = Vector3(-1.3, 0, 0), rotation = Quaternion.Euler(0, -60, 0)},
		[7064001] = {position = Vector3(1.5, 0, 0), rotation = Quaternion.Euler(0, -40, 0)},
		[7310001] = {position = Vector3(0, 0, 0), rotation = Quaternion.Euler(0, -60, -10)},
		[7025001] = {position = Vector3(0, 0, 0), rotation = Quaternion.Euler(0, -60, -13)},
		[7336001] = {position = Vector3(0.5, 0, -0.6), rotation = Quaternion.Euler(0, -60, 0)},
		[7045001] = {position = Vector3(0.8, 0.6, -0.3), rotation = Quaternion.Euler(0, -60, -12)},
		[7329001] = {position = Vector3(1, 0, -0.6), rotation = Quaternion.Euler(0, -60, 0)},
		[7053001] = {position = Vector3(0, -1.7, -5), rotation = Quaternion.Euler(0, -60, 0)},
		[7322001] = {position = Vector3(0.58, -2.24, -7.75), rotation = Quaternion.Euler(0, -60, 0)},
		[7322002] = {position = Vector3(0.58, -2.24, -7.75), rotation = Quaternion.Euler(0, -60, 0)},
		[7035001] = {position = Vector3(-0.3, 0, -6), rotation = Quaternion.Euler(0, 130, 0)},
		[7340001] = {position = Vector3(0.8, 0, 0), rotation = Quaternion.Euler(0, -60, 0)},
		[7333001] = {position = Vector3(0.9, 0, 0), rotation = Quaternion.Euler(0, -60, 0)},
	},
	["appearance_mount_weiyan"] = {
		[7053001] = {position = Vector3(-2, -1.9, -6), rotation = Quaternion.Euler(0, 140, 0)},
		[7057001] = {position = Vector3(-1.8, 0, 1.4), rotation = Quaternion.Euler(0, 130, 0)},
		[7064001] = {position = Vector3(-2, 0, 0.5), rotation = Quaternion.Euler(0, 120, 0)},
		[7322001] = {position = Vector3(-0.3, -3, -12), rotation = Quaternion.Euler(0, 130, 0)},
		[7086001] = {position = Vector3(-1.3, 0, 0), rotation = Quaternion.Euler(0, 140, 0)},
		[7029001] = {position = Vector3(-1.6, 0, 0.5), rotation = Quaternion.Euler(0, 130, 0)},
		[7033001] = {position = Vector3(-1.5, 0, 0.5), rotation = Quaternion.Euler(0, 130, 0)},
		[7045001] = {position = Vector3(-2, 0, 0), rotation = Quaternion.Euler(0, 120, 0)},
		[7329001] = {position = Vector3(-1.5, 0, 0.8), rotation = Quaternion.Euler(0, 130, 0)},
		[7332001] = {position = Vector3(-1.3, 0, 0), rotation = Quaternion.Euler(0, 140, 0)},
		[7333001] = {position = Vector3(-1.6, 0, 2), rotation = Quaternion.Euler(0, 140, 0)},
		[7336001] = {position = Vector3(-1.4, 0, 0.5), rotation = Quaternion.Euler(0, 140, 0)},
		[7131001] = {position = Vector3(-1.8, 0, 1), rotation = Quaternion.Euler(0, 130, 0)},
		[7322002] = {position = Vector3(-0.3, -3, -12), rotation = Quaternion.Euler(0, 130, 0)},
		[7035001] = {position = Vector3(-0.3, 0, -6), rotation = Quaternion.Euler(0, 130, 0)},
	},
	
	["discount_mount"] = {
		-- [7010001] = {position = Vector3(2, 2, 4), rotation = Quaternion.Euler(5, -60, 0)},
	},
	["discount_wing"] = {
		-- [8069001] = {position = Vector3(0, 0, 8), rotation = Quaternion.Euler(0, -60, 0)},
	},
	["discount_mingjiang"] = {
		[10007] = {position = Vector3(-0.4, 0.3, 4), rotation = Quaternion.Euler(0, -30, 0)},
		[10008] = {position = Vector3(-1, -1.2, 1), rotation = Quaternion.Euler(0, -30, 0)},
		[10006] = {position = Vector3(0, 0, 3), rotation = Quaternion.Euler(0, -30, 0)},
		[10005] = {position = Vector3(-0.5, 0, 4), rotation = Quaternion.Euler(0, 0, 0)},
	},
	["discount_spirit"] = {
		[10014001] = {position = Vector3(0, 0.3, 2.2), rotation = Quaternion.Euler(0, 0, 0)},
		[11001001] = {position = Vector3(0, -0.2, -0.5), rotation = Quaternion.Euler(0, 0, 0)},
		[10062001] = {position = Vector3(0.02, 0.3, 1.53), rotation = Quaternion.Euler(0, -35.76, 0)},
	},
	["discount_baoju"] = {
		[13002] = {position = Vector3(0, -0.06, 0.52), rotation = Quaternion.Euler(0, 0, 0)},
	},
	["discount_pet"] = {
		[1014001] = {position = Vector3(0, 0.1, 1.39), rotation = Quaternion.Euler(0, 0, 0)},
	},
}
