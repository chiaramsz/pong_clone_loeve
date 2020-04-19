WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()
MAX_SCORE = 6
STATE = ''
BALL_SIZE = 5

PADDLE_SPEED = 400
PADDLE_WIDTH = 15
PADDLE_HIGHT = 80

function love.load()
    serveBall()

    paddleL_x = 0
    paddleL_y = HEIGHT / 2 - PADDLE_HIGHT
    paddleR_x = WIDTH - paddleL_x - PADDLE_WIDTH
    paddleR_y = HEIGHT/ 2 - PADDLE_HIGHT

    STATE = 'startScreen'
    gameOverMsg = ''

    font = love.graphics.newFont('font.ttf', 50)
    love.graphics.setFont(font)
    love.window.setTitle('Pong by Chiara Szolderits')

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
	}
end

function love.update(dt)
    if STATE == 'play' then
        play(dt)
    end
end

function love.draw()
    red = 139/255
    green = 0/255
    blue = 139/255
	love.graphics.setBackgroundColor(red, green, blue)

    -- startscreen --
    if STATE == 'startScreen' then
        love.graphics.print('Welcome to Pong!\nPress Space to Start!\nPress Escape to quit\n\nPlayer with 6 points wins!', 3, 3)
	    Score_PlayerL = 0
        Score_PlayerR = 0
    
    -- ready --
	elseif STATE == 'ready' then
        love.graphics.print('Press space to serve \n\nPlayer with 6 points wins! \n\n       up      down\nleft     w      s\nright  up      down', 3, 3)
    
    -- play --   
    elseif STATE == 'play' then
        red = 216/255
        green = 191/255
        blue = 216/255
        love.graphics.setColor(red, blue, green)
        drawGraphics()

    -- game over --    
    elseif STATE == 'gameOver' then
        love.graphics.print(gameOverMsg, 10, 10)
    end
end

-- move between states --
function love.keypressed(key)
    if key == 'space' then
		if STATE == 'startScreen' then
			STATE = 'ready'
        elseif STATE == 'ready' then
            STATE = 'play'
        elseif STATE == 'gameOver' then
            STATE = 'startScreen'
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
end

function serveBall()
    ball_x = WIDTH / 2
    ball_y = HEIGHT / 2
	
	ballSpeed = 650
	ballDirection = math.rad(math.random(100, 395))
	
	ballSpeedX = math.cos(ballDirection) * ballSpeed *-1
	ballSpeedY = math.sin(ballDirection) * ballSpeed
end

-- play the game --
function play(dt)
    ball_x = ball_x + ballSpeedX * dt
    ball_y = ball_y + ballSpeedY * dt

	-- give the point, when paddle doesnt hit the ball (left & right)
    if ball_x + BALL_SIZE < 0 then
        serveBall()
        Score_PlayerR = Score_PlayerR + 1
        sounds['score']:play()
        if Score_PlayerR == MAX_SCORE
    then
            STATE = 'gameOver'
            gameOverMsg = 'Right Player wins!\nPress space to play again'
        else
            STATE = 'ready'
        end
    end

    if ball_x > WIDTH then
        serveBall()
        Score_PlayerL = Score_PlayerL + 1
        sounds['score']:play()
        if Score_PlayerL == MAX_SCORE then
            STATE = 'gameOver'
            gameOverMsg = 'Left Player wins!\nPress space to play again'
        else
            STATE = 'ready'
        end
    end
	
	-- check walls up and down
    if ball_y < 0 then
        ball_y = 0
        ballSpeedY = -ballSpeedY
        sounds['wall_hit']:play()
    end

    if ball_y > HEIGHT then
        ball_y = HEIGHT
        ballSpeedY = -ballSpeedY
        sounds['wall_hit']:play()
    end

	-- move paddle
    if love.keyboard.isDown('w') then
        paddleL_y = paddleL_y - PADDLE_SPEED * dt
	elseif love.keyboard.isDown('s') then
        paddleL_y = paddleL_y + PADDLE_SPEED * dt
	elseif love.keyboard.isDown('up') then
        paddleR_y = paddleR_y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('down') then
        paddleR_y = paddleR_y + PADDLE_SPEED * dt
    end

    paddleL_y = paddlePos(paddleL_y, 0, HEIGHT - PADDLE_HIGHT)
    paddleR_y = paddlePos(paddleR_y, 0, WIDTH - PADDLE_HIGHT)

    checkCollision()
end

function drawGraphics()
    love.graphics.circle('fill', ball_x, ball_y, BALL_SIZE)

    love.graphics.rectangle('fill', paddleL_x, paddleL_y, PADDLE_WIDTH, PADDLE_HIGHT)
    love.graphics.rectangle('fill', paddleR_x, paddleR_y, PADDLE_WIDTH, PADDLE_HIGHT)

    love.graphics.print(Score_PlayerL, 75, 10)
    love.graphics.print(Score_PlayerR, love.graphics.getWidth() - 150, 10)
end

function paddlePos(val, min, max)
    if val < min then
        val = min
    elseif max < val then
    end
    return val
end

function checkCollision()
    if  ball_x < paddleL_x + PADDLE_WIDTH and
        ball_x + BALL_SIZE > paddleL_x and
        ball_y < paddleL_y + PADDLE_HIGHT and
        ball_y + BALL_SIZE > paddleL_y
    then
        ball_x = paddleL_x + PADDLE_WIDTH
        ballSpeedX = -ballSpeedX
        sounds['paddle_hit']:play()
    end

    if  ball_x < paddleR_x + PADDLE_WIDTH and
        ball_x + BALL_SIZE > paddleR_x and
        ball_y < paddleR_y + PADDLE_HIGHT and
        ball_y + BALL_SIZE > paddleR_y
    then
        ball_x = paddleR_x - BALL_SIZE
        ballSpeedX = -ballSpeedX
        sounds['paddle_hit']:play()
    end
end



	
