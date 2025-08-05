-- liquibase formatted sql
-- changeset SAMQA:1754373937563 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.crm_interface_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.crm_interface_seq.sql:null:2d86599f9b472449c5c9d96f252c7e6ebe583b28:create

grant select on samqa.crm_interface_seq to rl_sam_rw;

