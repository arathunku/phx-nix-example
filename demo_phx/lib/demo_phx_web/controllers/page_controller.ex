defmodule DemoPhxWeb.PageController do
  use DemoPhxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
