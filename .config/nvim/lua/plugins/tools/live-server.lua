return {
  "barrett-ruth/live-server.nvim",
  event = "BufReadPre *.html",
  build = "pnpm i -g live-server",
  config = true,
}
