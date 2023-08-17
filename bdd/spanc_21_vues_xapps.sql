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
   
-- m_spanc.xapps_geo_vmr_spanc_anc
drop view if exists m_spanc.xapps_geo_vmr_spanc_anc;
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
        
        ), 
        req_dcontrl AS
(

with req_final as
(
with req_max as 
(

(
     --1er passage sur adresse principale
     select 
        ad.id_adresse,
        max(ad.date_vis) as date_vis,
        string_agg(ad.contr_confor,',') as contr_confor,
        string_agg(ad.contr_nat,',') as contr_nat,
        string_agg(
        case 
	         when ad.contr_nat = '99' then '9'
	         when ad.contr_confor <> '00' and ad.contr_confor <> 'ZZ' then left(ad.contr_confor,1)
         --    when ad.contr_confor = 'ZZ' then '4'
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
          --   when ad.contr_confor = 'ZZ' then '4'
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
          --   when ad.contr_confor = 'ZZ' then '4'
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
           --  when ad.contr_confor = 'ZZ' then '4'
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
	    	 --	 when dc.tri_confor_m like '%4%' then 'ZZ'
	    	 	 when dc.tri_confor_m like '%8%' then '80'
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

-- m_spanc.xapps_geo_v_spanc_tri_contr
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
             a.dem_concl,
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
    case when c.dem_concl is not null then dcl.valeur else 'n.r' END as "Conclusion de la demande de travaux",
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
    left join m_spanc.lt_spanc_contdt dcl on dcl.code = c.dem_concl
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
dcl.valeur as "Conclusion de la demande de travaux",
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
i.valeur as "Dernier moyen d'information",
c.observ as "Commentaires",
a.commune as "Commune",
c.epci as "epci"


from m_spanc.an_spanc_controle c
left join m_spanc.lt_spanc_modgest g on g.code = c.mod_gest
left join m_spanc.an_spanc_prestataire p on p.idpresta = c.idpresta 
left join m_spanc.an_spanc_dsp d on d.iddsp = c.iddsp 
left join m_spanc.lt_spanc_natcontr nc on nc.code = c.contr_nat 
left join m_spanc.lt_spanc_contcl cc on cc.code = c.contr_concl
left join m_spanc.lt_spanc_contdt dcl on dcl.code = c.dem_concl 
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

-- m_spanc.xapps_geo_v_spanc_tab2 source
drop view if exists m_spanc.xapps_geo_v_spanc_tab2;
CREATE OR REPLACE VIEW m_spanc.xapps_geo_v_spanc_tab2
AS 

with req_stat_territorial AS
(
(
WITH req_d AS (
         WITH req_a AS (
                 SELECT DISTINCT ((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || a.insee AS cle,
                    to_char(c.date_vis, 'YYYY'::text) AS annee,
                    g.code,
                    g.valeur,
                    a.insee,
                    a.commune,
                    c.epci
                   FROM m_spanc.an_spanc_controle c,
                    m_spanc.lt_spanc_natcontr g,
                    m_spanc.an_spanc_installation i,
                    x_apps.xapps_geo_vmr_adresse a
                  WHERE c.date_vis IS NOT null and c.idinstal = i.idinstal and i.idadresse = a.id_adresse 
                  ORDER BY (((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || a.insee)
                ), req_compte AS (
                 SELECT DISTINCT ((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || a.insee AS cle,
                    count(*) AS nb,
                    a.insee
                   FROM m_spanc.an_spanc_controle c
                     LEFT JOIN m_spanc.lt_spanc_natcontr g ON c.contr_nat::text = g.code::text
                     join m_spanc.an_spanc_installation i on i.idinstal = c.idinstal 
                     join x_apps.xapps_geo_vmr_adresse a on i.idadresse = a.id_adresse 
                  WHERE c.date_vis IS NOT NULL
                  GROUP BY (((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || a.insee), a.insee
                  ORDER BY (((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || a.insee)
                ), req_compte_tot AS (
                 SELECT DISTINCT to_char(c.date_vis, 'YYYY'::text) || a.insee AS cle,
                    a.insee,
                    count(*) AS nb_tot
                   FROM m_spanc.an_spanc_controle c,
                    m_spanc.an_spanc_installation i,
                    x_apps.xapps_geo_vmr_adresse a
                  WHERE c.date_vis IS NOT null and c.idinstal = i.idinstal and i.idadresse = a.id_adresse 
                  GROUP BY (to_char(c.date_vis, 'YYYY'::text)), a.insee
                  ORDER BY a.insee
                )
         SELECT DISTINCT row_number() OVER () AS id,
            req_a.code,
            req_a.epci,
            req_a.insee,
            req_a.commune,
            (((('<tr>'::text || '<td>'::text) || req_a.valeur) || '</td>'::text) || string_agg(('<td align=center>'::text ||
                CASE
                    WHEN req_compte.nb IS NOT NULL THEN req_compte.nb
                    ELSE 0::bigint
                END) || '</td>'::text, ''::text ORDER BY req_a.annee)) || '</tr>'::text AS tableau,
            string_agg(('<td>'::text || req_a.annee) || '</td>'::text, ''::text ORDER BY req_a.annee) AS annee,
            string_agg(('<td align=center>'::text || req_compte_tot.nb_tot) || '</td>'::text, ''::text ORDER BY ("left"(req_compte_tot.cle, 4))) AS nb_tot
           FROM req_a
             LEFT JOIN req_compte ON req_compte.cle = req_a.cle
             LEFT JOIN req_compte_tot ON req_compte_tot.cle = split_part(req_a.cle, '_'::text, 2)
          GROUP BY req_a.valeur, req_a.code, req_a.epci,req_a.insee, req_a.commune
          ORDER BY req_a.code
        )
 SELECT 
    req_d.commune as territoire,
    req_d.epci,
    ((((('<table border=1 align=center><tr><td>&nbsp;</td>'::text || req_d.annee) || '</tr>'::text) || string_agg(req_d.tableau, ''::text)) || '<tr><td align=right>Total</td>'::text) || req_d.nb_tot) || '</tr></table>'::text AS tableau1
   FROM req_d
  GROUP BY req_d.annee, req_d.nb_tot, req_d.epci, req_d.commune
  )
 
  union all
  (
  WITH req_d AS (
         WITH req_a AS (
                 SELECT DISTINCT ((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || c.epci AS cle,
                    to_char(c.date_vis, 'YYYY'::text) AS annee,
                    g.code,
                    g.valeur,
                    c.epci,
                    'Total EPCI' as territoire
                   FROM m_spanc.an_spanc_controle c,
                    m_spanc.lt_spanc_natcontr g
                  WHERE c.date_vis IS NOT NULL
                  ORDER BY (((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || c.epci)
                ), req_compte AS (
                 SELECT DISTINCT ((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || c.epci AS cle,
                    count(*) AS nb,
                    c.epci
                   FROM m_spanc.an_spanc_controle c
                     LEFT JOIN m_spanc.lt_spanc_natcontr g ON c.contr_nat::text = g.code::text
                  WHERE c.date_vis IS NOT NULL
                  GROUP BY (((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || c.epci), c.epci
                  ORDER BY (((g.code::text || '_'::text) || to_char(c.date_vis, 'YYYY'::text)) || c.epci)
                ), req_compte_tot AS (
                 SELECT DISTINCT to_char(c.date_vis, 'YYYY'::text) || c.epci AS cle,
                    c.epci,
                    count(*) AS nb_tot
                   FROM m_spanc.an_spanc_controle c
                  WHERE c.date_vis IS NOT NULL
                  GROUP BY (to_char(c.date_vis, 'YYYY'::text)), c.epci
                  ORDER BY c.epci
                )
         SELECT DISTINCT 
            req_a.code,
            req_a.epci,
            req_a.territoire,
            (((('<tr>'::text || '<td>'::text) || req_a.valeur) || '</td>'::text) || string_agg(('<td align=center>'::text ||
                CASE
                    WHEN req_compte.nb IS NOT NULL THEN req_compte.nb
                    ELSE 0::bigint
                END) || '</td>'::text, ''::text ORDER BY req_a.annee)) || '</tr>'::text AS tableau,
            string_agg(('<td>'::text || req_a.annee) || '</td>'::text, ''::text ORDER BY req_a.annee) AS annee,
            string_agg(('<td align=center>'::text || req_compte_tot.nb_tot) || '</td>'::text, ''::text ORDER BY ("left"(req_compte_tot.cle, 4))) AS nb_tot
           FROM req_a
             LEFT JOIN req_compte ON req_compte.cle = req_a.cle
             LEFT JOIN req_compte_tot ON req_compte_tot.cle = split_part(req_a.cle, '_'::text, 2)
          GROUP BY req_a.valeur, req_a.code, req_a.epci, req_a.territoire
          ORDER BY req_a.code
        )
 SELECT --row_number() OVER () AS id,
    req_d.territoire,
    req_d.epci,
    ((((('<table border=1 align=center><tr><td>&nbsp;</td>'::text || req_d.annee) || '</tr>'::text) || string_agg(req_d.tableau, ''::text)) || '<tr><td align=right>Total</td>'::text) || req_d.nb_tot) || '</tr></table>'::text AS tableau1
   FROM req_d
  GROUP BY req_d.annee, req_d.nb_tot, req_d.territoire,req_d.epci
 )
 )
  select 
 row_number() OVER () AS id,
 t.territoire,
 t.epci,
 t.tableau1
 from
 	req_stat_territorial t
  ;
  

COMMENT ON VIEW m_spanc.xapps_geo_v_spanc_tab2 IS 'Vue applicative ressortant les indicateurs des types de contrôles par année et par commune';




 
 
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
where c.date_dem is not null and c.date_trap is not NULL and c.date_dem > '2023-01-01'
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




-- ########################################################### xapps_an_vmr_spanc_periodicite ##################################################################

drop MATERIALIZED VIEW if exists m_spanc.xapps_an_vmr_spanc_periodicite;
CREATE MATERIALIZED VIEW m_spanc.xapps_an_vmr_spanc_periodicite
AS 

SELECT ad.idinstal,
    ad.idcontr,
    ad.date_trap::date AS date_trap,
    ad.date_act::date AS date_act,
    regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(age(
        CASE
            WHEN ad.contr_concl::text = '10'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_abs::text || ' month'::text)::interval))::date
            -- ajout contrôle lié aux ventes
            WHEN ad.contr_concl::text IN ('10','80') AND ad.contr_nat::text = '50'::text THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_ai::text || ' month'::text)::interval))::date
            
            WHEN ad.contr_concl::text IN ('31','32','40') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_nc::text || ' month'::text)::interval))::date
            -- fin ajout controle lié aux ventes
            WHEN ad.contr_concl::text = '20'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_c::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_trav::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text = '80'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_perio::text || ' month'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_nat::text = ANY (ARRAY['11'::character varying, '12'::character varying]::text[]) THEN (ad.date_trap + ((ad.contr_trav::text || ' year'::text)::interval))::date
            ELSE NULL::date
        END::timestamp with time zone, now()::date::timestamp with time zone)::text, 'years'::text, 'ans'::text), 'year'::text, 'an'::text), 'mons'::text, 'mois'::text), 'mon'::text, 'mois'::text), 'days'::text, 'jour(s)'::text), 'day'::text, 'jour'::text), '00:00:00'::text, '0 jour'::text) AS prochain_controle_dans,
        
        CASE
            WHEN ad.contr_concl::text = '10'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_abs::text || ' month'::text)::interval))::date
            -- ajout contrôle lié aux ventes
            WHEN ad.contr_concl::text IN ('10','80') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_ai::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text IN ('31','32','40') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_nc::text || ' month'::text)::interval))::date
            -- fin ajout controle lié aux ventes
            
            WHEN ad.contr_concl::text = '20'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_c::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_trav::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text = '80'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_perio::text || ' month'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_nat::text = ANY (ARRAY['11'::character varying, '12'::character varying]::text[]) THEN (ad.date_trap + ((ad.contr_trav::text || ' year'::text)::interval))::date
            ELSE NULL::date
        END AS date_prcontl,
        
        CASE
            WHEN ad.contr_concl::text = '10'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_abs::text || ' month'::text)::interval))::date
            -- ajout contrôle lié aux ventes
            WHEN ad.contr_concl::text IN ('10','80') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_ai::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text IN ('31','32','40') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_nc::text || ' month'::text)::interval))::date
                -- fin ajout controle lié aux ventes
            WHEN ad.contr_concl::text = '20'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_c::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_trav::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text = '80'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_perio::text || ' month'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_nat::text = ANY (ARRAY['11'::character varying, '12'::character varying]::text[]) THEN (ad.date_trap + ((ad.contr_trav::text || ' year'::text)::interval))::date
            ELSE NULL::date
        END - now()::date AS tri_nb_jours,
    case when    
    (case 
    	when contr_confor = 'ZZ' then to_char(now(),'YYYY')
    else
    	to_char(
    CASE
            WHEN ad.contr_concl::text = '10'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_abs::text || ' month'::text)::interval))::date
            -- ajout contrôle lié aux ventes
            WHEN ad.contr_concl::text IN ('10','80') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_ai::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text IN ('31','32','40') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_nc::text || ' month'::text)::interval))::date
            -- fin ajout controle lié aux ventes
            
            WHEN ad.contr_concl::text = '20'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_c::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_trav::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text = '80'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_perio::text || ' month'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_nat::text = ANY (ARRAY['11'::character varying, '12'::character varying]::text[]) THEN (ad.date_trap + ((ad.contr_trav::text || ' year'::text)::interval))::date
            ELSE NULL::date
        END,'YYYY') end) = to_char(now(),'YYYY') then 'Contrôle à réaliser dans l''année' 
        when 
        (case 
    	when contr_confor = 'ZZ' then to_char(now(),'YYYY')
    else
    	to_char(
    CASE
            WHEN ad.contr_concl::text = '10'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_abs::text || ' month'::text)::interval))::date
            -- ajout contrôle lié aux ventes
            WHEN ad.contr_concl::text IN ('10','80') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_ai::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text IN ('31','32','40') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_nc::text || ' month'::text)::interval))::date
            -- fin ajout controle lié aux ventes
            
            WHEN ad.contr_concl::text = '20'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_c::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_trav::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text = '80'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_perio::text || ' month'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_nat::text = ANY (ARRAY['11'::character varying, '12'::character varying]::text[]) THEN (ad.date_trap + ((ad.contr_trav::text || ' year'::text)::interval))::date
            ELSE NULL::date
        END,'YYYY') end)::integer < to_char(now(),'YYYY')::integer then 'Contrôle en retard'
        
        else 
        (case 
    	when contr_confor = 'ZZ' then to_char(now(),'YYYY')
    else
    	to_char(
    CASE
            WHEN ad.contr_concl::text = '10'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_abs::text || ' month'::text)::interval))::date
            -- ajout contrôle lié aux ventes
            WHEN ad.contr_concl::text IN ('10','80') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_ai::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text IN ('31','32','40') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_nc::text || ' month'::text)::interval))::date
            -- fin ajout controle lié aux ventes
            
            WHEN ad.contr_concl::text = '20'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_c::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_trav::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text = '80'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying,'60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_perio::text || ' month'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_nat::text = ANY (ARRAY['11'::character varying, '12'::character varying]::text[]) THEN (ad.date_trap + ((ad.contr_trav::text || ' year'::text)::interval))::date
            ELSE NULL::date
        END,'YYYY') end)
        end
    as periode_contr,
    (select EXTRACT(YEAR FROM age) * 12 + EXTRACT(MONTH FROM age) AS mois_ecart
    FROM age(now(), ad.date_trap) AS t(age)),
        (select EXTRACT(YEAR FROM age) AS annee_ecart
    FROM age(now(), ad.date_trap) AS t(age)),
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
    ad.rel_vente_ai,
    ad.rel_vente_nc,
    ad.idadresse
   FROM ( SELECT DISTINCT a.idinstal,
            a.idcontr,
            a.contr_confor,
            a.contr_concl,
            ct.valeur AS lib_contr_concl,
            a.contr_nat,
            nt.valeur AS lib_contr_nat,
            a.date_trap,
            a.date_act,
            a.epci,
            cf.contr_perio_c,
            cf.contr_perio_nc,
            cf.contr_trav,
            cf.contr_abs,
            cf.rel_perio,
            cf.rel_vente_ai,
            cf.rel_vente_nc,
            inst.idadresse
           FROM m_spanc.an_spanc_controle a
             LEFT JOIN m_spanc.lt_spanc_contcl ct ON ct.code::text = a.contr_concl::text
             LEFT JOIN m_spanc.lt_spanc_natcontr nt ON nt.code::text = a.contr_nat::text
             LEFT JOIN m_spanc.an_spanc_conf cf ON cf.epci = a.epci
             LEFT JOIN m_spanc.an_spanc_installation inst ON inst.idinstal = a.idinstal
             JOIN ( SELECT c.idinstal,
                    max(c.date_trap) AS date_trap
                   FROM m_spanc.an_spanc_controle c,
                    m_spanc.an_spanc_installation i
                  WHERE c.idinstal = i.idinstal AND i.inst_etat::text = '10'::text AND c.contr_nat::text <> '00'::text
                  GROUP BY c.idinstal) b_1 ON a.idinstal = b_1.idinstal AND a.date_trap = b_1.date_trap) ad
  WHERE ad.contr_concl::text = ANY (ARRAY['10'::character varying, '20'::character varying, '40'::character varying, '50'::character varying, '80'::character varying, '31'::character varying, '32'::character varying, 'ZZ'::character varying]::text[])

  ORDER BY (
        CASE
            WHEN ad.contr_concl::text = '10'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_abs::text || ' month'::text)::interval))::date
            
            -- Début ajout contrôle lié à une vente
             WHEN ad.contr_concl::text IN ('10','80') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_ai::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text IN ('31','32','40') AND ad.contr_nat::text = '50' THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_vente_nc::text || ' month'::text)::interval))::date
            -- fin ajout controle lié à une vente
            
            WHEN ad.contr_concl::text = '20'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_c::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_concl::text = '40'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_trav::text || ' month'::text)::interval))::date
            WHEN ad.contr_concl::text = '80'::text AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.rel_perio::text || ' month'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '60'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN (ad.contr_concl::text = ANY (ARRAY['31'::character varying, '32'::character varying]::text[])) AND (ad.contr_nat::text = ANY (ARRAY['13'::character varying, '14'::character varying]::text[])) THEN (
            CASE
                WHEN ad.date_act IS NOT NULL THEN ad.date_act
                ELSE ad.date_trap
            END + ((ad.contr_perio_nc::text || ' year'::text)::interval))::date
            WHEN ad.contr_nat::text = ANY (ARRAY['11'::character varying, '12'::character varying]::text[]) THEN (ad.date_trap + ((ad.contr_trav::text || ' year'::text)::interval))::date
            ELSE NULL::date
        END - now()::date)         
       WITH DATA;
        

COMMENT ON MATERIALIZED VIEW m_spanc.xapps_an_vmr_spanc_periodicite IS 'Vue matérialisée applicative calculant les dates des prochains contrôles à partir des derniers contrôles en fonction de leur nature et de leur conclusion de chaque installation active (rafraichie après chaque insertion ou mise à jour d''un contrôle)';




-- ########################################################### xapps_an_vmr_spanc_conception ##################################################################

drop MATERIALIZED VIEW if exists m_spanc.xapps_an_vmr_spanc_conception;
create materialized view m_spanc.xapps_an_vmr_spanc_conception as
-- installation avec dernier contrôle en conception sans visite
SELECT 
 a.idinstal,n.valeur as nature, d.valeur as avis, '' as conformite, a.date_trap, 
 
 case when (d.valeur = 'Avis défavorable' or d.valeur = 'Incomplet') then 'En attente d''un nouveau dossier' else
	 (select case 
	 	when EXTRACT(YEAR FROM age) < 4  then 'Travaux en cours (délais < à 4ans)' else 'Délais de visite dépassé (> à 4ans)' end AS annee_ecart
 FROM age(now(), a.date_trap) AS t(age))
 end
 
 ,
 a.date_trap + interval '4 year' as date_prochain_controle,
 to_char(a.date_trap + interval '4 year','YYYY') as annee_prochain_controle,
 case when to_char(a.date_trap + interval '4 year','YYYY') = to_char(now(),'YYYY') then 'oui' else 'non' END as controle_dans_annee_encours
  
FROM m_spanc.an_spanc_controle a 
join

(SELECT c.idinstal, max(c.date_vis) AS date_vis
FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
where c.idinstal = i.idinstal and c.date_vis is not null 
group by c.idinstal
)
b_1 
ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
join m_spanc.lt_spanc_contdt d on d.code = a.dem_concl 
join m_spanc.lt_spanc_natcontr n on n.code = a.contr_nat 
where a.contr_nat in ('11','12')

union ALL

-- installation avec dernier contrôle en visite non conforme
SELECT 
 a.idinstal,n.valeur as nature, cl.valeur as avis, co.valeur as conformite, a.date_trap, 
 
 null AS annee_ecart,
 null as date_prochain_controle,
 null as annee_prochain_controle,
 null as controle_dans_annee_encours
  
FROM m_spanc.an_spanc_controle a 
join

(SELECT c.idinstal, max(c.date_vis) AS date_vis
FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
where c.idinstal = i.idinstal and c.date_vis is not null 
group by c.idinstal
)
b_1 
ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis
join m_spanc.lt_spanc_contcl cl on cl.code = a.contr_concl
join m_spanc.lt_spanc_natcontr n on n.code = a.contr_nat 
join m_spanc.lt_spanc_confor co on co.code = a.contr_confor 
where a.contr_nat in ('13','14')
;

COMMENT ON MATERIALIZED VIEW m_spanc.xapps_an_vmr_spanc_conception IS 'Vue matérialisée applicative gérant la recherche des installations en conception rafraichie à chaque insertion ou modification d''un contrôle';



-- ########################################################### xapps_an_vmr_spanc_conformite ##################################################################

drop MATERIALIZED VIEW if exists m_spanc.xapps_an_vmr_spanc_conformite;
create materialized view m_spanc.xapps_an_vmr_spanc_conformite as



SELECT idinstal, case when COUNT(*) = 1 THEN '00' ELSE '' end as confor, '00' as concl,
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_non_atribue.png" >' as decision
FROM m_spanc.an_spanc_installation i
WHERE i.idinstal not in (select c.idinstal from m_spanc.an_spanc_controle c where c.contr_nat not in ('11','12')) and i.inst_etat = '10' group by idinstal

UNION ALL

SELECT 
  a.idinstal, 
  case when a.contr_nat in ('11','12') then '99' else a.contr_confor end as confor, a.contr_concl as contl,
  CASE 
WHEN  a.contr_confor IN ('00') AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_non_atribue.png" >'
WHEN  a.contr_confor <> 'ZZ' AND a.contr_nat in ('11','12') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_non_atribue.png" >'
WHEN  a.contr_confor = '10' AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_conforme.png" >'
WHEN  a.contr_confor = '20' AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
CASE WHEN a.contr_concl IN ('31','32') THEN
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_nonconforme.png" >'
ELSE
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_nonconforme_st.png" >'
END
WHEN  a.contr_confor = '30' AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_absence_instal.png" >'
WHEN  a.contr_confor = 'ZZ' AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_refus.png" >'
end as decision
FROM m_spanc.an_spanc_controle a  
JOIN
(SELECT c.idinstal, max(c.date_vis) AS date_vis 
FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
where c.idinstal = i.idinstal and c.contr_nat not in ('11','12')  and i.inst_etat = '10'
GROUP BY c.idinstal) b_1 
ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis

union all

SELECT 
  a.idinstal, 
  case when a.contr_nat in ('11','12') then '99' else a.contr_confor end as confor, a.contr_concl as contl,
  CASE 
WHEN  a.contr_confor IN ('00') AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_non_atribue.png" >'
WHEN  a.contr_confor <> 'ZZ' AND a.contr_nat in ('11','12') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_non_atribue.png" >'
WHEN  a.contr_confor = '10' AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_conforme.png" >'
WHEN  a.contr_confor = '20' AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
CASE WHEN a.contr_concl IN ('31','32') THEN
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_nonconforme.png" >'
ELSE
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_nonconforme_st.png" >'
END
WHEN  a.contr_confor = '30' AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_absence_instal.png" >'
WHEN  a.contr_confor = 'ZZ' AND a.contr_nat in ('13','14','20','30','40','50','60') THEN 
'<img src="http://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_refus.png" >'
end as decision
FROM m_spanc.an_spanc_controle a 
JOIN
(SELECT c.idinstal, max(c.date_dem) AS date_dem 
FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
where c.idinstal = i.idinstal and c.date_vis is null and c.contr_nat not in ('11','12') and i.inst_etat = '10'
GROUP BY c.idinstal) b_1 
ON a.idinstal = b_1.idinstal AND a.date_dem = b_1.date_dem

;


COMMENT ON MATERIALIZED VIEW m_spanc.xapps_an_vmr_spanc_conformite IS 'Vue matérialisée applicative gérant la recherche des installations selon leur conformité rafraichie à chaque insertion ou modification d''un contrôle';





-- ########################################################### xapps_an_v_spanc_dernier_etat_equi ##################################################################

-- drop view if exists m_spanc.xapps_an_v_spanc_dernier_etat_equi;

create or replace view m_spanc.xapps_an_v_spanc_dernier_etat_equi as
with req_rech_contl as
(
-- récupération du dernier contrôle hors diagnostic initial et hors demande de travaux
SELECT 

a.idinstal,
a.date_vis,
a.contr_nat,
a.equ_pretrait,
a.equ_pretrait_a,
a.equ_trait,
a.equ_trait_a,
a.equ_rejet,
a.equ_rejet_a,
a.equ_ventil,
case
    when a.contr_confor = '00' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_non_atribue.png'
	when a.contr_confor = '10' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_conforme.png'
	when a.contr_confor = '20' and a.contr_concl in ('31','32') then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_nonconforme.png'	
	when a.contr_confor = '20' and a.contr_concl <> '31' and a.contr_concl <> '32' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_nonconforme_st.png'
	when a.contr_confor = '30' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_absence_instal.png'		
	when a.contr_confor = 'ZZ' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_refus.png'	
END as conclusion
FROM m_spanc.an_spanc_controle a 
JOIN
(SELECT c.idinstal, max(c.date_vis) AS date_vis 
FROM m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i
where c.idinstal = i.idinstal and contr_nat in ('13','14','30','40','50','60') and date_vis is not null
GROUP BY c.idinstal) b_1 
ON a.idinstal = b_1.idinstal AND a.date_vis = b_1.date_vis

union ALL
-- diagnostic initial (à priori qu'un seul) ou demande de travaux
select 
 i.idinstal,
 c.date_vis,
 c.contr_nat,
 c.equ_pretrait,
 c.equ_pretrait_a,
 c.equ_trait,
 c.equ_trait_a,
 c.equ_rejet,
 c.equ_rejet_a,
 c.equ_ventil,
 case when c.contr_nat = '20' then 
 case
    when c.contr_confor = '00' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_non_atribue.png'
	when c.contr_confor = '10' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_conforme.png'
	when c.contr_confor = '20' and c.contr_concl in ('31','32') then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_nonconforme.png'	
	when c.contr_confor = '20' and c.contr_concl <> '31' and c.contr_concl <> '32' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_nonconforme_st.png'
	when c.contr_confor = '30' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_absence_instal.png'		
	when c.contr_confor = 'ZZ' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/cc_refus.png'	
 END 
 else 
 case
    when c.dem_concl = '10' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/ac_favorable.png'
	when c.dem_concl = '20' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/ac_defavorable.png'
	when c.dem_concl = '30' then 'https://geo.compiegnois.fr/documents/metiers/resh/spanc/ac_incomplet.png'	
 end end as conclusion
from m_spanc.an_spanc_controle c, m_spanc.an_spanc_installation i where c.idinstal = i.idinstal and contr_nat IN ('11','12','20') and c.date_vis is not null
)
select 
 i.idinstal,
 case when c.idinstal is null then 'Aucune conclusion de contrôles n''est disponible pour le moment (date de visite non renseignée).' else
 '<center><table border=1>' ||
	'<tbody>' ||
		'<tr>' ||
		    '<td rowspan="2" align="center">&nbsp;</td>' ||
			--'<td rowspan="2" align="center">&nbsp;Nature du contrôle&nbsp;</td>' ||
			'<td rowspan="2" align="center">&nbsp;Date de visite&nbsp;</td>' ||
			'<td colspan="3" align="center">&nbsp;Equipements&nbsp;</td>' ||
			'<td rowspan="2" align="center">&nbsp;Ventilation&nbsp;</td>' ||
			'<td rowspan="2" align="center">&nbsp;Décision&nbsp;</td>' ||
		'</tr>' ||
		'<tr>' ||
			'<td align="center">&nbsp;Pré-traitement&nbsp;</td>' ||
			'<td align="center">&nbsp;Traitement&nbsp;</td>' ||
			'<td align="center">&nbsp;Rejet&nbsp;</td>' ||
		'</tr>' ||
  string_agg(
			'<tr>' ||
			'<td>&nbsp;' || case when c.contr_nat IN ('11','12','20') then 'Etat du diagnostic initial <br>&nbsp;ou de la demande de travaux' else 'Etat du dernier contrôle' end  || '&nbsp;</td>' ||
			--'<td align="center">&nbsp;' || n.valeur || '&nbsp;</td>' ||
			'<td align="center">&nbsp;' || to_char(c.date_vis,'yyyy-mm-dd') || '&nbsp;</td>' ||
			'<td align="center">&nbsp;' || case when c.equ_pretrait = '99' then c.equ_pretrait_a else pt.valeur END || '&nbsp;</td>' ||
			'<td align="center">&nbsp;' || case when c.equ_trait = '99' then c.equ_trait_a else t.valeur END || '&nbsp;</td>' ||
			'<td align="center">&nbsp;' || case when c.equ_rejet = '99' then c.equ_rejet_a else r.valeur END || '&nbsp;</td>' ||
			'<td align="center">&nbsp;' || 
			case when c.equ_ventil = 'f' then 'non'
			     when c.equ_ventil = 't' then 'oui'
			else 'n.r' END || '&nbsp;</td>' ||
			'<td align="center">&nbsp;<img src=" ' || c.conclusion || '" alt='''' />&nbsp;</td>' ||
		'</tr>','' order by c.date_vis desc)
   /*
 ||
'<tr><td colspan=6>' ||
'<font size = 1>Sont listés ici :<br>' ||
'- l''état du diagnostic initial ou de la demande de travaux<br>' ||
'- et l''état du dernier contrôle (hors diagnostic initial et demande de travaux)' ||
'</font>' ||
'</td></tr>' ||
'</tbody>' ||
'</table></center>'
*/
end as affiche_tab_fin

 
from m_spanc.an_spanc_installation i left join req_rech_contl c on i.idinstal = c.idinstal
left join m_spanc.lt_spanc_natcontr n  on n.code = c.contr_nat
left join m_spanc.lt_spanc_equinstall pt on pt.code = c.equ_pretrait
left join m_spanc.lt_spanc_equinstall t on t.code = c.equ_trait
left join m_spanc.lt_spanc_equinstall r on r.code = c.equ_rejet
group by i.idinstal, c.idinstal;

COMMENT ON VIEW m_spanc.xapps_an_v_spanc_dernier_etat_equi IS 'Vue applicative formattant l''affichage des derniers contrôles à l''installation (soit le diag initial ou le demande de travaux et le dernier contrôle';

                   

