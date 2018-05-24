-- Table: plan.poc_bkatalog

-- DROP TABLE plan.poc_bkatalog;

CREATE TABLE plan.poc_bkatalog
(
  id serial NOT NULL,
  bkod text,
  btyp text,
  aform text,
  hskap text,
  kat text,
  form text,
  farg text,
  CONSTRAINT poc_bkatalog_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

INSERT INTO poc_bkatalog (id, bkod, btyp, aform, hskap, kat, form, farg) VALUES (1, 'DP_AP_Ko_Gata', 'Användning', 'Allmän plats', 'Kommunalt', 'Gata', 'Gata', '219,219,219');
INSERT INTO poc_bkatalog (id, bkod, btyp, aform, hskap, kat, form, farg) VALUES (2, 'DP_KM_R_A', 'Användning', 'Kvartersmark', NULL, 'Besöksanläggningar', NULL, '200,100,0');
INSERT INTO poc_bkatalog (id, bkod, btyp, aform, hskap, kat, form, farg) VALUES (5, 'DP_AP_Ko_Gang', 'Användning', 'Allmän plats', 'Kommunalt', 'Gång', 'Gångväg', '219,219,219');
INSERT INTO poc_bkatalog (id, bkod, btyp, aform, hskap, kat, form, farg) VALUES (6, 'DP_AP_Ko_Cykelmoped', 'Användning', 'Allmän plats', 'Kommunalt', 'Cykel', 'Cykelväg', '219,219,219');
INSERT INTO poc_bkatalog (id, bkod, btyp, aform, hskap, kat, form, farg) VALUES (4, 'DP_KM_E', 'Användning', 'Kvartersmark', NULL, 'Tekniska anläggningar', 'Tekniska anläggningar', '138,171,255');
INSERT INTO poc_bkatalog (id, bkod, btyp, aform, hskap, kat, form, farg) VALUES (7, 'DP_AP_Ko_Natur', 'Användning', 'Allmän plats', 'Kommunalt', 'Natur', 'Naturområde', '159,207,171');
INSERT INTO poc_bkatalog (id, bkod, btyp, aform, hskap, kat, form, farg) VALUES (3, 'DP_KM_S', 'Användning', 'Kvartersmark', NULL, 'Skola', 'Skola', '225,25,25');

-- View: plan.v_poc_anv

-- DROP VIEW plan.v_poc_anv;

CREATE OR REPLACE VIEW plan.v_poc_anv AS 
 SELECT b.uuid,
    b.anvandningsslag,
    b.beteckning,
    b.index,
    b.precisering,
    b.huvudsaklig,
    b.norr,
    b.ost,
    b.rotation,
    k.btyp,
    k.aform,
    k.hskap,
    k.kat,
    k.form,
    k.farg,
    b.ey_uuid,
    y.geom,
    y.plan_uuid
   FROM plan.poc_anv_best b
     JOIN plan.poc_anv_yta y ON b.ey_uuid::text = y.ey_uuid::text
     JOIN plan.poc_bkatalog k ON b.anvandningsslag = k.bkod;

ALTER TABLE plan.v_poc_anv
  OWNER TO edit_geodata;
GRANT ALL ON TABLE plan.v_poc_anv TO edit_geodata;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE plan.v_poc_anv TO edit_plan;
GRANT SELECT ON TABLE plan.v_poc_anv TO read_geodata;
COMMENT ON VIEW plan.v_poc_anv
  IS 'Användningsbestämmelser';

-- Rule: v_poc_anv_del ON plan.v_poc_anv

-- DROP RULE v_poc_anv_del ON plan.v_poc_anv;

CREATE OR REPLACE RULE v_poc_anv_del AS
    ON DELETE TO plan.v_poc_anv DO INSTEAD  DELETE FROM plan.poc_anv_best
  WHERE poc_anv_best.uuid = old.uuid;

-- Rule: v_poc_anv_ins ON plan.v_poc_anv

-- DROP RULE v_poc_anv_ins ON plan.v_poc_anv;

CREATE OR REPLACE RULE v_poc_anv_ins AS
    ON INSERT TO plan.v_poc_anv DO INSTEAD NOTHING;

-- Rule: v_poc_anv_upd ON plan.v_poc_anv

-- DROP RULE v_poc_anv_upd ON plan.v_poc_anv;

CREATE OR REPLACE RULE v_poc_anv_upd AS
    ON UPDATE TO plan.v_poc_anv DO INSTEAD  UPDATE plan.poc_anv_best SET anvandningsslag = new.anvandningsslag, beteckning = new.beteckning, index = new.index, precisering = new.precisering, huvudsaklig = new.huvudsaklig, norr = new.norr, ost = new.ost, rotation = new.rotation
  WHERE poc_anv_best.uuid = old.uuid;


-- View: plan.v_poc_eg

-- DROP VIEW plan.v_poc_eg;

CREATE OR REPLACE VIEW plan.v_poc_eg AS 
 SELECT b.uuid,
    b.bestammelsetyp,
    b.beteckning,
    b.index,
    b.norr,
    b.ost,
    b.rotation,
    y.geom
   FROM plan.poc_eg_best b
     JOIN plan.poc_eg_yta y ON b.ey_uuid = y.ey_uuid;

ALTER TABLE plan.v_poc_eg
  OWNER TO edit_geodata;
GRANT ALL ON TABLE plan.v_poc_eg TO edit_geodata;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE plan.v_poc_eg TO edit_plan;
GRANT SELECT ON TABLE plan.v_poc_eg TO read_geodata;
COMMENT ON VIEW plan.v_poc_eg
  IS 'Egenskapsbestämmelser';

-- View: plan.v_poc_admin

-- DROP VIEW plan.v_poc_admin;

CREATE OR REPLACE VIEW plan.v_poc_admin AS 
 SELECT b.uuid,
    b.bestammelsetyp,
    b.beteckning,
    b.index,
    b.norr,
    b.ost,
    b.rotation,
    y.geom
   FROM plan.poc_admin_best b
     JOIN plan.poc_admin_yta y ON b.ey_uuid = y.ey_uuid;

ALTER TABLE plan.v_poc_admin
  OWNER TO edit_geodata;
GRANT ALL ON TABLE plan.v_poc_admin TO edit_geodata;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE plan.v_poc_admin TO edit_plan;
GRANT SELECT ON TABLE plan.v_poc_admin TO read_geodata;
COMMENT ON VIEW plan.v_poc_admin
  IS 'Administrativa bestämmelser';

-- View: plan.v_poc_eg_hojd

-- DROP VIEW plan.v_poc_eg_hojd;

CREATE OR REPLACE VIEW plan.v_poc_eg_hojd AS 
 SELECT b.uuid,
    b.bestammelsetyp,
    b.beteckning,
    b.index,
    b.norr,
    b.ost,
    b.rotation,
    v.namn,
    v.varde_dec,
    v.varde_hel,
    v.varde_txt,
    y.geom
   FROM plan.poc_eg_best b
     JOIN plan.poc_eg_yta y ON b.ey_uuid = y.ey_uuid
     LEFT JOIN plan.poc_variabel v ON b.uuid = v.best_uuid
  WHERE v.namn = 'hojd'::text;

ALTER TABLE plan.v_poc_eg_hojd
  OWNER TO edit_geodata;
GRANT ALL ON TABLE plan.v_poc_eg_hojd TO edit_geodata;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE plan.v_poc_eg_hojd TO edit_plan;
GRANT SELECT ON TABLE plan.v_poc_eg_hojd TO read_geodata;
COMMENT ON VIEW plan.v_poc_eg_hojd
  IS 'Egenskapsbestämmelser höjd';

-- View: plan.v_poc_eg_byblock

-- DROP VIEW plan.v_poc_eg_byblock;

CREATE OR REPLACE VIEW plan.v_poc_eg_byblock AS 
 SELECT y.ey_uuid,
    b.bestammelsetyp AS btyp1,
    b.beteckning AS bet1,
    b2.bestammelsetyp AS btyp2,
    b2.beteckning AS bet2,
    v.namn AS namn1,
    v.varde_dec AS varde1,
    v2.namn AS namn2,
    v2.varde_dec AS varde2,
    st_setsrid(st_makebox2d(st_point((b.ost - sqrt(v.varde_dec) / 2::numeric)::double precision, (b.norr - sqrt(v.varde_dec) / 2::numeric)::double precision), st_point((b.ost + sqrt(v.varde_dec) / 2::numeric)::double precision, (b.norr + sqrt(v.varde_dec) / 2::numeric)::double precision))::geometry, 3008) AS geom
   FROM plan.poc_eg_yta y
     JOIN plan.poc_eg_best b ON y.ey_uuid = b.ey_uuid
     JOIN plan.poc_eg_best b2 ON y.ey_uuid = b2.ey_uuid
     LEFT JOIN plan.poc_variabel v ON b.uuid = v.best_uuid
     LEFT JOIN plan.poc_variabel v2 ON b2.uuid = v2.best_uuid
  WHERE v2.namn = 'hojd'::text AND v.namn = 'exploatering'::text;

ALTER TABLE plan.v_poc_eg_byblock
  OWNER TO edit_geodata;
GRANT ALL ON TABLE plan.v_poc_eg_byblock TO edit_geodata;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE plan.v_poc_eg_byblock TO edit_plan;
GRANT SELECT ON TABLE plan.v_poc_eg_byblock TO read_geodata;
COMMENT ON VIEW plan.v_poc_eg_byblock
  IS 'Maximalt byggnadsblock';
