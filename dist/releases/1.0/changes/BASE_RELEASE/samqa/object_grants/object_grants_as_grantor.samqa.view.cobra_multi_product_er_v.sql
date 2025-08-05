-- liquibase formatted sql
-- changeset SAMQA:1754373943403 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cobra_multi_product_er_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cobra_multi_product_er_v.sql:null:c15bb11ad5f800c23e283a401590243e35e92b6a:create

grant select on samqa.cobra_multi_product_er_v to rl_sam1_ro;

grant select on samqa.cobra_multi_product_er_v to rl_sam_rw;

grant select on samqa.cobra_multi_product_er_v to rl_sam_ro;

grant select on samqa.cobra_multi_product_er_v to sgali;

