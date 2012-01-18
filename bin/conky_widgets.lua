require 'cairo'
-- options: name, arg, max, bg_colour, bg_alpha, fg_colour, fg_alpha, xc, yc, radius, thickness, start_angle, end_angle
function ring(cr, name, arg, max, bgc, bga, fgc, fga, xc, yc, r, t, sa, ea)
	local function rgb_to_r_g_b(colour,alpha)
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
	end
	
	local function draw_ring(pct)
		local angle_0=sa*(2*math.pi/360)-math.pi/2
		local angle_f=ea*(2*math.pi/360)-math.pi/2
		local pct_arc=pct*(angle_f-angle_0)

		-- Draw background ring

		cairo_arc(cr,xc,yc,r,angle_0,angle_f)
		cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
		cairo_set_line_width(cr,t)
		cairo_stroke(cr)
	
		-- Draw indicator ring

		cairo_arc(cr,xc,yc,r,angle_0,angle_0+pct_arc)
		cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
		cairo_stroke(cr)
	end
	
	local function setup_ring()
		local str = ''
		local value = 0
		
		str = string.format('${%s %s}', name, arg)
		str = conky_parse(str)
		
		value = tonumber(str)
		if value == nil then value = 0 end
		pct = value/max
		
		draw_ring(pct)
	end	
	
	local updates=conky_parse('${updates}')
	update_num=tonumber(updates)
	
	if update_num>5 then setup_ring() end
end
function conky_widgets()
	if conky_window == nil then return end
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	cr = cairo_create(cs)
	ring(cr, 'cpu', 'CPU0', 100, 0xFFFFFF, 0.2, 0xFFFFFF, 0.8, 100, 100, 90, 10, 90, 450) 
	cairo_destroy(cr)

	cr = cairo_create(cs)
	ring(cr, 'memperc', 'memperc', 100, 0xFFFFFF, 0.0, 0xFFFFFF, 0.8, 100, 100, 70, 20, 90, 450)
	cairo_destroy(cr)	

	cr = cairo_create(cs)
	ring(cr, 'fs_used_perc', '/', 100, 0xFFFFFF, 0.6, 0xFFFFFF, 0.8, 100, 100, 50, 10, 90, 450)
	cairo_destroy(cr)	

	cr = cairo_create(cs)
	ring(cr, 'fs_used_perc', '/home', 100, 0xFFFFFF, 0.4, 0xFFFFFF, 0.8, 100, 100, 30, 15, 90, 450)
	cairo_destroy(cr)	
end
