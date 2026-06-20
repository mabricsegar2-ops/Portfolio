#!"D:/tools/WinPython-64bit-3.5.3.1Qt5/python-3.5.3.amd64/python.exe"
#-*- encoding: utf-8 -*-
# myshowbook.py: Show all informations about a book.
#
import cgi, cgitb
cgitb.enable()

form = cgi.FieldStorage()

print ("Content-type:text/html\n\n")

import mysql.connector
from config import config

con = None
cur = None

try:
    # read connection params
    params = config()

    con = mysql.connector.connect(host=params['hostname'],  # your host
                         port=params['port'],               # your port 
                         user=params['username'],           # username
                         passwd=params['password'],         # password
                         db=params['database'],             # name of the database
                         auth_plugin=params['auth_plugin'])   

    cur = con.cursor()
    cur.execute('SELECT version()')
    version = cur.fetchone()
    print ('<html>')
    print ('<head>')
    print ('<title>La Fnuc on-line (avec .:: MySQL %s ::.)</title>'% (version))
    print ('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /></head>')
    # Affichage du logo Fnuc
    print('<BODY BG_COLOR="white"><CENTER><IMG SRC="' + params['urlbase'] + 'images/fnuc.jpg" WIDTH="100" ALIGN="middle"></CENTER><table>')
    
    if 'bookId' not in form:
        raise Exception("Invocation illegale du CGI !")
    else:
        cgi_bookid=cgi.escape(form.getvalue('bookId'))
        # pour le titre
        cur.execute('SELECT titre FROM livres WHERE id=%s'% (cgi_bookid))
        titre = cur.fetchone()
        print ('<h1>%s</h1>' % titre[0]) #car c un tuple ptn de merde
        # pour le auteurs
        cur.execute('SELECT auteurs FROM livres WHERE id=%s'% (cgi_bookid))
        auteurs = cur.fetchone()
        print('<p>Auteurs : %s</p>'% auteurs[0])
        # pour le prix
        cur.execute('SELECT prix FROM livres WHERE id=%s'% (cgi_bookid))
        prix = cur.fetchone()
        print('<p>Prix : %s'% prix[0] + 'F</p>')
        # pour le image
        cur.execute('SELECT couverture_url FROM livres WHERE id=%s'% (cgi_bookid))
        img = cur.fetchone()
        print('<img src="' +str({params['urlbase']})[2:-2] + img[0] + '" align="left">')
        #texte
        cur.execute('SELECT resume_url FROM livres WHERE id=%s', (cgi_bookid,))
        resume = cur.fetchone()
        print( '<iframe src="'  + params["urlbase"]  + resume[0]  + '" width="85%" height="300"></iframe>')

        
    print('<hr>')
    print ('</TABLE><CENTER><A HREF=''e2401441_myorderbook.py?bookId=%s''>Commander cet ouvrage</A></CENTER>' % (cgi_bookid))
    print ('<HR><CENTER><A HREF="myshowalltopics.py"> Retour au menu general </A></BODY></HTML>')

    print ('</table>')
    print ('</body>')
    print ('</html>')


except (mysql.connector.Error, Exception) as error:
    print(error)    
finally:
    # on ferme les ressources de la DB API v2
    if cur is not None:
         cur.close
    if con is not None:
         con.close

