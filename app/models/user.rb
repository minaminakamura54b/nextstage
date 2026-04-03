class User < ApplicationRecord
    before_save {self.email = email.downcase}
    #email は実際には self.email と同じく このインスタンスの email 属性 を指します。
	#しかし代入するときは Ruby は単に email = … と書くとローカル変数を作る と解釈するので、
    #属性に代入したい場合は self.email = … と書く必要があります。
    has_secure_password
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: {minimum: 6}
end
