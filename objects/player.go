components {
  id: "player"
  component: "/scripts/player.script"
}
components {
  id: "skins"
  component: "/scripts/skins.script"
}
embedded_components {
  id: "base"
  type: "sprite"
  data: "default_animation: \"stand-idle\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/resource/atlases/player-bluepants.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.1
  }
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_KINEMATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"player\"\n"
  "mask: \"ground\"\n"
  "mask: \"spring\"\n"
  "mask: \"question_block\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: -0.335973\n"
  "      y: -2.553393\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "    id: \"box\"\n"
  "  }\n"
  "  data: 9.289027\n"
  "  data: 22.543476\n"
  "  data: 10.0\n"
  "}\n"
  ""
}
embedded_components {
  id: "body"
  type: "sprite"
  data: "default_animation: \"stand-idle\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/resource/atlases/default.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.2
  }
}
embedded_components {
  id: "head"
  type: "sprite"
  data: "default_animation: \"stand-idle\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/resource/atlases/default.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.2
  }
}
embedded_components {
  id: "accessory"
  type: "sprite"
  data: "default_animation: \"stand-idle\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 46.0\n"
  "  y: 54.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/resource/atlases/default.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.3
  }
}
embedded_components {
  id: "projectile_factory"
  type: "factory"
  data: "prototype: \"/objects/projectile.go\"\n"
  ""
}
