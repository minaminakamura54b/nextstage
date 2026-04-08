class User < ApplicationRecord
  attr_accessor :remember_token #get,setterを作成、メソッドの作成
    before_save {self.email = email.downcase}
    #email は実際には self.email と同じく このインスタンスの email 属性 を指します。
	#しかし代入するときは Ruby は単に email = … と書くとローカル変数を作る と解釈するので、
    #属性に代入したい場合は self.email = … と書く必要があります。
    has_secure_password
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: {minimum: 6}

     # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64 #ログイン時にランダムな文字列の作成
  end

   # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember #remember_tokenにランダム文字列を記憶させる
    self.remember_token = User.new_token #self出ないとローカル変数を作成してしまう
    self.update_attribute(:remember_digest, User.digest(remember_token)) #update_attributeはバリデーションを無視
    #rember_digestにuser.digestでハッシュ化した値を代入
  end

    # 渡されたトークンがダイジェストと一致したらtrueを返す
    def authenticated?(remember_token)
      return false if remember_digest.nil? #連続した２回のログアウトの阻止
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end #(BCrypt::Password.new)これをすることでcookiesの平文と比較することができる

  def forget
    update_attribute(:remember_digest, nil)
  end

end
