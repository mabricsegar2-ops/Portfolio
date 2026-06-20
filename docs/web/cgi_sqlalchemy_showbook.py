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
    db_type = form.getvalue('db', 'mysql') # Récupération du moteur, mysql par défaut
    
    # Construction du DSN selon le moteur
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
    
    book_id = cgi.escape(form.getvalue('bookId'))

    with engine.connect() as con:
        # Requête paramétrée SQLAlchemy standard
        query = text("SELECT titre, auteurs, prix, couverture_url, resume_url FROM livres WHERE id = :id")
        book = con.execute(query, {"id": book_id}).fetchone()

        if book:
            print('<h1>%s</h1>' % book[0])
            print('<p>Auteurs : %s</p>' % book[1])
            print('<p>Prix : %s F</p>' % book[2])
            # Affichage de la couverture
            if book[3]:
                print('<img src="' + params['urlbase'] + book[3] + '" align="left">')
            # Affichage du résumé
            if book[4]:
                print('<iframe src="' + params['urlbase'] + book[4] + '" width="85%" height="300"></iframe>')

    print('<hr>')
    # Propagation du paramètre 'db' dans l'URL
    print('</TABLE><CENTER><A HREF="e2401441_sqlaorderbook.py?bookId=%s&db=%s">Commander cet ouvrage</A></CENTER>' % (book_id, db_type))
    print('<HR><CENTER><A HREF="sqlashowalltopics.py"> Retour au menu general </A></BODY></HTML>')

except Exception as error:
    print("<p><b>Erreur :</b> %s</p>" % error)