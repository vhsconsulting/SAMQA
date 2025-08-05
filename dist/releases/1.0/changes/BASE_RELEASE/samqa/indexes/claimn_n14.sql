-- liquibase formatted sql
-- changeset SAMQA:1754373930430 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n14.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n14.sql:null:4b8a40052f243455889037359bf977e6574e77eb:create

create index samqa.claimn_n14 on
    samqa.claimn (
        service_type
    );

