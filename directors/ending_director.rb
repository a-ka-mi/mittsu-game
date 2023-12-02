require_relative 'base'

module Directors
	# エンディング画面用ディレクター
	class EndingDirector < Base
		# 初期化
		def initialize(screen_width:, screen_height:, renderer:, point:)
			super

			self.point = point

			@point = []

			# テキスト表示用パネルを生成し、カメラから程よい距離に配置する
			draw_score
		end

		# 1フレーム分の進行処理
		def play
			# テキスト表示用パネルを1フレーム分アニメーションさせる
			@description.play
		end

		# キー押下（単発）時のハンドリング
		def on_key_pressed(glfw_key:)
			case glfw_key
				# ESCキー押下で終了する
				when GLFW_KEY_ESCAPE
					puts "クリア!!"
					transition_to_next_director # self.next_directorがセットされていないのでメインループが終わる
			end
		end

		def draw_score
			@description = Panel.new(width: 0.25, height: 0.25,  map: TextureFactory.create_score_description)
			@description.mesh.position.x = -0.3
      		@description.mesh.position.y = 0
      		@description.mesh.position.z = -0.5
			self.scene.add(@description.mesh)
			@point.each do |num|
				string_num = Panel.new(width: 0.25, height: 0.25,  map: TextureFactory.create_number_description(num.to_i))
				self.scene.add(@description.mesh)
			end

		end

		def count_digit
			count = self.point.to_s.length
			count.times{|n|
				@point << (self.point/10.pow(n))%10
			}
		end
	end
end