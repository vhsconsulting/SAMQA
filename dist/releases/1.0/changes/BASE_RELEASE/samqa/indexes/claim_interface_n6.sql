-- liquibase formatted sql
-- changeset SAMQA:1754373930307 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_interface_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_interface_n6.sql:null:f867a53b09164b2eb2205186999d3711f43f6ba9:create

create index samqa.claim_interface_n6 on
    samqa.claim_interface (
        claim_id,
        interface_status
    );

