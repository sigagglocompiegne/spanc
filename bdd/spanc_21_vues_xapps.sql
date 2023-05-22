/*SPANC V1.0*/
/*Creation du squelette de la structure des données (view) */
/* spanc_21_vues_xapps.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Grégory Bodet */

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                VUES                                                                          ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################   

-- ########################################################### xapps_geo_vmr_spanc_anc ##################################################################   
   
-- m_spanc.xapps_geo_v_spanc_anc
drop view if exists m_spanc.xapps_geo_v_spanc_anc;
CREATE MATERIALIZED VIEW m_spanc.xapps_geo_vmr_spanc_anc
AS


WITH req_ad AS (
         SELECT a.id_adresse,
            a.commune,
            a.libvoie_c,
            a.numero,
            a.repet,
            (((((((a.numero::text ||
                CASE
                    WHEN a.repet IS NOT NULL OR a.repet::text <> ''::text THEN a.repet
                    ELSE ''::character varying
                END::text) || ' '::text) || a.libvoie_c::text) ||
                CASE
                    WHEN a.ld_compl  IS NULL OR a.ld_compl::text = ''::text THEN ''::text
                    ELSE chr(10) || a.ld_compl::text
                END ||
                CASE
                    WHEN a.complement IS NULL OR a.complement::text = ''::text THEN ''::text
                    ELSE chr(10) || a.complement::text
                END) || chr(10)) || a.codepostal::text) || ' '::text) || a.commune::text AS adresse,
            a.mot_dir,
            a.libvoie_a,
            e.iepci,
            a.geom
           FROM x_apps.xapps_geo_vmr_adresse a, r_administratif.an_geo g, r_osm.geo_osm_epci e 
           where a.insee = g.insee and e.cepci = g.epci 
        ),
        req_nb_anc as
        (
        with req_sous_ad as (
        --1er passe sur adresse principale
        select 
        a.id_adresse,
        count(*) as nb_inst
        from
        	m_spanc.an_spanc_installation i, x_apps.xapps_geo_vmr_adresse a
        where i.idadresse = a.id_adresse AND i.inst_etat = '10' group by  a.id_adresse
        union all 
        --2ème passe 
        select 
        a.idadresse as id_adresse,
        count(*) as nb_inst
        from
        	m_spanc.an_spanc_installation i, m_spanc.lk_spanc_installad a
        where i.idinstal = a.idinstal AND i.inst_etat = '10' group by  a.idadresse
        )
        select 
        	b.id_adresse,
        	sum(nb_inst) as nb_inst
        from 
       		 req_sous_ad b
        group by b.id_adresse
        
        ),  
 
        req_nb_contr as
        (
        with req_sous_cont as 
        (
        --1er passage sur adresse principale
        select 
        a.id_adresse,
        count(*) as nb_contr
        from
        	m_spanc.an_spanc_installation i, 
        	m_spanc.an_spanc_controle c,
        	x_apps.xapps_geo_vmr_adresse a
        	
        where i.idadresse = a.id_adresse and i.idinstal = c.idinstal and i.inst_etat = '10' AND c.contr_confor IN ('10','20','30') 
        AND c.contr_nat in ('13','14','20','30','40','50','60') group by  a.id_adresse
        union all 
        --2ème passage sur adresse associée
        select 
        a.idadresse as id_adresse,
        count(*) as nb_contr
        from
        	m_spanc.an_spanc_installation i, 
        	m_spanc.an_spanc_controle c,
        	m_spanc.lk_spanc_installad a
        	
        where i.idinstal = a.idinstal and i.idinstal = c.idinstal and i.inst_etat = '10' AND c.contr_confor IN ('10','20','30') 
        AND c.contr_nat in ('13','14','20','30','40','50','60') group by  a.idadresse
        )
        select 
        	c.id_adresse,
        	sum(nb_contr) as nb_contr
        from 
        	req_sous_cont c
        group by
        	c.id_adresse
        
        ), req_dcontrl AS
(

with req_final as
(
with req_max as 
(

(
     --2ème passage sur adresse principale
     select 
        ad.id_adresse,
        max(ad.date_vis) as date_vis,
        string_agg(ad.contr_confor,',') as contr_confor,
        string_agg(ad.contr_nat,',') as contr_nat,
        string_agg(
        case 
	         when ad.contr_nat = '99' then '9'
	         when ad.contr_confor <> '00' and ad.contr_confor <> 'ZZ' then left(ad.contr_confor,1)
             when ad.contr_confor = 'ZZ' then '4'
             else '' END
        
        ,',') as tri_confor
      FROM  
      (       
      SELECT DISTINCT 
             b_1.id_adresse,
             a.idinstal,
              -- ici gestion des conformités si travaux ou non (pas en base, mais déduit de la conclusion du contrôle 31 ou 32 => avec travaux donc rouge à l'affichage)
              -- la valeur 50 est écrite temporairement pour gérer le tri à la fin de la requête
              case when a.contr_concl in ('31','32') then '50' else a.contr_confor end,
              case when a.contr_nat in ('11','12') then '99' else a.contr_nat end,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT a.id_adresse, c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i, x_apps.xapps_geo_vmr_adresse a
                   where c.idinstal = i.idinstal and i.idadresse = a.id_adresse  AND i.inst_etat = '10'
                  GROUP BY c.idinstal, a.id_adresse) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
                  ) ad group by ad.id_adresse /*, ad.contr_confor*/ order by max(ad.date_vis) desc --limit 1
                  )
          union all 
          --2ème passage sur adresse associée
        (
        select 
        ad.idadresse as id_adresse,
        max(ad.date_vis) as date_vis,
        string_agg(ad.contr_confor,',') as contr_confor,
        string_agg(ad.contr_nat,',') as contr_nat,
        string_agg(
        case 
	         when ad.contr_nat = '99' then '9'
	         when ad.contr_confor <> '00' and ad.contr_confor <> 'ZZ' then left(ad.contr_confor,1)
             when ad.contr_confor = 'ZZ' then '4'
             else '' END
        
        ,',') as tri_confor
      FROM  
      (       
      SELECT DISTINCT 
             b_1.idadresse,
             a.idinstal,
              -- ici gestion des conformités si travaux ou non (pas en base, mais déduit de la conclusion du contrôle 31 ou 32 => avec travaux donc rouge à l'affichage)
              -- la valeur 50 est écrite temporairement pour gérer le tri à la fin de la requête
              case when a.contr_concl in ('31','32') then '50' else a.contr_confor end,
              case when a.contr_nat in ('11','12') then '99' else a.contr_nat end,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT a.idadresse, c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i, m_spanc.lk_spanc_installad a
                   where c.idinstal = i.idinstal and i.idinstal = a.idinstal  AND i.inst_etat = '10'
                  GROUP BY c.idinstal, a.idadresse) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
                  ) ad group by ad.idadresse /*, ad.contr_confor*/ order by max(ad.date_vis) desc --limit 1
                  )
)
select 
 		f.id_adresse,
        f.date_vis,
        f.contr_confor,
        f.contr_nat,
        /*string_agg(
        case 
	         when f.contr_nat = '99' then '9'
	         when f.contr_confor <> '00' and f.contr_confor <> 'ZZ' then left(f.contr_confor,1)
             when f.contr_confor = 'ZZ' then '4'
             else '' END
        
        ,',') as tri_confor*/
        f.tri_confor 
        
from 
req_max f
), req_max as
(
with req_max_t as 
(

(
     --2ème passage sur adresse principale
     select 
        ad.id_adresse,
        max(ad.date_vis) as date_vis,
        string_agg(ad.contr_confor,',') as contr_confor,
        string_agg(ad.contr_nat,',') as contr_nat,
        string_agg(
        case 
	         when ad.contr_nat = '99' then '9'
	         when ad.contr_confor <> '00' and ad.contr_confor <> 'ZZ' then left(ad.contr_confor,1)
             when ad.contr_confor = 'ZZ' then '4'
             else '' END
        
        ,',') as tri_confor
      FROM  
      (       
      SELECT DISTINCT 
             b_1.id_adresse,
             a.idinstal,
              -- ici gestion des conformités si travaux ou non (pas en base, mais déduit de la conclusion du contrôle 31 ou 32 => avec travaux donc rouge à l'affichage)
              -- la valeur 50 est écrite temporairement pour gérer le tri à la fin de la requête
              case when a.contr_concl in ('31','32') then '50' else a.contr_confor end,
              case when a.contr_nat in ('11','12') then '99' else a.contr_nat end,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT a.id_adresse, c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i, x_apps.xapps_geo_vmr_adresse a
                   where c.idinstal = i.idinstal and i.idadresse = a.id_adresse  AND i.inst_etat = '10'
                  GROUP BY c.idinstal, a.id_adresse) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
                  ) ad group by ad.id_adresse /*, ad.contr_confor*/ order by max(ad.date_vis) desc --limit 1
                  )
          union all 
          --2ème passage sur adresse associée
        (
        select 
        ad.idadresse as id_adresse,
        max(ad.date_vis) as date_vis,
        string_agg(ad.contr_confor,',') as contr_confor,
        string_agg(ad.contr_nat,',') as contr_nat,
        string_agg(
        case 
	         when ad.contr_nat = '99' then '9'
	         when ad.contr_confor <> '00' and ad.contr_confor <> 'ZZ' then left(ad.contr_confor,1)
             when ad.contr_confor = 'ZZ' then '4'
             else '' END
        
        ,',') as tri_confor
      FROM  
      (       
      SELECT DISTINCT 
             b_1.idadresse,
             a.idinstal,
              -- ici gestion des conformités si travaux ou non (pas en base, mais déduit de la conclusion du contrôle 31 ou 32 => avec travaux donc rouge à l'affichage)
              -- la valeur 50 est écrite temporairement pour gérer le tri à la fin de la requête
              case when a.contr_concl in ('31','32') then '50' else a.contr_confor end,
              case when a.contr_nat in ('11','12') then '99' else a.contr_nat end,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT a.idadresse, c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i, m_spanc.lk_spanc_installad a
                   where c.idinstal = i.idinstal and i.idinstal = a.idinstal  AND i.inst_etat = '10'
                  GROUP BY c.idinstal, a.idadresse) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
                  ) ad group by ad.idadresse /*, ad.contr_confor*/ order by max(ad.date_vis) desc --limit 1
                  )
)
select 
 		m.id_adresse,
        max(m.tri_confor) as tri_confor_m
        
from 
req_max_t m
group by m.id_adresse
)
select 
f.id_adresse,
        f.date_vis,
        f.contr_confor,
        f.contr_nat,
m.tri_confor_m
from 
req_final f
left join req_max m on m.id_adresse = f.id_adresse where f.tri_confor = m.tri_confor_m

)



 SELECT distinct row_number() OVER () AS gid,
    b.id_adresse,
    b.commune,
    b.libvoie_c,
    b.libvoie_a,
    b.numero,
    b.repet,
    b.adresse,
    b.mot_dir,
    b.iepci,
    case when a.nb_inst is null then 0 else a.nb_inst end as nb_inst,
    case when c.nb_contr is null then 0 else c.nb_contr end as nb_contr,
    -- gestion ici de l'affichage, si une installation prend l'état du dernier contrôle
    case when a.nb_inst = 1 then 
          			case when dc.contr_confor is not null and dc.contr_nat in ('11','12') then 'n.r'
          			     when dc.contr_confor is not null and dc.contr_nat in ('13','14','20','30','40','50','60') then dc.contr_confor::character varying
          			else 'n.r' END
    -- gestion ici de l'affichage, si plusieurs installations prend l'état le plus mauvais des n installations
          			when a.nb_inst > 1 then
    	 case when dc.contr_confor is null then 'n.r' else 
    	 -- gestion ici de la priorisation des contrôles, le plus mauvais (ici on retrouve la valeur 50 à 5 pour indiquer le code 21. Ce code est repris dans GEO
    	 -- pour gérer l'affichage de la carte et dans la fiche à l'adresse (champ_calculé affiche_conformite)
    	 	case 
	    	 	 when dc.tri_confor_m like '%9%' then 'n.r'
	    	 	 when dc.tri_confor_m like '%4%' then 'ZZ'
    	 		 when dc.tri_confor_m like '%3%' then '30'
    	 		 when dc.tri_confor_m like '%5%' then '21'
    	 	     when dc.tri_confor_m like '%2%' then '20'
    	 	     when dc.tri_confor_m like '%1%' then '10' 
    	 	    
    	 	     else 'n.r' 
    	    end
    	 --left(dc.contr_confor,2)::character varying end 
     	 end
     else	
     'Aucune'
    END	
     	as confor,

 --   contr_nat,
    b.geom
   FROM req_ad b 
  	left join req_nb_anc a on b.id_adresse=a.id_adresse
  	LEFT JOIN req_nb_contr c ON a.id_adresse = c.id_adresse
    LEFT JOIN req_dcontrl dc ON dc.id_adresse = b.id_adresse
   --  where b.id_adresse = 30801 
    
    group by b.id_adresse, b.commune,
    b.libvoie_c, b.libvoie_a, b.numero, b.repet, b.adresse, b.mot_dir, b.iepci,dc.contr_confor,dc.tri_confor_m,b.geom,c.nb_contr,dc.contr_nat,a.nb_inst
   
    WITH DATA;
   
-- where a.nb_inst >= 1 and  b.id_adresse = 30380;
   
COMMENT ON MATERIALIZED VIEW m_spanc.xapps_geo_vmr_spanc_anc 
	IS 'Vue matérialisée rafraichie applicative récupérant le nombre de dossier SPANC de conformité par adresse et affichant l''état du dernier contrôle (conforme ou non conforme) pour affichage dans GEO';



-- ########################################################### xapps_geo_v_spanc_tri_contr ##################################################################

-- m_spanc.xapps_geo_v_spanc_anc
drop view if exists m_spanc.xapps_geo_v_spanc_tri_contr;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_v_spanc_tri_contr
AS 

select
    row_number() over(order by CASE WHEN c.date_vis IS NOT NULL THEN c.date_vis ELSE c.date_dem end desc) as id,
	i.idinstal,
	c.idcontr,
	c.idcontr_epci,
	c.contr_nat,
	c.contr_confor,
	CASE WHEN c.date_vis IS NOT NULL THEN to_char(c.date_vis,'dd-mm-yyyy') ELSE to_char(c.date_dem,'dd-mm-yyyy') END AS tri_date
FROM
	m_spanc.an_spanc_installation i, m_spanc.an_spanc_controle c
WHERE
	i.idinstal = c.idinstal 
	ORDER BY CASE WHEN c.date_vis IS NOT NULL THEN c.date_vis ELSE c.date_dem end desc
	;


COMMENT ON VIEW m_spanc.xapps_geo_v_spanc_tri_contr 
	IS 'Vue applicative pour palier au bug de GEO2.2 pour l''affichage des contrôles triés par date dans la fiche de l''installation';



-- ########################################################### xapps_geo_an_spanc_install_export ##################################################################


-- m_spanc.xapps_geo_an_spanc_install_export
drop view if exists m_spanc.xapps_geo_an_spanc_install_export;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_an_spanc_install_export
AS 

with req_etat_confor as
(
SELECT DISTINCT 
             a.idinstal,
             a.contr_confor,
             a.contr_nat,
             a.contr_concl,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i, x_apps.xapps_geo_vmr_adresse a
                   where c.idinstal = i.idinstal and i.idadresse = a.id_adresse AND i.inst_etat = '10'
                  GROUP BY c.idinstal) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
)
select 
    i.idinstal as "Installation n°",
    e.valeur as "Etat",
    case when c.contr_nat is not null then nc.valeur else 'n.r' END as "Nature du contrôle",
    case when c.contr_concl is not null then cl.valeur else 'n.r' END as "Conclusion du contrôle",
    case when c.contr_confor is not null then co.valeur else 'n.r' END as "Conformité",
    
    im.valeur as "Type d'immeuble",
    a.numero ||
	CASE WHEN a.repet IS NULL THEN '' ELSE a.repet END 
	|| ' ' || a.libvoie_c || ', ' ||  a.codepostal || ' ' || a.commune
	||
	CASE WHEN a.complement IS NULL THEN '' ELSE
	chr(10) || a.complement end as "Adresse",
    i.adcompl as "Complément d'adresse",
    
    eh.valeur as eh,
    case when i.inst_com is true then 'oui' else 'non' end as "Installation commune",
    case when i.inst_acontr is true then 'oui' else 'non' end as "Soumise à contrôle",
    case when i.inst_conv is true then 'oui' else 'non' end as "Soumise à convention",
    to_char(i.date_crea,'yyyy-mm-dd') as "Date de création",
    
    CASE WHEN i.date_crea IS NOT NULL THEN
	(
	select case when extract(year from age(now(),i.date_crea)) = 1 THEN
		  extract(year from age(now(),i.date_crea)) || ' an'
    	 when extract(year from age(now(),i.date_crea)) > 1 THEN
           extract(year from age(now(),i.date_crea)) || ' ans'
	else ''           
	END
	)  || 
	(
	select case when extract(month from age(now(),i.date_crea)) > 0 THEN
 	' et ' || extract(month from age(now(),i.date_crea)) || ' mois'
	else ''
	end
	)
	ELSE
	null
	END
    
    as "Age de l'installation",
    
    i.observ as "Commentaires",
    i.epci,
    a.commune as "Commune"
    
FROM
	m_spanc.an_spanc_installation i 
	left join x_apps.xapps_geo_vmr_adresse a on a.id_adresse = i.idadresse
	left join req_etat_confor c on i.idinstal = c.idinstal
	left join m_spanc.lt_spanc_typimmeuble im on im.code = i.typ_im 
	left join m_spanc.lt_spanc_confor co on co.code = c.contr_confor
	left join m_spanc.lt_spanc_etatinstall e on e.code = i.inst_etat 
    left join m_spanc.lt_spanc_eh eh on eh.code = i.inst_eh
    left join m_spanc.lt_spanc_natcontr nc on nc.code = c.contr_nat
    left join m_spanc.lt_spanc_contcl cl on cl.code = c.contr_concl
	;


COMMENT ON VIEW m_spanc.xapps_geo_an_spanc_install_export 
	IS 'Vue applicative générant les exports des installations';



-- ########################################################### xapps_geo_an_spanc_contr_export ##################################################################

-- m_spanc.xapps_geo_an_spanc_contr_export

drop view if exists m_spanc.xapps_geo_an_spanc_contr_export;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_an_spanc_contr_export
AS 

select 
split_part(c.idcontr,'_',2) as "Contrôle n°",
c.idcontr_epci as "N° de dossier",
c.idinstal as "N° de l''installation",
g.valeur as "Mode de gestion",
case when c.idpresta is not null then p.lib_presta else '' end as "Prestataire",
case when c.iddsp is not null then d.lib_dsp else '' end as "DSP",
c.date_env as "Envoie de la demande",
nc.valeur as "Nature du contrôle",
-- équipement à intégrer (multivalué)
cc.valeur as "Conclusion du contrôle",
co.valeur as "Conformité",
r.valeur as "Motif de refus",
to_char(c.date_dem,'yyyy-mm-dd') as "Date de la demande",
to_char(c.date_dem,'yyyy') as "Année de la demande",
to_char(c.date_prdv,'yyyy-mm-dd') as "Date de prise de RDV",
to_char(c.date_rdv,'yyyy-mm-dd') as "Date du RDV",
to_char(c.date_vis,'yyyy-mm-dd') as "Date de la visite",
to_char(c.date_vis,'yyyy') as "Année du contrôle",
to_char(c.date_act,'yyyy-mm-dd') as "Date de l'acte de vente",
to_char(c.date_rap,'yyyy-mm-dd') as "Date du rapport",
to_char(c.date_trap,'yyyy-mm-dd') as "Date de transmission du rapport",
to_char(c.date_fact,'yyyy-mm-dd') as "Date de facturation",
c.mont_fact as "Montant de la redevance",
c.mont_pen as "Montant des pénalités",
case when c.acq_fact is true then 'oui' else 'non' end as "Facture acquitée",
i.code as "Dernier moyen d'information",
c.observ as "Commentaires",
a.commune as "Commune",
c.epci as "epci"


from m_spanc.an_spanc_controle c
left join m_spanc.lt_spanc_modgest g on g.code = c.mod_gest
left join m_spanc.an_spanc_prestataire p on p.idpresta = c.idpresta 
left join m_spanc.an_spanc_dsp d on d.iddsp = c.iddsp 
left join m_spanc.lt_spanc_natcontr nc on nc.code = c.contr_nat 
left join m_spanc.lt_spanc_contcl cc on cc.code = c.contr_concl 
left join m_spanc.lt_spanc_confor co on co.code = c.contr_confor 
left join m_spanc.lt_spanc_refus r on r.code = c.contr_nreal  
left join m_spanc.lt_spanc_info i on i.code = c.contr_info 
left join m_spanc.an_spanc_installation inst on inst.idinstal = c.idinstal
left join x_apps.xapps_geo_vmr_adresse a on a.id_adresse = inst.idadresse 
order by split_part(c.idcontr,'_',2)::integer
;



COMMENT ON VIEW m_spanc.xapps_geo_an_spanc_contr_export 
	IS 'Vue applicative générant les exports des contrôles';



-- ########################################################### xapps_geo_v_spanc_rpqs_tab1 ##################################################################

-- m_spanc.xapps_geo_v_spanc_rpqs_tab1

drop view if exists m_spanc.xapps_geo_v_spanc_rpqs_tab1;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_v_spanc_rpqs_tab1
AS 

-- nombre d'installation contrôlée
with
req_epci as
(
select 
 iepci as epci,
 lib_epci
from r_osm.geo_osm_epci where iepci in ('cclo','cc2v','ccpe','arc')
),
req_nb_inst as
(
select epci, count(*) as nb_inst from m_spanc.an_spanc_installation where idinstal in (
 select 
        ad.idinstal
       -- max(ad.date_vis),
       -- string_agg(ad.contr_confor,',') as contr_confor
      FROM  
      (       
      SELECT DISTINCT 
             a.idinstal,
              -- ici gestion des conformités si travaux ou non (pas en base, mais déduit de la conclusion du contrôle 31 ou 32 => avec travaux donc rouge à l'affichage)
              -- la valeur 50 est écrite temporairement pour gérer le tri à la fin de la requête
              a.contr_concl,
              a.contr_nat,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
                   where c.idinstal = i.idinstal and i.inst_etat = '10'
                  GROUP BY c.idinstal) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
         ) ad 
         where ad.contr_concl IN ('10','20','31','32','40') and ad.contr_nat in ('13','14','20','30','40','50','60')
         group by ad.idinstal order by max(ad.date_vis) desc --limit 1
         )
         group by epci
),
req_nb_conf as
(
select epci, count(*) as nb_inst_conf from m_spanc.an_spanc_installation where idinstal in (
 select 
        ad.idinstal
       -- max(ad.date_vis),
       -- string_agg(ad.contr_confor,',') as contr_confor
      FROM  
      (       
      SELECT DISTINCT 
             a.idinstal,
              -- ici gestion des conformités siu travaux ou non (pas en base, mais déduit de la conclusion du contrôle 31 ou 32 => avec travaux donc rouge à l'affichage)
              -- la valeur 50 est écrite temporairement pour gérer le tri à la fin de la requête
              a.contr_concl,
              a.contr_nat,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
                   where c.idinstal = i.idinstal and i.inst_etat = '10'
                  GROUP BY c.idinstal) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
         ) ad 
         where ad.contr_concl = '20' and ad.contr_nat in ('13','14','20','30','40','50','60')
         group by ad.idinstal order by max(ad.date_vis) desc --limit 1
         )
         group by epci
),
req_nb_nonconf as
(
select epci, count(*) as nb_inst_nonconf from m_spanc.an_spanc_installation where idinstal in (
 select 
        ad.idinstal
       -- max(ad.date_vis),
       -- string_agg(ad.contr_confor,',') as contr_confor
      FROM  
      (       
      SELECT DISTINCT 
             a.idinstal,
              -- ici gestion des conformités siu travaux ou non (pas en base, mais déduit de la conclusion du contrôle 31 ou 32 => avec travaux donc rouge à l'affichage)
              -- la valeur 50 est écrite temporairement pour gérer le tri à la fin de la requête
              a.contr_concl,
            a.date_vis
           FROM m_spanc.an_spanc_controle a
             JOIN ( SELECT c.idinstal,
                    max(c.date_vis) AS date_vis
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
                   where c.idinstal = i.idinstal and i.inst_etat = '10'
                  GROUP BY c.idinstal) b_1 ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
         ) ad 
         where ad.contr_concl = '40'
         group by ad.idinstal order by max(ad.date_vis) desc --limit 1
         )
         group by epci
)


select 
row_number() over() as id,
e.epci,
e.lib_epci,
case when i.nb_inst is null then 0 else i.nb_inst end as nb_inst,
case when ic.nb_inst_conf is null then 0 else ic.nb_inst_conf end as nb_inst_conf,
case when inc.nb_inst_nonconf is null then 0 else inc.nb_inst_nonconf end as nb_inst_nonconf,
case when i.nb_inst is not null then
    round((case when ic.nb_inst_conf is null then 0 else ic.nb_inst_conf end + case when inc.nb_inst_nonconf is null then 0 else inc.nb_inst_nonconf end)/i.nb_inst::decimal*100,1)
else 0 end || '%'
    as tx_conform


from req_epci e
left join req_nb_inst i on i.epci = e.epci
left join req_nb_conf ic on ic.epci = e.epci
left join req_nb_nonconf inc on inc.epci = e.epci;




COMMENT ON VIEW m_spanc.xapps_geo_v_spanc_rpqs_tab1 
	IS 'Vue applicative ressortant les indicateurs RPQS pour le tableau de bord n°1 du SPANC';


-- ########################################################### xapps_geo_v_spanc_tab2 ##################################################################

-- m_spanc.xapps_geo_v_spanc_tab2

drop view if exists m_spanc.xapps_geo_v_spanc_tab2;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_v_spanc_tab2
AS 

WITH req_d AS (
         WITH req_a AS (
                 SELECT DISTINCT g.code || '_' || to_char(c.date_vis, 'YYYY'::text) || c.epci AS cle,
                    to_char(c.date_vis, 'YYYY'::text) AS annee,
                    g.code,
                    g.valeur,
                    c.epci
                   FROM m_spanc.an_spanc_controle c,
                        m_spanc.lt_spanc_natcontr g
                   where c.date_vis is not null
                  ORDER BY g.code || '_' || to_char(c.date_vis, 'YYYY'::text) || c.epci
                ), req_compte AS (
                 SELECT DISTINCT g.code || '_' || to_char(c.date_vis, 'YYYY'::text) || c.epci AS cle,
                    count(*) AS nb, 
                    c.epci
                   FROM m_spanc.an_spanc_controle c
                     left JOIN m_spanc.lt_spanc_natcontr g ON c.contr_nat = g.code
                   where c.date_vis is not null
                   group by g.code || '_' || to_char(c.date_vis, 'YYYY'::text) || c.epci, c.epci
                   ORDER by g.code || '_' || to_char(c.date_vis, 'YYYY'::text) || c.epci
                ), req_compte_tot as (
                 SELECT DISTINCT to_char(c.date_vis, 'YYYY'::text) || c.epci AS cle,
 					c.epci,
                    count(*) AS nb_tot
                   FROM m_spanc.an_spanc_controle c
                   where c.date_vis is not NULL 
                   group by to_char(c.date_vis, 'YYYY'::text),c.epci
                   ORDER by c.epci
                )
         SELECT DISTINCT row_number() OVER () AS id,req_a.code,
           req_a.epci,
            (((('<tr>'::text || '<td>'::text) || req_a.valeur::text) || '</td>'::text) || string_agg(('<td align=center>'::text ||
                CASE
                    WHEN req_compte.nb IS NOT NULL THEN req_compte.nb
                    ELSE 0::bigint
                END) || '</td>'::text, ''::text ORDER BY req_a.annee)) || '</tr>'::text AS tableau,
            string_agg(('<td>'::text || req_a.annee) || '</td>'::text, ''::text ORDER BY req_a.annee) AS annee,
            string_agg(('<td align=center>'::text || req_compte_tot.nb_tot) || '</td>'::text, ''::text ORDER BY left(req_compte_tot.cle,4)) AS nb_tot
           FROM req_a
             LEFT JOIN req_compte ON req_compte.cle = req_a.cle
             LEFT JOIN req_compte_tot ON req_compte_tot.cle = split_part(req_a.cle,'_',2)
             GROUP BY req_a.valeur, req_a.code, req_a.epci
                 order by req_a.code
        )
 SELECT row_number() OVER () AS id,
    epci,
    ((('<table border=1 align=center><tr><td>&nbsp;</td>'::text || req_d.annee) || '</tr>'::text) || string_agg(req_d.tableau, ''::text)) || '<tr><td align=right>Total</td>' || req_d.nb_tot || '</tr></table>'::text AS tableau1
   FROM req_d
  GROUP BY req_d.annee, req_d.nb_tot, req_d.epci;


COMMENT ON VIEW m_spanc.xapps_geo_v_spanc_tab2 
	IS 'Vue applicative ressortant les indicateurs des types de contrôles par année sur l''EPCI (à transformer par commune)';

-- ########################################################### xapps_geo_v_spanc_tab3 ##################################################################

-- m_spanc.xapps_geo_v_spanc_tab3

drop view if exists m_spanc.xapps_geo_v_spanc_tab3;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_v_spanc_tab3
AS 


SELECT DISTINCT 
	row_number() over() as id,
	c.epci,
    count(*) AS nb_tot, 
    to_char(c.date_vis,'yyyy') as annee
FROM m_spanc.an_spanc_controle c
where c.date_vis is not null
group by c.epci,to_char(c.date_vis,'yyyy');

        
     


COMMENT ON VIEW m_spanc.xapps_geo_v_spanc_tab3 
	IS 'Vue applicative ressortant le nombre total de contrôles par année et par epci';


-- ########################################################### xapps_geo_v_spanc_tab4 ##################################################################

-- m_spanc.xapps_geo_v_spanc_tab4

drop view if exists m_spanc.xapps_geo_v_spanc_tab4;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_v_spanc_tab4
AS 

WITH req_d AS (
         WITH req_a AS (
                 SELECT DISTINCT to_char(c.date_vis, 'YYYY'::text) || c.epci AS cle,
                    to_char(c.date_vis, 'YYYY'::text) AS annee,
                    c.epci
                   FROM m_spanc.an_spanc_controle c
                   where c.date_fact is not null
                  ORDER BY to_char(c.date_vis, 'YYYY'::text) || c.epci
                ), req_compte_fact AS (
                 SELECT DISTINCT to_char(c.date_vis, 'YYYY'::text) || c.epci AS cle,
                    sum(c.mont_fact) AS mont_fact, 
                    sum(c.mont_pen) AS mont_pen, 
                    c.epci
                   FROM m_spanc.an_spanc_controle c
                   where c.date_fact is not null and (c.mont_fact is not null or c.mont_fact > 0)
                   group by to_char(c.date_vis, 'YYYY'::text) || c.epci, c.epci
                   ORDER by to_char(c.date_vis, 'YYYY'::text) || c.epci
                ), req_compte_acq AS (
                 SELECT DISTINCT to_char(c.date_vis, 'YYYY'::text) || c.epci AS cle,
                    sum(c.mont_fact) AS mont_fact_acq, 
                    sum(c.mont_pen) AS mont_pen_acq, 
                    c.epci
                   FROM m_spanc.an_spanc_controle c
                   where c.date_fact is not null and (c.mont_fact > 0) and c.acq_fact is true
                   group by to_char(c.date_vis, 'YYYY'::text) || c.epci, c.epci
                   ORDER by to_char(c.date_vis, 'YYYY'::text) || c.epci
                )                
         SELECT DISTINCT row_number() OVER () AS id,
           req_a.epci,
            '<tr>'::text || '<td>Montant de la redevance (facturé)</td>'::text || string_agg('<td align=center>'::text ||
                CASE
                    WHEN req_compte_fact.mont_fact IS NOT NULL THEN req_compte_fact.mont_fact
                    ELSE 0::bigint
                END || '€</td>'::text, ''::text ORDER BY req_a.annee) || '</tr>'::text AS tableau_fact,
                
                    '<tr>'::text || '<td>Montant de la redevance (acquité)</td>'::text || string_agg('<td align=center>'::text ||
                CASE
                    WHEN req_compte_acq.mont_fact_acq IS NOT NULL THEN req_compte_acq.mont_fact_acq
                    ELSE 0::bigint
                END || '€</td>'::text, ''::text ORDER BY req_a.annee) || '</tr>'::text AS tableau_fact_acq,
                
               '<tr>'::text || '<td>Montant des pénalités (facturé)</td>'::text || string_agg('<td align=center>'::text ||
                CASE
                    WHEN req_compte_fact.mont_pen IS NOT NULL THEN req_compte_fact.mont_pen
                    ELSE 0::bigint
                END || '€</td>'::text, ''::text ORDER BY req_a.annee) || '</tr>'::text AS tableau_pen,
                
                '<tr>'::text || '<td>Montant des pénalités (acquité)</td>'::text || string_agg('<td align=center>'::text ||
                CASE
                    WHEN req_compte_acq.mont_pen_acq IS NOT NULL THEN req_compte_acq.mont_pen_acq
                    ELSE 0::bigint
                END || '€</td>'::text, ''::text ORDER BY req_a.annee) || '</tr>'::text AS tableau_pen_acq,
                
            string_agg(('<td>'::text || req_a.annee) || '</td>'::text, ''::text ORDER BY req_a.annee) AS annee
            
           FROM req_a
             LEFT JOIN req_compte_fact ON req_compte_fact.cle = req_a.cle
             LEFT JOIN req_compte_acq ON req_compte_acq.cle = req_a.cle
             GROUP BY  req_a.epci
       
        )
 SELECT row_number() OVER () AS id,
    epci,
    '<table border=1 align=center><tr><td>&nbsp;</td>'::text 
    || req_d.annee || '</tr>'::text 
    || string_agg(req_d.tableau_fact, ''::text) 
    || string_agg(req_d.tableau_fact_acq, ''::text)
    || string_agg(req_d.tableau_pen, ''::text)
    || string_agg(req_d.tableau_pen_acq, ''::text) 
    || '</table>'::text AS tableau1
   FROM req_d
  GROUP BY req_d.annee,req_d.epci;

COMMENT ON VIEW m_spanc.xapps_geo_v_spanc_tab4 
	IS 'Vue applicative ressortant le montant de la redevance et des pénalités';



-- ########################################################### xapps_geo_v_spanc_tab5 ##################################################################

-- m_spanc.xapps_geo_v_spanc_tab5

drop view if exists m_spanc.xapps_geo_v_spanc_tab5;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_v_spanc_tab5
AS 

with req_epci as
(
select 
 iepci as epci,
 lib_epci
from r_osm.geo_osm_epci where iepci in ('cclo','cc2v','ccpe','arc')
), req_inst_active as
(
SELECT
    i.epci,
    count(*) as nb_instl_active
FROM 
	m_spanc.an_spanc_installation i
where i.inst_etat = '10'
group by i.epci
), req_inst_inactive as
(
SELECT
    i.epci,
    count(*) as nb_instl_inactive
FROM 
	m_spanc.an_spanc_installation i
where i.inst_etat = '20'
group by i.epci
), req_delais_moyen as 
(
select 
	c.epci,
	count(*) as nb,
	sum(extract(day from (c.date_trap-c.date_dem))) as nb_jours,
	round(sum(extract(day from (c.date_trap-c.date_dem)))::decimal/count(*)::decimal,1)::decimal as delais_moyen
from m_spanc.an_spanc_controle c
where c.date_dem is not null and c.date_trap is not null
group by c.epci
)
select 
e.epci,
e.lib_epci,
case when ia.nb_instl_active is not null then ia.nb_instl_active else 0 end as nb_instl_active,
case when ina.nb_instl_inactive is not null then ina.nb_instl_inactive else 0 end as nb_instl_inactive,
case when d.delais_moyen is not null then d.delais_moyen::text || ' jours' else 'n.r' end as delais_moyen
from 
req_epci e 
left join req_inst_active ia on e.epci = ia.epci
left join req_inst_inactive ina on e.epci = ina.epci
left join req_delais_moyen d on d.epci = e.epci;


COMMENT ON VIEW m_spanc.xapps_geo_v_spanc_tab5 
	IS 'Vue applicative ressortant les chiffres clés du SPANC';


-- ########################################################### an_v_log_controle ##################################################################

create or replace view m_spanc.an_v_log_controle as select * from m_spanc.an_spanc_log where
( 
datanew like '%bnormand%'
or
datanew like '%glemaitre%'
or
datanew like '%halexandre%'
or
datanew like '%kleger%'
or
datanew like '%mbarbosa%'
or
datanew like '%mgabriel%'
or
datanew like '%mvincelle%'
or
datanew like '%sherbin%'
or
dataold like '%bnormand%'
or
dataold like '%glemaitre%'
or
dataold like '%halexandre%'
or
dataold like '%kleger%'
or
dataold like '%mbarbosa%'
or
dataold like '%mgabriel%'
or
dataold like '%mvincelle%'
or
dataold like '%sherbin%'
);

COMMENT ON VIEW m_spanc.an_v_log_controle IS 'Vue interne récupérant les mouvements réalisées sur les données du SPANC par les utilisateurs avec un profil EDIT pour la phase de test';




-- ########################################################### an_v_spanc_periodicite ##################################################################

drop view if exists m_spanc.an_v_spanc_periodicite;
create or replace view m_spanc.an_v_spanc_periodicite as 
select 
        ad.idinstal,
        ad.idcontr,
        ad.date_trap::date,
        ad.date_act::date,
        /*     
        case
	    	-- cas d'un contrôle avec absence d'installation
	        when ad.contr_concl = '10' and ad.contr_nat in ('20','30','40','50') then (ad.date_trap::timestamp + (ad.contr_abs::text || ' month')::interval)::date
	        -- cas d'un contrôle avec une conformité conforme
	        when ad.contr_concl = '20' and ad.contr_nat in ('13','14','20','30','40','50') then (ad.date_trap::timestamp + (ad.contr_perio_c::text || ' year')::interval)::date
 	        -- cas d'un contrôle avec une non-conformité non grave (hors visite exécution de travaux)
        	when ad.contr_concl = '40' and ad.contr_nat in ('20','30','40','50') then (ad.date_trap::timestamp + (ad.contr_perio_nc::text || ' year')::interval)::date
        	-- cas d'un refus du contrôle
	        when ad.contr_concl = 'ZZ' and ad.contr_nat in ('13','14','20','30','40','50') then (ad.date_trap::timestamp + (ad.rel_perio::text || ' month')::interval)::date
	        -- cas d'un contrôle avec une non-conformité grave
	        when ad.contr_concl IN ('31','32') and ad.contr_nat in ('13','14','20','30','40','50') then (ad.date_trap::timestamp + (ad.contr_perio_nc::text || ' year')::interval)::date
            -- cas d'un contrôle lié à une demande
	        when ad.contr_nat in ('11','12') then (ad.date_trap::timestamp + (ad.contr_trav::text || ' year')::interval)::date
	        else null
        end as date_prochain_controle,
        */
        replace(replace(replace(replace(
        age(case 
	        -- cas d'un contrôle avec absence d'installation
        	when ad.contr_concl = '10' and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_abs::text || ' month')::interval)::date
        	-- cas d'un contrôle avec une conformité conforme
	        when ad.contr_concl = '20' and ad.contr_nat in ('13','14','20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_c::text || ' year')::interval)::date
	        -- cas d'un contrôle avec une non-conformité non grave (hors visite exécution de travaux)
        	when ad.contr_concl = '40' and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date
			-- cas d'un contrôle avec une non-conformité non grave (pour les visites exécution de travaux)
        	when ad.contr_concl = '40' and ad.contr_nat in ('13','14') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_trav::text || ' month')::interval)::date
        	-- cas d'un refus du contrôle
	        when ad.contr_concl = 'ZZ' and ad.contr_nat in ('13','14','20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.rel_perio::text || ' month')::interval)::date
	        -- cas d'un contrôle avec une non-conformité grave (hors visite d'exécution de travaux)
	        when ad.contr_concl IN ('31','32') and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date
			-- cas d'un contrôle avec une non-conformité grave (pour les visites d'exécution de travaux)
	        when ad.contr_concl IN ('31','32') and ad.contr_nat in ('13','14') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date
	        -- cas d'un contrôle lié à une demande
	        when ad.contr_nat in ('11','12') then (ad.date_trap::timestamp + (ad.contr_trav::text || ' year')::interval)::date
        	else null
        end, now()::date)::text,'years','ans'),'mons','mois'),'days','jour(s)'),'00:00:00','0 jour')
        
        as prochain_controle_dans,
        
        
        case
	        -- cas d'un contrôle avec absence d'installation
	        when ad.contr_concl = '10' and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_abs::text || ' month')::interval)::date
	        -- cas d'un contrôle avec une conformité conforme
	        when ad.contr_concl = '20' and ad.contr_nat in ('13','14','20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_c::text || ' year')::interval)::date
	        -- cas d'un contrôle avec une non-conformité non grave (hors visite exécution de travaux)
        	when ad.contr_concl = '40' and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date
        	-- cas d'un contrôle avec une non-conformité non grave (pour les visites exécution de travaux)
        	when ad.contr_concl = '40' and ad.contr_nat in ('13','14') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_trav::text || ' month')::interval)::date
        	-- cas d'un refus du contrôle
	        when ad.contr_concl = 'ZZ' and ad.contr_nat in ('13','14','20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.rel_perio::text || ' month')::interval)::date
	        -- cas d'un contrôle avec une non-conformité grave (hors visite d'exécution de travaux)
	        when ad.contr_concl IN ('31','32') and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date
	        -- cas d'un contrôle avec une non-conformité grave (pour les visites d'exécution de travaux)
	        when ad.contr_concl IN ('31','32') and ad.contr_nat in ('13','14') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date
	         -- cas d'un contrôle lié à une demande
	        when ad.contr_nat in ('11','12') then (ad.date_trap::timestamp + (ad.contr_trav::text || ' year')::interval)::date
        	else null
        end as date_prcontl,
        case 
	        -- cas d'un contrôle avec absence d'installation
        	when ad.contr_concl = '10' and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_abs::text || ' month')::interval)::date
        	-- cas d'un contrôle avec une conformité conforme
	        when ad.contr_concl = '20' and ad.contr_nat in ('13','14','20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_c::text || ' year')::interval)::date
	        -- cas d'un contrôle avec une non-conformité non grave (hors visite exécution de travaux)
        	when ad.contr_concl = '40' and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date
        	-- cas d'un contrôle avec une non-conformité non grave (pour les visites exécution de travaux)
        	when ad.contr_concl = '40' and ad.contr_nat in ('13','14') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_trav::text || ' month')::interval)::date
        	-- cas d'un refus du contrôle
	        when ad.contr_concl = 'ZZ' and ad.contr_nat in ('13','14','20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.rel_perio::text || ' month')::interval)::date
	        -- cas d'un contrôle avec une non-conformité grave (hors visite d'exécution de travaux)
	        when ad.contr_concl IN ('31','32') and ad.contr_nat in ('20','30','40','50') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date
			-- cas d'un contrôle avec une non-conformité grave (pour les visites d'exécution de travaux)
	        when ad.contr_concl IN ('31','32') and ad.contr_nat in ('13','14') then (case when ad.date_act is not null then ad.date_act::timestamp else ad.date_trap::timestamp END + (ad.contr_perio_nc::text || ' year')::interval)::date	        
	         -- cas d'un contrôle lié à une demande
	        when ad.contr_nat in ('11','12') then (ad.date_trap::timestamp + (ad.contr_trav::text || ' year')::interval)::date
        	else null
        end-now()::date
        
        
        as tri_nb_jours,
        ad.contr_concl,
        ad.lib_contr_concl,
        ad.contr_nat,
        ad.lib_contr_nat,
        ad.contr_confor,
        ad.epci,
        ad.contr_perio_c,
        ad.contr_perio_nc,
        ad.contr_trav,
        ad.contr_abs,
        ad.rel_perio,
        ad.idadresse
      FROM  
      (       
      SELECT DISTINCT 
             a.idinstal,
             a.idcontr,
             a.contr_confor,
             a.contr_concl,
             ct.valeur as lib_contr_concl,
             a.contr_nat,
             nt.valeur as lib_contr_nat,
             a.date_trap,
             a.date_act,
             a.epci,
             cf.contr_perio_c,
             cf.contr_perio_nc,
        	 cf.contr_trav,
             cf.contr_abs,
             cf.rel_perio,
             inst.idadresse 
           FROM m_spanc.an_spanc_controle a
             left join m_spanc.lt_spanc_contcl ct on ct.code = a.contr_concl
             left join m_spanc.lt_spanc_natcontr nt on nt.code = a.contr_nat
             left join m_spanc.an_spanc_conf cf on cf.epci = a.epci
             left join m_spanc.an_spanc_installation inst on inst.idinstal = a.idinstal 
             JOIN ( SELECT c.idinstal,
                    max(c.date_trap) AS date_trap
                   FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
                   where c.idinstal = i.idinstal AND i.inst_etat = '10' and c.contr_nat <> '00'
                  GROUP BY c.idinstal) b_1 ON a.idinstal = b_1.idinstal AND a.date_trap = b_1.date_trap
       ) ad where ad.contr_concl IN ('10','20','40','ZZ','31','32') order by tri_nb_jours      
       ;

COMMENT ON VIEW m_spanc.an_v_spanc_periodicite IS 'Vue applicative calculant les dates des prochains contrôles à partir des derniers contrôles en fonction de leur nature et de leur conclusion de chaque installation active';

                      
                   
-- ########################################################### old_xapps_geo_v_spanc_anc ##################################################################
                   
  -- m_spanc.old_xapps_geo_v_spanc_anc source

CREATE OR REPLACE VIEW m_spanc.old_xapps_geo_v_spanc_anc
AS WITH req_ad AS (
         SELECT a_1.id_adresse,
            a_1.commune,
            a_1.libvoie_c,
            a_1.numero,
            a_1.repet,
            ((((((((a_1.numero::text ||
                CASE
                    WHEN a_1.repet IS NOT NULL OR a_1.repet::text <> ''::text THEN a_1.repet
                    ELSE ''::character varying
                END::text) || ' '::text) || a_1.libvoie_c::text) ||
                CASE
                    WHEN a_1.ld_compl IS NULL OR a_1.ld_compl::text = ''::text THEN ''::text
                    ELSE chr(10) || a_1.ld_compl::text
                END) ||
                CASE
                    WHEN a_1.complement IS NULL OR a_1.complement::text = ''::text THEN ''::text
                    ELSE chr(10) || a_1.complement::text
                END) || chr(10)) || a_1.codepostal::text) || ' '::text) || a_1.commune::text AS adresse,
            a_1.mot_dir,
            a_1.libvoie_a,
            e.iepci,
            a_1.geom
           FROM x_apps.xapps_geo_vmr_adresse a_1,
            r_administratif.an_geo g,
            r_osm.geo_osm_epci e
          WHERE a_1.insee = g.insee::bpchar AND e.cepci::text = g.epci::text
        ), req_nb_anc AS (
         SELECT a_1.id_adresse,
            count(*) AS nb_inst
           FROM m_spanc.an_spanc_installation i,
            x_apps.xapps_geo_vmr_adresse a_1
          WHERE i.idadresse = a_1.id_adresse AND i.inst_etat::text = '10'::text
          GROUP BY a_1.id_adresse
        ), req_nb_contr AS (
         SELECT a_1.id_adresse,
            count(*) AS nb_contr
           FROM m_spanc.an_spanc_installation i,
            m_spanc.an_spanc_controle c_1,
            x_apps.xapps_geo_vmr_adresse a_1
          WHERE i.idadresse = a_1.id_adresse AND i.idinstal = c_1.idinstal AND i.inst_etat::text = '10'::text AND (c_1.contr_confor::text = ANY (ARRAY['10'::character varying, '20'::character varying, '30'::character varying]::text[])) AND (c_1.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[]))
          GROUP BY a_1.id_adresse
        ), req_dcontrl AS (
         SELECT ad.id_adresse,
            max(ad.date_vis) AS max,
            string_agg(ad.contr_confor::text, ','::text) AS contr_confor,
            string_agg(ad.contr_nat::text, ','::text) AS contr_nat,
            string_agg(
                CASE
                    WHEN ad.contr_nat::text = '99'::text THEN '9'::text
                    WHEN ad.contr_confor::text <> '00'::text AND ad.contr_confor::text <> 'ZZ'::text THEN "left"(ad.contr_confor::text, 1)
                    WHEN ad.contr_confor::text = 'ZZ'::text THEN '4'::text
                    ELSE ''::text
                END, ','::text) AS tri_confor
           FROM ( SELECT DISTINCT b_1.id_adresse,
                    a_1.idinstal,
                        CASE
                            WHEN a_1.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[]) THEN '50'::character varying
                            ELSE a_1.contr_confor
                        END AS contr_confor,
                        CASE
                            WHEN a_1.contr_nat::text = ANY (ARRAY['11'::character varying, '12'::character varying]::text[]) THEN '99'::character varying
                            ELSE a_1.contr_nat
                        END AS contr_nat,
                    a_1.date_vis
                   FROM m_spanc.an_spanc_controle a_1
                     JOIN ( SELECT a_2.id_adresse,
                            c_1.idinstal,
                            max(c_1.date_vis) AS date_vis
                           FROM m_spanc.an_spanc_controle c_1,
                            m_spanc.an_spanc_installation i,
                            x_apps.xapps_geo_vmr_adresse a_2
                          WHERE c_1.idinstal = i.idinstal AND i.idadresse = a_2.id_adresse AND i.inst_etat::text = '10'::text
                          GROUP BY c_1.idinstal, a_2.id_adresse) b_1 ON a_1.idinstal = b_1.idinstal AND a_1.date_vis = b_1.date_vis) ad
          GROUP BY ad.id_adresse
          ORDER BY (max(ad.date_vis)) DESC
        )
 SELECT row_number() OVER () AS gid,
    b.id_adresse,
    b.commune,
    b.libvoie_c,
    b.libvoie_a,
    b.numero,
    b.repet,
    b.adresse,
    b.mot_dir,
    b.iepci,
        CASE
            WHEN a.nb_inst IS NULL THEN 0::bigint
            ELSE a.nb_inst
        END AS nb_inst,
        CASE
            WHEN c.nb_contr IS NULL THEN 0::bigint
            ELSE c.nb_contr
        END AS nb_contr,
        CASE
            WHEN a.nb_inst = 1 THEN
            CASE
                WHEN dc.contr_confor IS NOT NULL AND (dc.contr_nat = ANY (ARRAY['11'::text, '12'::text])) THEN 'n.r'::character varying
                WHEN dc.contr_confor IS NOT NULL AND (dc.contr_nat = ANY (ARRAY['13'::text, '14'::text, '20'::text, '30'::text, '40'::text, '50'::text, '60'::text])) THEN dc.contr_confor::character varying
                ELSE 'n.r'::character varying
            END
            WHEN a.nb_inst > 1 THEN
            CASE
                WHEN dc.contr_confor IS NULL THEN 'n.r'::text
                ELSE
                CASE
                    WHEN dc.tri_confor ~~ '%9%'::text THEN 'n.r'::text
                    WHEN dc.tri_confor ~~ '%4%'::text THEN 'ZZ'::text
                    WHEN dc.tri_confor ~~ '%3%'::text THEN '30'::text
                    WHEN dc.tri_confor ~~ '%5%'::text THEN '21'::text
                    WHEN dc.tri_confor ~~ '%2%'::text THEN '20'::text
                    WHEN dc.tri_confor ~~ '%1%'::text THEN '10'::text
                    ELSE 'n.r'::text
                END
            END::character varying
            ELSE 'Aucune'::character varying
        END AS confor,
    b.geom
   FROM req_ad b
     LEFT JOIN req_nb_anc a ON b.id_adresse = a.id_adresse
     LEFT JOIN req_nb_contr c ON a.id_adresse = c.id_adresse
     LEFT JOIN req_dcontrl dc ON dc.id_adresse = b.id_adresse;

COMMENT ON VIEW m_spanc.old_xapps_geo_v_spanc_anc IS 'Ancienne vue applicative récupérant le nombre de dossier SPANC de conformité par adresse et affichant l''état du dernier contrôle (conforme ou non conforme) pour affichage dans GEO. Remplacée par une vue matérialisée gérant également l''affichage des installations partagées entre plusieurs adresses';

