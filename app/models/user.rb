class User < ApplicationRecord

  has_many :microposts, dependent: :destroy #dependent: :destroyというオプションを使うと、ユーザーが削除されたときに、そのユーザーに紐付いた、つまりそのユーザーが投稿したマイクロポストも一緒に削除されるようになります。
  attr_accessor :remember_token, :activation_token, :reset_token #get,setterを作成、メソッドの作成
    before_save {self.email = email.downcase}
    before_save   :downcase_email
    before_create :create_activation_digest
    #email は実際には self.email と同じく このインスタンスの email 属性 を指します。
	#しかし代入するときは Ruby は単に email = … と書くとローカル変数を作る と解釈するので、
    #属性に代入したい場合は self.email = … と書く必要があります。
    has_secure_password
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: {minimum: 6}, allow_nil: true

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
    remember_digest
  end

    # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

    # 渡されたトークンがダイジェストと一致したらtrueを返す
    #def authenticated?(remember_token)
      #return false if remember_digest.nil? #連続した２回のログアウトの阻止
      #BCrypt::Password.new(remember_digest).is_password?(remember_token)
     #(BCrypt::Password.new)これをすることでcookiesの平文と比較することができる

    # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  #update_attributeはバリデーションを無視してデータベースに保存する

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    Micropost.where("user_id = ?", id)
  end


  private

  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
