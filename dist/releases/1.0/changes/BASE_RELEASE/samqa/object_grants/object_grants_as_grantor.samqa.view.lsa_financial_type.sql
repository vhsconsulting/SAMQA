-- liquibase formatted sql
-- changeset SAMQA:1754373944514 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.lsa_financial_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.lsa_financial_type.sql:null:ad29ad0d950185e4873a7727ecf2092b4a37d4ab:create

grant select on samqa.lsa_financial_type to rl_sam1_ro;

grant select on samqa.lsa_financial_type to rl_sam_ro;

grant select on samqa.lsa_financial_type to rl_sam_rw;

