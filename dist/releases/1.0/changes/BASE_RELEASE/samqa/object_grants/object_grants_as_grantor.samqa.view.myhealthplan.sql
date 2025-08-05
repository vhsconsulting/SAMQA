-- liquibase formatted sql
-- changeset SAMQA:1754373944618 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.myhealthplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.myhealthplan.sql:null:8dc45a1da98017525824485f28f57ef982725e0b:create

grant select on samqa.myhealthplan to rl_sam1_ro;

grant select on samqa.myhealthplan to rl_sam_ro;

grant select on samqa.myhealthplan to rl_sam_rw;

grant select on samqa.myhealthplan to sgali;

