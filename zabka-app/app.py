from flask import Flask, render_template, request, redirect, session, flash
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
import hashlib
from flask_mysqldb import MySQL
import MySQLdb

from config import AppUser, ManagerUser, AdminUser

# Flask setup
app = Flask(__name__)
app.secret_key = 'supersekret'

app.config.from_object(AppUser)
mysql = MySQL(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://app:apppasswd@localhost/zabka?charset=utf8mb4'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

def get_mysql_by_role(role):
    import MySQLdb
    if role == 'manager':
        return MySQLdb.connect(
            host="localhost",
            user="manager",
            passwd="password1",
            db="zabka",
            charset='utf8mb4',
            cursorclass=MySQLdb.cursors.DictCursor
        )
    elif role == 'admin':
        return MySQLdb.connect(
            host="localhost",
            user="admin",
            passwd="password3",
            db="zabka",
            charset='utf8mb4',
            cursorclass=MySQLdb.cursors.DictCursor
        )
    else:
        return MySQLdb.connect(
            host="localhost",
            user="client",
            passwd="apppasswd",
            db="zabka",
            charset='utf8mb4',
            cursorclass=MySQLdb.cursors.DictCursor
        )



@app.route('/')
def index():
    if 'logged_in' in session:
        with db.engine.connect() as conn:
            result = conn.execute(text('''
    SELECT p.*, s.city, s.street 
    FROM Package p
    JOIN Shop s ON p.shop_id = s.shop_id
    WHERE order_status = 'Do odbioru'
            ''')).mappings()
            packages = [row for row in result]


            pickup_result = conn.execute(
            text("SELECT package_id FROM Pickup WHERE user_id = :uid"), {'uid': session['user_id']}).mappings()
            ordered_ids = [row['package_id'] for row in pickup_result]


        return render_template('index.html', packages=packages, ordered_ids=ordered_ids)
    return redirect('/login')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = hashlib.sha256(request.form['password'].encode()).hexdigest()

        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SET NAMES utf8mb4 COLLATE utf8mb4_polish_ci;")

        cursor.execute('SELECT user_id, name, role FROM User_info WHERE mail = %s', (email,))
        user = cursor.fetchone()


        cursor.execute('''
            SELECT user_id, name, surname, points, role 
            FROM User_info 
            WHERE mail = %s AND password_hash = %s
        ''', (email, password))

        user = cursor.fetchone()

        if user:
            session['logged_in'] = True
            session['user_id'] = user['user_id']
            session['user_name'] = f"{user['name']} {user['surname']}"
            session['points'] = user['points']
            session['role'] = user['role']  # 👈 ключевое
            return redirect('/')
        else:
            flash("Błędny login lub hasło")

    return render_template('login.html')


@app.route('/order_package', methods=['POST'])
def order_package():
    if 'logged_in' in session:
        package_id = request.form.get('package_id')
        user_id = session['user_id']

        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Получаем shop_id из таблицы Package
        cursor.execute("SELECT shop_id FROM Package WHERE package_id = %s", (package_id,))
        result = cursor.fetchone()
        if result:
            shop_id = result['shop_id']

            cursor.execute("""
                INSERT INTO Pickup (user_id, shop_id, package_id, discount_code, rating)
                VALUES (%s, %s, %s, NULL, 5)
            """, (user_id, shop_id, package_id))

            mysql.connection.commit()

        return redirect('/')
    return redirect('/login')
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        surname = request.form['surname']
        email = request.form['email']
        password = hashlib.sha256(request.form['password'].encode()).hexdigest()
        city = request.form.get('city')
        street = request.form.get('street')
        post_code = request.form.get('post_code')
        diet_type = request.form.get('diet_type')

        cursor = mysql.connection.cursor()

        try:
            cursor.execute('''
                INSERT INTO User_info (name, surname, mail, password_hash, city, street, post_code, diet_type)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ''', (name, surname, email, password, city, street, post_code, diet_type))
            mysql.connection.commit()
        except Exception as e:
            flash("Nie udało się zarejestrować użytkownika.")
            print("Błąd MySQL:", e)
            return redirect('/register')

        # automatyczne logowanie po rejestracji
        cursor.execute("SELECT user_id, points FROM User_info WHERE mail = %s", (email,))
        user = cursor.fetchone()
        session['logged_in'] = True
        session['user_id'] = user['user_id']
        session['user_name'] = f"{name} {surname}"
        session['points'] = user['points']

        return redirect('/')
    return render_template('register.html')


@app.route('/profile')
def profile():
    if not session.get('logged_in'):
        return redirect('/login')

    with db.engine.connect() as conn:
        result = conn.execute(text('''
            SELECT p.pickup_code, p.rating, s.city, s.street, 
                   pk.size, pk.price, pk.pickup_day
            FROM Pickup p
            JOIN Shop s ON p.shop_id = s.shop_id
            JOIN Package pk ON p.package_id = pk.package_id
            WHERE p.user_id = :uid
        '''), {'uid': session['user_id']}).mappings()

        orders = [row for row in result]

    return render_template('profile.html', orders=orders)
@app.route('/manager', methods=['GET', 'POST'])
def manager_panel():
    if not session.get('logged_in') or session.get('role') != 'manager':
        flash("Dostęp tylko dla menadżera.")
        return redirect('/')

    conn = get_mysql_by_role(session['role'])
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Shop")
    shops = cursor.fetchall()

    if request.method == 'POST':
        size = request.form['size']
        price = request.form['price']
        diet_type = request.form['diet_type']
        order_status = request.form['order_status']
        pickup_day = request.form['pickup_day']
        start = request.form['start_pickup']
        end = request.form['end_pickup']
        shop_id = request.form['shop_id']

        cursor.execute('''
            INSERT INTO Package (shop_id, size, price, diet_type, order_status, pickup_day, start_pickup_hours, end_pickup_hours)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ''', (shop_id, size, price, diet_type, order_status, pickup_day, start, end))
        conn.commit()
        flash("Paczka została dodana!")

    conn.close()
    return render_template('manager.html', shops=shops)

@app.route('/admin')
def admin_panel():
    if not session.get('logged_in') or session.get('role') != 'admin':
        flash("Dostęp tylko dla administratora.")
        return redirect('/')
    return render_template('admin.html')  # пока заготовка

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/login')

if __name__ == '__main__':
    app.run(debug=True)
