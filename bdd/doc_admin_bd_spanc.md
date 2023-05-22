![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation d'administration de la base de données du SPANC (Service Public d'Assainissement Non Collectif #

## Principes
  * **généralité** :

En 2022, un nouveau cadre de mutualisation s'est ouvert avec l'accueil d'une nouvelle EPCI formant ainsi le territoire du Grand Compiégnois comprenant désormais 4 EPCI. Celui-ci a fait émerger l'envie de disposer d'une application sur les contrôles de l'assainissement non collecif qui est une préoccupation partagée.

Cette application repose sur le développement d'une base de données partagée, stockée dans l'entrepôt de données du GéoCompiégnois, et à la fois étanche entre chaque EPCI.

L'application ainsi développée permet à chaque EPCI de disposer de ses propres données et de bénéficier des apports fonctionnels de tous.
 
 * **résumé fonctionnel** :

Pour rappel des grands principes :

* le modèle de données et l'application répondent à un besoin de gestion administrative des dossiers ANC. Ils ne permettent pas la saisie d'un contrôle complet dans le cadre du SPANC de chaque EPCI.
* la localisation des installations s'appuie sur le référentiel Base Adresse Locale
* un contrôle est rattachée à une installation et une seule
* une adresse peut disposer de n installations
* une installation peut-être partagée par plusieurs adresses
* l'application permet d'associer des documents, des contacts, ...
* des statistiques pour le SPANC sont disponibles
* la gestion des automatismes de rappel ou d'alertes sont gérées pour chaque EPCI (paramétrage possible pour chacun)

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
