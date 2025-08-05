-- liquibase formatted sql
-- changeset SAMQA:1754373943397 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cobra_multi_product_ee_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cobra_multi_product_ee_v.sql:null:59f9b15fd5748dd15ffac145db8c09529eca26b0:create

grant select on samqa.cobra_multi_product_ee_v to rl_sam1_ro;

grant select on samqa.cobra_multi_product_ee_v to rl_sam_rw;

grant select on samqa.cobra_multi_product_ee_v to rl_sam_ro;

grant select on samqa.cobra_multi_product_ee_v to sgali;

