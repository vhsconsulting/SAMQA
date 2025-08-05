-- liquibase formatted sql
-- changeset SAMQA:1754373943438 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.creditcard_response_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.creditcard_response_detail_v.sql:null:07ed240bdbc08a22060dc1f84dbaf2ff023fc729:create

grant select on samqa.creditcard_response_detail_v to rl_sam_ro;

