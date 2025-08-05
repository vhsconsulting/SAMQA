-- liquibase formatted sql
-- changeset SAMQA:1754373930462 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n5.sql:null:31a8ab1b9f16ded559f3053e337eb678c0b620f7:create

create index samqa.claimn_n5 on
    samqa.claimn (
        entrp_id
    );

