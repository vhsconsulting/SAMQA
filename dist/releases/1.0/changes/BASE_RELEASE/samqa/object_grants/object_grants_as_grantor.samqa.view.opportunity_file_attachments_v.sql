-- liquibase formatted sql
-- changeset SAMQA:1754373944761 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.opportunity_file_attachments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.opportunity_file_attachments_v.sql:null:c0382dda44cc6362a3746f6a4b3868d9715b6fe8:create

grant select on samqa.opportunity_file_attachments_v to sgali;

grant select on samqa.opportunity_file_attachments_v to rl_sam1_ro;

grant select on samqa.opportunity_file_attachments_v to rl_sam_ro;

grant select on samqa.opportunity_file_attachments_v to rl_sam_rw;

