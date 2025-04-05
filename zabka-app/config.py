
class Config:
    SECRET_KEY = 'tajne'
    MYSQL_HOST = 'localhost'
    MYSQL_DB = 'zabka'
    MYSQL_CHARSET = 'utf8mb4'
    MYSQL_COLLATION = 'utf8mb4_polish_ci'
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    @staticmethod
    def sqlalchemy_uri(user, password):
        return f"mysql+pymysql://{user}:{password}@localhost/zabka?charset=utf8mb4"

class AppUser(Config):
    MYSQL_USER = 'client'
    MYSQL_PASSWORD = 'apppasswd'
    SQLALCHEMY_DATABASE_URI = Config.sqlalchemy_uri(MYSQL_USER, MYSQL_PASSWORD)

class ManagerUser(Config):
    MYSQL_USER = 'manager'
    MYSQL_PASSWORD = 'password1'
    SQLALCHEMY_DATABASE_URI = Config.sqlalchemy_uri(MYSQL_USER, MYSQL_PASSWORD)

class AdminUser(Config):
    MYSQL_USER = 'admin'
    MYSQL_PASSWORD = 'password3'
    SQLALCHEMY_DATABASE_URI = Config.sqlalchemy_uri(MYSQL_USER, MYSQL_PASSWORD)
