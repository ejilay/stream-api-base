package streams

import (
	"github.com/labstack/echo"
	"net/http"
)

func Create(c echo.Context) error {
	return c.String(http.StatusOK, "Hello, World!")
}
