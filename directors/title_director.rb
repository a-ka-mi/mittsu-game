require_relative 'base'

module Directors
  # タイトル画面用ディレクター
  class TitleDirector < Base
    # 初期化
    def initialize(screen_width:, screen_height:, renderer:)
      super
      # タイトル画面の登場オブジェクト群を生成
      create_objects
    end

    # １フレーム分の進行処理
    def play
      # 地球を斜め方向に回転させる
      @earth.rotate_x(0.001)
      @earth.rotate_y(0.001)

      # 説明用文字パネルを１フレーム分進行させる
      @description.play
    end

    # キー押下（単発）時のハンドリング
    def on_key_pressed(glfw_key:)
      super
      case glfw_key
        when GLFW_KEY_SPACE
          self.next_director = StartDirector.new(screen_width: screen_width, screen_height: screen_height, renderer: renderer)
          transition_to_next_director
      end
    end

    private

    # タイトル画面の登場オブジェクト群を生成
    def create_objects
      # 太陽光をセット
      @sun = LightFactory.create_sun_light
      self.scene.add(@sun)

      # 背景用の地球を作成
      @earth = MeshFactory.create_earth
      @earth.position.z = -2
      self.scene.add(@earth)

      # タイトル文字パネルの初期表示位置（X座標）を定義
      start_x = -0.35

      # 説明文字列用のパネル作成
      # タイトル画面表示開始から180フレーム経過で表示するように調整
      # 位置は適当に決め打ち
      @description = Panel.new(width: 1.0, height: 0.75, map: TextureFactory.create_image_description("5000choyen.png"))
      @description.mesh.position.y = -0.2
      @description.mesh.position.z = -0.5
      self.scene.add(@description.mesh)
    end
  end
end