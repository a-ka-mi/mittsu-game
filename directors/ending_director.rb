require_relative 'base'

module Directors
	# エンディング画面用ディレクター
	class EndingDirector < Base
		# 初期化
		def initialize(screen_width:, screen_height:, renderer:, point:)
			super

			self.point = point
			@point_digit = []
			@string_num = []

			# テキスト表示用パネルを生成し、カメラから程よい距離に配置する
			draw_score
		end

		# 1フレーム分の進行処理
		def play
			# テキスト表示用パネルを1フレーム分アニメーションさせる
			@description.play
			@string_num.each {|dig| dig.play}
		end

		# キー押下（単発）時のハンドリング
		def on_key_pressed(glfw_key:)
			super
			case glfw_key
				# spaceキー押下でスタートへ遷移する
				when GLFW_KEY_SPACE 
					self.next_director = Directors::StarteDirector.new(screen_width: SCREEN_WIDTH, screen_height: SCREEN_HEIGHT, renderer: renderer)
					transition_to_next_director
			end
		end

		def draw_score
			count_digit
			@description = Panel.new(width: 0.25, height: 0.25,  map: TextureFactory.create_score_description)
			@description.mesh.position.x = -0.3
      		@description.mesh.position.y = 0
      		@description.mesh.position.z = -0.5
			self.scene.add(@description.mesh)
			@point_digit.each_with_index do |dig,n|
				@string_num[n] = Panel.new(width: 0.1, height: 0.13,  map: TextureFactory.create_number_description(dig.to_i))
				@string_num[n].mesh.position.x = @description.mesh.position.x + 0.1 + 0.1 * (n + 1)
				@string_num[n].mesh.position.y = -0.01
				@string_num[n].mesh.position.z = -0.5
				self.scene.add(@string_num[n].mesh)
				p @string_num[n].mesh.position.x
			end

		end

		def count_digit
			count = self.point.to_s.length
			(count - 1).downto(0){|n|
				@point_digit << (self.point / 10.pow(n))%10
			}
		end
	end
end