components {
  id: "ball"
  component: "/scripts/ball.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"ball-1\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/atlases/sprites.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.9
  }
}
