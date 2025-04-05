# sql_zabka
Bazy Danych, PWr
jak uruchomić na Win:
1. w cmd otwieracie folder, gdzie leży zabka.sql
2. dalej szukacie, gdzie u was leży plik "mysql.exe", zwykle "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" i wpisujecie w cmd:

C:\gdzie-leży-plik-zabka.sql>"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p zabka < zabka.sql

dalej wpisujecie hasło, które ustawialiście, kiedy instalowaliście mysql, jeśli wszystko się powiedzie, to będzie pusta linia

Jeśli wszystko git, to:

C:\gdzie-leży-plik-zabka.sql>"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p zabka
tak się uruchamia bd
musi być taki zanczek "mysql>"

dalej przchodzicie do Pycharm i otwieracie project
instalujecie pakiety niezbędne ( pip install packety...) 
uruchmiacie "python app.py" w terminalu albo po prostu "run app.py", output będzie taki:
 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 648-648-272

wpisujecie adres "http://127.0.0.1:5000" w przeglądarkę i życzę dobrej zabawy
