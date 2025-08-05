-- liquibase formatted sql
-- changeset SAMQA:1754373931405 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eob_header_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eob_header_n3.sql:null:157c85584bb780477279b992cbc4258c518f61f4:create

create index samqa.eob_header_n3 on
    samqa.eob_header (
        member_id
    );

