-- liquibase formatted sql
-- changeset SAMQA:1754373932877 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_n1.sql:null:ccb46c9972ad3bd265835e496acd1fe8c67359f1:create

create index samqa.person_n1 on
    samqa.person (
        orig_sys_vendor_ref
    );

