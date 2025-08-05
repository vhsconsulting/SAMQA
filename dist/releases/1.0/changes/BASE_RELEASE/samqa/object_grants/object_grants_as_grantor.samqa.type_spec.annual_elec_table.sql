-- liquibase formatted sql
-- changeset SAMQA:1754373942570 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.annual_elec_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.annual_elec_table.sql:null:b2d402668930daeb847605e7d549758e04c05c8d:create

grant execute on samqa.annual_elec_table to rl_sam1_ro;

grant execute on samqa.annual_elec_table to rl_sam_ro;

grant execute on samqa.annual_elec_table to rl_sam_rw;

