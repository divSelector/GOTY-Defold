components {
  id: "tilemap"
  component: "/assets/tilemaps/blank.tilemap"
}
components {
  id: "level"
  component: "/scripts/level.script"
}
embedded_components {
  id: "enemy_factory"
  type: "factory"
  data: "prototype: \"/objects/enemy.go\"\n"
  ""
}
embedded_components {
  id: "platform_factory"
  type: "factory"
  data: "prototype: \"/objects/platform.go\"\n"
  ""
}
embedded_components {
  id: "block_factory"
  type: "factory"
  data: "prototype: \"/objects/block.go\"\n"
  ""
}
embedded_components {
  id: "ball_factory"
  type: "factory"
  data: "prototype: \"/objects/ball.go\"\n"
  ""
}
embedded_components {
  id: "checkpoint_factory"
  type: "factory"
  data: "prototype: \"/objects/checkpoint.go\"\n"
  ""
}
