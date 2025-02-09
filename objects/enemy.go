components {
  id: "skins"
  component: "/scripts/skins.script"
}
components {
  id: "enemy"
  component: "/scripts/enemy.script"
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
    z: 0.13
  }
}
embedded_components {
  id: "base"
  type: "sprite"
  data: "default_animation: \"stand-idle\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 46.0\n"
  "  y: 54.0\n"
  "}\n"
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
  id: "body"
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
    z: 0.12
  }
}
embedded_components {
  id: "head"
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
    z: 0.12
  }
}
embedded_components {
  id: "projectile_factory"
  type: "factory"
  data: "prototype: \"/objects/projectile.go\"\n"
  ""
}
