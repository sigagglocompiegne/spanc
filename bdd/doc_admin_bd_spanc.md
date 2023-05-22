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

Cette base de donnnées est dépendante de la Base Adresse Locale.

`[x_apps].[x_apps_geo_vmr_adresse]` : table géographique partagé des adresses

## Classes d'objets partagé et primitive graphique

`[m_spanc].[xapps_geo_vmr_spanc_anc]` : vue matérialisée géographique partagé avec la Base Adresse Locale permettant l'affichage et le fonctionnel au clic dans l'application. Cette vue remonte pour chaque adresse le nombre d'installation active, de contrôles et la conformité du dernier contrôle.

|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|gid|Identifiant unique de l'objet point adresse|bigint| |
|id_adresse|Identifiant unique interne de l'adresse|bigint| |
|commune|Libellé de la commune|varchar(80)|issue de la BAL|
|libvoie_c|Libellé de la voie|varchar(100)|issu de la BAL|
|libvoie_a|Libellé de la commune (norme AFNOR)|varchar(100)|issu de la BAL|
|numero|Numéro de voirie|varchar(10)|issu de la BAL|
|repet|indice de répétition dans la voie|varchar(10)|issu de la BAL |
|adresse|reconstruction de l'adresse complète|varchar(10)|issue de la BAL |
|iepci|acronyme de l'EPCI|text|arc, cclo, ccpe, cc2v (issue de la table `r_administratif.an_geo`) |
|nb_inst|nombre d'installation active à l'adresse (associée ou non)|numeric||
|nb_contr|nombre de contrôles réalisés à l'adresse avec un niveau de conformité attribué|numeric||
|confor|dernier niveau de conformité attribué (si 1 installation = conformité du dernier contrôle, si n installations conformité la moins favorable du dernier contrôle de chaque installation)|varchar||
|geom|géométrie du point d'adresse|geom(point,2154)|issu de la BAL|

Particularité(s) à noter :
* L'attribut `gid` sert de référence unique 
* Cette vue matérialisée est rafraichie automatiquement à chaque insertion, mise à jour ou suppression d'une installation, d'un contrôle ou d'une association d'adresses. 

## Classes d'objets du SPANC

L'ensemble des classes d'objets de gestion sont stockés dans le schéma `m_spanc`.

### Classes d'objets attributaire :

`[m_spanc].[xapps_geo_vmr_spanc_anc]` : table alphanumérique contenant
   
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
