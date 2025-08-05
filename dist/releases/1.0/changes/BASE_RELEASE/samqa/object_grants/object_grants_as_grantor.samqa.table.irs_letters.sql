-- liquibase formatted sql
-- changeset SAMQA:1754373940928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.irs_letters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.irs_letters.sql:null:6bda3742dde2aeccdcb566e3dcce194979c5b484:create

grant select on samqa.irs_letters to rl_sam1_ro;

grant select on samqa.irs_letters to rl_sam_ro;

