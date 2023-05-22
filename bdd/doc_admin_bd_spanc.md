![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation d'administration de la base de données du SPANC (Service Public d'Assainissement Non Collectif #

## Principes
  * **généralité** :

(en cours)
 
 * **résumé fonctionnel** :

Pour rappel des grands principes :

(en cours)

## Schéma fonctionnel

(en refonte)

## Modèle relationel simplifié


![spanc_mcd](mcd_v1.png)

## Dépendances

(en cours)

## Classes d'objets partagé et primitive graphique

`[].[]` : table géographique partagé des adresses
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|


Particularité(s) à noter :
* Une clé primaire existe sur le champ `` l'attribution automatique de la référence unique s'effectue via les vues de gestion. 


* 0 triggers :


---

## Classes d'objets du SPANC

L'ensemble des classes d'objets de gestion sont stockés dans le schéma `m_spanc`.

### Classes d'objets attributaire :

`[].[]` : table alphanumérique contenant 
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|


Particularité(s) à noter :
* Une clé primaire existe sur le champ `` l'attribution automatique de la référence unique s'effectue via une séquence. 
* Une clé étrangère existe sur la table de valeur `` (lien vers la liste de valeurs du type de contact ``)

* 1 triggers :
  * `t_t1_date_maj` : trigger permettant d'insérer la date de mise à jour
 
---


#### Liste de valeurs

`[m_spanc].[]` : Liste des valeurs permettant de décrire 

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    


Particularité(s) à noter :
* Une clé primaire existe sur le champ code 

Valeurs possibles :

|Code|Valeur|
|:---|:---|


---


### Classes d'objets attributaire gérant les associations (ou relation d'appartenance des objets entre eux) :

`[m_spanc].[]` : table alphanumérique de relation entre 
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|



Particularité(s) à noter :
* Une clé primaire existe sur le champ `` l'attribution automatique de la référence unique s'effectue via une séquence. 

* 4 triggers :
  * `` : trigger permettant de 

  
---


### classes d'objets applicatives métiers :

  * `` : Vue alphanumérique permettant de calculer des 

### classes d'objets applicatives grands publics sont classés dans le schéma x_apps_public :

Sans objet

### classes d'objets opendata sont classés dans le schéma x_opendata :

Sans objet

## Projet QGIS pour la gestion

Sans objet

## Traitement automatisé mis en place (Workflow de l'ETL FME)

Sans objet

## Export Open Data

Sans objet


---
