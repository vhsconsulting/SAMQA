-- liquibase formatted sql
-- changeset SAMQA:1754373945091 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.semi_annually_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.semi_annually_v.sql:null:2c6b17e0a611b3438f6d1b71698e5848513f1131:create

grant select on samqa.semi_annually_v to rl_sam1_ro;

grant select on samqa.semi_annually_v to rl_sam_rw;

grant select on samqa.semi_annually_v to rl_sam_ro;

grant select on samqa.semi_annually_v to sgali;

