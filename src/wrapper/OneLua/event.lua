function love.event.quit(mode)
    love.quit()

    if mode == "restart" then
        ---@diagnostic disable-next-line: undefined-field
        os.restart()
    else
        wrapper.run = false
        os.exit()
    end
end
