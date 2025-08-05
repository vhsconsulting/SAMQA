-- liquibase formatted sql
-- changeset SAMQA:1754373930652 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_user_map_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_user_map_n1.sql:null:5bb82a9f06bf56a8e580e70a5a638f2d92de1984:create

create index samqa.contact_user_map_n1 on
    samqa.contact_user_map (
        contact_id
    );

