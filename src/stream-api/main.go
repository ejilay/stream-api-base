package main

import (
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"

	streamHandler "handlers/v1/streams"
)

func main() {
	router := echo.New()
	router.Pre(middleware.RemoveTrailingSlash())

	v1 := router.Group("api/v1")

	streams := v1.Group("streams")

	streams.GET("/", streamHandler.Index)

	streams.GET("/:id", streamHandler.Show)

	streams.POST("/", streamHandler.Create)

	streams.PATCH("/:id", streamHandler.Update)

	router.Logger.Fatal(router.Start("0.0.0.0:1323"))
}
