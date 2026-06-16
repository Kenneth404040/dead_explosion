-- Registro de la entidad invisible que aplica la fuerza de empuje
minetest.register_entity("dead_explosion:push_object", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        pointable = false,
        visual = "sprite",
        textures = {"invisible.png"},
        visual_size = {x=0, y=0},
        static_save = false,
    },
})

-- Función que se llama cuando un jugador muere
minetest.register_on_dieplayer(function(player)
    local pos = player:get_pos()
    pos.y = pos.y + 1 -- Asegurarse de que la explosion no esté directamente en el suelo

    -- Funcion para generar una capa de partículas
    local function generate_particles(radius)
        for angle = 0, 360, 5 do
            local rad = math.rad(angle)
            local particle_pos = {
                x = pos.x + math.cos(rad) * radius,
                y = pos.y,
                z = pos.z + math.sin(rad) * radius
            }
            minetest.add_particle({
                pos = particle_pos,
                velocity = {x = math.cos(rad) * 3, y = 1, z = math.sin(rad) * 3},
                acceleration = {x = 0, y = 2, z = 0},
                expirationtime = 2,
                size = 5,
                collisiondetection = false,
                vertical = false,
                texture = "explosion_custom.png",
            })
        end
    end

    -- Genera la primera capa de partículas inmediatamente
    generate_particles(2)

    -- Programa la generación de la segunda y tercera capa con retraso
    minetest.after(0.2, generate_particles, 3) -- Segunda capa después de 0.2 segundos
    minetest.after(0.4, generate_particles, 4) -- Tercera capa después de 0.4 segundos

    -- Reproduce el sonido de la explosión
    minetest.sound_play("explosion_custom", {
        pos = pos,
        gain = 1.0,
        max_hear_distance = 128,
        ephemeral = false
    })

    -- Encuentra todos los objetos dentro de un radio específico
    local objects = minetest.get_objects_inside_radius(pos, 5)
    for _, obj in ipairs(objects) do
        -- Aplica la fuerza tanto a jugadores como a ítems
        if obj:is_player() or (obj:get_luaentity() and obj:get_luaentity().name == "__builtin:item") then
            local obj_pos = obj:get_pos()
            local dir = vector.direction(obj_pos, pos)
            local force = vector.multiply(dir, -10) -- Ajusta la magnitud del empuje según sea necesario
            obj:set_velocity(force)
        end
    end
end)
