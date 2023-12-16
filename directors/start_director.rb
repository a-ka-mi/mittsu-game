require_relative 'base'

module Directors
  # タイトル画面用ディレクター
  class StartDirector < Base
    # 初期化
    def initialize(screen_width:, screen_height:, renderer:)
      super
      # タイトル画面の登場オブジェクト群を生成
      create_objects
    end

    # １フレーム分の進行処理
    def play
      
    end

    # キー押下（単発）時のハンドリング
    def on_key_pressed(glfw_key:)
        super
        case glfw_key
            # SPACEキー押下で弾丸を発射
            when GLFW_KEY_SPACE
                self.next_director = GameDirector.new(screen_width: screen_width, screen_height: screen_height, renderer: renderer)
                transition_to_next_director
        end
    end

    private

    # タイトル画面の登場オブジェクト群を生成
    def create_objects
      # 太陽光をセット
		  @sun = LightFactory.create_sun_light
      self.scene.add(@sun)
      # 床生成
		  @wall = MeshFactory.create_base
		  @wall.position.y = -0.9
		  @wall.position.z = -0.8
      self.scene.add(@wall)
      # タイトル
      @description = Panel.new(width: 0.25, height: 0.25,  map: TextureFactory.create_score_description)
      @description.mesh.position.x = -0.3
      @description.mesh.position.y = 0
      @description.mesh.position.z = -0.5
      self.scene.add(@description.mesh)
    end

    # タイトルロゴ用アニメーションパネル作成
    # タイトル画面の表示開始から30+delay_framesのフレームが経過してから、120フレーム掛けてアニメーションするよう設定
    def create_title_logo(char, x_pos, delay_frames)
      panel = AnimatedPanel.new(start_frame: 30 + delay_frames, duration: 120, map: TextureFactory.create_string(char))
      panel.mesh.position.x = x_pos
      panel.mesh.position.z = -0.5
      self.scene.add(panel.mesh)
      @panels ||= []
      @panels << panel
    end
  end
end