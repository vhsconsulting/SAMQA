-- liquibase formatted sql
-- changeset SAMQA:1754373930660 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_user_map_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_user_map_n2.sql:null:f995eaba1d83e292a97db1d8fb3b886252ab26e4:create

create index samqa.contact_user_map_n2 on
    samqa.contact_user_map (
        user_id
    );

