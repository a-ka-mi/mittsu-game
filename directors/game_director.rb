require_relative 'base'

module Directors
	# ゲーム本編のディレクター
	class GameDirector < Base
		CAMERA_ROTATE_SPEED_X = 0.01
		CAMERA_ROTATE_SPEED_Y = 0.01

		# 初期化
		def initialize(screen_width:, screen_height:, renderer:)
			super

			#得点
			self.point = 0

			#終了時間
			@time = 1500

			# ゲーム本編の登場オブジェクト群を生成
			create_objects

			# 弾丸の詰め合わせ用配列
			@bullets = []

			# 敵の詰め合わせ用配列
			@enemies = []

			# 現在のフレーム数をカウントする
			@frame_counter = 0
			

			@camera_rotate_x = 0.0
			@camera_rotate_y = 0.0

			@current_position_x=0.0
			@current_position_y=0.0
		end

		# １フレーム分の進行処理
		def play
			# 現在発射済みの弾丸を一通り動かす
			@bullets.each(&:play)

			# 現在登場済みの敵を一通り動かす
			@enemies.each(&:play)

			# 各弾丸について当たり判定実施
			@bullets.each{|bullet| hit_any_enemies(bullet) }

			# 消滅済みの弾丸及び敵を配列とシーンから除去(わざと複雑っぽく記述しています)
			rejected_bullets = []
			@bullets.delete_if{|bullet| bullet.expired ? rejected_bullets << bullet : false }
			rejected_bullets.each{|bullet| self.scene.remove(bullet.mesh) }
			rejected_enemies = []
			@enemies.delete_if{|enemy| enemy.expired ? rejected_enemies << enemy : false }
			rejected_enemies.each{|enemy| self.scene.remove(enemy.mesh) }

			# 一定のフレーム数経過毎に敵キャラを出現させる
			if @frame_counter % 60 == 0
				enemy = Enemy.new

				@enemies << enemy
				self.scene.add(enemy.mesh)
			end

			@frame_counter += 1

			#camera.position.z = 0.05

			#self.camera.rotate_x(CAMERA_ROTATE_SPEED_X) if self.renderer.window.on_mouse_move 
			#self.camera.position.x = ((position.x/SCREEN_WIDTH)*0.002-0.001) * 5.0
			#self.camera.rotate_y(CAMERA_ROTATE_SPEED_Y) if self.renderer.window.on_mouse_move 
			#self.camera.position.y = ((position.y/SCREEN_HEIGHT)*-0.002+0.001) * 5.0

			self.camera.rotate_x(CAMERA_ROTATE_SPEED_X) if self.renderer.window.key_down?(GLFW_KEY_UP)
			self.camera.rotate_x(-CAMERA_ROTATE_SPEED_X) if self.renderer.window.key_down?(GLFW_KEY_DOWN)
			self.camera.rotate_y(CAMERA_ROTATE_SPEED_Y) if self.renderer.window.key_down?(GLFW_KEY_LEFT)
			self.camera.rotate_y(-CAMERA_ROTATE_SPEED_Y) if self.renderer.window.key_down?(GLFW_KEY_RIGHT)

			self.renderer.window.on_mouse_move do |position|
				if @current_position_x != 0.0 && @current_position_y != 0.0
					#変位
					dy = @current_position_y - position.y
					dx = @current_position_x - position.x
					self.camera.rotation.x += dy * 0.008
					self.camera.rotation.y += dx * 0.008
					#self.camera.position.x = ((position.x/SCREEN_WIDTH)* 0.2 - 0.1) * 5.0
					#self.camera.position.y = ((position.y/SCREEN_HEIGHT)*-0.2 + 0.1) * 5.0
				end

				@current_position_x=position.x
				@current_position_y=position.y
				#self.camera.rotate_x(CAMERA_ROTATE_SPEED_X)
				#self.camera.position.x = ((position.x/SCREEN_WIDTH)* 0.2 - 0.1) * 5.0
				#self.camera.rotate_y(CAMERA_ROTATE_SPEED_Y)
				#self.camera.position.y = ((position.y/SCREEN_HEIGHT)*-0.2 + 0.1) * 5.0
				#puts "position.x:#{position.x}, position.y:#{position.y}"
			end

			self.check_finish?
		end
	

		# キー押下（単発）時のハンドリング
		def on_key_pressed(glfw_key:)
			super
			case glfw_key
				# ESCキー押下でエンディングに無理やり遷移
				when GLFW_KEY_ESCAPE
					transition_to_next_director
			end
		end
		
		#左クリックで射撃
		def on_mouse_button_pressed(button:)
			case button
				when GLFW_MOUSE_BUTTON_LEFT
				shoot
				#puts "test1"
			end
		end

		private

		# ゲーム本編の登場オブジェクト群を生成
		def create_objects
			# 太陽光をセット
			@sun = LightFactory.create_sun_light
			self.scene.add(@sun)
			@wall = MeshFactory.create_base
			@wall.position.y = -0.9
			@wall.position.z = -0.8
      		self.scene.add(@wall)
		end

		# 弾丸発射
		def shoot
			# 現在カメラが向いている方向を進行方向とし、進行方向に対しBullet::SPEED分移動する単位単位ベクトルfを作成する
			f = Mittsu::Vector4.new(0, 0, 1, 0)
			f.apply_matrix4(self.camera.matrix).normalize
			f.multiply_scalar(Bullet::SPEED)

			# 弾丸オブジェクト生成
			bullet = Bullet.new(f)
			self.scene.add(bullet.mesh)
			@bullets << bullet
		end

		# 弾丸と敵の当たり判定
		def hit_any_enemies(bullet)
			return if bullet.expired
			@enemies.each do |enemy|
				next if enemy.expired
				distance = bullet.position.distance_to(enemy.position)

				if distance < 0.22
					bullet.expired = true
					enemy.expired = true
					self.point += 10
				end
			end
		end

		def check_finish?
			if @frame_counter == @time
				self.next_director = EndingDirector.new(screen_width: screen_width, screen_height: screen_height, renderer: renderer, point: self.point)
				transition_to_next_director 
			end
		end
	end
end