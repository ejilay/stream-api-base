package main

import (
	"github.com/labstack/echo"

	streamHandler "handlers/v1/streams"
)

func main() {
	router := echo.New()

	v1 := router.Group("/api/v1")

	streams := v1.Group("streams")

	streams.GET("/", streamHandler.Index)

	streams.GET("/:id", streamHandler.Show)

	streams.POST("/", streamHandler.Create)

	streams.PATCH("/:id", streamHandler.Update)
}
