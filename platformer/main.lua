levels = {
    {
        offset = 0,
        width = 96,
        height = 16,
		camera_mode = 1,
		music = 38,
    },
}
level_index = 1
level = levels[level_index]

function restart_level()
    camera_x = 0
    camera_y = 0
    sfx_timer = 0
    death_count = 0
	have_grapple = level_index > 0
    objects = {}

    for i = 0,level.width-1 do
        for j = 0,level.height-1 do
            if fget(tile_at(i, j), 0) then
                local t = types[tile_at(i, j)]
                if t then
                    create(t, i * 8, j * 8)
                    -- If that tile was just a spawn point
                    -- for an object, remove it
                    -- mset(i, j, 0)
                end
            end
        end
    end
end

function _init()
    restart_level()
end

function _update()
	update_input()

    for o in all(objects) do
        if o.freeze > 0 then
            o.freeze -= 1
        else
            o:update()
        end

        if o.destroyed then
            del(objects, o)
        end
    end
end

function _draw()
    cls()

    -- draw tileset
    for x = 0,127 do
        for y = 0,63 do
            local tile = tile_at(x, y)
            if fget(tile, 1) then spr(tile, x * 8, y * 8) end
        end
    end

	local p = nil
	for o in all(objects) do
		if o.base == player then p = o else o:draw() end
	end
	if p then p:draw() end
end

-- utils --
function approach(x, target, max_delta)
	return x < target and min(x + max_delta, target) or max(x - max_delta, target)
end

function psfx(id, off, len, lock)
	if sfx_timer <= 0 or lock then
		sfx(id, 3, off, len)
		if lock then sfx_timer = lock end
	end
end

function draw_sine_h(x0, x1, y, col, amplitude, time_freq, x_freq, fade_x_dist)
	pset(x0, y, col)
	pset(x1, y, col)

	local x_sign = sgn(x1 - x0)
	local x_max = abs(x1 - x0) - 1
	local last_y = y
	local this_y = 0
	local ax = 0
	local ay = 0
	local fade = 1

	for i = 1, x_max do
		
		if i <= fade_x_dist then
			fade = i / (fade_x_dist + 1)
		elseif i > x_max - fade_x_dist + 1 then
			fade = (x_max + 1 - i) / (fade_x_dist + 1)
		else
			fade = 1
		end

		ax = x0 + i * x_sign
		ay = y + sin(time() * time_freq + i * x_freq) * amplitude * fade
		pset(ax, ay + 1, 1)
		pset(ax, ay, col)

		this_y = ay
		while abs(ay - last_y) > 1 do
			ay -= sgn(this_y - last_y)
			pset(ax - x_sign, ay + 1, 1)
			pset(ax - x_sign, ay, col)
		end
		last_y = this_y
	end
end
