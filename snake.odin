package snake
import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
Vec2 :: [2]int

snake_head_pos: Vec2

main :: proc() {
    // Enable vsync
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake Game")

    snake_head_pos = {GRID_WIDTH / 2, GRID_WIDTH / 2}

    for !rl.WindowShouldClose() {
        // Create the background and add zoom
        rl.BeginDrawing()
        rl.ClearBackground({102, 49, 101, 255})

        camera := rl.Camera2D {
            zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
        }
        rl.BeginMode2D(camera)
        
        // Draw the snake head
        head_rect := rl.Rectangle {
            f32(snake_head_pos.x) * CELL_SIZE,
            f32(snake_head_pos.y) * CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE
        }
        rl.DrawRectangleRec(head_rect, rl.WHITE)
        
        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}