package streams

import (
	"github.com/labstack/echo"
	"net/http"
)

func Show(c echo.Context) error {
	return c.String(http.StatusOK, "Hello, World!")
}
