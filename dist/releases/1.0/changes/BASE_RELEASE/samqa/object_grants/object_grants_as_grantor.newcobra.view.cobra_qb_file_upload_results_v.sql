-- liquibase formatted sql
-- changeset SAMQA:1754373926376 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.view.cobra_qb_file_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.view.cobra_qb_file_upload_results_v.sql:null:6de9949ad5daa7f78afebfdce5c976bbc6a2f3b0:create

grant delete on newcobra.cobra_qb_file_upload_results_v to samqa;

grant insert on newcobra.cobra_qb_file_upload_results_v to samqa;

grant select on newcobra.cobra_qb_file_upload_results_v to samqa;

grant update on newcobra.cobra_qb_file_upload_results_v to samqa;

grant references on newcobra.cobra_qb_file_upload_results_v to samqa;

grant read on newcobra.cobra_qb_file_upload_results_v to samqa;

grant on commit refresh on newcobra.cobra_qb_file_upload_results_v to samqa;

grant query rewrite on newcobra.cobra_qb_file_upload_results_v to samqa;

grant debug on newcobra.cobra_qb_file_upload_results_v to samqa;

grant flashback on newcobra.cobra_qb_file_upload_results_v to samqa;

grant merge view on newcobra.cobra_qb_file_upload_results_v to samqa;

