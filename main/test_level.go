components {
  id: "test"
  component: "/assets/tilemaps/test.tilemap"
}
components {
  id: "level"
  component: "/scripts/level.script"
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "collision_shape: \"/assets/tilemaps/test.tilemap\"\n"
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
  data: "prototype: \"/player/enemy.go\"\n"
  ""
}
