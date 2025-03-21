/*spanc V1.0*/
/*Creation du fichier trace qui permet de suivre l'évolution du code*/
/* spanc_10_trace.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Grégory Bodet */

/*
#################################################################### SUIVI CODE SQL ####################################################################

-- 2025-03-17 : GB / AJout d'une vue matérialisée pour l'affiche des installations avec une demande de travaux en cours
-- 2023/11/07 : GB / ANOMALIE : affichage des périodicités selon la date de transmission du rapport ou de la date de visite si transmission non saisie
-- 2023/10/31 : GB / Ajustement de la fonction générant les clés primaires de contrôles
-- 2023/08/30 : GB / Ajout de patronymes
-- 2023/08/27 : GB / Ajustement de structures et des vues fonctionnelles suite intégration d'un jeu de données
-- 2023/08/07 : GB / Ajustement suite traitement des insertions des contrôles CCLO
-- 2023/06/23 : GB / Ajustement du code SQL suite retour de la période test
-- 2023/05/22 : GB / Initialisation du code SQL pour la création de structure de la base de données
