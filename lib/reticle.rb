require 'mittsu'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

scene = Mittsu::Scene.new
camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)

renderer = Mittsu::OpenGLRenderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: '01 Scene Example'

class TextureFactory
  # 任意のテクスチャマップの生成
  def self.create_texture_map(filename)
    @@maps ||= {}
    @@maps[filename] ||= Mittsu::ImageUtils.load_texture("./images/#{filename}")
    @@maps[filename]
  end
end

geometry = Mittsu::BoxGeometry.new(1.0, 1.0, 1.0)
  texture = Mittsu::ImageUtils.load_texture('./images/reticle_b.png')
  material = Mittsu::MeshBasicMaterial.new(map: texture)
  earth = Mittsu::Mesh.new(geometry, material)
  scene.add(earth)
  camera.position.z = 5.0

renderer.window.on_resize do |width, height|
  renderer.set_viewport(0, 0, width, height)
  camera.aspect = width.to_f / height.to_f
  camera.update_projection_matrix
end

renderer.window.run do

  renderer.render(scene, camera)
  # break
end
