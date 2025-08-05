-- liquibase formatted sql
-- changeset SAMQA:1754373943721 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employer_hsa_welcome_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employer_hsa_welcome_email.sql:null:9200ea5d27266d70923b330c126c475964a54b8d:create

grant select on samqa.employer_hsa_welcome_email to rl_sam1_ro;

grant select on samqa.employer_hsa_welcome_email to rl_sam_ro;

grant select on samqa.employer_hsa_welcome_email to rl_sam_rw;

