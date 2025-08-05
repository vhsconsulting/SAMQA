-- liquibase formatted sql
-- changeset SAMQA:1754373926420 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.view.qb_online_file_unprocessed_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.view.qb_online_file_unprocessed_v.sql:null:3822090a46337e5662e587b9e0731d4d77344280:create

grant delete on newcobra.qb_online_file_unprocessed_v to samqa;

grant insert on newcobra.qb_online_file_unprocessed_v to samqa;

grant select on newcobra.qb_online_file_unprocessed_v to samqa;

grant update on newcobra.qb_online_file_unprocessed_v to samqa;

grant references on newcobra.qb_online_file_unprocessed_v to samqa;

grant read on newcobra.qb_online_file_unprocessed_v to samqa;

grant on commit refresh on newcobra.qb_online_file_unprocessed_v to samqa;

grant query rewrite on newcobra.qb_online_file_unprocessed_v to samqa;

grant debug on newcobra.qb_online_file_unprocessed_v to samqa;

grant flashback on newcobra.qb_online_file_unprocessed_v to samqa;

grant merge view on newcobra.qb_online_file_unprocessed_v to samqa;

