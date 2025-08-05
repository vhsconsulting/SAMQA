-- liquibase formatted sql
-- changeset SAMQA:1754374146894 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\claim_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/claim_pers.sql:null:2eea4aea5c0ea924d0dc4bd9c36eb63cff34d873:create

alter table samqa.claim
    add constraint claim_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;

