-- liquibase formatted sql
-- changeset SAMQA:1754373930414 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n12.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n12.sql:null:b0182a044da9a067f024b96c89ee1e462eb31b72:create

create index samqa.claimn_n12 on
    samqa.claimn (
        unsubstantiated_flag
    );

