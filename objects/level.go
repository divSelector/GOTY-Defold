components {
  id: "tilemap"
  component: "/resource/tilemaps/one.tilemap"
}
components {
  id: "level"
  component: "/scripts/level.script"
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "collision_shape: \"/resource/tilemaps/test.tilemap\"\n"
  "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"ground,spring,question_block\"\n"
  "mask: \"player\"\n"
  "mask: \"projectile\"\n"
  "mask: \"enemy\"\n"
  ""
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
