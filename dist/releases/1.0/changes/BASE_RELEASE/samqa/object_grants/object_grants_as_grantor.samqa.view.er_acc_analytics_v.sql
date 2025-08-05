-- liquibase formatted sql
-- changeset SAMQA:1754373943783 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_acc_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_acc_analytics_v.sql:null:7538433668c327b47c17975d27e1255af2b4eda7:create

grant select on samqa.er_acc_analytics_v to rl_sam1_ro;

grant select on samqa.er_acc_analytics_v to rl_sam_rw;

grant select on samqa.er_acc_analytics_v to rl_sam_ro;

grant select on samqa.er_acc_analytics_v to sgali;

