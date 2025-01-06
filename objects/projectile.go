components {
  id: "projectile"
  component: "/scripts/projectile.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"default\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/atlases/sprites.atlas\"\n"
  "}\n"
  ""
  position {
    z: 2.0
  }
}
