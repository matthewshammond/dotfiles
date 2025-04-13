return {
	black = 0xff181926,
	white = 0x99ffffff,
	red = 0xffbf616a,
	green = 0xffa3be8c,
	blue = 0xff5e81ac,
	yellow = 0xffebcb8b,
	orange = 0xffd08770,
	magenta = 0xffb48ead,
	grey = 0xff4c566a,
	transparent = 0x00000000,
	border = 0x3bD9E0E3,
	border2 = 0x3b000000,

	bar = {
		bg = 0xfa2e3440,
		border = 0xffD9E0E3,
	},
	popup = {
		bg = 0xff3b4252,
		border = 0x3bD9E0E3,
	},
	bg1 = 0xff2e3440,
	bg2 = 0xff3b4252,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
