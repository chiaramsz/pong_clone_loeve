WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

function love.load()
    newGame()
    ballsize = 5

	-- dimensions from paddles
    paddleWidth = 15
    paddleHeight = 80
    paddle1X = 0
    paddle1Y = HEIGHT / 2 - paddleHeight
    paddle2X = WIDTH - paddle1X - paddleWidth
    paddle2Y = HEIGHT/ 2 - paddleHeight
    paddleSpeed = 400

    maxScore = 6

    currentState = 'startScreen'
    gameOverMessage = ''

	--love.graphics.setBackgroundColor(255, 240, 245)
	--love.graphics.setColor(176, 048, 096, 1)
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
    if currentState == 'play' then
        play(dt)
    end
end

function love.draw()
	love.graphics.setColor(176, 048, 096)
	if currentState == 'startScreen' then
		startScreen()
	    player1Score = 0
	    player2Score = 0
	elseif currentState == 'ready' then
        ready()
    elseif currentState == 'play' then
        drawGraphics()
    elseif currentState == 'gameOver' then
        gameOver()
    end
end

function love.keypressed(key)
    if key == 'space' then
		if currentState == 'startScreen' then
			currentState = 'ready'
		elseif currentState == 'ready' then
            currentState = 'play'
        elseif currentState == 'gameOver' then
            currentState = 'startScreen'
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
end

function newGame()
    ballX = WIDTH / 2
    ballY = HEIGHT / 2
	
	ballSpeed = 650
	ballDirection = math.rad(math.random(200, 395))
	
	ballSpeedX = math.cos(ballDirection) * ballSpeed *-1
	ballSpeedY = math.sin(ballDirection) * ballSpeed
end

function play(dt)
    ballX = ballX + ballSpeedX * dt
    ballY = ballY + ballSpeedY * dt

	-- give the point, when paddle doesnt hit the ball (left & right)
    if ballX + ballsize < 0 then
        newGame()
        player2Score = player2Score + 1
        sounds['score']:play()
        if player2Score == maxScore then
            currentState = 'gameOver'
            gameOverMessage = 'Right Player wins!\nPress space to play again'
        else
            currentState = 'ready'
        end
    end

    if ballX > WIDTH then
        newGame()
        player1Score = player1Score + 1
        sounds['score']:play()
        if player1Score == maxScore then
            currentState = 'gameOver'
            gameOverMessage = 'Left Player wins!\nPress space to play again'
        else
            currentState = 'ready'
        end
    end
	
	-- check walls up and down
    if ballY < 0 then
        ballY = 0
        ballSpeedY = -ballSpeedY
        sounds['wall_hit']:play()
    end

    if ballY > HEIGHT then
        ballY = HEIGHT
        ballSpeedY = -ballSpeedY
        sounds['wall_hit']:play()
    end

	-- move paddle
    if love.keyboard.isDown('w') then
        paddle1Y = paddle1Y - paddleSpeed * dt
	elseif love.keyboard.isDown('s') then
        paddle1Y = paddle1Y + paddleSpeed * dt
	elseif love.keyboard.isDown('up') then
        paddle2Y = paddle2Y - paddleSpeed * dt
    elseif love.keyboard.isDown('down') then
        paddle2Y = paddle2Y + paddleSpeed * dt
    end

    paddle1Y = math.clamp(paddle1Y, 0, love.graphics.getHeight() - paddleHeight)
    paddle2Y = math.clamp(paddle2Y, 0, love.graphics.getHeight() - paddleHeight)

    checkCollision()
end

function drawGraphics()
    love.graphics.circle('fill', ballX, ballY, ballsize)

	love.graphics.setColor(199, 21, 133)
    love.graphics.rectangle('fill', paddle1X, paddle1Y, paddleWidth, paddleHeight)
    love.graphics.rectangle('fill', paddle2X, paddle2Y, paddleWidth, paddleHeight)

    love.graphics.print(player1Score, 75, 10)
    love.graphics.print(player2Score, love.graphics.getWidth() - 150, 10)
end


function startScreen()
	love.graphics.setColor(255,182,193)
	love.graphics.print('Welcome to Pong!\nPress Space to Start!\nPress Escape to quit\n\nPlayer with 6 points wins!', 3, 3)
end

function ready()
    love.graphics.print('Press space to serve \n\nPlayer with 6 points wins! \n\n       up      down\nleft     w      s\nright  up      down', 3, 3)
end

function gameOver()
    love.graphics.print(gameOverMessage, 10, 10)
end

function math.clamp(value, min, max)
    return math.max(math.min(value, max), min)
end

function checkCollision()
    if  ballX < paddle1X + paddleWidth and
        ballX + ballsize > paddle1X and
        ballY < paddle1Y + paddleHeight and
        ballY + ballsize > paddle1Y
    then
        ballX = paddle1X + paddleWidth
        ballSpeedX = -ballSpeedX
        sounds['paddle_hit']:play()
    end

    if  ballX < paddle2X + paddleWidth and
        ballX + ballsize > paddle2X and
        ballY < paddle2Y + paddleHeight and
        ballY + ballsize > paddle2Y
    then
        ballX = paddle2X - ballsize
        ballSpeedX = -ballSpeedX
        sounds['paddle_hit']:play()
    end
end



	
