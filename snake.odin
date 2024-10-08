package snake
import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
TICK_RATE :: 0.1
Vec2 :: [2]int
MAX_LEN :: GRID_WIDTH * GRID_WIDTH

tick_timer: f32 = TICK_RATE
move_direction: Vec2
snake: [MAX_LEN]Vec2
snake_len: int
game_over: bool
food_pos: Vec2

init_snake :: proc(start_head_pos: Vec2) {
    snake[0] = start_head_pos
    snake[1] = start_head_pos - {1, 0}
    snake[2] = start_head_pos - {2, 0}
    snake_len = 3
    move_direction = {1, 0}
    game_over = false
}

get_direction :: proc() {
    // Update direction vector
    if rl.IsKeyDown(.UP) || rl.IsKeyDown(.KP_8) || rl.IsKeyDown(.W) do move_direction = {0, -1}
    else if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.KP_5) || rl.IsKeyDown(.A) do move_direction = {0, 1}
    else if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.KP_4) || rl.IsKeyDown(.S) do move_direction = {-1, 0}
    else if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.KP_6) || rl.IsKeyDown(.D) do move_direction = {1, 0}
}

move_snake :: proc() {
    // Get new direction vector
    get_direction()
    if tick_timer <= 0 {
        // Update snake head
        next_part_pos := snake[0]
        snake[0] += move_direction
        head_pos := snake[0]

        // Game over if snake out of bounds
        if head_pos.x < 0 || head_pos.y < 0 || head_pos.x >= GRID_WIDTH || head_pos.y >= GRID_WIDTH {
            game_over = true
        }

        // Update snake body parts
        for i in 1..<snake_len {
            curr_pos := snake[i]
            if curr_pos == head_pos do game_over = true
            snake[i] = next_part_pos
            next_part_pos = curr_pos
        }

        if head_pos == food_pos {
            snake_len += 1
            snake[snake_len - 1] = next_part_pos
            place_food()
        }

        tick_timer += TICK_RATE
    }
}

place_food :: proc() {
    // Get the position of cells ocuppied by the snake
    occupied: [GRID_WIDTH][GRID_WIDTH]bool
    for i in 0..<snake_len {
        occupied[snake[i].x][snake[i].y] = true
    }

    // Create a dynamic array of the cells that are not occupied
    free_cells := make([dynamic]Vec2, context.temp_allocator)
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if !occupied[x][y] do append(&free_cells, Vec2{x, y})
        }
    }

    // Randomly assign a food position to an available cell
    if len(free_cells) > 0 {
        random_cell_idx := rl.GetRandomValue(0, i32(len(free_cells) - 1))
        food_pos = free_cells[random_cell_idx]
    }
}

main :: proc() {
    // Enable vsync
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake Game")

    // Initialize snake object
    start_head_pos := Vec2{GRID_WIDTH / 2, GRID_WIDTH / 2}
    init_snake(start_head_pos)
    place_food()

    for !rl.WindowShouldClose() {
        // Create the background and add zoom
        rl.BeginDrawing()
        rl.ClearBackground({102, 49, 101, 255})

        camera := rl.Camera2D {
            zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
        }
        rl.BeginMode2D(camera)
        
        // Crash on game over, update timer otherwise
        if game_over {
            if rl.IsKeyPressed(.ENTER) {
                init_snake(Vec2{GRID_WIDTH / 2, GRID_WIDTH / 2})
                game_over = false
                place_food()
            }
        }
        else do tick_timer -= rl.GetFrameTime()
        
        food_rect := rl.Rectangle {
            f32(food_pos.x) * CELL_SIZE,
            f32(food_pos.y) * CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE
        }

        rl.DrawRectangleRec(food_rect, rl.RED)

        for i in 0..<snake_len {
            // Draw the snake body
            head_rect := rl.Rectangle {
                f32(snake[i].x) * CELL_SIZE,
                f32(snake[i].y) * CELL_SIZE,
                CELL_SIZE,
                CELL_SIZE
            }

            rl.DrawRectangleRec(head_rect, rl.WHITE)
        } 
        
        move_snake()

        if game_over {
            rl.DrawText("GAME OVER :(", 80, 4, 24, rl.GREEN)
            rl.DrawText("Press ENTER to play again!", 80, 30, 12, rl.BLACK)
        }
        rl.EndMode2D()
        rl.EndDrawing()

        // Free all temporary memory
        free_all(context.temp_allocator)
    }

    rl.CloseWindow()
}