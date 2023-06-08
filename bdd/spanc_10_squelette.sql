/*SPANC V1.0*/
/*Creation du squelette de la structure des données (table, séquence, trigger,...) */
/* spanc_10_squelette.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Grégory Bodet */

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                SCHEMA                                                                        ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

/*
DROP SCHEMA IF EXISTS m_spanc CASCADE;

CREATE SCHEMA m_spanc AUTHORIZATION create_sig;

COMMENT ON SCHEMA m_spanc IS 'Gestion des contrôles liés au SPANC (Service Public d''Assainissement non collectif';

-- Permissions

GRANT ALL ON SCHEMA m_spanc TO create_sig;
GRANT ALL ON SCHEMA m_spanc TO csarg;
GRANT ALL ON SCHEMA m_spanc TO sig_edit;
GRANT ALL ON SCHEMA m_spanc TO sig_read;
*/


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                SEQUENCE                                                                      ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- ################################################# an_spanc_installation_id_seq #####################################################################
-- ################################################# Séquence des identifiants internes des installtions ANC ##########################################

CREATE SEQUENCE m_spanc.an_spanc_installation_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

-- ################################################# an_spanc_contact_id_seq #####################################################################
-- ################################################# Séquence des identifiants internes des contacts liés aux installations ANC ##########################################

CREATE SEQUENCE m_spanc.an_spanc_contact_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

-- ################################################# an_spanc_controle_id_seq #####################################################################
-- ################################################# Séquence des identifiants construisant l'identifiant des controles ##########################################

CREATE SEQUENCE m_spanc.an_spanc_controle_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;   
   
-- ################################################# an_spanc_entretien_media_seq #####################################################################
-- ################## Séquence des identifiants construisant l'identifiant des médias pour les documents liés à l'entretien ###########################

CREATE SEQUENCE m_spanc.an_spanc_entretien_media_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;      
   
-- ################################################# an_spanc_installation_media_seq #####################################################################
-- ################## Séquence des identifiants construisant l'identifiant des installations ###########################

CREATE SEQUENCE m_spanc.an_spanc_installation_media_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
   
-- ################################################# an_spanc_controle_media_seq #####################################################################
-- ################## Séquence des identifiants construisant l'identifiant des contrôles ###########################

CREATE SEQUENCE m_spanc.an_spanc_controle_media_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;   
   
-- ################################################# an_spanc_prestataire_seq #####################################################################
-- ################## Séquence des identifiants construisant l'identifiant des prestataires ###########################

CREATE SEQUENCE m_spanc.an_spanc_prestataire_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1; 
   
-- ################################################# an_spanc_dsp_seq #####################################################################
-- ################## Séquence des identifiants construisant l'identifiant des DSP ###########################

CREATE SEQUENCE m_spanc.an_spanc_dsp_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;  
   
-- ################################################# an_spanc_conf_seq #####################################################################
-- ################## Séquence des identifiants construisant l'identifiant configuration des variables paramétrables ###########################

CREATE SEQUENCE m_spanc.an_spanc_conf_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;    
   
-- ################################################# an_spanc_cad_seq #####################################################################
-- ################################################# Séquence des identifiants internes des références parcelles de l'installation ##########################################

CREATE SEQUENCE m_spanc.an_spanc_cad_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1; 
   
-- ################################################# lk_spanc_installad_seq #####################################################################
-- ################################################# Séquence des identifiants internes des relations installations/adresse ##########################################

CREATE SEQUENCE m_spanc.lk_spanc_installad_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;   
      
-- ################################################# lk_spanc_contact_seq #####################################################################
-- ################################################# Séquence des identifiants internes des relations installations/contacts ##########################################

CREATE SEQUENCE m_spanc.lk_spanc_contact_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;      

   
   -- ################################################# an_spanc_log_seq #####################################################################
-- ################################################# Séquence des identifiants internes des logs ##########################################

CREATE SEQUENCE m_spanc.an_spanc_log_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1; 

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINES DE VALEURS                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- ################################################################# Domaine valeur - lt_spanc_typimmeuble ############################################

CREATE TABLE m_spanc.lt_spanc_typimmeuble
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_typimmeuble_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_typimmeuble
    IS 'Liste de valeurs des types d''immeubles disposant d''une installation ANC';

COMMENT ON COLUMN m_spanc.lt_spanc_typimmeuble.code
    IS 'Code du type d''immeuble';

COMMENT ON COLUMN m_spanc.lt_spanc_typimmeuble.valeur
    IS 'Valeur du type d''immeuble';

-- Index: lt_spanc_typimmeuble_idx
-- DROP INDEX m_spanc.lt_spanc_typimmeuble_idx;

CREATE INDEX lt_spanc_typimmeuble_idx
    ON m_spanc.lt_spanc_typimmeuble USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_typimmeuble(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Maison individuelle'),
    ('20','Collectif'),
    ('31','Local commercial'),
    ('32','Autres locaux (hors habitation et hors CCPE'),
    ('40','Habitation temporaire (mobil-home, caravanes, …)'),
    ('50','Groupement d''habitations');
   
-- ################################################################# Domaine valeur - lt_spanc_typinstall ############################################

CREATE TABLE m_spanc.lt_spanc_typinstall
(
    code character varying(3) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_typinstall_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_typinstall
    IS 'Liste de valeurs des types d''installations ANC';

COMMENT ON COLUMN m_spanc.lt_spanc_typinstall.code
    IS 'Code du type d''installation';

COMMENT ON COLUMN m_spanc.lt_spanc_typinstall.valeur
    IS 'Libellé du type d''installation';   
      

-- Index: lt_spanc_typimmeuble_idx
-- DROP INDEX m_spanc.lt_spanc_typimmeuble_idx;

CREATE INDEX lt_spanc_typinstall_idx
    ON m_spanc.lt_spanc_typinstall USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_typinstall(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Pré-traitement'),
    ('20','Traitement'),
    ('30','Rejet');
   
   -- ################################################################# Domaine valeur - lt_spanc_equinstall ############################################

CREATE TABLE m_spanc.lt_spanc_equinstall
(
    code character varying(3) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_equinstall_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_equinstall
    IS 'Liste de valeurs des types d''équipements liés à une installation';

COMMENT ON COLUMN m_spanc.lt_spanc_equinstall.code
    IS 'Code des types d''équipements liés à une installation';

COMMENT ON COLUMN m_spanc.lt_spanc_equinstall.valeur
    IS 'Valeur des types d''équipements liés à une installation';   
   
-- Index: lt_spanc_typimmeuble_idx
-- DROP INDEX m_spanc.lt_spanc_typimmeuble_idx;

CREATE INDEX lt_spanc_equinstall_idx
    ON m_spanc.lt_spanc_equinstall USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_equinstall(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Aucun'),
    ('21','Fosse septique avec bac à graisse'),
    ('22','Fosse septique sans bac à graisse'),
    ('23','Fosse toutes eaux'),
    ('31','Tranchée d''épandange'),
    ('32','Filtre à sable drainé'),
    ('33','Filtre à sable non drainé'),
    ('34','Micro-station'),
    ('35','Filière compacte agréée'),
    ('36','Tertre'),    
    ('37','Filtre à cheminement lent'),  
    ('43','Puisard'),
    ('44','Puits d''infiltration'),
    ('45','Cours d''eau'),
    ('46','Réseau pluvial'),
    ('47','Ecoulement à la parcelle'),
    ('ZZ','Non concerné');


-- ################################################################# Domaine valeur - lt_spanc_eh ############################################

CREATE TABLE m_spanc.lt_spanc_eh
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_eh_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_eh
    IS 'Liste de valeurs des équivalents/habitants';

COMMENT ON COLUMN m_spanc.lt_spanc_eh.code
    IS 'Code de l''équivalent habitat';

COMMENT ON COLUMN m_spanc.lt_spanc_eh.valeur
    IS 'Valeur de l''équivalent habitat';

-- Index: lt_spanc_eh_idx
-- DROP INDEX m_spanc.lt_spanc_eh_idx;

CREATE INDEX lt_spanc_eh_idx
    ON m_spanc.lt_spanc_eh USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_eh(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','<= 20 EH'),
    ('20','> 20 EH');
   

-- ################################################################# Domaine valeur - lt_spanc_etatinstall ############################################

CREATE TABLE m_spanc.lt_spanc_etatinstall
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_etatinstall_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_etatinstall
    IS 'Liste de valeurs des état de l''installation';

COMMENT ON COLUMN m_spanc.lt_spanc_etatinstall.code
    IS 'Code de l''état de l''installation';

COMMENT ON COLUMN m_spanc.lt_spanc_etatinstall.valeur
    IS 'Valeur de l''état de l''installation';

-- Index: lt_spanc_eh_idx
-- DROP INDEX m_spanc.lt_spanc_eh_idx;

CREATE INDEX lt_spanc_etatinstall_idx
    ON m_spanc.lt_spanc_etatinstall USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_etatinstall(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Activée'),
    ('20','Désactivée');   
   
   
-- ################################################################# Domaine valeur - lt_spanc_typcontact ############################################

CREATE TABLE m_spanc.lt_spanc_typcontact
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_typcontact_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_typcontact
    IS 'Liste de valeurs des types de contacts des installations';

COMMENT ON COLUMN m_spanc.lt_spanc_typcontact.code
    IS 'Code des types de contacts des installations';

COMMENT ON COLUMN m_spanc.lt_spanc_typcontact.valeur
    IS 'Valeur des types de contacts des installations';

-- Index: lt_spanc_typcontact_idx
-- DROP INDEX m_spanc.lt_spanc_typcontact_idx;

CREATE INDEX lt_spanc_typcontact_idx
    ON m_spanc.lt_spanc_typcontact USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_typcontact(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Propriétaire'),
    ('20','Occupant'),
    ('99','Autre');  

-- ################################################################# Domaine valeur - lt_spanc_patro ############################################

CREATE TABLE m_spanc.lt_spanc_patro
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_patro_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_patro
    IS 'Liste de valeurs des types des patronymes des contacts des installations';

COMMENT ON COLUMN m_spanc.lt_spanc_patro.code
    IS 'Code des types des patronymes des contacts des installations';

COMMENT ON COLUMN m_spanc.lt_spanc_patro.valeur
    IS 'Valeur des types des patronymes des contacts des installations';

-- Index: lt_spanc_patro_idx
-- DROP INDEX m_spanc.lt_spanc_patro_idx;

CREATE INDEX lt_spanc_patro_idx
    ON m_spanc.lt_spanc_patro USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_patro(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('11','Monsieur'),
    ('12','Madame'),
    ('20','Madame & Monsieur'),
    ('30','Mesdames & Messieurs'),
    ('40','SCI'),
    ('99','Autre');
   
-- ################################################################# Domaine valeur - lt_spanc_natcontr ############################################

CREATE TABLE m_spanc.lt_spanc_natcontr
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_natcontr_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_natcontr
    IS 'Liste de valeurs de la nature des contrôles';

COMMENT ON COLUMN m_spanc.lt_spanc_natcontr.code
    IS 'Code des types de la nature des contrôles';

COMMENT ON COLUMN m_spanc.lt_spanc_natcontr.valeur
    IS 'Valeur des types de la nature des contrôles';

-- Index: lt_spanc_natcontr_idx
-- DROP INDEX m_spanc.lt_spanc_natcontr_idx;

CREATE INDEX lt_spanc_natcontr_idx
    ON m_spanc.lt_spanc_natcontr USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_natcontr(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('11','Demande de travaux (neuf)'),
    ('12','Demande de travaux (réhabilitation)'),
    ('13','Visite d''éxécution des travaux (neuf)'),
    ('14','Visite d''éxécution des travaux (réhabilitation)'),
    ('20','Diagnostic initial'),
    ('30','Contrôle périodique'),
    ('40','Contrôle exceptionnel'),
    ('50','Contrôle lié à une vente'),
    ('60','Contre-visite');  

-- ################################################################# Domaine valeur - lt_spanc_contcl ############################################

CREATE TABLE m_spanc.lt_spanc_contcl
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_contcl_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_contcl
    IS 'Liste de valeurs sur les conclusions du contrôle';

COMMENT ON COLUMN m_spanc.lt_spanc_contcl.code
    IS 'Code des types sur les conclusions du contrôle';

COMMENT ON COLUMN m_spanc.lt_spanc_contcl.valeur
    IS 'Valeur des types sur les conclusions du contrôle';

-- Index: lt_spanc_contcl_idx
-- DROP INDEX m_spanc.lt_spanc_contcl_idx;

CREATE INDEX lt_spanc_contcl_idx
    ON m_spanc.lt_spanc_contcl USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_contcl(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Absence d''installation'),
    ('20','Installation ne présentant pas de défaut apparent'),
    ('31','Installation présentant un défaut sanitaire'),
    ('32','Installation présentant un défaut environnementale'),
    ('40','Installation incomplète, sous-dimentionnée, avec dysfonctionnement'),
    ('ZZ','Non concerné (refus du contrôle)');
    
   
-- ################################################################# Domaine valeur - lt_spanc_confor ############################################

CREATE TABLE m_spanc.lt_spanc_confor
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_confor_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_confor
    IS 'Liste de valeurs des conformités du contrôle';

COMMENT ON COLUMN m_spanc.lt_spanc_confor.code
    IS 'Code des conformités du contrôle';

COMMENT ON COLUMN m_spanc.lt_spanc_confor.valeur
    IS 'Valeur des conformités du conclusion du contrôle';

-- Index: lt_spanc_confor_idx
-- DROP INDEX m_spanc.lt_spanc_confor_idx;

CREATE INDEX lt_spanc_confor_idx
    ON m_spanc.lt_spanc_confor USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_confor(
            code, valeur)
    VALUES
    ('00','Non renseigné (non attribuée)'),
    ('10','Conforme'),
    ('20','Non conforme'),
    ('30','Absence d''installation'),
    ('ZZ','Non concerné (refus du contrôle)');   
   

-- ################################################################# Domaine valeur - lt_spanc_refus ############################################

CREATE TABLE m_spanc.lt_spanc_refus
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_refus_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_refus
    IS 'Liste de valeurs des refus du contrôle par l''usager';

COMMENT ON COLUMN m_spanc.lt_spanc_refus.code
    IS 'Code des types des refus du contrôle par l''usager';

COMMENT ON COLUMN m_spanc.lt_spanc_refus.valeur
    IS 'Valeur des types des refus du contrôle par l''usager';

-- Index: lt_spanc_refus_idx
-- DROP INDEX m_spanc.lt_spanc_refus_idx;

CREATE INDEX lt_spanc_refus_idx
    ON m_spanc.lt_spanc_refus USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_refus(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Refus de l''usager'),
    ('20','Absent'),
    ('30','Report abusif des RDV'),
    ('ZZ','Non concerné (contrôle réalisé');   
   
-- ################################################################# Domaine valeur - lt_spanc_info ############################################

CREATE TABLE m_spanc.lt_spanc_info
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_info_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_info
    IS 'Liste de valeurs du dernier moyen d''informations ou de communication utilisé';

COMMENT ON COLUMN m_spanc.lt_spanc_info.code
    IS 'Code du dernier moyen d''informations ou de communication utilisé';

COMMENT ON COLUMN m_spanc.lt_spanc_info.valeur
    IS 'Valeur du dernier moyen d''informations ou de communication utilisé';

-- Index: lt_spanc_info_idx
-- DROP INDEX m_spanc.lt_spanc_info_idx;

CREATE INDEX lt_spanc_info_idx
    ON m_spanc.lt_spanc_info USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_info(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('11','Courrier simple'),
    ('12','Courrier recommandé'),
    ('20','Téléphone'),
    ('30','Email');    
   
   
-- ################################################################# Domaine valeur - lt_spanc_entr ############################################

CREATE TABLE m_spanc.lt_spanc_entr
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_entr_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_entr
    IS 'Liste de valeurs des documents liés à l''entretien';

COMMENT ON COLUMN m_spanc.lt_spanc_entr.code
    IS 'Code du document de l''entretien';

COMMENT ON COLUMN m_spanc.lt_spanc_entr.valeur
    IS 'Valeur du document de l''entretien';

-- Index: lt_spanc_entr_idx
-- DROP INDEX m_spanc.lt_spanc_entr_idx;

CREATE INDEX lt_spanc_entr_idx
    ON m_spanc.lt_spanc_entr USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_entr(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Vidange'),
    ('20','Carnet d''entretien'),
    ('99','Autre');
   
  
-- ################################################################# Domaine valeur - lt_spanc_contrdoc ############################################

CREATE TABLE m_spanc.lt_spanc_contrdoc
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_contrdoc_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_contrdoc
    IS 'Liste de valeurs des types de documents liés à un contrôle';

COMMENT ON COLUMN m_spanc.lt_spanc_contrdoc.code
    IS 'Code du document lié aux contrôles';

COMMENT ON COLUMN m_spanc.lt_spanc_contrdoc.valeur
    IS 'Valeur du document lié aux contrôles';

-- Index: lt_spanc_contrdoc_idx
-- DROP INDEX m_spanc.lt_spanc_contrdoc_idx;

CREATE INDEX lt_spanc_contrdoc_idx
    ON m_spanc.lt_spanc_contrdoc USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_contrdoc(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Projet de travaux'),
    ('20','Rapport d''examen'),
    ('30','Rapport de visite'),
    ('40','Mise en demeure'),
    ('50','Application de pénalités');

-- ################################################################# Domaine valeur - lt_spanc_docinstal ############################################

CREATE TABLE m_spanc.lt_spanc_docinstal
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_docinstal_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_docinstal
    IS 'Liste de valeurs des types de documents liés à un installation';

COMMENT ON COLUMN m_spanc.lt_spanc_docinstal.code
    IS 'Code du document lié une installation';

COMMENT ON COLUMN m_spanc.lt_spanc_docinstal.valeur
    IS 'Valeur du document lié une installation';

-- Index: lt_spanc_docinstal_idx
-- DROP INDEX m_spanc.lt_spanc_docinstal_idx;

CREATE INDEX lt_spanc_docinstal_idx
    ON m_spanc.lt_spanc_docinstal USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_docinstal(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Convention d''entretien'),
    ('99','Autre');
   
-- ################################################################# Domaine valeur - lt_spanc_modgest  ############################################

CREATE TABLE m_spanc.lt_spanc_modgest
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur text COLLATE pg_catalog."default",
    epci text COLLATE pg_catalog."default",
    CONSTRAINT lt_spanc_modgest_pkkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lt_spanc_modgest
    IS 'Liste de valeurs du mode de gestion du contrôle';

COMMENT ON COLUMN m_spanc.lt_spanc_modgest.code
    IS 'Code du mode de gestion du contrôle';

COMMENT ON COLUMN m_spanc.lt_spanc_modgest.valeur
    IS 'Valeur du mode de gestion du contrôle';
   
COMMENT ON COLUMN m_spanc.lt_spanc_modgest.epci
    IS 'Acronyme de l''EPCI concernée';

-- Index: lt_spanc_modgest_idx
-- DROP INDEX m_spanc.lt_spanc_modgest_idx;

CREATE INDEX lt_spanc_modgest_idx
    ON m_spanc.lt_spanc_modgest USING btree
    (code COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO m_spanc.lt_spanc_modgest(
            code, valeur,epci)
    VALUES
    ('11','Régie','arc'),
    ('12','Régie','cclo'),
    ('13','Régie','ccpe'),
    ('14','Régie','cc2v'),
    ('21','Prestataire','arc'),
    ('22','Prestataire','cclo'),
    ('23','Prestataire','ccpe'),
    ('24','Prestataire','cc2v'),
    ('31','DSP','arc'),
    ('32','DSP','cclo'),
    ('33','DSP','ccpe'),
    ('34','DSP','cc2v');
   
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                FUNCTION TRIGGER                                                              ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################   

   
-- ################################################################# Fonction - ft_r_autorite_competente_user_login (public)  ############################################   

CREATE OR REPLACE FUNCTION public.ft_r_autorite_competente_user_login()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

BEGIN

  -- function récupérant l'EPCI d'appartenance affecté à l'utilisateur
   NEW.epci := (select values from custom_attributes ca where name = 'epci' and user_login = NEW.op_sai);
  
 

return new;

END;
$function$
;

COMMENT ON FUNCTION public.ft_r_autorite_competente_user_login() 
IS 'Fonction trigger affecter l''autorité compétente en fonction de l''utilisateur de saisie';


-- ################################################################# Fonction - ft_m_idcontr  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_idcontr()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

DECLARE v_epci text;
DECLARE v_num bigint;

BEGIN

  -- je récupère l'EPCI d'appartenance affecté à l'utilisateur
   v_epci := (select values from custom_attributes ca where name = 'epci' and user_login = NEW.op_sai);
   
  -- je lance recherche le n° d'ordre pour l'EPCI concernée 
   v_num := (SELECT count(*)+1 FROM m_spanc.an_spanc_controle WHERE epci = v_epci);
  
  -- je formate l'identifiant du contrôle
   new.idcontr := v_epci || '_' || v_num;
  
return new;

END;
$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_idcontr() 
IS 'Fonction trigger générant la clé unique du contrôle composé de l''EPCI et d''un n° d''ordre';


    

-- ################################################################# Fonction - ft_m_verif_ref_cad  ############################################
  
CREATE OR REPLACE FUNCTION m_spanc.ft_m_verif_ref_cad()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

BEGIN

-- contrôle sur la saisie de la section cadastrale et le numéro de parcelle (longueur)
IF length(NEW.ccosec) <> 2 OR length(NEW.dnupla) <> 4 THEN
RAISE EXCEPTION USING MESSAGE = 'La section doit être codée sur 2 caractères et la parcelle sur 4 caractères. Vérifiez votre saisie et recommencer.';
END IF;

-- contrôle sur la saisie de la section cadastrale (positionnement du 0)
IF (right(NEW.ccosec,1) = '0' OR NEW.ccosec = '00') THEN
RAISE EXCEPTION USING MESSAGE = 'Une section ne peut pas être composée d''une lettre suivie d''un 0, n''y être composée d''un double 0. Corrigez votre saisie et validez.';
END IF;

NEW.ccosec := upper(NEW.ccosec);

return new;

END;
$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_verif_ref_cad() 
IS 'Fonction trigger vérifiant la saisie des références cadastrales';

 

-- ################################################################# Fonction - ft_m_controle_saisie_instal  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_saisie_instal()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

declare n_years interval;

BEGIN

if TG_OP ='INSERT' THEN
	-- si installation soumis à contrôle et convention est identique pas possible
	if new.inst_acontr = new.inst_conv then 
	raise exception 'Vous ne pouvez pas indiquer que l''installation est à la fois soumise à un contrôle et à une convention';
	end if;

    -- calcul de l'âge de l'installation si uniquement l'âge déduit
 if new.inst_age is not null then
  n_years := '''' || new.inst_age || ' years''';
   --raise EXCEPTION  'interval %',n_years;
   new.date_crea := (select now()::timestamp - n_years);
 end if;

 -- récupération de la géométrie du point d'adresse
 new.geom1 := (select geom from x_apps.xapps_geo_vmr_adresse where id_adresse = new.idadresse);


elseif 	TG_OP ='UPDATE' then

	-- si installation soumis à contrôle et convention est identique pas possible
	if new.inst_acontr = new.inst_conv then 
	raise exception 'Vous ne pouvez pas indiquer que l''installation est à la fois soumise à un contrôle et à une convention';
	end if;

    -- calcul de l'âge de l'installation si uniquement l'âge déduit
 if new.inst_age is not null then
  n_years := '''' || new.inst_age || ' years''';
   --raise EXCEPTION  'interval %',n_years;
   new.date_crea := (select now()::timestamp - n_years);
 end if;

 -- une installation ne peut pas être activée si elle est désactivée
	if (new.inst_etat = '10' or new.inst_etat = '00') and old.inst_etat = '20' then 
	raise exception 'Vous ne pouvez pas réactiver une installation désactivée.';
	end if;


    if new.inst_etat = '20' then
    raise exception 'Vous ne pouvez pas modifier un état en "Désactivée". Utilisez le bouton "SUPPRIMER " en bas de la fiche si vous souhaitez désactiver l''installation.';
    end if;
  
  
    elseif 	TG_OP ='DELETE' then

    new.inst_etat := '20';

end if;

return new;

END;
$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_saisie_instal() 
IS 'Fonction trigger contrôlant la saisie et la cohérence des données de l''installation';


-- ################################################################# Fonction - ft_m_controle_saisie_contact  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_saisie_contact()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

BEGIN
    

	if TG_OP = 'INSERT' or  TG_OP = 'UPDATE' then	
	-- contrôle sur la saisie des références téléphoniques ....
	/*
    IF (trim(new.ref_telp) IS NULL OR trim(new.ref_telp) = '') AND (trim(new.ref_tel) IS NULL OR trim(new.ref_tel) = '') 
    AND (trim(new.ref_email) IS NULL OR trim(new.ref_email) = '') THEN
	RAISE EXCEPTION 'Vous devez au moins remplir un n° de téléphone ou un email pour créer un contact';
	END IF;
	*/
	IF  trim(new.ref_tel) IS NOT NULL AND trim(new.ref_tel) <> '' THEN
		IF left(new.ref_tel,1) <> '0' THEN
			RAISE EXCEPTION 'Le numéro de téléphone ne peut commencer que par le chiffre 0.';
		END IF;
	END IF;
    IF trim(new.ref_telp) IS NOT NULL AND trim(new.ref_telp) <> '' THEN
	   IF left(new.ref_telp,1) <> '0' THEN
        	RAISE EXCEPTION 'Le numéro de téléphone portable ne peut commencer que par le chiffre 0.';
	   END IF;
	END IF;	
    IF trim(new.ref_tel) IS NOT NULL AND trim(new.ref_tel) <> '' THEN
		IF (SELECT to_number(new.ref_tel,'999999999')) < 10000000 OR (SELECT to_number(new.ref_tel,'999999999')) > 99999999 THEN
        RAISE EXCEPTION 'Le numéro de téléphone ne correspond pas à un numéro valide.';
		END IF;
	END IF;	
	IF trim(new.ref_telp) IS NOT NULL AND trim(new.ref_telp) <> '' THEN
		IF (SELECT to_number(new.ref_telp,'999999999')) < 10000000 OR (SELECT to_number(new.ref_telp,'999999999')) > 99999999 THEN
        RAISE EXCEPTION 'Le numéro de téléphone portable ne correspond pas à un numéro valide.';
		END IF;
	END IF;	
	IF trim(new.ref_tel) IS NOT NULL AND trim(new.ref_tel) <> '' THEN
	     IF length(new.ref_tel)-1 <> length(to_number(new.ref_tel,'9999999999')::text) THEN
		 RAISE EXCEPTION 'Le numéro de téléphone saisie contient des lettres ou des caractères non chiffrés.';
		 END IF;
		 
		 
	END IF;
	IF trim(new.ref_telp) IS NOT NULL AND trim(new.ref_telp) <> '' THEN
	     IF length(new.ref_telp)-1 <> length(to_number(new.ref_telp,'9999999999')::text) THEN
		 RAISE EXCEPTION 'Le numéro de téléphone portable saisie contient des lettres ou des caractères non chiffrés.';
		 END IF;
	END IF;
	IF trim(new.ref_email) IS NOT NULL AND trim(new.ref_email) <> '' THEN
	   IF trim(new.ref_email) not like '%@%' THEN
	   RAISE EXCEPTION 'Votre email ne contient pas le caractère @.';
	   END IF;
	END IF;
	IF trim(new.ref_email) IS NOT NULL AND trim(new.ref_email) <> '' THEN
	   IF trim(new.ref_email) not like '%.%' THEN
	   RAISE EXCEPTION 'Votre email ne contient pas le caractère .fr, .com, ...';
	   END IF;
	END IF;

 -- si il y a plusieurs contacts pour la facturation pas possible
    /*
	IF new.factu_cont is true THEN
		IF
		(SELECT count(*) FROM m_spanc.an_spanc_contact c, m_spanc.lk_spanc_contact lk, WHERE lk.idcontact = c.idcontact AND idcontact = NEW.idcontact and new.factu_cont = true) > 1 THEN
		RAISE EXCEPTION 'Vous ne pouvez pas avoir plus de 1 contact pour la facturation';
		end if;
	END IF;
    */
    -- un patronyme doit-être saisie si pas autre
	IF new.ref_typ <> '99' and new.ref_patro is null THEN
		
		RAISE EXCEPTION 'Vous devez saisir un type de patronyme.';
		
	END IF;

	  -- si autre adresse de facturation cochée doit saisir une adresse
     IF new.factu_adc is true and (new.factu_ad is null or new.factu_ad = '') THEN
		
		RAISE EXCEPTION 'Vous devez saisir une autre adresse pour la facturation.';
		
	END IF;
end if;
    return new ;
   
END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_saisie_contact() IS 'Fonction de contrôle de saisie d''un contact';



-- ################################################################# Fonction - ft_m_controle_conform  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_conform()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$


begin
	
	-- A LA SAISIE
	
	if TG_OP = 'INSERT' then
	
	
	 -- si un contrôle grave sur une installation active ne peut pas un contrôle de meilleurs qualités (nouvelle installation donc autre contrôle)
	 -- ce contrôle n'est pas nécessaire à la mise à jour car le verrou n'autorisera pas la modification de la conclusion du contrôle donc une autre conformité
    if 
     (select 
        ad.contr_concl
      FROM  
      (       
      SELECT DISTINCT 
             a.idinstal,
              a.contr_concl
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
                   where c.idinstal = i.idinstal  AND i.inst_etat = '10'
                  GROUP BY c.idinstal) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
                  ) ad where ad.idinstal = new.idinstal) IN ('31','32') and new.contr_concl IN ('20','40','10','00') THEN

     			RAISE EXCEPTION 'Vous ne pouvez pas insérer un nouveau contrôle de meilleur qualité après avoir saisi un contrôle avec une non-conformité grave.';

    end if;

	
	-- SAISIE AUTOMATIQUE DE LA CONFORMITE
	
	-- si conclusion = absence d'installation
	-- conformité = absence d'installation
    IF NEW.contr_concl = '10' THEN
       NEW.contr_confor := '30'; 
    END IF;

   -- si conclusion = Installation ne présentant pas de défaut apparent
	-- conformité = conforme 
    IF NEW.contr_concl = '20' THEN
       NEW.contr_confor := '10'; 
    END IF;
   
    -- si conclusion = Installation présentant un défaut ou incomplète, sous-dimensionnée, avec dysfonctionnement
	-- conformité = conforme 
    IF NEW.contr_concl IN ('31','32','40') THEN
       NEW.contr_confor := '20'; 
    END IF;
   
    -- si conclusion = refus du contrôles
	-- conformité = conforme 
    IF NEW.contr_concl = 'ZZ' THEN
       NEW.contr_confor := 'ZZ'; 
    end if;
   
    -- si conclusion = N.R
	-- conformité = N.R 
    IF NEW.contr_concl = '00' THEN
       NEW.contr_confor := '00'; 
    END IF;

  
 	-- si il y a au moins une installation à NR ou à aucun, la conclusion ne peut pas être différente de installation incomplète
   if new.contr_concl <> '10' THEN
   IF NEW.contr_concl <> '40' and NEW.contr_concl <> '00' and NEW.contr_concl <> '20' and NEW.contr_concl <> 'ZZ'
   	  AND NEW.equ_pretrait || NEW.equ_trait || NEW.equ_rejet LIKE '%00%' THEN
   	RAISE EXCEPTION 'Votre conclusion n''est pas cohérente avec les équipements contrôlés. Vous ne pouvez pas avoir un équipement renseignés à "Non renseigné"';
   END IF;
    end if;
   
       -- si contrôle conforme on ne peut pas avoir d'équipement à '00', 'ZZ' ou '10'
   if  (new.contr_concl = '20' and NEW.equ_pretrait || NEW.equ_trait || NEW.equ_rejet like '%00%')
       or (new.contr_concl = '20' and NEW.equ_pretrait || NEW.equ_trait || NEW.equ_rejet like '%10%')
   THEN
  	RAISE EXCEPTION 'Votre conclusion n''est pas cohérente avec les équipements contrôlés. Vous ne pouvez pas laisser des équipements à "Non renseignés" ou à "Aucun"';
   END IF;
 	
   -- si aucun équipement, seule l'absence d'installation peut être indiqué en contrôle
   if  new.contr_concl = '10' and NEW.equ_pretrait || NEW.equ_trait || NEW.equ_rejet <> '101010' THEN
  	RAISE EXCEPTION 'Votre conclusion n''est pas cohérente avec les équipements contrôlés. Vous devez indiquer "Aucun" équipements contrôlés pour conclure à une absence d''installation';
   END IF;

   -- si il existe déjà un contrôle avec une même date de visite, pas possible
   if (select count(*) from m_spanc.an_spanc_controle where date_vis = new.date_vis and idinstal = new.idinstal) > 0 then 
   RAISE exception 'Vous ne pouvez pas saisir ce contrôle. Il existe déjà un contrôle sur cette installation avec la même date de viste';
   end if;
  
   -- si aucune date de visite n'est renseignée, l'enregistrement de la conformité ne peut pas avoir lieu (sauf si Non renseigné)
   if new.date_vis is not null and new.contr_concl = '00' then 
   RAISE EXCEPTION 'Vous ne pouvez pas enregistrer le contrôle avec une date de visite et mettre en conclusion "Non renseignée".';
   end if;
  
  -- si aucune date de visite est renseignée, l'enregistrement de la conformité ne peut pas avoir lieu si Non renseigné sauf si la nature du contrôle n'est pas liée à une demande de travaux)
   if new.date_vis is null and new.contr_concl <> '00' and new.contr_nat in ('13','14','20','30','40','50','60') then 
   RAISE EXCEPTION 'Vous ne pouvez pas enregistrer le contrôle avec une conclusion différente de "Non renseigné" si vous n''indiquez pas une date de visite.';
   end if;

  /*
    -- aucune date de visite ne doit être renseignée si la nature du contrôle est liée à une demande de travaux)
   if new.date_vis is not null and new.contr_nat in ('11','12') then 
   RAISE EXCEPTION 'Vous ne pouvez pas indiquer une date de visite dans le cadre d''un contrôle lié à une demande de travaux.';
   end if;
*/
  -- si aucune date de demande
  if new.date_dem is null then
   RAISE EXCEPTION 'Vous devez renseigner obligatoirement la date de la demande.';
  end if;
 
   -- date de visite obligatoire si date d'un rapport ou de transmission
  if new.date_vis is null and (new.date_rap is not null or new.date_trap is not null) then
   RAISE EXCEPTION 'Vous devez saisir obligatoirement une date de visite';
  end if;
 
  -- si date de la demande supérieure à la date de la visite
  if new.date_dem > new.date_vis then
   RAISE EXCEPTION 'La date de la demande ne peut pas être supérieure à la date de visite.';
  end if;
 
   -- si date de la  visite est supérieur à la date du rapport
  if new.date_vis > new.date_rap then
   RAISE EXCEPTION 'La date de la visite ne peut pas être supérieure à la date du rapport.';
  end if;
 
    -- si date de la transmission du rapport est supérieur à la date du rapport
  if new.date_rap > new.date_trap then
   RAISE EXCEPTION 'La date de la transmission du rapport ne peut pas être supérieure à la date du rapport.';
  end if;
 
   -- si date de la visite est supérieur à la date de la transmission rapport
  if new.date_vis > new.date_trap then
   RAISE EXCEPTION 'La date de la visite ne peut pas être supérieure à la date de transmission du rapport.';
  end if;
 
   -- si date de transmission du rapport, la date du rapport ne peut pas être null
  if new.date_trap IS NOT null and new.date_rap IS null then
   RAISE EXCEPTION 'Une date de transmission du rapport ne peut pas être indiqué sans indiquer la date du rapport.';
  end if;
 
    -- si date du RDV est inférieure à la demande
    if new.date_dem > new.date_rdv then
   RAISE EXCEPTION 'La date du RDV ne peut pas être inférieure à la date de la demande.';
  end if;
 
    -- si date du RDV est inférieure à la date de prise de rdv
    if new.date_prdv > new.date_rdv then
   RAISE EXCEPTION 'La date de prise de RDV ne peut pas être supérieure à la date du RDV.';
  end if;
 
 -- si mode de gestion = prestataire doit en choisir 1
 if left(new.mod_gest,1) = '2' and new.idpresta is null then 
 	RAISE EXCEPTION 'Vous devez choisir un prestataire dans la liste.';
 end if;

 -- si montant acquité, date de facturation doit-être indiquée
 if new.acq_fact is true and new.date_fact is null then 
    RAISE EXCEPTION 'Si vous acquitez une facture, il faut renseigner obligatoirement la date de facturation.';
 end if;

 -- si date de facturation > à la date de translmission du rapport
 if new.date_fact < new.date_trap then 
    RAISE EXCEPTION 'Vous ne pouvez pas indiquer une date de facturation inférieure à la date d''envoi du rapport.';
 end if;


   -- initialisation du verrou minimum sur les données à la saisie (après les contrôles)
   if new.date_trap is not null then
      new.verrou_min := true;
   end if;
  
    -- initialisation du verrou minimum sur les données à la saisie (après les contrôles)
   if new.date_trap is not null and new.date_fact is not null and new.acq_fact is true then
      new.verrou_max := true;
   end if;
  

   return new;
	
  --A LA MISE A JOUR
	
  elseif TG_OP = 'UPDATE' then
	
    
  
    -- VERROU : les contrôles sont verrouillés (non modifiables) si date de transmission du rapport renseignée (sauf les montants facturés)
    -- si montant acquité en +, rien de peut être modifié
  
    -- verrou minimum
	if (select verrou_min from m_spanc.an_spanc_controle where idcontr = new.idcontr) is true 
	and 
	(
	case when new.observ is null or new.observ = '' then '1' else new.observ end <> case when old.observ is null or old.observ = '' then '1' else old.observ end
	or 
	case when new.idcontr_epci is null or new.idcontr_epci = '' then '1' else new.idcontr_epci end <> case when old.idcontr_epci is null or old.idcontr_epci = '' then '1' else old.idcontr_epci end
	or 
	new.contr_nat <> old.contr_nat
	or 
	new.mod_gest <> old.mod_gest
	or 
	new.idpresta <> old.idpresta
	or 
	new.iddsp <> old.iddsp
	or 
	new.date_env <> old.date_env
	or 
	new.equ_pretrait <> old.equ_pretrait
	or 
	new.equ_trait <> old.equ_trait
	or 
	new.equ_rejet <> old.equ_rejet
	or 
	new.contr_concl <> old.contr_concl
	or 
	new.date_dem <> old.date_dem
	or 
	new.date_prdv <> old.date_prdv
	or 
	new.date_rdv <> old.date_rdv
	or 
	new.date_vis <> old.date_vis
	or 
	new.date_rap <> old.date_rap
	or 
	new.date_trap <> old.date_trap 
	or 
	new.date_act <> old.date_act
	or 
	new.contr_info <> old.contr_info
	) then 
	RAISE EXCEPTION 'VERROU MINIMUM - vous pouvez modifier uniquement les élements de facturation non encore complétés.';
    end if;
   
    -- verrou maximum
	if (select verrou_max from m_spanc.an_spanc_controle where idcontr = new.idcontr) is true 
	and 
	(
	new.date_fact <> old.date_fact
	or 
	new.mont_fact <> old.mont_fact
	or 
	new.mont_pen <> old.mont_pen
	or 
	new.acq_fact <> old.acq_fact
	) then 
	RAISE EXCEPTION 'VERROU MAXIMUM - vous ne pouvez pas modifier un contrôle transmis avec une facture acquitée.';
    end if;
  
  
	-- SAISIE AUTOMATIQUE DE LA CONFORMITE
	
	-- si conclusion = absence d'installation
	-- conformité = absence d'installation
    IF NEW.contr_concl = '10' THEN
       NEW.contr_confor := '30'; 
    END IF;

   -- si conclusion = Installation ne présentant pas de défaut apparent
	-- conformité = conforme 
    IF NEW.contr_concl = '20' THEN
       NEW.contr_confor := '10'; 
    END IF;
   
    -- si conclusion = Installation présentant un défaut ou incomplète, sous-dimensionnée, avec dysfonctionnement
	-- conformité = conforme 
    IF NEW.contr_concl IN ('31','32','40') THEN
       NEW.contr_confor := '20'; 
    END IF;
   
    -- si conclusion = refus du contrôles
	-- conformité = conforme 
    IF NEW.contr_concl = 'ZZ' THEN
       NEW.contr_confor := 'ZZ'; 
    end if;
   
    -- si conclusion = N.R
	-- conformité = N.R 
    IF NEW.contr_concl = '00' THEN
       NEW.contr_confor := '00'; 
    END IF;

   -- un contrôle lié à une installation supprimée ne peut pas être modifiée
   if (select count(*) from m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i where i.idinstal = c.idinstal and i.inst_etat='20' and c.idcontr = new.idcontr) > 0 THEN
   raise exception 'Vous ne pouvez pas modifier un contrôle d''une installation désactivée.';   
   end if;
  
   -- si il existe déjà un contrôle avec une même date de visite, pas possible
   if (select count(*) from m_spanc.an_spanc_controle where date_vis = new.date_vis and idinstal = new.idinstal) > 0 then 
   RAISE exception 'Vous ne pouvez pas modifier ce contrôle. Il existe déjà un contrôle sur cette installation avec la même date de viste';
   end if;
  
   -- CONTROLE SI DATE_VISITE renseigné ne peux plus modifier modifier le prestataire
   if new.date_vis is not null and old.idpresta <> new.idpresta then 
   raise exception 'Vous ne pouvez pas modifier le prestataire car la date de visite est renseignée.';
   end if;
  
      -- CONTROLE SI DATE_VISITE renseigné ne peux plus modifier modifier le mode de gestion
   if new.date_vis is not null and old.mod_gest <> new.mod_gest then 
   raise exception 'Vous ne pouvez pas modifier le mode de gestion car la date de visite est renseignée.';
   end if;
  
    if new.date_vis is not null and (old.iddsp <> new.iddsp or old.idpresta <> new.idpresta) then 
   raise exception 'Vous ne pouvez pas modifier le prestataire ou la DSP car la date de visite est renseignée.';
   end if;
   
     -- SI DATE DE VISITE NE PEUT PAS MODIFIER LE MODE DE GESTION 
   if (old.date_vis <> new.date_vis or old.date_vis = new.date_vis) and old.mod_gest <> new.mod_gest then
   raise exception 'Vous ne pouvez pas modifier le mode de gestion car la date de visite est déjà renseignée.'	;
   end if;
   
     -- SI MODIFICATION DU MODE DE GESTION EN REGIE AU LIEU DU PRESTA OU DE LA DSP
   if left(new.mod_gest,1) = '1' and (left(old.mod_gest,1) = '2' or left(old.mod_gest,1) = '3') then 
   new.idpresta := null;
   new.iddsp := null;
   end if;
  
  -- SI MODIFICATION DU MODE DE GESTION PRESTA AU LIEU DU DSP
   if left(new.mod_gest,1) = '2' and left(old.mod_gest,1) = '3' then 
  --raise EXCEPTION 'ok1';
  new.iddsp := null;
   end if;
  
    -- SI MODIFICATION DU MODE DE GESTION DSP AU LIEU DU PRESTA ou de REGIE
   if left(new.mod_gest,1) = '3' and (left(old.mod_gest,1) = '2' or left(old.mod_gest,1) = '1') then 
   --raise EXCEPTION 'ok2';
   new.idpresta := null;
   new.iddsp := (select iddsp from m_spanc.an_spanc_dsp where epci = new.epci and date_fin is null);
   end if;

  
 	-- si il y a au moins une installation à NR ou à aucun, la conclusion ne peut pas être différente de installation incomplète
   if new.contr_concl <> '10' THEN
   IF NEW.contr_concl <> '40' and NEW.contr_concl <> '20' and NEW.contr_concl <> '00' and NEW.contr_concl <> 'ZZ'
   	  AND NEW.equ_pretrait || NEW.equ_trait || NEW.equ_rejet LIKE '%00%' THEN
   	RAISE EXCEPTION 'Votre conclusion n''est pas cohérente avec les équipements contrôlés. Vous ne pouvez pas avoir un équipement renseignés à "Non renseigné"';
   END IF;
    end if;
   
    -- si contrôle conforme on ne peut pas avoir d'équipement à '00', 'ZZ' ou '10'
   if  (new.contr_concl = '20' and NEW.equ_pretrait || NEW.equ_trait || NEW.equ_rejet like '%00%')
       or (new.contr_concl = '20' and NEW.equ_pretrait || NEW.equ_trait || NEW.equ_rejet like '%10%')
   THEN
  	RAISE EXCEPTION 'Votre conclusion n''est pas cohérente avec les équipements contrôlés. Vous ne pouvez pas laisser des équipements à "Non renseignés" ou à "Aucun"';
   END IF;
   
	
   -- si aucun équipement, seule l'absence d'installation peut être indiqué en contrôle
   if  new.contr_concl = '10' and NEW.equ_pretrait || NEW.equ_trait || NEW.equ_rejet <> '101010' THEN
  	RAISE EXCEPTION 'Votre conclusion n''est pas cohérente avec les équipements contrôlés. Vous devez indiquer "Aucun" équipements contrôlés pour conclure à une absence d''installation';
   END IF;

  
   -- si aucune date de visite n'est renseignée, l'enregistrement de la conformité ne peut pas avoir lieu (sauf si Non renseigné)
   if new.date_vis is not null and new.contr_concl = '00' then 
   RAISE EXCEPTION 'Vous ne pouvez pas enregistrer le contrôle avec une date de visite et mettre en conclusion "Non renseignée".';
   end if;
  
  -- si aucune date de visite est renseignée, l'enregistrement de la conformité ne peut pas avoir lieu si Non renseigné sauf si la nature du contrôle n'est pas liée à une demande de travaux)
   if new.date_vis is null and new.contr_concl <> '00' and new.contr_nat in ('13','14','20','30','40','50','60') then 
   RAISE EXCEPTION 'Vous ne pouvez pas enregistrer le contrôle avec une conclusion différente de "Non renseigné" si vous n''indiquez pas une date de visite.';
   end if;
  
    -- date de visite obligatoire si date d'un rapport ou de transmission
  if new.date_vis is null and (new.date_rap is not null or new.date_trap is not null) then
   RAISE EXCEPTION 'Vous devez saisir obligatoirement une date de visite';
  end if;
  /*
      -- aucune date de visite ne doit être renseignée si la nature du contrôle est liée à une demande de travaux)
   if new.date_vis is not null and new.contr_nat in ('11','12') then 
   RAISE EXCEPTION 'Vous ne pouvez pas indiquer une date de visite dans le cadre d''un contrôle lié à une demande de travaux.';
   end if;
*/
  -- si aucune date de demande
  if new.date_dem is null then
   RAISE EXCEPTION 'Vous devez renseigner obligatoirement la date de la demande';
  end if;
 
  -- si date de la demande supérieure à la date de la visite
  if new.date_dem > new.date_vis then
   RAISE EXCEPTION 'La date de la demande ne peut pas être supérieure à la date de visite';
  end if;
 
    -- si date de la  visite est supérieur à la date du rapport
  if new.date_vis > new.date_rap then
   RAISE EXCEPTION 'La date de la visite ne peut pas être supérieure à la date du rapport.';
  end if;
 
    -- si date de la transmission du rapport est supérieur à la date du rapport
  if new.date_rap > new.date_trap then
   RAISE EXCEPTION 'La date de la transmission du rapport ne peut pas être supérieure à la date du rapport.';
  end if;
 
   -- si date de la visite est supérieur à la date de la transmission rapport
  if new.date_vis > new.date_trap then
   RAISE EXCEPTION 'La date de la visite ne peut pas être supérieure à la date de transmission du rapport.';
  end if;
 
   -- si date de transmission du rapport, la date du rapport ne peut pas être null
  if new.date_trap IS NOT null and new.date_rap IS null then
   RAISE EXCEPTION 'Une date de transmission du rapport ne peut pas être indiqué sans indiquer la date du rapport.';
  end if;
 
  -- si date de prise de RDV est inférieure à la demande
    if new.date_dem > new.date_prdv then
   RAISE EXCEPTION 'La date de prise de RDV ne peut pas être inférieure à la date de la demande.';
  end if;
 
   -- si date du RDV est inférieure à la demande
    if new.date_dem > new.date_rdv then
   RAISE EXCEPTION 'La date du RDV ne peut pas être inférieure à la date de la demande.';
  end if;
 
    -- si date du RDV est inférieure à la date de prise de rdv
    if new.date_prdv > new.date_rdv then
   RAISE EXCEPTION 'La date de prise de RDV ne peut pas être supérieure à la date du RDV.';
  end if;
  
    -- si date du RDV est inférieure à la date de prise de rdv
    if new.date_prdv > new.date_rdv then
   RAISE EXCEPTION 'La date de prise de RDV ne peut pas être supérieure à la date du RDV.';
  end if;
 
 
  -- si mode de gestion = prestataire doit en choisir 1
 if left(new.mod_gest,1) = '2' and new.idpresta is null then 
 	RAISE EXCEPTION 'Vous devez choisir un prestataire dans la liste.';
 end if;

 -- si montant acquité, date de facturation doit-être indiquée
 if new.acq_fact is true and new.date_fact is null then 
    RAISE EXCEPTION 'Si vous acquitez une facture, il faut renseigner obligatoirement la date de facturation.';
 end if;

 -- si date de facturation > à la date de translmission du rapport
 if new.date_fact < new.date_trap then 
    RAISE EXCEPTION 'Vous ne pouvez pas indiquer une date de facturation inférieure à la date d''envoi du rapport.';
 end if;


   -- initialisation du verrou minimum sur les données à la saisie (après les contrôles)
   if new.date_trap is not null then
      new.verrou_min := true;
   end if;
  
    -- initialisation du verrou minimum sur les données à la saisie (après les contrôles)
   if new.date_trap is not null and new.date_fact is not null and new.acq_fact is true then
      new.verrou_max := true;
   end if;


   return new ;

  -- A LA SUPPRESSION
  
elseif TG_OP='DELETE' then

	if (select count(*) from m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i where i.idinstal = c.idinstal and i.inst_etat ='10' and c.idcontr = old.idcontr) > 0 then

	  RAISE EXCEPTION 'Vous ne pouvez pas supprimer de contrôle.';

	end if;

 return new ;

end if;

  
END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_conform() IS 'Fonction générant automatiquement la conformité selon la conclusion du contrôle et la vérification de la saisie du contrôle';



-- ################################################################# Fonction - ft_m_controle_conform_after  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_conform_after()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$


begin
	
   -- un contrôle lié à une installation supprimée ne peut pas être inséré
   if (select count(*) from m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i where i.idinstal = c.idinstal and i.inst_etat ='20' and c.idcontr = new.idcontr) > 0 then
   delete from m_spanc.an_spanc_controle c where c.idcontr = new.idcontr;
   raise exception 'Vous ne pouvez pas insérer un contrôle liée à une installation désactivée.';   
   end if;
  return old;
END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_conform_after() IS 'Fonction générant la non insertion d''contrôle si l''installation est désactivée (supprimer le contrôle inséré et renvoi un message';


-- ################################################################# Fonction - ft_m_controle_dsp  ############################################   
   
CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_dsp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

begin
	
if TG_OP ='INSERT' THEN
	-- RAISE EXCEPTION 'ok'; 
    -- une nouvelle DSP ne peut pas être insérée si une autre est toujours active
	if (select count(*) from m_spanc.an_spanc_dsp where epci = 
	(select values from custom_attributes ca where name = 'epci' and user_login = NEW.op_sai) and date_fin is null) = 1  then
	 RAISE EXCEPTION 'Vous ne pouvez pas ajouter une nouvelle DSP sans clore la précédente (indiquer une date de fin).';	
	end if;
	
    -- une nouvelle DSP doit avoir une date supérieure ou égale à la date de fin de la dernière
    IF NEW.date_deb < (SELECT max(date_fin) FROM m_spanc.an_spanc_dsp WHERE epci = NEW.epci) THEN
     RAISE EXCEPTION 'Votre nouvelle DSP doit avoir une date de début au moins égale à la date de fin de la dernière';
    END IF;

   return new ;
elseif TG_OP = 'UPDATE' then
   
    --DSP doit avoir une date supérieure ou égale à la date de fin de la dernière
    IF old.date_deb > new.date_fin THEN
     RAISE EXCEPTION 'Votre DSP doit avoir une date de fin supérieure à la date de début';
    END IF;

   return new ;
elseif TG_OP='DELETE' then

RAISE EXCEPTION 'Vous ne pouvez pas supprimer de DSP.';

 return new ;

end if;

 return new ;
  
END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_dsp() IS 'Fonction générant les contrôles de saisies des DSP';

-- ################################################################# Fonction - ft_m_controle_presta  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_presta()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

begin
	
 if TG_OP='DELETE' then
   if old.idpresta in (select distinct idpresta from m_spanc.an_spanc_controle) THEN
   RAISE EXCEPTION 'Vous ne pouvez pas supprimer le prestataire car il est lié à des contrôles.';
   end if;
 return old ;

end if;

 return new ;
  
END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_presta() IS 'Fonction générant les contrôles de saisies des prestataires';

   
-- ################################################################# Fonction - ft_m_update_install_equi  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_update_install_equi()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

begin

	
 -- mise à jour des équipements de l'installation par le dernier contrôle uniquement

-- récupération de la date de visite du dernier contrôle pour comparaison avec le contrôle modifié
IF (select ad.idcontr
      FROM  
      (       
      SELECT DISTINCT 
             a.idcontr,
             a.idinstal,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
                   where c.idinstal = i.idinstal AND date_trap is not null
                  GROUP BY c.idinstal) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
                  ) ad 
                  WHERE ad.idinstal = new.idinstal
                  group by ad.idcontr) = NEW.idcontr
 THEN	
	
 UPDATE m_spanc.an_spanc_installation SET 
 	equ_pretrait = NEW.equ_pretrait,
 	equ_trait = NEW.equ_trait,
 	equ_rejet = NEW.equ_rejet
 WHERE idinstal = NEW.idinstal;
END IF;
 return new ;


END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_update_install_equi() IS 'Fonction générant la mise à jour des équipements au niveau de l''installation';


-- ################################################################# Fonction - ft_m_controle_conf  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_conf()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

begin
	
-- A LA SUPPRESSION
  
if TG_OP='DELETE' then

RAISE EXCEPTION 'Vous ne pouvez pas supprimer la configuration.';

 return new ;

end if;

 return new ;

END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_conf() IS 'Fonction sécurisant la non suppression de la configuration des périodicités.';


-- ################################################################# Fonction - ft_m_controle_instal_media  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_instal_media()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

begin

	 -- si une installation est désactivée on ne doit pas pouvoir intégrer, modifier ou supprimer un média	
if TG_OP='UPDATE' or TG_OP = 'INSERT' then	
 if (select inst_etat from m_spanc.an_spanc_installation where idinstal = new.id) = '20' THEN
   RAISE EXCEPTION 'INSTALLATION DESACTIVEE - vous ne pouvez pas insérer, modifier ou supprimer de documents.';
 end if;

elseif TG_OP='DELETE' then
	 if (select inst_etat from m_spanc.an_spanc_installation where idinstal = old.id) = '20' THEN
   RAISE EXCEPTION 'INSTALLATION DESACTIVEE - vous ne pouvez pas insérer, modifier ou supprimer de documents.';
 end if;
end if;
 return new ;
  
END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_instal_media() IS 'Fonction générant les contrôles de saisies des médias pour les installations';


-- ################################################################# Fonction - ft_m_controle_media  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_media()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

begin

	 -- si un contrôle est désactivée on ne doit pas pouvoir intégrer, modifier ou supprimer un média	
if TG_OP='UPDATE' or TG_OP = 'INSERT' then	

 if (select verrou_min from m_spanc.an_spanc_controle where idcontr = new.id) is true and 
     (select verrou_max from m_spanc.an_spanc_controle where idcontr = new.id) is false and 
     new.t_doc in ('00','10','20','30','40')
     THEN
   RAISE EXCEPTION 'CONTROLE VERROUILLE - vous ne pouvez pas insérer, modifier ou supprimer de documents.';
 end if;
  if (select verrou_min from m_spanc.an_spanc_controle where idcontr = new.id) is true and 
  (select verrou_max from m_spanc.an_spanc_controle where idcontr = new.id) is true THEN
   RAISE EXCEPTION 'CONTROLE VERROUILLE - vous ne pouvez pas insérer, modifier ou supprimer de documents.';
 end if;

elseif TG_OP='DELETE' then

      if (select verrou_min from m_spanc.an_spanc_controle where idcontr = old.id) is true and 
     (select verrou_max from m_spanc.an_spanc_controle where idcontr = old.id) is false and 
     old.t_doc in ('00','10','20','30','40')
     THEN
   RAISE EXCEPTION 'CONTROLE VERROUILLE - vous ne pouvez pas insérer, modifier ou supprimer de documents.';
      end if;

	 if (select verrou_min from m_spanc.an_spanc_controle where idcontr = old.id) is true and 
	 (select verrou_max from m_spanc.an_spanc_controle where idcontr = old.id) is true THEN
   RAISE EXCEPTION 'CONTROLE VERROUILLE - vous ne pouvez pas insérer, modifier ou supprimer de documents.';
 end if;
end if;
 return new ;
  
END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_controle_media() IS 'Fonction générant les contrôles de saisies des médias pour les contrôles';


-- ################################################################# Fonction - ft_m_spanc_log  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_spanc_log()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

DECLARE v_idlog integer;
DECLARE v_dataold character varying(50000);
DECLARE v_datanew character varying(50000);
DECLARE v_name_table character varying(254);

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

  v_idlog := nextval('m_spanc.an_spanc_log_seq'::regclass);
  v_datanew := ROW(NEW.*); ------------------------------------ On concatène tous les attributs dans un seul

  ---
  INSERT INTO m_spanc.an_spanc_log (idlog, tablename, type_ope, dataold, datanew, date_maj)
  SELECT
  v_idlog,
  TG_TABLE_NAME,
  'INSERT',
  NULL,
  v_datanew,
  now();

  ---
  
  RETURN NEW;
  

-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN 
  ---
  
   v_idlog := nextval('m_spanc.an_spanc_log_seq'::regclass);
  v_dataold := ROW(OLD.*);------------------------------------ On concatène tous les anciens attributs dans un seul
  v_datanew := ROW(NEW.*);------------------------------------ On concatène tous les nouveaux attributs dans un seul	
  v_name_table := TG_TABLE_NAME;

  ---
  
  INSERT INTO m_spanc.an_spanc_log (idlog, tablename,  type_ope, dataold, datanew, date_maj)
  SELECT
  v_idlog,
  v_name_table,
  'UPDATE',
  v_dataold,
  v_datanew,
  now();
  RETURN NEW;

-- DELETE
ELSIF (TG_OP = 'DELETE') THEN 
  ---
  
  v_idlog := nextval('m_spanc.an_spanc_log_seq'::regclass);
  v_dataold := ROW(OLD.*);------------------------------------ On concatène tous les anciens attributs dans un seul
  v_name_table := TG_TABLE_NAME;

  ---
  
  INSERT INTO m_spanc.an_spanc_log (idlog, tablename,  type_ope, dataold, datanew, date_maj)
  SELECT
  v_idlog,
  v_name_table,
  'DELETE',
  v_dataold,
  NULL,
  now();
  RETURN OLD;
  

END IF;

end;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_spanc_log() IS 'Fonction gérant l''insertion d''une opération effectuée sur les données du spanc dans la table des logs';



-- ################################################################# Fonction - ft_m_refresh_instal  ############################################

CREATE OR REPLACE FUNCTION m_spanc.ft_m_refresh_instal()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

begin
	
 refresh materialized view m_spanc.xapps_geo_vmr_spanc_anc;
 return new ;

END;

$function$
;

COMMENT ON FUNCTION m_spanc.ft_m_refresh_instal() IS 'Fonction rafraichissant la vue xapps_geo_vmr_spanc_anc pour localisater les adresses avec ou sans installation.';


-- ################################################################# Fonction - ft_m_controle_adresse_associe (plus utilisée)  ############################################
/*
CREATE OR REPLACE FUNCTION m_spanc.ft_m_controle_adresse_associe()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

begin

if (
with 
req_buffer as 
(
select st_buffer(a.geom,100) as geom_buffer from x_apps.xapps_geo_vmr_adresse a, m_spanc.an_spanc_installation i where i.idadresse = a.id_adresse and i.idinstal = new.idinstal
)
select 
case when st_intersects(a1.geom,b.geom_buffer) is true then 'adresse possible' else 'adresse impossible' end as test
from 
req_buffer b, x_apps.xapps_geo_vmr_adresse a1 where a1.id_adresse = new.idadresse) = 'adresse impossible'
then 
RAISE EXCEPTION 'L''adresse associée est à plus de 100 mètres de l''installation sélectionnée. Veuillez vérifier votre association.';

end if;

 return new ;

END;

$function$
;
COMMENT ON FUNCTION m_spanc.ft_m_controle_adresse_associe() IS 'Fonction vérifiant que l''adresse associée pour une installation est dans un rayon de 100 mètres de l''installation.';
*/
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                TABLE                                                                         ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ################################################# Classe des objets des installations : an_spanc_installation ##################################

CREATE TABLE m_spanc.an_spanc_installation
(
    idinstal bigint NOT NULL DEFAULT nextval('m_spanc.an_spanc_installation_id_seq'::regclass),
    idadresse bigint NOT NULL,
    adcompl text COLLATE pg_catalog."default",
    typ_im character varying(2) COLLATE pg_catalog."default",
    equ_pretrait text COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    equ_trait text COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,    
    equ_rejet text COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,    
    inst_eh character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    inst_com boolean NOT NULL DEFAULT false,
    inst_acontr boolean NOT NULL DEFAULT true,
    inst_conv boolean NOT NULL DEFAULT false,
    date_crea timestamp without time zone,
    inst_age integer,
	inst_etat character varying(2) COLLATE pg_catalog."default" DEFAULT '10'::character varying not NULL,
	cad_sect character varying(2) COLLATE pg_catalog."default",
	cad_par character varying(4) COLLATE pg_catalog."default",
	observ character varying(5000) COLLATE pg_catalog."default",
    date_sai timestamp without time ZONE NOT NULL,
    date_maj timestamp without time zone,
    op_sai character varying(20) COLLATE pg_catalog."default" NOT NULL,
    op_maj character varying(20) COLLATE pg_catalog."default",
    epci text COLLATE pg_catalog."default" NOT NULL,
    geom1 geometry(point,2154) NOT NULL,
    CONSTRAINT an_spanc_installation_pkey PRIMARY KEY (idinstal),
    CONSTRAINT an_spanc_installation_typim_fkey FOREIGN KEY (typ_im)
        REFERENCES m_spanc.lt_spanc_typimmeuble (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION, 
    CONSTRAINT an_spanc_installation_eh_fkey FOREIGN KEY (inst_eh)
        REFERENCES m_spanc.lt_spanc_eh (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,     
    CONSTRAINT an_spanc_installation_inst_etat_fkey FOREIGN KEY (inst_etat)
        REFERENCES m_spanc.lt_spanc_etatinstall (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION         
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.an_spanc_installation
    IS 'Classe d''objets pour la gestion des installations ANC';

COMMENT ON COLUMN m_spanc.an_spanc_installation.idinstal
    IS 'Identifiant interne non signifiant';
COMMENT ON COLUMN m_spanc.an_spanc_installation.idadresse
    IS 'Identifiant de base adresse locale du Grand Compiégnois';
COMMENT ON COLUMN m_spanc.an_spanc_installation.adcompl
    IS 'Complément d''adresse';   
COMMENT ON COLUMN m_spanc.an_spanc_installation.typ_im
    IS 'Type d''immeuble concerné';
COMMENT ON COLUMN m_spanc.an_spanc_installation.equ_pretrait
    IS 'Equipement de pré-traitement';
   COMMENT ON COLUMN m_spanc.an_spanc_installation.equ_trait
    IS 'Equipement de traitement';
COMMENT ON COLUMN m_spanc.an_spanc_installation.equ_rejet
    IS 'Equipement de rejet';   
COMMENT ON COLUMN m_spanc.an_spanc_installation.inst_eh
    IS 'Equivalent habitant de l''installation';
COMMENT ON COLUMN m_spanc.an_spanc_installation.inst_com
    IS 'Installation commune à plusieurs immeubles';
COMMENT ON COLUMN m_spanc.an_spanc_installation.inst_acontr
    IS 'Installation soumis à un contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_installation.inst_conv
    IS 'Installation soumis à une convention';
COMMENT ON COLUMN m_spanc.an_spanc_installation.date_crea
    IS 'Date de création de l''installation';
COMMENT ON COLUMN m_spanc.an_spanc_installation.inst_age
    IS 'Age de l''installation sans connaître la date de création';   
COMMENT ON COLUMN m_spanc.an_spanc_installation.inst_etat
    IS 'Etat de l''installation';
COMMENT ON COLUMN m_spanc.an_spanc_installation.cad_sect
    IS 'Section cadastrale';
COMMENT ON COLUMN m_spanc.an_spanc_installation.cad_par
    IS 'Parcelle cadastrale';
COMMENT ON COLUMN m_spanc.an_spanc_installation.observ
    IS 'Commentaires divers';
COMMENT ON COLUMN m_spanc.an_spanc_installation.date_sai
    IS 'Date de saisie des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_installation.date_maj
    IS 'Date de mise à jour des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_installation.op_sai
    IS 'Opérateur ayant saisi l''information d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_installation.op_maj
    IS 'Opérateur ayant modifier les informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_installation.epci
    IS 'Acronyme de l''EPCI d''assise de l''installation';
COMMENT ON COLUMN m_spanc.an_spanc_installation.geom1
    IS 'Géométrie du point d''adresse récupéré à la saisie pour la fonctionnalité d''association d''adresse à une installation pour la sélection via l''objet courant dans GEO et affichage des adresses dans un rayon de 50m';   

-- Index: an_spanc_installation_idinstal_idx
-- DROP INDEX m_spanc.an_spanc_installation_idinstal_idx;

CREATE INDEX an_spanc_installation_idinstal_idx
    ON m_spanc.an_spanc_installation USING btree
    (idinstal ASC NULLS LAST)
    TABLESPACE pg_default;

   
create trigger t_t1_an_spanc_installation_date_sai before
insert on
    m_spanc.an_spanc_installation for each row execute procedure ft_r_timestamp_sai();
   
create trigger t_t2_an_spanc_installation_date_maj before
update on
    m_spanc.an_spanc_installation for each row execute procedure ft_r_timestamp_maj();
   
create trigger t_t3_an_spanc_installation_controle_saisie before
INSERT OR update on
    m_spanc.an_spanc_installation for each row execute procedure m_spanc.ft_m_controle_saisie_instal();   

create trigger t_t8_refresh_carto after
insert or delete or update
    on
    m_spanc.an_spanc_installation for each row execute procedure m_spanc.ft_m_refresh_instal();

create trigger t_t9_autorite_competente before
INSERT on
    m_spanc.an_spanc_installation for each row execute procedure ft_r_autorite_competente_user_login();

create trigger t_t100_log after
insert or delete or update
    on
    m_spanc.an_spanc_installation for each row execute procedure m_spanc.ft_m_spanc_log();  
   
-- ################################################# Classe des objets des contacts des installations : an_spanc_contact ##################################

CREATE TABLE m_spanc.an_spanc_contact
(
    idcontact bigint NOT NULL DEFAULT nextval('m_spanc.an_spanc_contact_id_seq'::regclass),
    ref_typ character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    ref_patro character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    ref_autre text COLLATE pg_catalog."default" ,
    ref_nom text COLLATE pg_catalog."default",
    ref_prenom text COLLATE pg_catalog."default",
    ref_tel character varying(10) COLLATE pg_catalog."default",
    ref_telp character varying(10) COLLATE pg_catalog."default",
    ref_email text COLLATE pg_catalog."default",
    adcompl text COLLATE pg_catalog."default",
    adautre boolean NOT NULL DEFAULT false,
    adautre_lib text COLLATE pg_catalog."default",
    factu_cont boolean NOT NULL DEFAULT false,
	factu_adc boolean NOT NULL DEFAULT false,
	factu_ad text,
	date_sai timestamp without time zone,
    date_maj timestamp without time zone,
    op_sai character varying(20) COLLATE pg_catalog."default" NOT NULL,
    op_maj character varying(20) COLLATE pg_catalog."default",
    epci text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT an_spanc_contact_pkey PRIMARY KEY (idcontact),
    CONSTRAINT an_spanc_contact_reftyp_fkey FOREIGN KEY (ref_typ)
        REFERENCES m_spanc.lt_spanc_typcontact (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT an_spanc_installation_refpatro_fkey FOREIGN KEY (ref_patro)
        REFERENCES m_spanc.lt_spanc_patro (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION        
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.an_spanc_contact
    IS 'Classe d''objets pour la gestion des contacts de chaque installation';   

COMMENT ON COLUMN m_spanc.an_spanc_contact.idcontact
    IS 'Identifiant interne non signifiant';
COMMENT ON COLUMN m_spanc.an_spanc_contact.ref_typ
    IS 'Typologie de la référence pour le contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_contact.ref_patro
    IS 'Patronyme du référent';
COMMENT ON COLUMN m_spanc.an_spanc_contact.ref_autre
    IS 'Libellé de l''organisme référente pour le contrôle (si type de référent est autre)';
COMMENT ON COLUMN m_spanc.an_spanc_contact.ref_nom
    IS 'Nom de la personne physique référente pour le contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_contact.ref_prenom
    IS 'Prénom de la personne physique référente pour le contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_contact.ref_tel
    IS 'Téléphone du référent pour le contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_contact.ref_telp
    IS 'Téléphone portable du référent pour le contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_contact.ref_email
    IS 'Email du référent pour le contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_contact.adcompl
    IS 'Complément d''adresse';
COMMENT ON COLUMN m_spanc.an_spanc_contact.adautre
    IS 'Adresse différente du lieu';     
COMMENT ON COLUMN m_spanc.an_spanc_contact.adautre_lib
    IS 'Libellé de l''Adresse différente du lieu';   
COMMENT ON COLUMN m_spanc.an_spanc_contact.factu_cont
    IS 'Contact pour la facturation';
COMMENT ON COLUMN m_spanc.an_spanc_contact.factu_adc
    IS 'Adresse de facturation différente de l''adresse de l''installation';
COMMENT ON COLUMN m_spanc.an_spanc_contact.factu_ad
    IS 'Adresse de facturation';
COMMENT ON COLUMN m_spanc.an_spanc_contact.date_sai
    IS 'Date de saisie des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_contact.date_maj
    IS 'Date de mise à jour des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_contact.op_sai
    IS 'Opérateur ayant saisi l''information d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_contact.op_maj
    IS 'Opérateur ayant modifier les informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_contact.epci
    IS 'Acronyme de l''EPCI d''assise de l''installation';
   
   
-- Index: an_spanc_contact_idcontact_idx
-- DROP INDEX m_spanc.an_spanc_contact_idcontact_idx;

CREATE INDEX an_spanc_contact_idcontact_idx
    ON m_spanc.an_spanc_contact USING btree
    (idcontact ASC NULLS LAST)
    TABLESPACE pg_default;
   
   
create trigger t_t1_an_spanc_contact_date_sai before
insert
    on
    m_spanc.an_spanc_contact for each row execute procedure ft_r_timestamp_sai();
    
create trigger t_t2_an_spanc_contact_date_maj before
update
    on
    m_spanc.an_spanc_contact for each row execute procedure ft_r_timestamp_maj();
   
create trigger t_t3_an_spanc_contact_controle_saisie before
insert OR update
    on
    m_spanc.an_spanc_contact for each row execute procedure m_spanc.ft_m_controle_saisie_contact();
    
create trigger t_t9_autorite_competente before
insert
    on
    m_spanc.an_spanc_contact for each row execute procedure ft_r_autorite_competente_user_login();   

create trigger t_t100_log after
insert or delete or update
    on
    m_spanc.an_spanc_contact for each row execute procedure m_spanc.ft_m_spanc_log();     

-- ################################################# Classe des objets des contacts des installations : an_spanc_controle ##################################
--DROP TABLE IF EXISTS m_spanc.an_spanc_controle;
CREATE TABLE m_spanc.an_spanc_controle
(
    idcontr text COLLATE pg_catalog."default" NOT NULL,
    idcontr_epci text COLLATE pg_catalog."default",
    idinstal bigint NOT NULL,
	mod_gest character varying(2) COLLATE pg_catalog."default" NOT NULL,
	idpresta integer,
	iddsp integer,
	date_env timestamp without time zone,
    contr_nat character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    equ_pretrait text COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    equ_trait text COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,    
    equ_rejet text COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,    
    contr_concl character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    contr_confor character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    contr_nreal character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    date_dem timestamp without time zone,
    date_prdv timestamp without time zone,
    date_rdv timestamp without time zone,
    date_vis timestamp without time zone,
    date_rap timestamp without time zone,
    date_fact timestamp without time zone,
    mont_fact double precision,
    mont_pen double precision,
    acq_fact boolean NOT NULL DEFAULT false,
    date_trap timestamp without time zone,
    date_act timestamp without time zone,
    verrou_min boolean not null default false,
    verrou_max boolean not null default false,
    contr_info character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying not NULL,
    observ character varying(5000) COLLATE pg_catalog."default",
	date_sai timestamp without time zone,
    date_maj timestamp without time zone,
    op_sai character varying(20) COLLATE pg_catalog."default" NOT NULL,
    op_maj character varying(20) COLLATE pg_catalog."default",
    epci text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT an_spanc_controle_pkey PRIMARY KEY (idcontr),
    CONSTRAINT an_spanc_controle_contrnat_fkey FOREIGN KEY (contr_nat)
        REFERENCES m_spanc.lt_spanc_natcontr (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT an_spanc_controle_contrconcl_fkey FOREIGN KEY (contr_concl)
        REFERENCES m_spanc.lt_spanc_contcl (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT an_spanc_controle_contrconfor_fkey FOREIGN KEY (contr_confor)
        REFERENCES m_spanc.lt_spanc_confor (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT an_spanc_controle_contrnreal_fkey FOREIGN KEY (contr_nreal)
        REFERENCES m_spanc.lt_spanc_refus (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
     CONSTRAINT an_spanc_controle_contrinfo_fkey FOREIGN KEY (contr_info)
        REFERENCES m_spanc.lt_spanc_info (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
     CONSTRAINT an_spanc_controle_modgest_fkey FOREIGN KEY (mod_gest)
        REFERENCES m_spanc.lt_spanc_modgest (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION  
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.an_spanc_controle
    IS 'Classe d''objets pour la gestion des différents contrôles de chaque installation ANC';   

COMMENT ON COLUMN m_spanc.an_spanc_controle.idcontr
    IS 'Identifiant interne non signifiant';
COMMENT ON COLUMN m_spanc.an_spanc_controle.idcontr_epci
    IS 'Identifiant propre à l''EPCI';
COMMENT ON COLUMN m_spanc.an_spanc_controle.idinstal
    IS 'Identifiant de l''installation';
COMMENT ON COLUMN m_spanc.an_spanc_controle.mod_gest
    IS 'Mode de gestion du contrôle';   
COMMENT ON COLUMN m_spanc.an_spanc_controle.idpresta
    IS 'Identifiant du prestataire ayant réalisé le contrôle'; 
COMMENT ON COLUMN m_spanc.an_spanc_controle.iddsp
    IS 'Identifiant de la DSP ayant réalisé le contrôle';  
COMMENT ON COLUMN m_spanc.an_spanc_controle.contr_nat
    IS 'Origine de déclenchement du contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_controle.equ_pretrait
    IS 'Equipement de pré-traitement';
   COMMENT ON COLUMN m_spanc.an_spanc_controle.equ_trait
    IS 'Equipement de traitement';
COMMENT ON COLUMN m_spanc.an_spanc_controle.equ_rejet
    IS 'Equipement de rejet';   
COMMENT ON COLUMN m_spanc.an_spanc_controle.contr_concl
    IS 'Conclusion du contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_controle.contr_confor
    IS 'Conformité du contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_controle.contr_nreal
    IS 'Motif de la non réalisation du contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_dem
    IS 'Date de la demande du contrôle';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_prdv
    IS 'Date de prise de rendez-vous';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_rdv
    IS 'Date du rendez-vous';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_vis
    IS 'Date de la visite';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_rap
    IS 'Date du rapport';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_trap
    IS 'Date de transmission du rapport';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_act
    IS 'Date d''acte de vente';   
COMMENT ON COLUMN m_spanc.an_spanc_controle.mont_fact
    IS 'Montant facturé de la redevance'; 
COMMENT ON COLUMN m_spanc.an_spanc_controle.mont_pen
    IS 'Montant des pénalités';     
COMMENT ON COLUMN m_spanc.an_spanc_controle.acq_fact
    IS 'Facture réglée';      
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_fact
    IS 'Date de facturation';
COMMENT ON COLUMN m_spanc.an_spanc_controle.contr_info
    IS 'Dernier moyen d''informations ou de communication utilisé';
COMMENT ON COLUMN m_spanc.an_spanc_controle.verrou_min
    IS 'Verrou minimum sur les données, si date de transmission, peut encore modifier la facturation';   
COMMENT ON COLUMN m_spanc.an_spanc_controle.verrou_max
    IS 'Verrou maximum sur les données, si facture acquitée, avec date de facturation et date de transmission bloque les modifications';   
   
COMMENT ON COLUMN m_spanc.an_spanc_controle.observ
    IS 'Commentaires divers';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_sai
    IS 'Date de saisie des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_controle.date_maj
    IS 'Date de mise à jour des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_controle.op_sai
    IS 'Opérateur ayant saisi l''information d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_controle.op_maj
    IS 'Opérateur ayant modifier les informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_controle.epci
    IS 'Acronyme de l''EPCI d''assise de l''installation';
   
   
-- Index: an_spanc_controle_idcontr_idx
-- DROP INDEX m_spanc.an_spanc_controle_idcontr_idx;

CREATE INDEX an_spanc_controle_idcontr_idx
    ON m_spanc.an_spanc_controle USING btree
    (idcontr ASC NULLS LAST)
    TABLESPACE pg_default;   

   
create trigger t_t0_an_spanc_controle_idcontr before
insert
    on
    m_spanc.an_spanc_controle for each row execute procedure m_spanc.ft_m_idcontr();  
   
create trigger t_t1_an_spanc_controle_date_sai before
insert
    on
    m_spanc.an_spanc_controle for each row execute procedure ft_r_timestamp_sai();
    
create trigger t_t2_an_spanc_controle_date_maj before
update
    on
    m_spanc.an_spanc_controle for each row execute procedure ft_r_timestamp_maj();

create trigger t_t4_an_spanc_controle_conform before
INSERT OR DELETE OR update
    on
    m_spanc.an_spanc_controle for each row execute procedure m_spanc.ft_m_controle_conform();
   

create trigger t_t5_an_spanc_controle_equi_update before
update of date_trap on
    m_spanc.an_spanc_controle for each row execute procedure m_spanc.ft_m_update_install_equi();
   
create trigger t_t6_an_spanc_controle_equi_insert after
insert on
    m_spanc.an_spanc_controle  for each row execute procedure m_spanc.ft_m_update_install_equi();  

create trigger t_t8_refresh_carto after
insert or delete or update
    on
    m_spanc.an_spanc_controle for each row execute procedure m_spanc.ft_m_refresh_instal();   
   
create trigger t_t9_autorite_competente before
insert
    on
    m_spanc.an_spanc_controle for each row execute procedure ft_r_autorite_competente_user_login(); 
   
create trigger t_t100_log after
insert or delete or update
    on
    m_spanc.an_spanc_controle for each row execute procedure m_spanc.ft_m_spanc_log();    

-- ################################################# Classe des objets des contacts des installations : lk_spanc_installad ##################################

CREATE TABLE m_spanc.lk_spanc_installad
(
    id bigint NOT NULL DEFAULT nextval('m_spanc.lk_spanc_installad_seq'::regclass),
    idinstal bigint NOT NULL,
    idadresse bigint NOT NULL,
    adcompl text,
    CONSTRAINT lk_spanc_installad_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lk_spanc_installad
    IS 'Classe d''objets d''association d''une installation à plusieurs adresses (cas d''une installation desservant plusieurs habitations avec une adresse différente)';   

COMMENT ON COLUMN m_spanc.lk_spanc_installad.id
    IS 'Identifiant interne non signifiant';
COMMENT ON COLUMN m_spanc.lk_spanc_installad.idinstal
    IS 'Identifiant de l''installation';
COMMENT ON COLUMN m_spanc.lk_spanc_installad.adcompl
    IS 'Complément d''adresse';   
COMMENT ON COLUMN m_spanc.lk_spanc_installad.idadresse
    IS 'Identifiant interne Grand Compiégnois de l''adresse';
  
   
-- Index: lk_spanc_installad_id_idx
-- DROP INDEX m_spanc.lk_spanc_installad_id_idx;

CREATE INDEX lk_spanc_installad_id_idx
    ON m_spanc.lk_spanc_installad USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;  
   
create trigger t_t1_refresh_carto after
insert or delete or update
    on
    m_spanc.lk_spanc_installad  for each row execute procedure m_spanc.ft_m_refresh_instal(); 
   
   
   -- ################################################# Classe des objets des contacts des installations : lk_spanc_contact ##################################

CREATE TABLE m_spanc.lk_spanc_contact
(
    id bigint NOT NULL DEFAULT nextval('m_spanc.lk_spanc_contact_seq'::regclass),
    idinstal bigint NOT NULL,
    idcontact bigint NOT NULL,
    CONSTRAINT lk_spanc_contact_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

COMMENT ON TABLE m_spanc.lk_spanc_contact
    IS 'Classe d''objets d''association d''un contact à n installations';   

COMMENT ON COLUMN m_spanc.lk_spanc_contact.id
    IS 'Identifiant interne non signifiant';
COMMENT ON COLUMN m_spanc.lk_spanc_contact.idinstal
    IS 'Identifiant de l''installation';
COMMENT ON COLUMN m_spanc.lk_spanc_contact.idcontact
    IS 'Identifiant interne du contact';
  
   
-- Index: lk_spanc_contact_id_idx
-- DROP INDEX m_spanc.lk_spanc_contact_id_idx;

CREATE INDEX lk_spanc_contact_id_idx
    ON m_spanc.lk_spanc_contact USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;    
   
create trigger t_t100_log after
insert or delete or update
    on
    m_spanc.lk_spanc_contact for each row execute procedure m_spanc.ft_m_spanc_log();    

-- ################################################# Classe des objets des contacts des installations : an_spanc_entretien_media ##################################

CREATE TABLE m_spanc.an_spanc_entretien_media (
	gid bigint NOT NULL DEFAULT nextval('m_spanc.an_spanc_entretien_media_seq'::regclass),
	id bigint, 
	media text,
	miniature bytea, 
	n_fichier text, 
	t_fichier text, 
	date_sai timestamp without time zone,
	op_sai varchar(20) NULL, 
	date_ent timestamp without time zone, 
	t_doc character varying(2) COLLATE pg_catalog."default" NOT NULL,
	l_doc character varying(254) COLLATE pg_catalog."default",
	observ character varying(5000) COLLATE pg_catalog."default" ,
	CONSTRAINT an_spanc_entretien_media_pkey PRIMARY KEY (gid),
	CONSTRAINT an_spanc_entretien_media_t_doc_fkey 
		FOREIGN KEY (t_doc) REFERENCES m_spanc.lt_spanc_entr(code)
);


-- Index: an_spanc_entretien_media_gid_idx
-- DROP INDEX m_spanc.an_spanc_entretien_media_gid_idx;

CREATE INDEX an_spanc_entretien_media_gid_idx
    ON m_spanc.an_spanc_entretien_media USING btree
    (gid ASC NULLS LAST)
    TABLESPACE pg_default;   

-- Index: an_spanc_entretien_media_id_idx
-- DROP INDEX m_spanc.an_spanc_entretien_media_id_idx;

CREATE INDEX an_spanc_entretien_media_id_idx
    ON m_spanc.an_spanc_entretien_media USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;   
   
COMMENT ON TABLE m_spanc.an_spanc_entretien_media 
 IS 'Table gérant les documents intégrés pour l''entretien des installations';

COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.gid 
	IS 'Compteur (identifiant interne)';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.id 
	IS 'Identifiant interne non signifiant de l''objet saisi';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.media 
	IS 'Champ Média de GEO';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.miniature 
	IS 'Champ miniature de GEO';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.n_fichier 
	IS 'Nom du fichier';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.t_fichier 
	IS 'Type de média dans GEO';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.op_sai 
	IS 'Opérateur de saisie (par défaut login de connexion à GEO)';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.date_sai 
	IS 'Date de la saisie du document';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.date_ent 
	IS 'Date de l''entretien ou du document';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.t_doc 
	IS 'Type de documents';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.l_doc 
	IS 'Libellé du document';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.date_ent 
	IS 'Date de l''entretien ou du document';
COMMENT ON COLUMN m_spanc.an_spanc_entretien_media.observ 
	IS 'Commentaires divers';
 
create trigger t_t1_an_spanc_controle_instal_media before
INSERT OR update OR DELETE on
    m_spanc.an_spanc_entretien_media for each row execute procedure m_spanc.ft_m_controle_instal_media(); 
   
-- ################################################# Classe des objets des contacts des installations : an_spanc_installation_media ##################################

CREATE TABLE m_spanc.an_spanc_installation_media (
	gid bigint NOT NULL DEFAULT nextval('m_spanc.an_spanc_installation_media_seq'::regclass),
	id bigint, 
	media text,
	miniature bytea, 
	n_fichier text, 
	t_fichier text, 
	date_sai timestamp without time zone,
	op_sai varchar(20) NULL, 
	t_doc character varying(2) COLLATE pg_catalog."default" not NULL,
	l_doc character varying(254) COLLATE pg_catalog."default",
	observ character varying(5000) COLLATE pg_catalog."default" ,
	CONSTRAINT an_spanc_installation_media_pkey PRIMARY KEY (gid),
	CONSTRAINT an_spanc_installation_media_t_doc_fkey 
		FOREIGN KEY (t_doc) REFERENCES m_spanc.lt_spanc_docinstal(code)
);


-- Index: an_spanc_installation_media_gid_idx
-- DROP INDEX m_spanc.an_spanc_installation_media_gid_idx;

CREATE INDEX an_spanc_installation_media_gid_idx
    ON m_spanc.an_spanc_installation_media USING btree
    (gid ASC NULLS LAST)
    TABLESPACE pg_default;   

-- Index: an_spanc_installation_media_id_idx
-- DROP INDEX m_spanc.an_spanc_installation_media_id_idx;

CREATE INDEX an_spanc_installation_media_id_idx
    ON m_spanc.an_spanc_installation_media USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;   
   
COMMENT ON TABLE m_spanc.an_spanc_installation_media 
 IS 'Table gérant les documents intégrés pour l''entretien des installations';

COMMENT ON COLUMN m_spanc.an_spanc_installation_media.gid 
	IS 'Compteur (identifiant interne)';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.id 
	IS 'Identifiant interne non signifiant de l''objet saisi';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.media 
	IS 'Champ Média de GEO';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.miniature 
	IS 'Champ miniature de GEO';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.n_fichier 
	IS 'Nom du fichier';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.t_fichier 
	IS 'Type de média dans GEO';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.op_sai 
	IS 'Opérateur de saisie (par défaut login de connexion à GEO)';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.date_sai 
	IS 'Date de la saisie du document';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.t_doc 
	IS 'Type de document';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.l_doc 
	IS 'Libellé du document';
COMMENT ON COLUMN m_spanc.an_spanc_installation_media.observ 
	IS 'Commentaires divers';

create trigger t_t1_an_spanc_controle_instal_media before
INSERT OR update OR DELETE on
    m_spanc.an_spanc_installation_media for each row execute procedure m_spanc.ft_m_controle_instal_media();   

-- ################################################# Classe des objets des contacts des installations : an_spanc_controle_media ##################################
drop table if exists m_spanc.an_spanc_controle_media;
CREATE TABLE m_spanc.an_spanc_controle_media (
	gid bigint NOT NULL DEFAULT nextval('m_spanc.an_spanc_controle_media_seq'::regclass),
	id text, 
	media text,
	miniature bytea, 
	n_fichier text, 
	t_fichier text, 
	date_sai timestamp without time zone,
	op_sai varchar(20) COLLATE pg_catalog."default" NOT NULL, 
	date_doc timestamp without time zone, 
	t_doc character varying(2) COLLATE pg_catalog."default" NOT NULL,
	observ character varying(5000) COLLATE pg_catalog."default" ,
	CONSTRAINT an_spanc_controle_media_pkey PRIMARY KEY (gid),
	CONSTRAINT an_spanc_controle_media_t_doc_fkey 
		FOREIGN KEY (t_doc) REFERENCES m_spanc.lt_spanc_contrdoc(code)
);


-- Index: an_spanc_controle_media_gid_idx
-- DROP INDEX m_spanc.an_spanc_controle_media_gid_idx;

CREATE INDEX an_spanc_controle_media_gid_idx
    ON m_spanc.an_spanc_controle_media USING btree
    (gid ASC NULLS LAST)
    TABLESPACE pg_default;   

-- Index: an_spanc_controle_media_id_idx
-- DROP INDEX m_spanc.an_spanc_controle_media_id_idx;

CREATE INDEX an_spanc_controle_media_id_idx
    ON m_spanc.an_spanc_controle_media USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;   
   
COMMENT ON TABLE m_spanc.an_spanc_controle_media 
 IS 'Table gérant les documents intégrés pour l''entretien des installations';

COMMENT ON COLUMN m_spanc.an_spanc_controle_media.gid 
	IS 'Compteur (identifiant interne)';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.id 
	IS 'Identifiant interne non signifiant de l''objet saisi';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.media 
	IS 'Champ Média de GEO';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.miniature 
	IS 'Champ miniature de GEO';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.n_fichier 
	IS 'Nom du fichier';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.t_fichier 
	IS 'Type de média dans GEO';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.op_sai 
	IS 'Opérateur de saisie (par défaut login de connexion à GEO)';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.date_sai 
	IS 'Date de la saisie du document';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.t_doc 
	IS 'Type de documents';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.date_doc
	IS 'Date du document';
COMMENT ON COLUMN m_spanc.an_spanc_controle_media.observ 
	IS 'Commentaires divers';

-- ################################################# Classe des objets des contacts des installations : an_spanc_prestataire ##################################

CREATE TABLE m_spanc.an_spanc_prestataire (
	idpresta integer NOT NULL DEFAULT nextval('m_spanc.an_spanc_prestataire_seq'::regclass),
	lib_presta text COLLATE pg_catalog."default" NOT NULL, 
	exist boolean NOT NULL DEFAULT true,
	adresse text COLLATE pg_catalog."default", 
	tel varchar(10) COLLATE pg_catalog."default", 
	telp varchar(10) COLLATE pg_catalog."default", 
	email text COLLATE pg_catalog."default",
	siret varchar(14) COLLATE pg_catalog."default",
	nom_assur text COLLATE pg_catalog."default", 
	num_assur text COLLATE pg_catalog."default",
	date_assur timestamp without time zone, 
	date_sai timestamp without time ZONE NOT NULL,
    date_maj timestamp without time zone,
    op_sai character varying(20) COLLATE pg_catalog."default" NOT NULL,
    op_maj character varying(20) COLLATE pg_catalog."default",
    epci text COLLATE pg_catalog."default" NOT NULL,
	CONSTRAINT an_spanc_prestataire_pkey PRIMARY KEY (idpresta)
);


-- Index: an_spanc_prestataire_idpresta_idx
-- DROP INDEX m_spanc.an_spanc_prestataire_idpresta_idx;

CREATE INDEX an_spanc_prestataire_id_idx
    ON m_spanc.an_spanc_prestataire USING btree
    (idpresta ASC NULLS LAST)
    TABLESPACE pg_default;   

COMMENT ON TABLE m_spanc.an_spanc_prestataire 
 IS 'Table gérant l''identification des prestataires des contrôles';   
   
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.idpresta
    IS 'Identifiant interne non signifiant pour chaque enregistrement';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.lib_presta
    IS 'Libellé du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.exist
    IS 'Prestataire en activité';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.adresse
    IS 'Adresse du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.tel
    IS 'Téléphone du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.telp
    IS 'Téléphone portable du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.email
    IS 'Email du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.siret
    IS 'Numéro SIRET du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.nom_assur
    IS 'Libellé de l''assureur du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.num_assur
    IS 'N° de police d''assurance du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.date_assur
    IS 'Date de fin de validité du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.date_sai
    IS 'Date de saisie des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.date_maj
    IS 'Date de mise à jour des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.op_sai
    IS 'Opérateur ayant saisi l''information d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.op_maj
    IS 'Opérateur ayant modifier les informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_prestataire.epci
    IS 'Acronyme de l''EPCI d''assise de l''installation';

   
create trigger t_t1_an_spanc_prestataire_date_sai before
insert
    on
    m_spanc.an_spanc_prestataire for each row execute procedure ft_r_timestamp_sai();
    
create trigger t_t2_an_spanc_prestataire_date_maj before
update
    on
    m_spanc.an_spanc_prestataire for each row execute procedure ft_r_timestamp_maj();
   
create trigger t_t4_an_spanc_controle_presta before
INSERT OR DELETE OR update
    on
    m_spanc.an_spanc_prestataire for each row execute procedure m_spanc.ft_m_controle_presta()  ; 
    
create trigger t_t9_autorite_competente before
insert
    on
    m_spanc.an_spanc_prestataire for each row execute procedure ft_r_autorite_competente_user_login();  

create trigger t_t100_log after
insert or delete or update
    on
    m_spanc.an_spanc_prestataire for each row execute procedure m_spanc.ft_m_spanc_log();     
   
-- ################################################# Classe des objets des contacts des installations : an_spanc_dsp ##################################

CREATE TABLE m_spanc.an_spanc_dsp (
	iddsp bigint NOT NULL DEFAULT nextval('m_spanc.an_spanc_dsp_seq'::regclass),
	lib_dsp text COLLATE pg_catalog."default" NOT NULL, 
	date_deb timestamp without time ZONE NOT NULL,
	date_fin timestamp without time ZONE,
	adresse text COLLATE pg_catalog."default", 
	tel varchar(10) COLLATE pg_catalog."default", 
	telp varchar(10) COLLATE pg_catalog."default", 
	email text COLLATE pg_catalog."default",
	siret varchar(14) COLLATE pg_catalog."default",
	nom_assur text COLLATE pg_catalog."default", 
	num_assur text COLLATE pg_catalog."default",
	date_assur timestamp without time zone, 
	date_sai timestamp without time ZONE NOT NULL,
    date_maj timestamp without time zone,
    op_sai character varying(20) COLLATE pg_catalog."default" NOT NULL,
    op_maj character varying(20) COLLATE pg_catalog."default",
    epci text COLLATE pg_catalog."default" NOT NULL,
	CONSTRAINT an_spanc_dsp_pkey PRIMARY KEY (iddsp)
);

-- Index: an_spanc_dsp_iddsp_idx
-- DROP INDEX m_spanc.an_spanc_dsp_iddsp_idx;

CREATE INDEX an_spanc_dsp_id_idx
    ON m_spanc.an_spanc_dsp USING btree
    (iddsp ASC NULLS LAST)
    TABLESPACE pg_default;   

COMMENT ON TABLE m_spanc.an_spanc_dsp 
 IS 'Table gérant l''identification des DSP';      
   
COMMENT ON COLUMN m_spanc.an_spanc_dsp.iddsp
    IS 'Identifiant interne non signifiant pour chaque enregistrement';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.lib_dsp
    IS 'Libellé de la société exerçant la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.date_deb
    IS 'Date de début de la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.date_fin
    IS 'Date de fin de la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.adresse
    IS 'Adresse de la société excercant la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.tel
    IS 'Téléphone de la société excercant la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.telp
    IS 'Téléphone portable de la société excercant la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.email
    IS 'Email de la société excercant la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.siret
    IS 'Numéro SIRET du prestataire';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.nom_assur
    IS 'Libellé de l''assureur de la société excercant la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.num_assur
    IS 'N° de police d''assurance de la société excercant la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.date_assur
    IS 'Date de fin de validité de la société excercant la DSP';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.date_sai
    IS 'Date de saisie des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.date_maj
    IS 'Date de mise à jour des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.op_sai
    IS 'Opérateur ayant saisi l''information d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.op_maj
    IS 'Opérateur ayant modifier les informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_dsp.epci
    IS 'Acronyme de l''EPCI d''assise de l''installation';

   
create trigger t_t1_an_spanc_dsp_date_sai before
insert
    on
    m_spanc.an_spanc_dsp for each row execute procedure ft_r_timestamp_sai();
    
create trigger t_t2_an_spanc_dsp_date_maj before
update
    on
    m_spanc.an_spanc_dsp for each row execute procedure ft_r_timestamp_maj();
   
create trigger t_t4_an_spanc_controle_dsp before
INSERT OR DELETE OR update
    on
    m_spanc.an_spanc_dsp for each row execute procedure m_spanc.ft_m_controle_dsp()   ;
    
create trigger t_t9_autorite_competente before
insert
    on
    m_spanc.an_spanc_dsp for each row execute procedure ft_r_autorite_competente_user_login();     

create trigger t_t100_log after
insert or delete or update
    on
    m_spanc.an_spanc_dsp for each row execute procedure m_spanc.ft_m_spanc_log();     
   
-- ################################################# Classe des objets des variables paramétrables : an_spanc_conf ##################################

CREATE TABLE m_spanc.an_spanc_conf (
	idconf bigint NOT NULL DEFAULT nextval('m_spanc.an_spanc_conf_seq'::regclass),
	--date_deb timestamp without time zone NOT NULL, 
	--date_fin timestamp without time ZONE,
	contr_perio_c smallint, 
	contr_perio_nc smallint,
	contr_trav smallint,
	contr_abs smallint,
	rel_perio smallint,
	date_sai timestamp without time ZONE NOT NULL,
    date_maj timestamp without time zone,
    op_sai character varying(20) COLLATE pg_catalog."default" NOT NULL,
    op_maj character varying(20) COLLATE pg_catalog."default",
    epci text COLLATE pg_catalog."default" NOT NULL,
	CONSTRAINT an_spanc_conf_pkey PRIMARY KEY (idconf)
);

-- Index: an_spanc_conf_idconf_idx
-- DROP INDEX m_spanc.an_spanc_conf_idconf_idx;

CREATE INDEX an_spanc_conf_idconf_idx
    ON m_spanc.an_spanc_conf USING btree
    (idconf ASC NULLS LAST)
    TABLESPACE pg_default;   

COMMENT ON TABLE m_spanc.an_spanc_conf 
 IS 'Table gérant les variables paramétrables de chaque EPCI pour les périodicités';      
   
COMMENT ON COLUMN m_spanc.an_spanc_conf.idconf
    IS 'Identifiant interne non signifiant pour chaque enregistrement';
   /*
COMMENT ON COLUMN m_spanc.an_spanc_conf.date_deb
    IS 'Date de début de période prise en compte';
COMMENT ON COLUMN m_spanc.an_spanc_conf.date_fin
    IS 'Date de fin de période de prise en compte';
*/    
COMMENT ON COLUMN m_spanc.an_spanc_conf.contr_perio_c
    IS 'Nombre d''années entre 2 contrôles périodiques des installations conformes';
COMMENT ON COLUMN m_spanc.an_spanc_conf.contr_perio_nc
    IS 'Nombre d''années entre 2 contrôles périodiques des installations non conformes';   
COMMENT ON COLUMN m_spanc.an_spanc_conf.contr_trav
    IS 'Nombre d''années de délais pour la réalisation des travaux';
COMMENT ON COLUMN m_spanc.an_spanc_conf.contr_abs
    IS 'Nombre de mois pour la vérification si absence d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_conf.rel_perio
    IS 'Délais de relance lié à un contrôle en mois si la date choisie pour l''automatisme n''est pas remplie';
COMMENT ON COLUMN m_spanc.an_spanc_conf.date_sai
    IS 'Date de saisie des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_conf.date_maj
    IS 'Date de mise à jour des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_conf.op_sai
    IS 'Opérateur ayant saisi l''information d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_conf.op_maj
    IS 'Opérateur ayant modifier les informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_conf.epci
    IS 'Acronyme de l''EPCI d''assise de l''installation';   

   
create trigger t_t1_an_spanc_conf_date_sai before
insert
    on
    m_spanc.an_spanc_conf for each row execute procedure ft_r_timestamp_sai();
    
create trigger t_t2_an_spanc_conf_date_maj before
update
    on
    m_spanc.an_spanc_conf for each row execute procedure ft_r_timestamp_maj();

create trigger t_t3_an_spanc_controle_conf before
insert or delete or update
    on
    m_spanc.an_spanc_conf for each row execute procedure m_spanc.ft_m_controle_conf();   
   
create trigger t_t9_autorite_competente before
insert
    on
    m_spanc.an_spanc_conf for each row execute procedure ft_r_autorite_competente_user_login();

create trigger t_t100_log after
insert or delete or update
    on
    m_spanc.an_spanc_conf for each row execute procedure m_spanc.ft_m_spanc_log();      
   
-- ################################################# Classe des objets des variables paramétrables : an_spanc_cad ##################################

CREATE TABLE m_spanc.an_spanc_cad (
	idcad bigint NOT NULL DEFAULT nextval('m_spanc.an_spanc_cad_seq'::regclass),
	idinstal bigint NOT NULL,
	ccosec character varying(2) COLLATE pg_catalog."default" NOT NULL,
    dnupla character varying(4) COLLATE pg_catalog."default" NOT NULL,
	date_sai timestamp without time ZONE NOT NULL,
    date_maj timestamp without time ZONE,
	CONSTRAINT an_spanc_cad_pkey PRIMARY KEY (idcad)
);

-- Index: an_spanc_cad_idcad_idx
-- DROP INDEX m_spanc.an_spanc_cad_idcad_idx;

CREATE INDEX an_spanc_cad_idcad_idx
    ON m_spanc.an_spanc_cad USING btree
    (idcad ASC NULLS LAST)
    TABLESPACE pg_default;   

COMMENT ON TABLE m_spanc.an_spanc_cad 
 IS 'Table gérant les références cadastrales associés à l''installation';      
   
COMMENT ON COLUMN m_spanc.an_spanc_cad.idcad
    IS 'Identifiant interne non signifiant pour chaque enregistrement';
COMMENT ON COLUMN m_spanc.an_spanc_cad.idinstal
    IS 'Identifiant interne non signifiant de l''installation';
COMMENT ON COLUMN m_spanc.an_spanc_cad.ccosec
    IS 'Section cadastrale';
COMMENT ON COLUMN m_spanc.an_spanc_cad.dnupla
    IS 'Parcelle cadastrale';
COMMENT ON COLUMN m_spanc.an_spanc_cad.date_sai
    IS 'Date de saisie des informations d''installation';
COMMENT ON COLUMN m_spanc.an_spanc_cad.date_maj
    IS 'Date de mise à jour des informations d''installation'; 

create trigger t_t1_an_spanc_cad_date_sai before
insert
    on
    m_spanc.an_spanc_cad for each row execute procedure ft_r_timestamp_sai();
    
create trigger t_t2_an_spanc_cad_date_maj before
update
    on
    m_spanc.an_spanc_cad for each row execute procedure ft_r_timestamp_maj();
   
create trigger t_t3_an_spanc_cad_controle before
INSERT OR update
    on
    m_spanc.an_spanc_cad for each row execute procedure m_spanc.ft_m_verif_ref_cad();   
    
create trigger t_t100_log after
insert or delete or update
    on
    m_spanc.an_spanc_cad for each row execute procedure m_spanc.ft_m_spanc_log();      
   
-- ################################################# Classe des objets des logs : an_spanc_log ##################################   
-- m_spanc.an_spanc_log definition

-- Drop table

-- DROP TABLE m_spanc.an_spanc_log;

CREATE TABLE m_spanc.an_spanc_log (
	idlog int4 NOT NULL, -- Identifiant unique
	tablename varchar(80) NOT NULL, -- Nom de la classe concernée par une opération
	type_ope text NOT NULL, -- Type d'opération
	dataold text NULL, -- Anciennes données
	datanew text NULL, -- Nouvelles données
	date_maj timestamp NULL DEFAULT now(), -- Date d'exécution de l'opération
	CONSTRAINT an_spanc_log_pkey PRIMARY KEY (idlog)
);
COMMENT ON TABLE m_spanc.an_spanc_log IS 'Table des opérations effectuées sur les données activités économiques à l''insert, update et delete';

-- Column comments

COMMENT ON COLUMN m_spanc.an_spanc_log.idlog IS 'Identifiant unique';
COMMENT ON COLUMN m_spanc.an_spanc_log.tablename IS 'Nom de la classe concernée par une opération';
COMMENT ON COLUMN m_spanc.an_spanc_log.type_ope IS 'Type d''opération';
COMMENT ON COLUMN m_spanc.an_spanc_log.dataold IS 'Anciennes données';
COMMENT ON COLUMN m_spanc.an_spanc_log.datanew IS 'Nouvelles données';
COMMENT ON COLUMN m_spanc.an_spanc_log.date_maj IS 'Date d''exécution de l''opération';

