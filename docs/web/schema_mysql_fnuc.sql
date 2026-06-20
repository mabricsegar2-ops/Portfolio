DROP VIEW Livres_Sujets_Motscles;
DROP VIEW clients_ca;
DROP TABLE IF EXISTS Commandes;
DROP TABLE IF EXISTS Livres_Sujets;
DROP TABLE IF EXISTS Livres_Motscles;
DROP TABLE IF EXISTS Stocks;
DROP TABLE IF EXISTS Sujets;
DROP TABLE IF EXISTS Motscles;
DROP TABLE IF EXISTS Clients;
DROP TABLE IF EXISTS Livres;
DROP TABLE IF EXISTS Parametres;


# -----------------------------------------------------------------------------
#       TABLE : CLIENTS
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Clients
 (
   ID INT NOT NULL COMMENT 'identifant du client',
   NOM VARCHAR (50) NOT NULL COMMENT 'Nom du client',
   MOTDEPASSE VARCHAR (10) NOT NULL COMMENT 'Mot de passe du client',
   CACUMUL DOUBLE PRECISION NULL COMMENT 'Le chiffre d''affaires cumule par client' CHECK (CACUMUL >= 0) 
   , PRIMARY KEY (ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Les clients'
;

insert into Clients values(1,'dubois','michel',0);
insert into Clients values(2,'budinger','marc',0);
insert into Clients values(3,'pommier','valerie',0);
insert into Clients values(4,'fevrier','yann',0);
insert into Clients values(5,'perez','jc',0);

# -----------------------------------------------------------------------------
#       TABLE : LIVRES
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Livres
 (
   ID INT NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du livre',
   TITRE VARCHAR (60) NOT NULL COMMENT 'Titre du livre' ,
   AUTEURS VARCHAR (50) NOT NULL COMMENT 'Auteurs du livre' ,
   RESUME_URL VARCHAR (100) NULL COMMENT 'URL de la page HTML qui decrit le livre' ,
   COUVERTURE_URL VARCHAR (100) NULL COMMENT 'URL de l''image de la couverture' ,
   PRIX DECIMAL(10,2) NOT NULL COMMENT 'Prix unique du livre' CHECK (PRIX > 0)
   , PRIMARY KEY (ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Les livres'
;
insert into Livres values(1,'La programation sous Unix ','J.-M. Rifflet','desc/lpsu.html','images/books/lpsu.gif',1000);
insert into Livres values(2,'La communication sous Unix','J.-M. Rifflet','desc/lcsu.html','images/books/lcsu.gif',210);
insert into Livres values(3,'Programmation Java','J.-F. Macary/C. Nicolas','desc/pj.html','images/books/pj.gif',168);
insert into Livres values(4,'Exploring Java','P. Niemeyer/J. Peck','desc/ej.html','images/books/ej.gif',110);
insert into Livres values(5,'Java in a nutshell','D. Flanagan ','desc/jian.html','images/books/jian.gif',135);
insert into Livres values(6,'Firewalls ','D. Chapman','desc/fw.html','images/books/fw.gif',255);
insert into Livres values(7,'Unix administration systeme et reseau','C. Pelissier','desc/uasr.html','images/books/uasr.gif',275.5);
insert into Livres values(8,'Unix in a nutshell','D. Gilly','desc/uian.html','images/books/uian.gif',87);
insert into Livres values(9,'Managing project with make','A. Oram/S. Talbott','desc/mpwm.html','images/books/mpwm.gif',153);
insert into Livres values(10,'Handbook of algorithms and data structures','G. Gonnet','desc/hoaads.html','images/books/hoaads.gif ',350);
insert into Livres values(11,'Fondements mathematiques de l'' informatique','J. Stern','desc/fmdli.html ','images/books/fmdli.gif',200);
insert into Livres values(12,'The C++ programming language','B. Stroustrup','desc/tcpl.html','images/books/tcpl.gif ',317);
insert into Livres values(13,'Programming Perl','L. Wall ','desc/pp.html','images/books/pp.gif ',253);
insert into Livres values(14,'Programmation d''application graphiques portable en C++','F. Pecheux','desc/pdagpec.html ','images/books/pdagpec.gif',323);
insert into Livres values(15,'XWindow system programming','N. Barkakati','desc/xwsp.html','images/books/xwsp.gif ',420);
insert into Livres values(16,'XWindow Programmation avec les XtInstrinsics','D. Young','desc/xwpalx.html','images/books/xwpalx.gif ',370);


# -----------------------------------------------------------------------------
#       TABLE : COMMANDES
# -----------------------------------------------------------------------------


CREATE TABLE IF NOT EXISTS Commandes
 (
   ID INT NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la commande',
   DATECOM DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date de la commande' ,
   ARTICLE INT NOT NULL COMMENT 'Reference de l''article commandee' ,
   CLIENT INT NOT NULL COMMENT 'Reference du client' ,
   QUANTITE DECIMAL NOT NULL COMMENT 'Quantite commandee'  CHECK (QUANTITE > 0),
   INDEX FKIndex_Article(ARTICLE),
   FOREIGN KEY FK_Article(ARTICLE) REFERENCES Livres (ID),
   INDEX FKIndex_Client(CLIENT),
   FOREIGN KEY FK_Client(CLIENT) REFERENCES Clients (ID)
   , PRIMARY KEY (ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Les commandes'
;
-- Triggers de mise a jour du l'attribut calculable , redondance concentie
DELIMITER //
CREATE TRIGGER INS_CMD_CAC AFTER INSERT ON Commandes FOR EACH ROW
BEGIN
declare deltaca numeric default 0;
select SUM(prix*quantite) into deltaca from Livres,Commandes where Livres.id=Commandes.article and client=NEW.client group by client ;
update Clients set cacumul=deltaca where Clients.id=NEW.client;
END
//
DELIMITER //
CREATE TRIGGER DEL_CMD_CAC AFTER DELETE ON Commandes FOR EACH ROW
BEGIN
declare deltaca numeric default 0;
select SUM(prix*quantite) into deltaca from Livres,Commandes where Livres.id=Commandes.article and client=OLD.client group by client ;
update Clients set cacumul=deltaca where Clients.id=OLD.client;
END
//
DELIMITER //
CREATE TRIGGER UPD_CMD_CAC AFTER UPDATE ON Commandes FOR EACH ROW
BEGIN
declare deltaca numeric default 0;
select SUM(prix*quantite) into deltaca from Livres,Commandes where Livres.id=Commandes.article and client=OLD.client group by client ;
update Clients set cacumul=deltaca where Clients.id=OLD.client;
select SUM(prix*quantite) into deltaca from Livres,Commandes where Livres.id=Commandes.article and client=NEW.client group by client ;
update Clients set cacumul=deltaca where Clients.id=NEW.client;
END
//

DELIMITER ;


-- SQLite version
-- DROP TRIGGER INS_CMD_CAC;
-- CREATE TRIGGER INS_CMD_CAC 
   -- AFTER INSERT ON commandes
   -- FOR EACH ROW
-- BEGIN
  -- UPDATE clients SET cacumul = (SELECT SUM(prix*quantite) from livres,commandes where livres.id=commandes.article and client=new.client group by client) WHERE clients.id=new.client;
-- END;

-- DROP TRIGGER DEL_CMD_CAC;
-- CREATE TRIGGER DEL_CMD_CAC 
   -- AFTER DELETE ON commandes
   -- FOR EACH ROW
-- BEGIN
  -- UPDATE clients SET cacumul = (SELECT SUM(prix*quantite) from livres,commandes where livres.id=commandes.article and client=old.client group by client) WHERE clients.id=old.client;
-- END;

-- DROP TRIGGER UPD_CMD_CAC;
-- CREATE TRIGGER UPD_CMD_CAC 
   -- AFTER UPDATE ON commandes
   -- FOR EACH ROW
   -- WHEN old.article <> new.article
        -- OR old.client <> new.client
        -- OR old.quantite <> new.quantite
-- BEGIN
  -- UPDATE clients SET cacumul = (SELECT SUM(prix*quantite) from livres,commandes where livres.id=commandes.article and client=old.client group by client) WHERE clients.id=old.client;
  -- UPDATE clients SET cacumul = (SELECT SUM(prix*quantite) from livres,commandes where livres.id=commandes.article and client=new.client group by client) WHERE clients.id=new.client;
-- END;

INSERT INTO Commandes VALUES(1,'1999-01-02',6,1,2);
INSERT INTO Commandes VALUES(2,'1999-02-03',1,1,1);
INSERT INTO Commandes VALUES(3,'1999-02-05',6,2,1);
INSERT INTO Commandes VALUES(4,'1999-02-06',4,1,1);
INSERT INTO Commandes VALUES(5,'1988-03-03',5,2,1);
INSERT INTO Commandes VALUES(6,'1999-09-10',8,2,1);

# -----------------------------------------------------------------------------
#       TABLE : Motscles
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Motscles
 (
   ID INT NOT NULL COMMENT 'Identifiant du mot cle' ,
   LIBELLE VARCHAR (50) NOT NULL COMMENT 'Libelle du mot cle' 
   , PRIMARY KEY (ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Les mots-cles'
;

insert into Motscles values(1,'programmation');
insert into Motscles values(2,'unix');
insert into Motscles values(3,'systeme');
insert into Motscles values(4,'internet');
insert into Motscles values(5,'reseau');
insert into Motscles values(6,'java');
insert into Motscles values(7,'securite');
insert into Motscles values(8,'firewall');
insert into Motscles values(9,'administration');
insert into Motscles values(10,'algorithmique');
insert into Motscles values(11,'pascal');
insert into Motscles values(12,'c++');
insert into Motscles values(13,'perl');
insert into Motscles values(14,'cgi');
insert into Motscles values(15,'ihm');
insert into Motscles values(16,'graphisme');
insert into Motscles values(17,'motif');
insert into Motscles values(18,'xwindow');
insert into Motscles values(19,'c');

# -----------------------------------------------------------------------------
#       TABLE : LIVRES_MOTSCLES
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Livres_Motscles
 (
   BOOK_ID INT NOT NULL COMMENT 'Reference au livre' ,
   KEYWORD_ID INT NOT NULL COMMENT 'Reference au mot cle' 
   , PRIMARY KEY (BOOK_ID,KEYWORD_ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Les liens mots-cles et livres'
;

insert into Livres_Motscles values(1,1);
insert into Livres_Motscles values(1,2);
insert into Livres_Motscles values(1,3);
insert into Livres_Motscles values(2,1);
insert into Livres_Motscles values(2,2);
insert into Livres_Motscles values(2,3);
insert into Livres_Motscles values(2,4);
insert into Livres_Motscles values(2,5);
insert into Livres_Motscles values(3,1);
insert into Livres_Motscles values(3,4);
insert into Livres_Motscles values(3,6);
insert into Livres_Motscles values(4,1);
insert into Livres_Motscles values(4,4);
insert into Livres_Motscles values(4,6);
insert into Livres_Motscles values(5,1);
insert into Livres_Motscles values(5,4);
insert into Livres_Motscles values(5,6);
insert into Livres_Motscles values(6,2);
insert into Livres_Motscles values(6,4);
insert into Livres_Motscles values(6,7);
insert into Livres_Motscles values(6,8);
insert into Livres_Motscles values(7,2);
insert into Livres_Motscles values(7,5);
insert into Livres_Motscles values(7,4);
insert into Livres_Motscles values(7,9);
insert into Livres_Motscles values(8,2);
insert into Livres_Motscles values(8,9);
insert into Livres_Motscles values(9,1);
insert into Livres_Motscles values(9,2);
insert into Livres_Motscles values(10,1);
insert into Livres_Motscles values(10,10);
insert into Livres_Motscles values(10,11);
insert into Livres_Motscles values(10,19);
insert into Livres_Motscles values(11,10);
insert into Livres_Motscles values(12,1);
insert into Livres_Motscles values(12,12);
insert into Livres_Motscles values(13,1);
insert into Livres_Motscles values(13,2);
insert into Livres_Motscles values(13,13);
insert into Livres_Motscles values(13,14);
insert into Livres_Motscles values(14,1);
insert into Livres_Motscles values(14,15);
insert into Livres_Motscles values(14,16);
insert into Livres_Motscles values(14,12);
insert into Livres_Motscles values(14,18);
insert into Livres_Motscles values(14,17);
insert into Livres_Motscles values(15,1);
insert into Livres_Motscles values(15,2);
insert into Livres_Motscles values(15,15);
insert into Livres_Motscles values(15,16);
insert into Livres_Motscles values(15,18);
insert into Livres_Motscles values(15,17);
insert into Livres_Motscles values(16,1);
insert into Livres_Motscles values(16,2);
insert into Livres_Motscles values(16,15);
insert into Livres_Motscles values(16,16);
insert into Livres_Motscles values(16,18);
insert into Livres_Motscles values(16,17);

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE LIVRES_MOTSCLES
# -----------------------------------------------------------------------------


CREATE  INDEX Livres_Motscles_BOOK_ID
     ON Livres_Motscles (BOOK_ID ASC);


CREATE  INDEX Livres_Motscles_KEYWORD_ID
     ON Livres_Motscles (KEYWORD_ID ASC);

# -----------------------------------------------------------------------------
#       TABLE : Sujets
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Sujets
 (
   ID INT NOT NULL COMMENT 'Identifiant du sujet' ,
   LIBELLE VARCHAR (50) NOT NULL COMMENT 'libelle du sujet',
   sujet_url VARCHAR (50) NOT NULL COMMENT 'URL de l''image du sujet'
   , PRIMARY KEY (ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Les sujets'
;

insert into Sujets values(1,'Unix','images/topics/unix.gif');
insert into Sujets values(2,'Infographie','images/topics/graphisme.gif');
insert into Sujets values(3,'Programmation','images/topics/programmation.gif');
insert into Sujets values(4,'Algorithmique','images/topics/algorithmique.gif');
insert into Sujets values(5,'Internet','images/topics/internet.gif');


# -----------------------------------------------------------------------------
#       TABLE : Livres_SUJETS
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Livres_Sujets
 (
   BOOK_ID INT NOT NULL COMMENT 'Reference au livre' ,
   TOPIC_ID INT NOT NULL COMMENT 'Reference au sujet' 
   , PRIMARY KEY (BOOK_ID,TOPIC_ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Les liens livres-sujets'
;

insert into Livres_Sujets values(1,1);
insert into Livres_Sujets values(2,1);
insert into Livres_Sujets values(2,5);
insert into Livres_Sujets values(3,3);
insert into Livres_Sujets values(3,5);
insert into Livres_Sujets values(4,3);
insert into Livres_Sujets values(4,5);
insert into Livres_Sujets values(5,3);
insert into Livres_Sujets values(5,5);
insert into Livres_Sujets values(6,5);
insert into Livres_Sujets values(7,1);
insert into Livres_Sujets values(7,5);
insert into Livres_Sujets values(8,1);
insert into Livres_Sujets values(9,3);
insert into Livres_Sujets values(9,1);
insert into Livres_Sujets values(10,4);
insert into Livres_Sujets values(10,3);
insert into Livres_Sujets values(11,4);
insert into Livres_Sujets values(12,3);
insert into Livres_Sujets values(13,3);
insert into Livres_Sujets values(14,2);
insert into Livres_Sujets values(14,3);
insert into Livres_Sujets values(15,1);
insert into Livres_Sujets values(15,2);
insert into Livres_Sujets values(15,3);
insert into Livres_Sujets values(16,1);
insert into Livres_Sujets values(16,2);
insert into Livres_Sujets values(16,3);

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE Livres_Sujets
# -----------------------------------------------------------------------------


CREATE  INDEX Livres_Sujets_BOOK_ID
     ON Livres_Sujets (BOOK_ID ASC);


CREATE  INDEX Livres_Sujets_TOPIC_ID
     ON Livres_Sujets (TOPIC_ID ASC);



# -----------------------------------------------------------------------------
	#       TABLE : Stocks
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Stocks
 (
   ID INT NOT NULL COMMENT 'Identifiant du stock' ,
   ARTICLE INT NOT NULL COMMENT 'Article reference' ,
   NIVEAU DECIMAL NULL COMMENT 'Niveau actuel du stock' CHECK (NIVEAU >= 0),
   SECURITE DECIMAL NULL COMMENT 'Niveau du stock de securite'  CHECK (SECURITE >= 0) 
   , PRIMARY KEY (ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Les stocks'
;

insert into Stocks values(1,1,0,3);
insert into Stocks values(2,2,1,3);
insert into Stocks values(3,3,2,3);
insert into Stocks values(4,4,3,3);
insert into Stocks values(5,5,7,3);
insert into Stocks values(6,6,5,3);
insert into Stocks values(7,7,1,3);
insert into Stocks values(8,8,0,3);
insert into Stocks values(9,9,0,3);
insert into Stocks values(10,10,0,3);
insert into Stocks values(11,11,1,3);
insert into Stocks values(12,12,13,3);
insert into Stocks values(13,13,10,3);
insert into Stocks values(14,14,1,3);
insert into Stocks values(15,15,2,3);
insert into Stocks values(16,16,4,3);

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE Stocks
# -----------------------------------------------------------------------------


CREATE UNIQUE INDEX Stocks_ARTICLE
     ON Stocks (ARTICLE ASC);



# -----------------------------------------------------------------------------
#       TABLE : PARAMETRES
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Parametres
 (
  id INT DEFAULT '1' COMMENT 'Identifiant qui garantie que la table ne contient qu''un seul tuple' CHECK (id=1),
  logo_url varchar(50) NOT NULL COMMENT 'URL du logo de la FNUC',
  taux_tva DECIMAL(10,3) DEFAULT '0.2' COMMENT 'Taux de TVA' CHECK (taux_tva >= 0 AND taux_tva < 1)
   , PRIMARY KEY (ID) 
 )
ENGINE=InnoDB
ROW_FORMAT=default
COMMENT='Table regroupant les parametres'
;

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE Parametres
# -----------------------------------------------------------------------------


CREATE UNIQUE INDEX Parametres_ID
     ON Parametres (ID ASC);


insert into Parametres values(1,'images/fnuc.jpg',.196);

# -----------------------------------------------------------------------------
#       CREATION DES REFERENCES DE TABLE
# -----------------------------------------------------------------------------




ALTER TABLE Livres_Motscles 
  ADD FOREIGN KEY FKLivres_MotsclesLIVRE (BOOK_ID)
      REFERENCES Livres (ID) ;


ALTER TABLE Livres_Motscles 
  ADD FOREIGN KEY FKLivres_MotsclesMOT (KEYWORD_ID)
      REFERENCES Motscles (ID) ;


ALTER TABLE Livres_Sujets 
  ADD FOREIGN KEY FKLivres_SujetsLIVRE (BOOK_ID)
      REFERENCES Livres (ID) ;


ALTER TABLE Livres_Sujets 
  ADD FOREIGN KEY FKLivres_SujetsSUJET (TOPIC_ID)
      REFERENCES Sujets (ID) ;


ALTER TABLE Stocks 
  ADD FOREIGN KEY FKStocksARTICLE (ARTICLE)
      REFERENCES Livres (ID) ;

;

CREATE VIEW Livres_Sujets_Motscles AS
SELECT livres.id, GROUP_CONCAT(DISTINCT sujets.libelle ORDER BY sujets.id SEPARATOR ', ') as rayons, GROUP_CONCAT(DISTINCT motscles.libelle ORDER BY motscles.id SEPARATOR ', ') as motscles 
FROM livres
INNER JOIN livres_sujets
ON livres.id=livres_sujets.book_id
INNER JOIN sujets
ON livres_sujets.topic_id=sujets.id
INNER JOIN livres_motscles
ON livres.id=livres_motscles.book_id
INNER JOIN motscles
ON livres_motscles.keyword_id=motscles.id
GROUP BY livres.id
;
-- SQLite version
-- On ne peut pas mettre de clause ORDER 
-- CREATE VIEW livres_sujets_motscles AS
-- SELECT livres.id, GROUP_CONCAT(DISTINCT sujets.libelle) as rayons, GROUP_CONCAT(DISTINCT motscles.libelle) as motscles 
-- FROM livres
-- INNER JOIN livres_sujets
-- ON livres.id=livres_sujets.book_id
-- INNER JOIN sujets
-- ON livres_sujets.topic_id=sujets.id
-- INNER JOIN livres_motscles
-- ON livres.id=livres_motscles.book_id
-- INNER JOIN motscles
-- ON livres_motscles.keyword_id=motscles.id
-- GROUP BY livres.id

-- SQLite sans DISTINCT mais aussi avec le bon resultat 
-- via des sous requêtes corrélées scalaires. il n' a toujours pas d'ordre
-- CREATE VIEW livres_sujets_motscles AS
-- SELECT id,
       -- (SELECT GROUP_CONCAT(libelle, ', ')
        -- FROM livres_sujets
        -- JOIN sujets
          -- ON livres_sujets.topic_id = sujets.id
        -- WHERE livres_sujets.book_id = livres.id
       -- ) AS rayons,
       -- (SELECT GROUP_CONCAT(libelle, ', ')
        -- FROM livres_motscles
        -- JOIN motscles
          -- ON livres_motscles.keyword_id = motscles.id
        -- WHERE livres_motscles.book_id = livres.id
       -- ) AS motscles
-- FROM livres
-- ;

CREATE VIEW clients_ca AS
SELECT clients.id as id, SUM(quantite*prix) as cacumul FROM commandes
INNER JOIN clients
ON clients.id=commandes.client
INNER JOIN livres
ON commandes.article=livres.id
GROUP BY clients.id
UNION SELECT clients.id,0
FROM clients
WHERE clients.id NOT IN (
  SELECT client
  FROM commandes
)
ORDER BY 1
;

CREATE VIEW commandes_article_client as
SELECT livres.id AS article, clients.id as client, clients.nom AS nom, titre AS titre, auteurs AS auteurs, SUM(QUANTITE) AS nbcommandes,prix 
FROM livres INNER JOIN commandes ON livres.id=commandes.article 
INNER JOIN clients
ON commandes.client=clients.id 
GROUP BY livres.id, clients.id , clients.nom, titre, auteurs,prix
UNION 
SELECT livres.id AS article, clients.id as client, clients.nom, titre AS titre, auteurs AS auteurs, 0 AS nbcommandes,prix 
FROM livres, clients WHERE (livres.id,clients.id) NOT IN (SELECT article, client FROM commandes) ORDER BY 1,2

