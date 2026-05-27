<!-- Slide 3 - Code Python -->
          <div class="carrousel-slide">
            <div class="scrollable-code">
              <pre><code class="language-python">
donnees = []
moisdico = {'janvier': '01', 'fevrier': '02', 
        'mars': '03', 'avril': '04', 'mai': '05', 
        'juin': '06','juillet': '07', 'aout': '08', 
        'septembre': '09', 'octobre': '10', 'novembre': '11', 'decembre': '12'}
monset = set()

with open("gros_extrait_source_1_et_15_2023.txt", "r", encoding='utf8') as f:
    lines = f.readlines()

    i = 0
    while i < len(lines):
        line = lines[i].replace("\n", "")
        if '<' in line:
            run = True
            projet = []
            
            i = i+1
            k = lines[i].split("=")[-1].replace(" ", "")
            k = k.replace("\n", "")  
            projet.append(k)

            i = i+1
            date_saisie = lines[i].split("=")[-1].replace(" ", "")
            date_saisie.replace("\n","")
            date_saisie.replace(" ","")
            jour = date_saisie[-3:]
            annee = date_saisie[-7:-3]
            mois = date_saisie[:-7]
            moischiffre = moisdico[mois] 

            projet.append((f"{annee}-{moischiffre}-{jour}").replace("\n",""))

            i = i+1
            k = lines[i].split("=")[-1].replace(" ", "")
            k = k.replace("\n", "")
            projet.append(k)

            i = i+1
            k = lines[i].split("=")[-1].replace(" ", "")
            k = k.replace("\n", "")
            projet.append(k)

            i = i+1
            k = lines[i].split("=")[-1].replace(" ", "")
            k = k.replace("\n", "")
            projet.append(k)
            
            i = i+1    
            k = lines[i].split("=")[-1].replace(" ", "")
            k = k.replace("\n", "")
            projet.append(k)

            k=i
            
            k=k+1
            
            """
            while run :
                if '#' in lines[k] :
                    codeprod = lines[k].split('=')
                    codeprod = codeprod[1].replace('\n','') # test pour creer le dico avce valeurs automatiquements
                    codeprod = codeprod.upper()
                    monset.add(codeprod)
                    k+=2
                else : 
                    run = False
            print(monset)
            """ 
            prixtotal = 0 
            dicoprix = {'VOLET':0,'CHAUFFE_EAU_SOLAIRE':0,'FEN_PVC':0,'ISOLANT_COMBLES':0,}
        
            while run :
                if '#' in lines[k] :
                    codeprod = lines[k].split('=')
                    codeprod = codeprod[1].replace('\n','')
                    codeprod = codeprod.upper()
                    
                    prix = lines[k+1].split('=')
                    prix = prix[1].replace('\n','')
                    prix = float(prix)                    
                    prixtotal +=prix 
                    dicoprix[codeprod] = prix
                    k+=2
                else : 
                    run = False
                    
            for j in dicoprix:
                projet.append(dicoprix[j])
            
            projet.append(prixtotal)
            donnees.append(projet)
            i+=1
        else:
            i += 1

with open("fichierlourdd.csv", "a", encoding='utf8') as fichier:
    fichier.write("id_projet;date_saisie;nom_departement;code_postal;commune;insee_commune;VOLET;FEN_PVC;ISOLANT_TOIT_INT;ISOLANT_MURS_EXT;Prix Total;\n")
    
    for ligne in donnees:
        id_projet = ligne[0]
        date_saisie = ligne[1]
        nom_departement = ligne[2]
        code_postal = ligne[3]
        commune = ligne[4]
        insee_commune = ligne[5]
        VOLET = ligne[6]
        CHAUFFE_EAU_SOLAIRE = ligne[7]
        FEN_PVC = ligne[8]
        ISOLANT_COMBLES = ligne[9]
        Prixxx = ligne[10]

        
        fichier.write(f"{id_projet};{date_saisie};{nom_departement};{code_postal};{commune};{insee_commune};{VOLET};{FEN_PVC};{ISOLANT_TOIT_INT};{ISOLANT_MURS_EXT};{Prixxx}\n")
i += 8 

            </code></pre>
            </div>
            <div class="slide-text">
              <h3>Code Python Finale</h3>
              <p>Création et traitement des données non traités avec envoie dans un fichier txt</p>
            </div>
          </div>
