defmodule ElixirServerWeb.PostView do
  use ElixirServerWeb, :view

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, ElixirServerWeb.PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, ElixirServerWeb.PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      name: post.name,
      email: post.email
    }
  end
end
