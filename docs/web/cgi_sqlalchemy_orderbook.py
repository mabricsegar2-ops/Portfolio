#!"D:/tools/WinPython-64bit-3.5.3.1Qt5/python-3.5.3.amd64/python.exe"
#-*- encoding: utf-8 -*-
import cgi, cgitb
from sqlalchemy import create_engine, text
from config import config

cgitb.enable()
form = cgi.FieldStorage()

print("Content-type:text/html\n\n")

try:
    params = config()
    db_type = form.getvalue('db', 'mysql')
    
    if db_type == 'postgresql':
        dsn = "postgresql+psycopg2://{username}:{password}@{hostname}:{port}/{database}".format(**params)
    elif db_type == 'oracle':
        dsn = "oracle+cx_oracle://{username}:{password}@{hostname}:{port}/{database}".format(**params)
    elif db_type == 'sqlite':
        dsn = "sqlite:///./fnuc.db"
    else:
        dsn = "mysql+mysqlconnector://{username}:{password}@{hostname}:{port}/{database}".format(**params)

    engine = create_engine(dsn)

    print('<html><head><title>La Fnuc on-line (SQLAlchemy - %s)</title>' % db_type.upper())
    print('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /></head>')
    # Affichage du logo Fnuc
    print('<BODY BG_COLOR="white"><CENTER><IMG SRC="' + params['urlbase'] + 'images/fnuc.jpg" WIDTH="100" ALIGN="middle"></CENTER><table>')

    if 'bookId' not in form:
        raise Exception("Invocation illegale du CGI !")
    
    book_id = form.getvalue('bookId')

    with engine.connect() as con:
        book = con.execute(text("SELECT titre, auteurs, prix FROM livres WHERE id = :id"), {"id": book_id}).fetchone()
        if book:
            print('<h1>%s</h1><p>Auteurs : %s</p><p>Prix : %s F</p>' % (book[0], book[1], book[2]))
            prix_unitaire = float(book[2])

    if form.getvalue('nom') == None or form.getvalue('mdp') == None or form.getvalue('qte') == None:
        # Propagation de bookId et db via champs cachés
        print('''
<form action="sqlaorderbook.py" method="post">
<input type="hidden" name="bookId" value="%s" />
<input type="hidden" name="db" value="%s" />
*Login        <input type="text" name="nom" /><BR>
*Mot de passe <input type="password" name="mdp" /><BR>
*Quantite     <input type="text" name="qte" /><BR>
<input type="submit" value="Commander">
</form>
''' % (cgi.escape(book_id), cgi.escape(db_type)))
    else:
        login = form.getvalue('nom')
        mdp = form.getvalue('mdp')
        qte = int(form.getvalue('qte'))

        if qte <= 0:
            raise ValueError("La quantité doit être supérieure à 0.")

        # engine.begin() gère le commit/rollback automatiquement
        with engine.begin() as con:
            # 1. Vérification stock
            stock = con.execute(text("SELECT NIVEAU FROM stocks WHERE ARTICLE = :id"), {"id": book_id}).fetchone()
            if not stock or stock[0] < qte:
                print("<p><b>Erreur :</b> Stock insuffisant.</p>")
            else:
                # 2. Gestion client
                client = con.execute(text("SELECT ID FROM clients WHERE NOM = :n AND MOTDEPASSE = :m"), {"n": login, "m": mdp}).fetchone()
                if client:
                    client_id = client[0]
                else:
                    con.execute(text("INSERT INTO clients (NOM, MOTDEPASSE, CACUMUL) VALUES (:n, :m, 0)"), {"n": login, "m": mdp})
                    # Récupération de l'ID via une nouvelle requête pour compatibilité multi-moteurs (SQLite/MySQL)
                    client_id = con.execute(text("SELECT ID FROM clients WHERE NOM = :n AND MOTDEPASSE = :m"), {"n": login, "m": mdp}).fetchone()[0]

                # 3. Commande, Stock et CA
                con.execute(text("INSERT INTO commandes (DATECOM, ARTICLE, CLIENT, QUANTITE) VALUES (CURRENT_TIMESTAMP, :a, :c, :q)"), 
                            {"a": book_id, "c": client_id, "q": qte})
                con.execute(text("UPDATE stocks SET NIVEAU = NIVEAU - :q WHERE ARTICLE = :a"), {"q": qte, "a": book_id})
                con.execute(text("UPDATE clients SET CACUMUL = CACUMUL + :ca WHERE ID = :c"), {"ca": prix_unitaire * qte, "c": client_id})
                
                print("<p>Commande validée sur le moteur <b>%s</b> : %s exemplaire(s) pour <b>%s</b>.</p>" % (db_type.upper(), qte, cgi.escape(login)))

    print('<hr>')
    print('<HR><CENTER><A HREF="sqlashowalltopics.py"> Retour au menu general </A></BODY></HTML>')

except ValueError as ve:
    print("<p><b>Erreur :</b> %s</p>" % ve)
except Exception as error:
    print("<p><b>Erreur Système :</b> %s</p>" % error)