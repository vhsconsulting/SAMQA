-- liquibase formatted sql
-- changeset SAMQA:1754373930978 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_divisions_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_divisions_n2.sql:null:bf005d77a47f1dc02c986a7aaa05245e3ef18626:create

create index samqa.employer_divisions_n2 on
    samqa.employer_divisions (
        entrp_id
    );

