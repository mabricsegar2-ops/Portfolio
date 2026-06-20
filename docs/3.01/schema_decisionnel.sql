DROP TABLE IF EXISTS faits_ventes_star;
DROP TABLE IF EXISTS faits_ventes;
DROP TABLE IF EXISTS faits_cours;
DROP TABLE IF EXISTS dim_temps;
DROP TABLE IF EXISTS dim_devise;
DROP TABLE IF EXISTS utilisateur;
DROP TABLE IF EXISTS securite;
DROP TABLE IF EXISTS profil;
DROP TABLE IF EXISTS dim_produit CASCADE;
DROP TABLE IF EXISTS dim_sous_categorie_produit;
DROP TABLE IF EXISTS dim_categorie_produit;
DROP TABLE IF EXISTS dim_enseigne;
DROP TABLE IF EXISTS dim_famille_produit;
DROP TABLE IF EXISTS dim_magasin;
DROP TABLE IF EXISTS dim_departement;
DROP TABLE IF EXISTS france_departements;
DROP TABLE IF EXISTS dim_geographique_com;
DROP TABLE IF EXISTS dim_geographique_admin;
DROP TABLE IF EXISTS dim_pays;

DROP TABLE IF EXISTS dim_devise CASCADE;
CREATE TABLE IF NOT EXISTS dim_devise(
id_devise INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant devise',
lib_devise VARCHAR(10) NOT NULL COMMENT 'Libelle devise',
isocode VARCHAR(3) NOT NULL COMMENT 'Code ISO de la device pour le web service d''alimentation',
symbole VARCHAR(3) COMMENT 'Symbole de la devise',
format_bo VARCHAR(20) COMMENT 'Format a utiliser dans BO',
cours_fixe DECIMAL(25,20) NULL COMMENT 'Pour les anciennes monnaies avant euro, la conversion fixe a utiliser',
date_maj TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de derniere mise a jour des donnees de la devise',
UNIQUE INDEX ISOCODE_UNIQUE (ISOCODE ASC)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Devises pour l''affichage dans la dimension devise';

DROP TABLE IF EXISTS dim_temps CASCADE;
CREATE TABLE IF NOT EXISTS dim_temps(
id_temps VARCHAR(8) PRIMARY KEY  COMMENT 'Identifiant de la periode de temps',
mois INTEGER NOT NULL COMMENT 'Mois de la periode de temps',
lib_mois VARCHAR(10) NOT NULL COMMENT 'Libelle du mois de la periode de temps',
trimestre INTEGER NOT NULL COMMENT 'Trimestre de la periode de temps',
semestre INTEGER NOT NULL COMMENT 'Semestre de la periode de temps',
annee INTEGER NOT NULL COMMENT 'Annee de la periode de temps',
date_maj TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de derniere mise a jour des donnees du temps'
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'La dimension temps';

DROP TABLE IF EXISTS faits_cours CASCADE;
CREATE TABLE IF NOT EXISTS faits_cours(
id_devise INT NOT NULL  COMMENT 'Devise du cours',
id_temps VARCHAR(8) NOT NULL  COMMENT 'Identifiant du temps (annee et mois)',
cours DECIMAL(25,20) NOT NULL COMMENT 'Cours par rapport a l''unite de compte (euro)',
date_maj TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de derniere mise a jour des donnees du cours fluctuant',
CONSTRAINT faits_cours_pkey PRIMARY KEY(id_devise,id_temps),
INDEX faits_cours_idev_fkey_idx (id_devise),
CONSTRAINT faits_cours_idev_fkey FOREIGN KEY(id_devise) REFERENCES dim_devise(id_devise),
INDEX faits_cours_itmp_fkey_idx (id_temps),
CONSTRAINT faits_cours_itmp_fkey FOREIGN KEY(id_temps) REFERENCES dim_temps(id_temps)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Cours fluctuants';

DROP TABLE IF EXISTS dim_pays CASCADE;
CREATE TABLE IF NOT EXISTS dim_pays(
id_pays INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant du pays',
lib_pays VARCHAR(55) NOT NULL COMMENT 'Libelle du pays',
iso_3166_1_numeric NUMERIC COMMENT 'code for country in iso standarts',
iso_3166_alpha_2 VARCHAR(2) COMMENT 'code for country in iso standarts',
fichier_image_carte_pays VARCHAR(20) NOT NULL COMMENT 'Nom du fichier image la carte du pays',
datemaj_pays TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de derniere mise a jour des donnees du pays'
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les pays du groupe Darties (flocon)';


DROP TABLE IF EXISTS dim_geographique_admin CASCADE;
CREATE TABLE IF NOT EXISTS dim_geographique_admin(
id_region_admin INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant de la region administrative',
lib_region_admin VARCHAR(55) NOT NULL COMMENT 'Libelle de la region administrative',
date_debut_valid_admin TIMESTAMP NOT NULL default '2001-01-01 00:00:00' COMMENT 'Date de debut de validite de la region administrative',
date_fin_valid_admin TIMESTAMP COMMENT 'Date de fin de validite de la region administrative',
fichier_image_carte_regadm VARCHAR(50) NOT NULL COMMENT 'Nom du fichier image la carte de la region administrative',
sas_map_id VARCHAR(15) COMMENT 'SAS Visual Analytics code for region',
sas_map_name VARCHAR(55) COMMENT 'Nom des regions pour SAS Visual Analytics',
id_pays INT NOT NULL COMMENT 'Identifiant du pays',
datemaj_geo_admin TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de derniere mise a jour des donnees de la région administrative',
INDEX dim_geographique_admin_i_fkey_idx (id_pays),
CONSTRAINT dim_geographique_admin_i_fkey FOREIGN KEY(id_pays) REFERENCES dim_pays(id_pays)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les regions administratives (flocon)';

DROP TABLE IF EXISTS dim_geographique_com CASCADE;
CREATE TABLE IF NOT EXISTS dim_geographique_com(
id_region_com INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant de la region commerciale',
lib_region_com VARCHAR(50) NOT NULL COMMENT 'Libelle de la region commerciale',
date_debut_valid_com TIMESTAMP NOT NULL default '2001-01-01 00:00:00' COMMENT 'Date de debut de validite de la region commerciale',
date_fin_valid_com TIMESTAMP COMMENT 'Date de fin de validite de la region commerciale',
fichier_image_carte_regcom VARCHAR(20) NOT NULL COMMENT 'Nom du fichier image la carte de la region commerciale',
id_pays INT NOT NULL COMMENT 'pays de la region commerciale',
datemaj_geo_com TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de la derniere mise a jour des donnees de la région commerciale' ,
INDEX dim_geographique_com_i_fkey_idx (id_pays),
CONSTRAINT dim_geographique_com_i_fkey FOREIGN KEY(id_pays) REFERENCES dim_pays(id_pays)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les regions commerciales (flocon)';


DROP TABLE IF EXISTS france_departements CASCADE;
CREATE TABLE IF NOT EXISTS france_departements(
code_dept VARCHAR(2) PRIMARY KEY COMMENT 'Code INSEE du departement',
lib_departement VARCHAR(55) NOT NULL COMMENT 'Nom du departement',
id_region_admin1 INT NOT NULL COMMENT 'Reference a la region administrative ancienne du departement',
id_region_admin2 INT NOT NULL COMMENT 'Reference a la region administrative nouvelle du departement',
id_region_com INT NOT NULL COMMENT 'Reference a la region commerciale du departement'
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Correspondance des niveaux geographique pour la France metropolitaine';

DROP TABLE IF EXISTS dim_departement CASCADE;
CREATE TABLE IF NOT EXISTS dim_departement(
id_departement INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant du departement',
code_departement VARCHAR(2) COMMENT 'Code INSEE du departement',
lib_departement VARCHAR(55) NOT NULL COMMENT 'Nom du departement',
id_region_admin1 INT NOT NULL COMMENT 'Reference a la region administrative ancienne du departement',
id_region_admin2 INT NOT NULL COMMENT 'Reference a la region administrative nouvelle du departement',
id_region_com INT NOT NULL COMMENT 'Reference a la region commerciale du departement',
datemaj_dep TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de la derniere mise a jour des donnees du departement' ,
INDEX dim_departement_i_fkey1_idx (id_region_admin1),
CONSTRAINT dim_departement_i1_fkey FOREIGN KEY(id_region_admin1) REFERENCES dim_geographique_admin(id_region_admin),
INDEX dim_departement_i_fkey2_idx (id_region_admin2),
CONSTRAINT dim_departement_i2_fkey FOREIGN KEY(id_region_admin2) REFERENCES dim_geographique_admin(id_region_admin),
INDEX dim_departement_i_fkey3_idx (id_region_com),
CONSTRAINT dim_departement_i3_fkey FOREIGN KEY(id_region_com) REFERENCES dim_geographique_com(id_region_com)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les departement des magasins (flocon)';

DROP TABLE IF EXISTS dim_enseigne CASCADE;
CREATE TABLE IF NOT EXISTS dim_enseigne(
id_enseigne INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant de l''enseigne',
lib_enseigne VARCHAR(32) NOT NULL COMMENT 'Libelle de l''enseigne',
fichier_image_logo_enseigne VARCHAR(20) COMMENT 'Nom du fichier image du logo de l''enseigne',
datemaj_enseigne TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de la derniere mise a jour des donnees de l''enseigne'
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les enseignes du groupe Darties (flocon)';

DROP TABLE IF EXISTS dim_magasin CASCADE;
CREATE TABLE IF NOT EXISTS dim_magasin(
id_magasin INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant du magasin',
id_enseigne INT NOT NULL COMMENT 'Reference a l''enseigne du magasin',
actif VARCHAR(6) NOT NULL COMMENT 'statut d''activite du magasin',
date_ouverture TIMESTAMP NOT NULL default '2001-01-01 00:00:00'  COMMENT 'Date d''ouverture du magasin',
date_fermeture TIMESTAMP NULL DEFAULT NULL COMMENT 'Date de fermeture du magasin',
emplacements VARCHAR(32) COMMENT 'Emplacements - Elements d''adresse du magasin',
nb_caisses NUMERIC COMMENT 'Nombre de caisses dans le magasin',
ville VARCHAR(32) NOT NULL COMMENT 'Ville du magasin',
dep INT NOT NULL COMMENT 'Departement du magasin',
fichier_image_carte_magasin VARCHAR(20) NOT NULL COMMENT 'Nom du fichier image la carte du magasin',
date_maj TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de derniere mise a jour des donnees du magasin',
INDEX dim_magasin_d_fkey_idx (dep),
INDEX fk_dim_magasin_dim_enseigne1 (id_enseigne ASC) -- ,
-- CONSTRAINT fk_dim_magasin_dim_enseigne1 FOREIGN KEY (id_enseigne) references dim_enseigne (id_enseigne ) ,
-- CONSTRAINT dim_magasin_d_fkey FOREIGN KEY(dep) REFERENCES dim_departement(id_departement)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les magasins (flocon)';

DROP TABLE IF EXISTS dim_famille_produit CASCADE;
CREATE TABLE IF NOT EXISTS dim_famille_produit(
id_famille_produit INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant de la famille des produits',
lib_famille_produit VARCHAR(32) NOT NULL COMMENT 'Libelle de la famille des produits',
datemaj_famille TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de la derniere mise a jour des donnees de la famille de produit'
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les familles de produits (flocon)';

DROP TABLE IF EXISTS dim_categorie_produit CASCADE;
CREATE TABLE IF NOT EXISTS dim_categorie_produit(
id_categorie_produit INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant de la categorie de produit',
lib_categorie_produit VARCHAR(32) NOT NULL COMMENT 'Libelle de la categorie de produit',
fk_famille_produit INT NOT NULL COMMENT 'Cle etrangere vers la famille de produit',
datemaj_categorie TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de la derniere mise a jour des donnees de la categorie de produit',
INDEX dim_categorie_produit_f_fkey_idx (fk_famille_produit),
CONSTRAINT dim_categorie_produit_f_fkey FOREIGN KEY(fk_famille_produit) REFERENCES dim_famille_produit(id_famille_produit)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les categories de produits (flocon)';

DROP TABLE IF EXISTS dim_sous_categorie_produit CASCADE;
CREATE TABLE IF NOT EXISTS dim_sous_categorie_produit(
id_sous_categorie_produit INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant de la sous-categorie de produit',
lib_sous_categorie_produit VARCHAR(255) NOT NULL COMMENT 'Libelle de la sous-categorie de produit',
fk_categorie_produit INT NOT NULL COMMENT 'Cle etrangere vers la categorie de produit',
datemaj_sous_categorie TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de la derniere mise a jour des donnees de la sous categorie de produit',
INDEX dim_sous_categorie_produit_f_fkey_idx (fk_categorie_produit),
CONSTRAINT dim_sous_categorie_produit_f_fkey FOREIGN KEY(fk_categorie_produit) REFERENCES dim_categorie_produit(id_categorie_produit)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les sous-categories de produit (flocon)';

DROP TABLE IF EXISTS dim_produit CASCADE;
CREATE TABLE IF NOT EXISTS dim_produit(
id_produit INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant du produit',
libelle VARCHAR(255) NOT NULL COMMENT 'Libelle du produit',
description VARCHAR(255) NOT NULL COMMENT 'Description du produit',
en_vente BOOLEAN COMMENT 'Le produit  peut-il faire l''objet de facture aupres des clients ?',
en_achat BOOLEAN COMMENT 'Le produit  peut-il faire l''objet de commaudes aupres des fournisseurs ?',
fk_sous_categorie_produit INT NOT NULL COMMENT 'Cle etrangere vers la sous-categorie de produit',
date_maj TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de derniere mise a jour des donnees du produit',
INDEX dim_produit_f_fkey_idx (fk_sous_categorie_produit),
CONSTRAINT dim_produit_f_fkey FOREIGN KEY(fk_sous_categorie_produit) REFERENCES dim_sous_categorie_produit(id_sous_categorie_produit)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les produits du groupe Darties (flocon)';

DROP TABLE IF EXISTS faits_ventes CASCADE;
CREATE TABLE IF NOT EXISTS faits_ventes(
id_magasin INT NOT NULL  COMMENT 'Cle etrangere vers DIM_MAGASIN',
id_produit INT NOT NULL  COMMENT 'Cle etrangere vers DIM_PRODUIT',
id_temps VARCHAR(8) NOT NULL  COMMENT 'Cle etrangere vers DIM_TEMPS',
ventes_objectif INT COMMENT 'Objectif pour les ventes',
ventes_reel INT COMMENT 'Nombre de ventes realisees',
ca_objectif DECIMAL(15,2) COMMENT 'Objectif pour le chiffre d''affaires',
ca_reel DECIMAL(15,2) COMMENT 'Chiffre d''affaires realise',
marge_objectif DECIMAL(15,2) COMMENT 'Objectif pour la marge',
marge_reel DECIMAL(15,2) COMMENT 'Marge realisee en numeraire',
date_maj TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'date de derniere mise a jour des indicateurs',
CONSTRAINT faits_ventes_pkey PRIMARY KEY(id_magasin,id_produit,id_temps),
CONSTRAINT faits_ventes_ibfk_2 FOREIGN KEY (ID_MAGASIN) REFERENCES dim_magasin (ID_MAGASIN ),
INDEX faits_ventes_i1_fkey_idx (id_produit),
CONSTRAINT faits_ventes_i1_fkey FOREIGN KEY(id_produit) REFERENCES dim_produit(id_produit),
INDEX faits_ventes_i2_fkey_idx (id_temps),
CONSTRAINT faits_ventes_i2_fkey FOREIGN KEY(id_temps) REFERENCES dim_temps(id_temps)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les ventes du groupe Darties';

DROP TABLE IF EXISTS profil CASCADE;

CREATE TABLE IF NOT EXISTS profil(
id_profil INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant du profil',
lib_profil VARCHAR(50) NOT NULL COMMENT 'Libelle du profil',
type_zone INT COMMENT 'Type de la zone (zone commerciale, magasin) du profil',
id_zone INT COMMENT 'Identifiant de la zone concernee (zone commerciale ou magasin)  du profil',
username_bo VARCHAR(20) COMMENT 'Identifiant dans SAP Business Objects XI 3.1',
password_bo VARCHAR(20) COMMENT 'Mot de passe pour SAP BusinessObjects XI 3.1',
datemaj_profil TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'date de derniere mise a jour du profil'
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Autre table sur la securite du portail decisionnel';

DROP TABLE IF EXISTS securite CASCADE;
CREATE TABLE IF NOT EXISTS securite(
id_magasin INT NOT NULL COMMENT 'Visibilite des donnees du magasin',
id_profil INT NOT NULL COMMENT 'Visibilite du profil',
id_onglet INT NOT NULL COMMENT 'Selon l''onglet du tableau de bord, des informations peuvent etre necessaires',
datemaj_securite TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'date de derniere mise a jour de la securite',
PRIMARY KEY (id_magasin, id_profil, id_onglet),
INDEX securite_i1_fkey_idx (id_magasin),
CONSTRAINT securite_i1_fkey FOREIGN KEY(id_magasin) REFERENCES dim_magasin(id_magasin),
INDEX securite_i2_fkey_idx (id_profil),
CONSTRAINT securite_i2_fkey FOREIGN KEY(id_profil) REFERENCES profil(id_profil)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'La securite du portail decisionnel';

DROP TABLE IF EXISTS utilisateur CASCADE;
CREATE TABLE IF NOT EXISTS utilisateur(
id_utilisateur INT AUTO_INCREMENT PRIMARY KEY  COMMENT 'Identifiant de l''utilisateur',
nom VARCHAR(50) NOT NULL COMMENT 'Nom de l''utilisateur',
prenom VARCHAR(50) NOT NULL COMMENT 'Prenom  de l''utilisateur',
username VARCHAR(50) NOT NULL UNIQUE  COMMENT 'Login de l''utilisateur',
password VARCHAR(10) NOT NULL COMMENT 'Mot de passe de l''utilisateur',
mail VARCHAR(100) NOT NULL UNIQUE  COMMENT 'Adresse electronique de l''utilisateur',
id_profil INT NOT NULL UNIQUE COMMENT 'Reference au profil de l''utilisateur',
datemaj_utilisateur TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'date de derniere mise a jour de l''utilisateur',
INDEX utilisateur_i_fkey_idx (id_profil),
CONSTRAINT utilisateur_i_fkey FOREIGN KEY(id_profil) REFERENCES profil(id_profil)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COMMENT 'Les utilisateurs du portail decisionnel';
-- CREATE INDEX utilisateur_mail ON utilisateur(mail);
-- CREATE INDEX utilisateur_username ON utilisateur(username);
-- CREATE INDEX utilisateur_idprofil ON utilisateur(id_profil);

DROP TABLE IF EXISTS dwr_faits_ventes_star;
DROP TABLE IF EXISTS securite_star ;
DROP TABLE IF EXISTS faits_ventes_star;
DROP TABLE IF EXISTS dim_magasin_star ;
DROP TABLE IF EXISTS dim_produit_star ;


CREATE TABLE dim_magasin_star ENGINE=InnoDB DEFAULT CHARACTER SET = UTF8MB4 COMMENT ='Les magasins (etoile)' AS
SELECT DISTINCT id_magasin,
    actif,
    date_ouverture ,
    date_fermeture ,
    emplacements ,
    nb_caisses ,
    ville ,
    fichier_image_carte_magasin ,
    date_maj ,
  dim_enseigne.id_enseigne,
  lib_enseigne,
    fichier_image_logo_enseigne,
    datemaj_enseigne,
  id_departement,
    code_departement,
    lib_departement ,
    datemaj_dep,
    anc_admin.id_region_admin as id_region_anc_admin,
    anc_admin.lib_region_admin as lib_region_anc_admin,
    anc_admin.date_debut_valid_admin as date_debut_valid_anc_admin,
    anc_admin.date_fin_valid_admin as date_fin_valid_anc_admin,
    anc_admin.fichier_image_carte_regadm as fichier_img_anc_reg_admin,
    anc_admin.sas_map_id as sas_map_id_anc_reg_admin,
    anc_admin.sas_map_name as sas_map_name_anc_reg_admin,
    anc_admin.datemaj_geo_admin as datemaj_geo_anc_reg_admin,
  nouv_admin.id_region_admin as id_region_nouv_admin,
    nouv_admin.lib_region_admin as lib_region_nouv_admin,
    nouv_admin.date_debut_valid_admin as date_debut_valid_nouv_admin,
    nouv_admin.date_fin_valid_admin as date_fin_valid_nouv_admin,
    nouv_admin.fichier_image_carte_regadm as fichier_img_nouv_reg_admin,
    nouv_admin.sas_map_id as sas_map_id_nouv_reg_admin,
    nouv_admin.sas_map_name as sas_map_name_nouv_reg_admin,
    nouv_admin.datemaj_geo_admin as datemaj_geo_nouv_reg_admin,   
  dim_geographique_com.id_region_com,
    lib_region_com,
    date_debut_valid_com ,
    date_fin_valid_com ,
    fichier_image_carte_regcom,
    datemaj_geo_com,
    dim_pays.id_pays,
    lib_pays,
    iso_3166_1_numeric,
    iso_3166_alpha_2,
    fichier_image_carte_pays,
    datemaj_pays
  from dim_magasin, dim_enseigne, dim_departement, dim_geographique_com, dim_geographique_admin anc_admin, dim_geographique_admin nouv_admin, dim_pays
  where dim_magasin.id_enseigne=dim_enseigne.id_enseigne
  and dim_departement.id_departement=dim_magasin.dep
  and dim_geographique_com.id_region_com=dim_departement.id_region_com
  and anc_admin.id_region_admin=id_region_admin1
  and nouv_admin.id_region_admin=id_region_admin2
  and dim_geographique_com.id_pays=dim_pays.id_pays
  ;


ALTER TABLE dim_magasin_star ADD CONSTRAINT PK_dim_magasin_star PRIMARY KEY (ID_MAGASIN);
/*
-- CREATE TABLE AS reprend les commentaires des tables interrogees
   COMMENT ON COLUMN "dim_magasin_star"...
   */
   


CREATE TABLE dim_produit_star ENGINE=InnoDB DEFAULT CHARACTER SET = UTF8MB4 COMMENT ='Les produits (etoile)' AS
SELECT DISTINCT
id_produit,libelle,description,en_vente,en_achat,date_maj,
id_sous_categorie_produit,lib_sous_categorie_produit,datemaj_sous_categorie,
id_categorie_produit,lib_categorie_produit,datemaj_categorie,
id_famille_produit,lib_famille_produit,datemaj_famille
FROM dim_produit
INNER JOIN dim_sous_categorie_produit
ON fk_sous_categorie_produit=id_sous_categorie_produit
INNER JOIN dim_categorie_produit
ON fk_categorie_produit=id_categorie_produit
INNER JOIN dim_famille_produit
ON fk_famille_produit=id_famille_produit
;

ALTER TABLE dim_produit_star ADD CONSTRAINT PK_dim_produit_star PRIMARY KEY (ID_PRODUIT);


CREATE TABLE faits_ventes_star ENGINE=InnoDB DEFAULT CHARACTER SET = UTF8MB4 COMMENT = 'Fait ventes (etoile)' AS
SELECT * FROM faits_ventes;

/*
-- CREATE TABLE AS reprend les commentaires des tables interrogees
   COMMENT ON COLUMN "faits_ventes_star"...;
*/  

--  CREATE UNIQUE INDEX "PK_faits_ventes_star" ON "faits_ventes_star" ("ID_MAGASIN", "ID_FAMILLE_PRODUIT", "ID_TEMPS")  ;


ALTER TABLE faits_ventes_star ADD CONSTRAINT PK_faits_ventes_star PRIMARY KEY (ID_MAGASIN, ID_PRODUIT, ID_TEMPS);


ALTER TABLE faits_ventes_star ADD CONSTRAINT FK_faits_ventes_STAR_DIM_PRODUIT FOREIGN KEY (ID_PRODUIT)
      REFERENCES dim_produit_star (ID_PRODUIT);
ALTER TABLE faits_ventes_star ADD CONSTRAINT FK_faits_ventes_SR_dim_magasin FOREIGN KEY (ID_MAGASIN)
      REFERENCES dim_magasin_star (ID_MAGASIN);
ALTER TABLE faits_ventes_star ADD CONSTRAINT FK_faits_ventes_star_DIM_TEMPS FOREIGN KEY (ID_TEMPS)
      REFERENCES dim_temps (ID_TEMPS);



CREATE TABLE securite_star ENGINE=InnoDB DEFAULT CHARACTER SET = UTF8MB4 COMMENT = 'Visibilite en fonction du profil (etoile)' AS
SELECT * FROM securite;

ALTER TABLE securite_star ADD CONSTRAINT PK_securite_star PRIMARY KEY (ID_PROFIL, ID_MAGASIN, ID_ONGLET) ;

/*
-- CREATE TABLE AS reprend les commentaires des tables interrogees
 
   COMMENT ON COLUMN "securite_star"...;
*/

CREATE INDEX securite_star_i1_fkey_idx ON securite_star (id_magasin ASC);
ALTER TABLE securite_star ADD CONSTRAINT securite_star_i1_fkey FOREIGN KEY (id_magasin)
      REFERENCES dim_magasin_star(id_magasin);
ALTER TABLE securite_star ADD CONSTRAINT securite_star_i2_fkey FOREIGN KEY (ID_PROFIL)
      REFERENCES profil (ID_PROFIL);

CREATE TABLE IF NOT EXISTS dwr_faits_ventes_star ENGINE=InnoDB DEFAULT CHARACTER SET = UTF8MB4 COMMENT ='Analyse croisee des faits (etoile)' AS
    select id_magasin , id_produit , id_temps , 'ventes' as indicateur , sum(ventes_objectif) as objectif , sum(ventes_reel)as reel,null as date_maj
    from faits_ventes_star
    group by id_magasin , id_produit , id_temps, date_maj
    union all
    select id_magasin , id_produit , id_temps , 'ca' as indicateur , sum(ca_objectif) as objectif , sum(ca_reel)as reel,null as date_maj
    from faits_ventes_star
    group by id_magasin , id_produit , id_temps , date_maj
    union all
    select id_magasin , id_produit , id_temps , 'marge' as indicateur , avg(marge_objectif) as objectif , avg(marge_reel) as reel,null as date_maj
    from faits_ventes_star
    group by id_magasin , id_produit , id_temps , date_maj
    order by 1,2,3,4
;
ALTER TABLE dwr_faits_ventes_star ADD CONSTRAINT PK_dwr_faits_ventes_star PRIMARY KEY (ID_MAGASIN , ID_PRODUIT , ID_TEMPS ,INDICATEUR);
ALTER TABLE dwr_faits_ventes_star MODIFY id_magasin int(11) NOT NULL DEFAULT '0' COMMENT 'Identifiant du magasin';
ALTER TABLE dwr_faits_ventes_star MODIFY id_produit int(11) NOT NULL DEFAULT '0' COMMENT 'Identifiant du produit';
ALTER TABLE dwr_faits_ventes_star MODIFY id_temps varchar(8) NOT NULL DEFAULT '' COMMENT 'Identifiant du temps';
ALTER TABLE dwr_faits_ventes_star MODIFY indicateur varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Indicateur à afficher';
ALTER TABLE dwr_faits_ventes_star MODIFY objectif decimal(36,4) DEFAULT NULL COMMENT 'Valeur de l''objectif de l''indicateur';
ALTER TABLE dwr_faits_ventes_star MODIFY reel decimal(36,4) DEFAULT NULL COMMENT 'Valeur du realise de l''indicateur';
ALTER TABLE dwr_faits_ventes_star MODIFY date_maj TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT 'Date de la dernière mise à jour des donnees';

-- Vous n'avez pas le droit de manipuler des procédures sur le serveur de production
DELIMITER ;
DROP PROCEDURE IF EXISTS maj_dim_magasin_star;
DELIMITER |
CREATE PROCEDURE maj_dim_magasin_star()
BEGIN
    ALTER TABLE faits_ventes_star DROP FOREIGN KEY FK_faits_ventes_SR_dim_magasin;
    ALTER TABLE securite_star DROP FOREIGN KEY securite_star_i1_fkey ;
    TRUNCATE dim_magasin_star;
    ALTER TABLE faits_ventes_star ADD CONSTRAINT FK_faits_ventes_SR_dim_magasin FOREIGN KEY (ID_MAGASIN)
      REFERENCES dim_magasin_star (ID_MAGASIN);
    ALTER TABLE securite_star ADD CONSTRAINT securite_star_i1_fkey FOREIGN KEY (id_magasin)
      REFERENCES dim_magasin_star(id_magasin);
    INSERT INTO dim_magasin_star
SELECT DISTINCT id_magasin,
    actif,
    date_ouverture ,
    date_fermeture ,
    emplacements ,
    nb_caisses ,
    ville ,
    fichier_image_carte_magasin ,
    date_maj ,
  dim_enseigne.id_enseigne,
  lib_enseigne,
    fichier_image_logo_enseigne,
    datemaj_enseigne,
  id_departement,
    code_departement,
    lib_departement ,
    datemaj_dep,
    anc_admin.id_region_admin as id_region_anc_admin,
    anc_admin.lib_region_admin as lib_region_anc_admin,
    anc_admin.date_debut_valid_admin as date_debut_valid_anc_admin,
    anc_admin.date_fin_valid_admin as date_fin_valid_anc_admin,
    anc_admin.fichier_image_carte_regadm as fichier_img_anc_reg_admin,
    anc_admin.sas_map_id as sas_map_id_anc_reg_admin,
    anc_admin.sas_map_name as sas_map_name_anc_reg_admin,
    anc_admin.datemaj_geo_admin as datemaj_geo_anc_reg_admin,
  nouv_admin.id_region_admin as id_region_nouv_admin,
    nouv_admin.lib_region_admin as lib_region_nouv_admin,
    nouv_admin.date_debut_valid_admin as date_debut_valid_nouv_admin,
    nouv_admin.date_fin_valid_admin as date_fin_valid_nouv_admin,
    nouv_admin.fichier_image_carte_regadm as fichier_img_nouv_reg_admin,
    nouv_admin.sas_map_id as sas_map_id_nouv_reg_admin,
    nouv_admin.sas_map_name as sas_map_name_nouv_reg_admin,
    nouv_admin.datemaj_geo_admin as datemaj_geo_nouv_reg_admin,   
  dim_geographique_com.id_region_com,
    lib_region_com,
    date_debut_valid_com ,
    date_fin_valid_com ,
    fichier_image_carte_regcom,
    datemaj_geo_com,
    dim_pays.id_pays,
    lib_pays,
    iso_3166_1_numeric,
    iso_3166_alpha_2,
    fichier_image_carte_pays,
    datemaj_pays
  from dim_magasin, dim_enseigne, dim_departement, dim_geographique_com, dim_geographique_admin anc_admin, dim_geographique_admin nouv_admin, dim_pays
  where dim_magasin.id_enseigne=dim_enseigne.id_enseigne
  and dim_departement.id_departement=dim_magasin.dep
  and dim_geographique_com.id_region_com=dim_departement.id_region_com
  and anc_admin.id_region_admin=id_region_admin1
  and nouv_admin.id_region_admin=id_region_admin2
  and dim_geographique_com.id_pays=dim_pays.id_pays
  ;
END |
DELIMITER ;
DROP PROCEDURE IF EXISTS maj_dim_produit_star;
DELIMITER |
CREATE PROCEDURE maj_dim_produit_star()
BEGIN
    ALTER TABLE faits_ventes_star DROP FOREIGN KEY FK_faits_ventes_STAR_DIM_PRODUIT;
    TRUNCATE dim_produit_star;
    ALTER TABLE faits_ventes_star ADD CONSTRAINT FK_faits_ventes_STAR_DIM_PRODUIT FOREIGN KEY (ID_PRODUIT)
      REFERENCES dim_produit_star (ID_PRODUIT);
    INSERT INTO dim_produit_star
    SELECT DISTINCT
    id_produit,libelle,description,en_vente,en_achat,date_maj,
    id_sous_categorie_produit,lib_sous_categorie_produit,datemaj_sous_categorie,
    id_categorie_produit,lib_categorie_produit,datemaj_categorie,
    id_famille_produit,lib_famille_produit,datemaj_famille
    FROM dim_produit
    INNER JOIN dim_sous_categorie_produit
    ON fk_sous_categorie_produit=id_sous_categorie_produit
    INNER JOIN dim_categorie_produit
    ON fk_categorie_produit=id_categorie_produit
    INNER JOIN dim_famille_produit
    ON fk_famille_produit=id_famille_produit
    ;
END |
DELIMITER ;
DROP PROCEDURE IF EXISTS maj_faits_ventes_star;
DELIMITER |
CREATE PROCEDURE maj_faits_ventes_star()
BEGIN
    TRUNCATE faits_ventes_star;
    INSERT INTO faits_ventes_star
    SELECT * FROM faits_ventes;
END |
DELIMITER ;
DROP PROCEDURE IF EXISTS maj_securite_star;
DELIMITER |
CREATE PROCEDURE maj_securite_star()
BEGIN
    TRUNCATE securite_star;
    INSERT INTO securite_star
    SELECT * FROM securite;
END |
DELIMITER ;
DROP PROCEDURE IF EXISTS maj_dwr_faits_ventes_star;
DELIMITER |
CREATE PROCEDURE maj_dwr_faits_ventes_star()

COMMENT 'Refresh pivoted data like a materialized view'
BEGIN
    TRUNCATE dwr_faits_ventes_star;
    INSERT INTO dwr_faits_ventes_star
    SELECT ID_MAGASIN , ID_PRODUIT , ID_TEMPS , 'VENTES' AS INDICATEUR , SUM(VENTES_OBJECTIF) AS OBJECTIF , SUM(VENTES_REEL)AS REEL,NULL AS DATE_MAJ
    FROM faits_ventes_star

    WHERE id_temps LIKE CONCAT(CAST(YEAR(NOW()) as char),'%') COLLATE utf8mb4_0900_ai_ci

    GROUP BY ID_MAGASIN , ID_PRODUIT , ID_TEMPS, DATE_MAJ
    UNION ALL
    SELECT ID_MAGASIN , ID_PRODUIT , ID_TEMPS , 'CA' AS INDICATEUR , SUM(CA_OBJECTIF) AS OBJECTIF , SUM(CA_REEL)AS REEL,NULL AS DATE_MAJ
    FROM faits_ventes_star
    WHERE id_temps LIKE CONCAT(CAST(YEAR(NOW()) as char),'%') COLLATE utf8mb4_0900_ai_ci

    GROUP BY ID_MAGASIN , ID_PRODUIT , ID_TEMPS , DATE_MAJ
    UNION ALL
    SELECT ID_MAGASIN , ID_PRODUIT , ID_TEMPS , 'MARGE' AS INDICATEUR , AVG(MARGE_OBJECTIF) AS OBJECTIF , AVG(MARGE_REEL) AS REEL,NULL AS DATE_MAJ
    FROM faits_ventes_star

    WHERE id_temps LIKE CONCAT(CAST(YEAR(NOW()) as char),'%') COLLATE utf8mb4_0900_ai_ci
    GROUP BY ID_MAGASIN , ID_PRODUIT , ID_TEMPS , DATE_MAJ
    ORDER by 1,2,3,4
    ;
END |

DELIMITER ;
CALL maj_dim_magasin_star();
CALL maj_dim_produit_star();
CALL maj_faits_ventes_star();
CALL maj_securite_star();
CALL maj_dwr_faits_ventes_star();
CALL maj_vues_materialises();

-- vous n'avez pas le droit de créer une vue sur le serveur de production
CREATE OR REPLACE VIEW select_temps AS
SELECT CONCAT( cast( YEAR( NOW( ) ) AS char ) , '_1_', cast( YEAR( NOW( ) ) AS char ) ) COLLATE utf8mb4_0900_ai_ci AS CODE_TEMPS, cast( YEAR( NOW( ) ) AS char ) COLLATE utf8mb4_0900_ai_ci AS LIB_TEMPS, 19 AS ORDRE
UNION ALL
SELECT CONCAT(ANNEE,'_4_',MOIS),CONCAT(' ',LIB_MOIS,' (',ANNEE,')'),MOIS from dim_temps
WHERE ANNEE=YEAR(NOW()) AND CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad(MOIS, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
UNION ALL
SELECT DISTINCT CONCAT(ANNEE,'_3_',TRIMESTRE),CONCAT(' Trimestre ',TRIMESTRE,' (',ANNEE,')'),12+TRIMESTRE from dim_temps
WHERE ANNEE=YEAR(NOW()) AND (CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((TRIMESTRE-1)*3+1, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((TRIMESTRE-1)*3+2, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((TRIMESTRE-1)*3+3, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
)
UNION ALL
SELECT DISTINCT CONCAT(ANNEE,'_2_',SEMESTRE),CONCAT(' Semestre ',SEMESTRE,' (',ANNEE,')'),16+SEMESTRE from dim_temps
WHERE ANNEE=YEAR(NOW()) AND (CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((SEMESTRE-1)*6+1, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((SEMESTRE-1)*6+2, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((SEMESTRE-1)*6+3, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((SEMESTRE-1)*6+4, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((SEMESTRE-1)*6+5, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) ) AS char ),lpad((SEMESTRE-1)*6+6, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
)
UNION ALL
SELECT CONCAT( cast( YEAR( NOW( ) )-1 AS char ) , '_1_', cast( YEAR( NOW( ) )-1 AS char ) ) AS CODE_TEMPS, cast( YEAR( NOW( ) )-1 AS char ) AS LIB_TEMPS, 39 AS ORDRE
UNION ALL
SELECT CONCAT(ANNEE,'_4_',MOIS),CONCAT(' ',LIB_MOIS,' (',ANNEE,')'),20+MOIS from dim_temps
WHERE ANNEE=YEAR(NOW())-1 AND CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad(MOIS, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
UNION ALL
SELECT DISTINCT CONCAT(ANNEE,'_3_',TRIMESTRE),CONCAT(' Trimestre ',TRIMESTRE,' (',ANNEE,')'),32+TRIMESTRE from dim_temps
WHERE ANNEE=YEAR(NOW())-1 AND (CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((TRIMESTRE-1)*3+1, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((TRIMESTRE-1)*3+2, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((TRIMESTRE-1)*3+3, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
)
UNION ALL
SELECT DISTINCT CONCAT(ANNEE,'_2_',SEMESTRE),CONCAT(' Semestre ',SEMESTRE,' (',ANNEE,')'),36+SEMESTRE from dim_temps
WHERE ANNEE=YEAR(NOW())-1 AND (CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((SEMESTRE-1)*6+1, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((SEMESTRE-1)*6+2, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((SEMESTRE-1)*6+3, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((SEMESTRE-1)*6+4, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((SEMESTRE-1)*6+5, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-1 AS char ),lpad((SEMESTRE-1)*6+6, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
)
UNION ALL
SELECT CONCAT( cast( YEAR( NOW( ) )-2 AS char ) , '_1_', cast( YEAR( NOW( ) )-2 AS char ) ) AS CODE_TEMPS, cast( YEAR( NOW( ) )-2 AS char ) AS LIB_TEMPS, 59 AS ORDRE
UNION ALL
SELECT CONCAT(ANNEE,'_4_',MOIS),CONCAT(' ',LIB_MOIS,' (',ANNEE,')'),40+MOIS from dim_temps
WHERE ANNEE=YEAR(NOW())-2 AND CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad(MOIS, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
UNION ALL
SELECT DISTINCT CONCAT(ANNEE,'_3_',TRIMESTRE),CONCAT(' Trimestre ',TRIMESTRE,' (',ANNEE,')'),52+TRIMESTRE from dim_temps
WHERE ANNEE=YEAR(NOW())-2 AND (CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((TRIMESTRE-1)*3+1, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((TRIMESTRE-1)*3+2, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((TRIMESTRE-1)*3+3, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
)
UNION ALL
SELECT DISTINCT CONCAT(ANNEE,'_2_',SEMESTRE),CONCAT(' Semestre ',SEMESTRE,' (',ANNEE,')'),56+SEMESTRE from dim_temps
WHERE ANNEE=YEAR(NOW())-2 AND (CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((SEMESTRE-1)*6+1, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((SEMESTRE-1)*6+2, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((SEMESTRE-1)*6+3, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((SEMESTRE-1)*6+4, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((SEMESTRE-1)*6+5, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-2 AS char ),lpad((SEMESTRE-1)*6+6, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
)
UNION ALL
SELECT CONCAT( cast( YEAR( NOW( ) )-3 AS char ) , '_1_', cast( YEAR( NOW( ) )-3 AS char ) ) AS CODE_TEMPS, cast( YEAR( NOW( ) )-3 AS char ) AS LIB_TEMPS, 79 AS ORDRE
UNION ALL
SELECT CONCAT(ANNEE,'_4_',MOIS),CONCAT(' ',LIB_MOIS,' (',ANNEE,')'),60+MOIS from dim_temps
WHERE ANNEE=YEAR(NOW())-3 AND CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad(MOIS, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
UNION ALL
SELECT DISTINCT CONCAT(ANNEE,'_3_',TRIMESTRE),CONCAT(' Trimestre ',TRIMESTRE,' (',ANNEE,')'),72+TRIMESTRE from dim_temps
WHERE ANNEE=YEAR(NOW())-3 AND (CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((TRIMESTRE-1)*3+1, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((TRIMESTRE-1)*3+2, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((TRIMESTRE-1)*3+3, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
)
UNION ALL
SELECT DISTINCT CONCAT(ANNEE,'_2_',SEMESTRE),CONCAT(' Semestre ',SEMESTRE,' (',ANNEE,')'),76+SEMESTRE from dim_temps
WHERE ANNEE=YEAR(NOW())-3 AND (CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((SEMESTRE-1)*6+1, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((SEMESTRE-1)*6+2, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((SEMESTRE-1)*6+3, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((SEMESTRE-1)*6+4, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((SEMESTRE-1)*6+5, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
OR CONCAT( cast( YEAR( NOW( ) )-3 AS char ),lpad((SEMESTRE-1)*6+6, 2, 0)) IN (SELECT DISTINCT ID_TEMPS FROM faits_ventes_star where CA_REEL is not null)
)
ORDER BY 3;
;

INSERT INTO dim_magasin VALUES(1,2,'Oui','2000-01-01',NULL,'ZAC',16,'Alencon',32,'alencon ','2015-01-05');
INSERT INTO dim_magasin VALUES(2,3,'Oui','2000-01-01',NULL,'Centre_Ville',14,'Amiens',33,'amiens ','2015-01-05');
INSERT INTO dim_magasin VALUES(3,1,'Oui','2000-01-01',NULL,'Centre_Ville',13,'Angers',34,'angers ','2015-01-05');
INSERT INTO dim_magasin VALUES(4,2,'Oui','2000-01-01',NULL,'ZAC',16,'Angouleme',24,'angouleme ','2015-01-05');
INSERT INTO dim_magasin VALUES(5,3,'Oui','2000-01-01',NULL,'ZAC',16,'Arras',10,'arras ','2015-01-05');
INSERT INTO dim_magasin VALUES(6,1,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Bastia',35,'bastia ','2015-01-05');
INSERT INTO dim_magasin VALUES(7,2,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Besancon',1,'besancon ','2015-01-05');
INSERT INTO dim_magasin VALUES(8,2,'Oui','2000-01-01',NULL,'ZAC',16,'Bobigny',25,'bobigny ','2015-01-05');
INSERT INTO dim_magasin VALUES(9,3,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Bordeaux',5,'bordeaux','2015-01-05');
INSERT INTO dim_magasin VALUES(10,1,'Oui','2000-01-01',NULL,'ZAC',15,'Bourges',21,'bourges ','2015-01-05');
INSERT INTO dim_magasin VALUES(11,2,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Carcassonne',36,'carcassonne ','2015-01-05');
INSERT INTO dim_magasin VALUES(12,3,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Cergy',26,'cergy ','2015-01-05');
INSERT INTO dim_magasin VALUES(13,1,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Chambery',17,'chambery ','2015-01-05');
INSERT INTO dim_magasin VALUES(14,2,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Clermont-Ferrand',37,'clermont-ferrand ','2015-01-05');
INSERT INTO dim_magasin VALUES(15,2,'Oui','2000-01-01',NULL,'Centre_Ville',14,'Creteil',38,'creteil ','2015-01-05');
INSERT INTO dim_magasin VALUES(16,3,'Oui','2000-01-01',NULL,'ZAC',16,'Digne',11,'digne ','2015-01-05');
INSERT INTO dim_magasin VALUES(17,1,'Oui','2000-01-01',NULL,'Centre_Ville',13,'Dijon',39,'dijon ','2015-01-05');
INSERT INTO dim_magasin VALUES(18,2,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Evry',40,'evry ','2015-01-05');
INSERT INTO dim_magasin VALUES(19,3,'Oui','2000-01-01',NULL,'ZAC',14,'Foix',12,'foix ','2015-01-05');
INSERT INTO dim_magasin VALUES(20,1,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Grenoble',13,'grenoble ','2015-01-05');
INSERT INTO dim_magasin VALUES(21,2,'Oui','2000-01-01',NULL,'ZAC',16,'Lille',41,'lille ','2015-01-05');
INSERT INTO dim_magasin VALUES(22,2,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Limoges',14,'limoges ','2015-01-05');
INSERT INTO dim_magasin VALUES(23,2,'Oui','2000-01-01',NULL,'ZAC',15,'Lyon',45,'lyon ','2015-01-05');
INSERT INTO dim_magasin VALUES(24,3,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Marseille',46,'marseille ','2015-01-05');
INSERT INTO dim_magasin VALUES(25,1,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Melun',6,'melun ','2015-01-05');
INSERT INTO dim_magasin VALUES(26,2,'Oui','2000-01-01',NULL,'Centre_Ville',13,'Metz',2,'metz ','2015-01-05');
INSERT INTO dim_magasin VALUES(27,1,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Nancy',42,'nancy ','2015-01-05');
INSERT INTO dim_magasin VALUES(28,2,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Nanterre',18,'nanterre ','2015-01-05');
INSERT INTO dim_magasin VALUES(29,2,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Nantes',7,'nantes ','2015-01-05');
INSERT INTO dim_magasin VALUES(30,3,'Oui','2000-01-01',NULL,'ZAC',16,'Nice',19,'nice ','2015-01-05');
INSERT INTO dim_magasin VALUES(31,3,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Nimes',3,'nimes ','2015-01-05');
INSERT INTO dim_magasin VALUES(32,2,'Oui','2000-01-01',NULL,'ZAC',13,'Paris-Sud',43,'paris-sud ','2015-01-05');
INSERT INTO dim_magasin VALUES(33,3,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Paris-Nord',43,'paris-nord ','2015-01-05');
INSERT INTO dim_magasin VALUES(34,2,'Oui','2000-01-01',NULL,'ZAC',16,'Pau',20,'pau ','2015-01-05');
INSERT INTO dim_magasin VALUES(35,1,'Oui','2000-01-01',NULL,'Centre_Ville',13,'Perigueux',15,'perigueux ','2015-01-05');
INSERT INTO dim_magasin VALUES(36,3,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Quimper',27,'quimper ','2015-01-05');
INSERT INTO dim_magasin VALUES(37,1,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Rodez',4,'rodez ','2015-01-05');
INSERT INTO dim_magasin VALUES(38,2,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Rouen',8,'rouen ','2015-01-05');
INSERT INTO dim_magasin VALUES(39,3,'Oui','2000-01-01',NULL,'ZAC',16,'Saint-Brieuc',16,'saint-brieuc ','2015-01-05');
INSERT INTO dim_magasin VALUES(40,1,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Saint-Etienne',22,'saint-etienne ','2015-01-05');
INSERT INTO dim_magasin VALUES(41,2,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Strasbourg',44,'strasbourg ','2015-01-05');
INSERT INTO dim_magasin VALUES(42,2,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Tarbes',23,'tarbes ','2015-01-05');
INSERT INTO dim_magasin VALUES(43,3,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Toulon',28,'toulon ','2015-01-05');
INSERT INTO dim_magasin VALUES(44,1,'Oui','2000-01-01',NULL,'Centre_Ville',15,'Tours',29,'tours ','2015-01-05');
INSERT INTO dim_magasin VALUES(45,2,'Oui','2000-01-01',NULL,'Centre_Ville',16,'Troyes',30,'troyes ','2015-01-05');
INSERT INTO dim_magasin VALUES(46,3,'Oui','2000-01-01',NULL,'ZAC',16,'Valence',9,'valence ','2015-01-05');
INSERT INTO dim_magasin VALUES(47,1,'Oui','2000-01-01',NULL,'ZAC',16,'Valenciennes',41,'valenciennes ','2015-01-05');
INSERT INTO dim_magasin VALUES(48,2,'Oui','2000-01-01',NULL,'ZAC',14,'Versailles',31,'versailles ','2015-01-05');

INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201801',1,'janvier',1,1,2018);

INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201802',2,'février',1,1,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201803',3,'mars',1,1,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201804',4,'avril',2,1,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201805',5,'mai',2,1,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201806',6,'juin',2,1,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201807',7,'juillet',3,2,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201808',8,'août',3,2,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201809',9,'septembre',3,2,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201810',10,'octobre',4,2,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201811',11,'novembre',4,2,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201812',12,'décembre',4,2,2018);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201901',1,'janvier',1,1,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201902',2,'février',1,1,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201903',3,'mars',1,1,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201904',4,'avril',2,1,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201905',5,'mai',2,1,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201906',6,'juin',2,1,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201907',7,'juillet',3,2,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201908',8,'août',3,2,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201909',9,'septembre',3,2,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201910',10,'octobre',4,2,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201911',11,'novembre',4,2,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('201912',12,'décembre',4,2,2019);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202001',1,'janvier',1,1,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202002',2,'février',1,1,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202003',3,'mars',1,1,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202004',4,'avril',2,1,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202005',5,'mai',2,1,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202006',6,'juin',2,1,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202007',7,'juillet',3,2,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202008',8,'août',3,2,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202009',9,'septembre',3,2,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202010',10,'octobre',4,2,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202011',11,'novembre',4,2,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202012',12,'décembre',4,2,2020);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202101',1,'janvier',1,1,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202102',2,'février',1,1,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202103',3,'mars',1,1,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202104',4,'avril',2,1,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202105',5,'mai',2,1,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202106',6,'juin',2,1,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202107',7,'juillet',3,2,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202108',8,'août',3,2,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202109',9,'septembre',3,2,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202110',10,'octobre',4,2,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202111',11,'novembre',4,2,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202112',12,'décembre',4,2,2021);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202201',1,'janvier',1,1,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202202',2,'février',1,1,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202203',3,'mars',1,1,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202204',4,'avril',2,1,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202205',5,'mai',2,1,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202206',6,'juin',2,1,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202207',7,'juillet',3,2,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202208',8,'août',3,2,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202209',9,'septembre',3,2,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202210',10,'octobre',4,2,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202211',11,'novembre',4,2,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202212',12,'décembre',4,2,2022);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202301',1,'janvier',1,1,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202302',2,'février',1,1,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202303',3,'mars',1,1,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202304',4,'avril',2,1,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202305',5,'mai',2,1,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202306',6,'juin',2,1,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202307',7,'juillet',3,2,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202308',8,'août',3,2,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202309',9,'septembre',3,2,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202310',10,'octobre',4,2,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202311',11,'novembre',4,2,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202312',12,'décembre',4,2,2023);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202401',1,'janvier',1,1,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202402',2,'février',1,1,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202403',3,'mars',1,1,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202404',4,'avril',2,1,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202405',5,'mai',2,1,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202406',6,'juin',2,1,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202407',7,'juillet',3,2,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202408',8,'août',3,2,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202409',9,'septembre',3,2,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202410',10,'octobre',4,2,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202411',11,'novembre',4,2,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202412',12,'décembre',4,2,2024);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202501',1,'janvier',1,1,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202502',2,'février',1,1,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202503',3,'mars',1,1,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202504',4,'avril',2,1,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202505',5,'mai',2,1,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202506',6,'juin',2,1,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202507',7,'juillet',3,2,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202508',8,'août',3,2,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202509',9,'septembre',3,2,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202510',10,'octobre',4,2,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202511',11,'novembre',4,2,2025);
INSERT INTO dim_temps(id_temps,mois,lib_mois,trimestre,semestre,annee) VALUES('202512',12,'décembre',4,2,2025);

INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(1,'Administrateur',NULL,NULL,'etudiant01','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(2,'Directeur commercial',3,NULL,'etudiant02','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(3,'Directeur Alencon',2,1,'etudiant08','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(4,'Directeur Amiens',2,2,'etudiant09','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(5,'Directeur Angers',2,3,'etudiant10','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(6,'Directeur Angouleme',2,4,'etudiant11','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(7,'Directeur Arras',2,5,'etudiant12','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(8,'Directeur Bastia',2,6,'etudiant13','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(9,'Directeur Besancon',2,7,'etudiant14','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(10,'Directeur Bobigny',2,8,'etudiant15','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(11,'Directeur Bordeaux',2,9,'etudiant16','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(12,'Directeur Bourges',2,10,'etudiant17','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(13,'Directeur Carcassonne',2,11,'etudiant18','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(14,'Directeur Cergy',2,12,'etudiant19','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(15,'Directeur Chambery',2,13,'etudiant20','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(16,'Directeur Clermont-Ferrand',2,14,'etudiant21','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(17,'Directeur Creteil',2,15,'etudiant22','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(18,'Directeur Digne',2,16,'etudiant23','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(19,'Directeur Dijon',2,17,'etudiant24','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(20,'Directeur Evry',2,18,'etudiant25','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(21,'Directeur Foix',2,19,'etudiant26','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(22,'Directeur Grenoble',2,20,'etudiant27','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(23,'Directeur Lille',2,21,'etudiant28','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(24,'Directeur Limoges',2,22,'etudiant29','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(25,'Directeur Lyon',2,23,'etudiant30','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(26,'Directeur Marseille',2,24,'etudiant31','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(27,'Directeur Melun',2,25,'etudiant32','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(28,'Directeur Metz',2,26,'etudiant33','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(29,'Directeur Nancy',2,27,'etudiant34','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(30,'Directeur Nanterre',2,28,'etudiant35','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(31,'Directeur Nantes',2,29,'etudiant36','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(32,'Directeur Nice',2,30,'etudiant37','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(33,'Directeur Nimes',2,31,'etudiant38','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(34,'Directeur Nord_Est',1,2,'etudiant04','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(35,'Directeur Nord_Ouest',1,1,'etudiant03','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(36,'Directeur Paris-Sud',2,32,'etudiant39','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(37,'Directeur Paris-Nord',2,33,'etudiant40','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(38,'Directeur Pau',2,34,'etudiant41','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(39,'Directeur Perigueux',2,35,'etudiant42','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(40,'Directeur Quimper',2,36,'etudiant43','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(41,'Directeur Rodez',2,37,'etudiant44','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(42,'Directeur Rouen',2,38,'etudiant45','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(43,'Directeur Région_parisienne',1,5,'etudiant07','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(44,'Directeur Saint-Brieuc',2,39,'etudiant46','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(45,'Directeur Saint-Etienne',2,40,'etudiant47','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(46,'Directeur Strasbourg',2,41,'etudiant48','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(47,'Directeur Sud_Est',1,4,'etudiant06','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(48,'Directeur Sud_Ouest',1,3,'etudiant05','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(49,'Directeur Tarbes',2,42,'etudiant49','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(50,'Directeur Toulon',2,43,'etudiant50','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(51,'Directeur Tours',2,44,'etudiant51','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(52,'Directeur Troyes',2,45,'etudiant52','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(53,'Directeur Valence',2,46,'etudiant53','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(54,'Directeur Valenciennes',2,47,'etudiant54','P@ssw0rd');
INSERT INTO profil(id_profil,lib_profil,type_zone,id_zone,username_bo,password_bo) VALUES(55,'Directeur Versailles',2,48,'etudiant55','P@ssw0rd');


INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(10,'BERNIER','Estelle','Estelle.BERNIER','CJ62hy9','Estelle.BERNIER@darties.com',10);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(11,'VIENS','Aurore','Aurore.VIENS','E8X2yd7','Aurore.VIENS@darties.Com',11);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(12,'GAGNEUX','Charles','Charles.GAGNEUX','Xd64cG9','Charles.GAGNEUX@darties.com',12);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(13,'MELANSON','Gustave','Gustave.MELANSON','XZy67c6','Gustave.MELANSON@darties.com',13);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(14,'SAVOIE','David','David.SAVOIE','W63yk8B','David.SAVOIE@darties.com',14);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(15,'SAINDON','Edward','Edward.SAINDON','hr9F4X9','Edward.SAINDON@darties.com',15);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(16,'BORDOUX','Isabelle','Isabelle.BORDOUX','49Vn6zC','Isabelle.BORDOUX@darties.com',16);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(17,'LACHARITE','Joanna','Joanna.LACHARITE','y7eN4V9','Joanna.LACHARITE@darties.com',17);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(18,'BONNEVILLE','Damiane','Damiane.BONNEVILLE','S22tTv2','Damiane.BONNEVILLE@darties.com',18);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(19,'PROULE','Lucas','Lucas.PROULE','3YT56vn','Lucas.PROULE@darties.com',19);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(20,'CHARPENTIER','Jeoffroi','Jeoffroi.CHARPENTIER','8x3Bx3T','Jeoffroi.CHARPENTIER@darties.com',20);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(21,'SEGIN','Stephane ','Stephane.SEGIN','227wTTg','Stephane.SEGIN@darties.com',21);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(22,'LEJEUNE','Romain','Romain.LEJEUNE','4L5Cjh8','Romain.LEJEUNE@darties.com',22);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(23,'LAFRAMMOISE','Paul','Paul.LAFRAMMOISE','fP67Xb9','Paul.LAFRAMMOISE@darties.com',23);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(24,'MOREL','Claude','Claude.MOREL','9zP6vS2','Claude.MOREL@darties.com',24);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(25,'GODDU','Bertrand','Bertrand.GODDU','28Qi9Wk','Bertrand.GODDU@darties.com',25);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(26,'LEPICIER','Laetitia','Laetitia.LEPICIER','bqT483T','Laetitia.LEPICIER@darties.com',26);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(27,'CHANDONNET','Marguerite','Marguerite.CHANDONNET','2jN8i2X','Marguerite.CHANDONNET@darties.com',27);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(28,'LECHAMPS','Maurice','Maurice.LECHAMPS','x4Br95Z','Maurice.LECHAMPS@darties.com',28);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(29,'DELAPOSE','Audrey ','Audrey.DELAPOSE','4sgV93U','Audrey.DELAPOSE@darties.com',29);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(30,'AUDRAN','Emilie','Emilie.AUDRAN','8qeP56Y','Emilie.AUDRAN@darties.com',30);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(31,'DEDIAUX','Benjamin','Benjamin.DEDIAUX','988hRnC','Benjamin.DEDIAUX@darties.com',31);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(32,'LAURENT','Thomas','Thomas.LAURENT','3Me5Z9h','Thomas.LAURENT@darties.com',32);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(33,'DEY','Benoit','Benoit.DEY','8G7Lfi6','Benoit.DEY@darties.com',33);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(34,'DELAUNAY','Angelique','Angelique.DELAUNAY','g6Gb25T','Angelique.DELAUNAY@darties.com',34);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(35,'LEGRAND','Alexis','Alexis.LEGRAND','7u4d5XP','Alexis.LEGRAND@darties.com',35);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(36,'VALLE','Marc','Marc.VALLE','c63L9zG','Marc.VALLE@darties.com',36);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(37,'GIGUERE','Gilbert','Gilbert.GIGUERE','MT8t6w8','Gilbert.GIGUERE@darties.com',37);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(38,'BEAULIEU','Theophile','Theophile.BEAULIEU','9znW65L','Theophile.BEAULIEU@darties.com',38);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(39,'TANGUAY','Lea','Lea.TANGUAY','x9F6zN9','Lea.TANGUAY@darties.com',39);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(40,'ZACHARE','Patrick','Patrick.ZACHARE','6jAg55V','Patrick.ZACHARE@darties.com',40);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(41,'FROCHET','Elise','Elise.FROCHET','4e69aEB','Elise.FROCHET@darties.com',41);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(42,'FORTER','Louis','Louis.FORTER','ja82R2Z','Louis.FORTER@darties.com',42);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(43,'JACKSON','William','William.JACKSON','fV9rY56','William.JACKSON@darties.com',43);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(44,'ADAMS','Georges','Georges.ADAMS','gPzY863','Georges.ADAMS@darties.com',44);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(45,'CARTER','Harry','Harry.CARTER','zB5e3D8','Harry.CARTER@darties.com',45);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(46,'JOHNSON','Jimmy','Jimmy.JOHNSON','579BHrp','Jimmy.JOHNSON@darties.com',46);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(47,'BUCHANAN','Martin','Martin.BUCHANAN','mDPp867','Martin.BUCHANAN@darties.com',47);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(48,'PIERCE','James','James.PIERCE','P58qg3J','James.PIERCE@darties.com',48);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(49,'COOLIDGE','Emma','Emma.COOLIDGE','qW436sF','Emma.COOLIDGE@darties.com',49);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(50,'HAYES','Richard','Richard.HAYES','5n8Hs2W','Richard.HAYES@darties.com',50);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(51,'CLEVELAND','Taylor','Taylor.CLEVELAND','662wYNv','Taylor.CLEVELAND@darties.com',51);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(52,'MADISON','Warren','Warren.MADISON','J95Pdx8','Warren.MADISON@darties.com',52);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(53,'REAGAN','Arthur','Arthur.REAGAN','3Jeh6G7','Arthur.REAGAN@darties.com',53);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(54,'EVENO','Julie','Julie.EVENO','7DusL99','Julie.EVENO@darties.com',54);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(55,'OLIVER','Aurelie','Aurelie.OLIVER','tkHS596','Aurelie.OLIVER@darties.com',55);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(1,'AUDIBERT','Javier','Javier.AUDIBERT','4AfgG97','Javier.AUDIBERT@darties.com',1);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(2,'DROUIN','Dominic','Dominic.DROUIN','t2eJ76Z','Dominic.DROUIN@darties.com',2);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(3,'ROUX','Angelique','Angelique.ROUX','7u2Mx4W','Angelique.ROUX@darties.com',3);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(4,'BOUTOT','Angelle','Angelle.BOUTOT','9M2jyH3','Angelle.BOUTOT@darties.com',4);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(5,'DESCOTEAUX','Huguette','Huguette.DESCOTEAUX','33j7UvW','Huguette.DESCOTEAUX@darties.com',5);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(6,'DUBEAU','Pascal','Pascal.DUBEAU','59Cx6eX','Pascal.DUBEAU@darties.com',6);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(7,'PAIMBOEUF','Laurent','Laurent.PAIMBOEUF','wX2J4a9','Laurent.PAIMBOEUF@darties.com',7);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(8,'SAUCIER','Yves','Yves.SAUCIER','Un38y7C','Yves.SAUCIER@darties.com',8);
INSERT INTO utilisateur(id_utilisateur,nom,prenom,username,password,mail,id_profil) VALUES(9,'GAUTHIER','Robert','Robert.GAUTHIER','F2Se72u','Robert.GAUTHIER@darties.com',9);

INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(1,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(2,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(3,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(4,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(5,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(6,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(7,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(8,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(9,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(10,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(11,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(12,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(13,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(14,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(15,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(16,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(17,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(18,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(19,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(20,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(21,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(22,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(23,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(24,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(25,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(26,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(27,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(28,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(29,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(30,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(31,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(32,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(33,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(34,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(35,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(36,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(37,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(38,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(39,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(40,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(41,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(42,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(43,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(44,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(45,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(46,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(47,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(48,1,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(1,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(2,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(3,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(4,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(5,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(6,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(7,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(8,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(9,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(10,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(11,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(12,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(13,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(14,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(15,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(16,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(17,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(18,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(19,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(20,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(21,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(22,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(23,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(24,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(25,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(26,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(27,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(28,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(29,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(30,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(31,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(32,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(33,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(34,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(35,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(36,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(37,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(38,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(39,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(40,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(41,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(42,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(43,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(44,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(45,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(46,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(47,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(48,2,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(1,3,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(2,4,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(3,5,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(4,6,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(5,7,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(6,8,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(7,9,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(8,10,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(9,11,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(10,12,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(11,13,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(12,14,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(13,15,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(14,16,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(15,17,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(16,18,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(17,19,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(18,20,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(19,21,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(20,22,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(21,23,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(22,24,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(23,25,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(24,26,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(25,27,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(26,28,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(27,29,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(28,30,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(29,31,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(30,32,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(31,33,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(5,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(7,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(17,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(21,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(26,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(27,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(41,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(45,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(47,34,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(1,35,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(2,35,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(3,35,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(29,35,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(36,35,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(38,35,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(39,35,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(44,35,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(32,36,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(33,37,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(34,38,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(35,39,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(36,40,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(37,41,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(38,42,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(8,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(12,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(15,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(18,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(25,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(28,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(32,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(33,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(48,43,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(39,44,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(40,45,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(41,46,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(6,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(10,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(13,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(14,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(16,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(20,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(23,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(24,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(30,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(31,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(40,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(46,47,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(4,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(9,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(11,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(19,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(22,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(34,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(35,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(37,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(42,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(43,48,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(42,49,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(43,50,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(44,51,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(45,52,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(46,53,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(47,54,1);
INSERT INTO securite(id_magasin,id_profil,id_onglet) VALUES(48,55,1);