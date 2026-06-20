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
    print ('<BODY BG_COLOR="white"><CENTER><IMG SRC="'+str({params['urlbase']})[2:-2]+'images/fnuc.jpg" WIDTH="100" ALIGN="middle"></CENTER><table>')

    if 'bookId' not in form:
            raise Exception("Invocation illegale du CGI !")
    else:
        raw_bookid = form.getvalue('bookId')
        cur.execute('SELECT titre, auteurs, prix FROM livres WHERE id=%s', (raw_bookid,))
        info = cur.fetchone()
        
        if info:
            print ('<h1>%s</h1>' % info[0])
            print('<p>Auteurs : %s</p>'% info[1])
            print('<p>Prix : %s F</p>'% info[2])
        
        if form.getvalue('nom')==None or form.getvalue('mdp')==None or form.getvalue('qte')==None:
            #  hidden pour transmettre le bookId
            print ('''
<form action="myorderbook.py" method="post">
<input type="hidden" name="bookId" value="%s" />
*Login        <input type="text" name="nom" /><BR>
*Mot de passe <input type="password" name="mdp" /><BR>
*Quantite     <input type="text" name="qte" /><BR>
<input type="submit" value="Commander">
</form>
    ''' % cgi.escape(raw_bookid)) 
        else:
            login = form.getvalue('nom')
            mdp = form.getvalue('mdp')
            
            try:
                qte = int(form.getvalue('qte'))
                if qte <= 0:
                    print("<p><b>Erreur :</b> La quantité doit être un nombre entier supérieur à 0.</p>")
                    raise ValueError("Quantité invalide")
                
                cur.execute("SELECT NIVEAU FROM stocks WHERE ARTICLE = %s", (raw_bookid,))
                stock_result = cur.fetchone()
                
                if not stock_result:
                    print("<p><b>Erreur :</b> Cet article n'est pas répertorié dans les stocks.</p>")
                elif stock_result[0] < qte:
                    print("<p><b>Erreur :</b> Stock insuffisant. Il ne reste que %s exemplaire(s) disponible(s).</p>" % stock_result[0])
                else:
                    cur.execute("SELECT ID FROM clients WHERE NOM = %s AND MOTDEPASSE = %s", (login, mdp))
                    client_result = cur.fetchone()
                    
                    if client_result:
                        client_id = client_result[0]
                    else:
                        cur.execute("INSERT INTO clients (NOM, MOTDEPASSE, CACUMUL) VALUES (%s, %s, 0)", (login, mdp))
                        client_id = cur.lastrowid
                    
                    cur.execute("INSERT INTO commandes (DATECOM, ARTICLE, CLIENT, QUANTITE) VALUES (NOW(), %s, %s, %s)", (raw_bookid, client_id, qte))
                    cur.execute("UPDATE stocks SET NIVEAU = NIVEAU - %s WHERE ARTICLE = %s", (qte, raw_bookid))
                    
                    con.commit()
                    print("<p>Commande validée : %s exemplaire(s) pour <b>%s</b>. Le stock a été mis à jour.</p>" % (qte, cgi.escape(login)))

            except mysql.connector.Error as err:
                con.rollback()
                print("<p><b>Erreur base de données :</b> %s</p>" % err)

    print('<hr>')

    print('<hr>')
    print ('<HR><CENTER><A HREF="myshowalltopics.py"> Retour au menu general </A></BODY></HTML>')

    print ('</table>')
    print ('</body>')
    print ('</html>')


except (mysql.connector.Error, Exception) as error:
    print(error)    
finally:
    if cur is not None:
         cur.close
    if con is not None:
         con.close

