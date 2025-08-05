-- liquibase formatted sql
-- changeset SAMQA:1754373932886 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_n2.sql:null:2ab2a78fdfb7aa575ab1a45d07cdaf00a1fa2d23:create

create index samqa.person_n2 on
    samqa.person (
        orig_sys_vendor_ref,
        person_type
    );

