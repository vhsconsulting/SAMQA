-- liquibase formatted sql
-- changeset SAMQA:1754373942746 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_opportunity3_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_opportunity3_v.sql:null:39e7e00ab2a76e97a688b3d106ca77bbc087df64:create

grant select on samqa.account_opportunity3_v to rl_sam_ro;

